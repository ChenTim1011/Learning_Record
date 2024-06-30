### Understanding Dependencies in `useEffect`

In the previous deep dive into `useEffect`, we learned that dependencies are a performance optimization tool rather than a means to control lifecycle or business logic. Lying about dependencies can cause hard-to-detect bugs in your application because it can make the component incorrectly ignore necessary synchronization actions when certain data changes.

Almost every React developer with class component experience has likely tried to deceive dependencies (myself included). You might think, "I just want this effect to run once on mount!"

When your effect causes some "accumulation" rather than "replacement" of its actions, repeated executions of this effect can indeed cause issues in your application. However, the solution is not to provide an empty array to trick dependencies into mimicking `componentDidMount`, but rather to find a better approach to handle this.

### What Happens When You Deceive Dependencies

Lying about dependencies leads to your component incorrectly ignoring necessary synchronization actions when certain data changes. Let's look at an example to help internalize this concept. This example tries to increment a number on the screen every second:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount(count + 1);
    }, 1000);

    return () => clearInterval(id);
  }, []);

  return <h1>{count}</h1>;
}
```

However, this example is problematic; the number will only increment once and then stop. Can you spot the issue?

In this example, you might think, "I want to set up an interval to automatically repeat the data update action, so I hope this effect only triggers once and only clears the interval on unmount. By giving the dependencies an empty array `[]`, it will only run on mount and unmount!"

Although this effect clearly depends on `count`, we deceive React by providing an empty array `[]`, leading to an unexpected result.

Let's see where the problem lies:

```jsx
// First render, count state is 0
function Counter() {
  // ...
  useEffect(() => {
    const id = setInterval(() => {
      setCount(0 + 1); // Will always be setCount(1)
    }, 1000);
    return () => clearInterval(id);
  }, []); // Will never re-execute
  // ...
}

// Subsequent renders, count state is 1
function Counter() {
  // ...
  useEffect(() => {
    // From the second render, this effect function will be skipped because we tricked React into thinking dependencies are empty
    const id = setInterval(() => {
      setCount(count + 1);
    }, 1000);
    return () => clearInterval(id);
  }, []);
  // ...
}
```

When this component first renders, `count` is 0, so the first render's effect will call `setCount(0 + 1)`. Since dependencies are `[]`, the effect will never re-run. The state in each render is always the same, so the `setInterval` inside the effect will always call `setCount(0 + 1)`.

We tricked React into thinking this effect doesn't depend on any component values, but it actually depends on `count`. This kind of issue caused by deceiving dependencies can be hard to detect. In such cases, a better approach is to always be honest about dependencies and handle issues with repeated effect executions in other ways.

Let's see how we can fix this example by honestly specifying the dependencies:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount(count + 1);
    }, 1000);

    return () => clearInterval(id);
  }, [count]); // Correctly specifying deps

  return <h1>{count}</h1>;
}
```

After honestly specifying the dependencies, you'll see the behavior is fixed. Let's simulate the render situation:

```jsx
// First render, count state is 0
function Counter() {
  // ...
  useEffect(() => {
    const id = setInterval(() => {
      setCount(0 + 1); // setCount(count + 1)
    }, 1000);
    return () => clearInterval(id);
  }, [0]); // [count]
  // ...
}

// Second render, count state is 1
function Counter() {
  // ...
  useEffect(() => {
    const id = setInterval(() => {
      setCount(1 + 1); // setCount(count + 1)
    }, 1000);
    return () => clearInterval(id);
  }, [1]); // [count]
  // ...
}
```

Since `count` is different in each render, the effect will correctly re-trigger. And since we've designed a proper cleanup, the previous render's effect will be cleaned up before the new effect executes:

```jsx
// --- First render, count is 0 ---

// First render's effect
const id = setInterval(() => {
  setCount(0 + 1); // setCount(count + 1)
}, 1000);

// --- Second render, count is 1 ---

// Check if dependencies count differs from the previous render:
// 0 !== 1, so this effect should not be skipped and should execute normally

// Clean up the first render's effect
clearInterval(id); // First render's setInterval id

// Second render's effect
const id = setInterval(() => {
  setCount(1 + 1); // setCount(count + 1)
}, 1000);

// ...and so on
```

You’ll notice that while this solves the problem without deceiving dependencies, each time `count` updates via `setState` in a re-render, our interval gets cleared and reset. Each interval lives for only one second before being cleared and recreated. This might not be the ideal behavior we want. Let's explore a better solution.

### Making the Effect Self-Sufficient

You should always be honest about dependencies, which is a principle you should maintain under any circumstances, with no exceptions. However, in cases like the above example, we should try to adjust the effect to not depend on a frequently updating value. This way, we can safely remove `count` from the dependencies while staying honest.

Let’s extend the counter example. We want the effect not to depend on `count`, to avoid frequent setInterval creation and cleanup. We need to observe why this effect depends on `count`:

```jsx
const [count, setCount] = useState(0);

useEffect(() => {
  const id = setInterval(() => {
    setCount(count + 1); // Depends on count here
  }, 1000);

  return () => clearInterval(id);
}, [count]);
```

It looks like we need `count` only to perform the "increment the current value" action. However, in this case, we don't really need the `count` variable. As introduced in the earlier chapter, "Day 14: Calling setState with a functional updater," when we want to update a state based on its previous value, we can use an updater function for `setState`:

```jsx
const [count, setCount] = useState(0);

useEffect(() => {
  const id = setInterval(() => {
    // Use an updater function to compute the new state, eliminating the need for the count variable
    setCount(prevCount => prevCount + 1);
  }, 1000);

  return () => clearInterval(id);
}, []); // Now we no longer depend on count, so it can be safely removed from deps!
```

After replacing it with an updater function, our effect no longer depends on `count`, allowing us to safely remove it from the dependencies! You can observe the actual effect in this [CodeSandbox](https://codesandbox.io/).

In the original approach, `count` was indeed a necessary dependency, but we used it only to calculate `count + 1` before passing it to `setCount`. However, React always knows the current state value internally, so we just need to tell React to "increment the current value by 1." This is precisely what `setCount(prevCount => prevCount + 1)` does. It provides React with an "update guideline," allowing React to update the data internally.

By using the updater function, we can safely remove the effect’s dependence on the current state value, achieving "self-sufficiency" while maintaining honesty about dependencies.

### Functions and Dependencies

A common misconception is that functions should not be included in dependencies. Let's look at this example:

```jsx
function SearchResults() {
  const [query, setQuery] = useState('react');
 
  async function fetchData() {
    const result = await axios(
      `https://foo.com/api/search?query=${query}`,
    );
    // ...
  }
 
  useEffect(() => {
    fetchData();
  }, []); // Not honest, the effect uses the internal function fetchData
  // ...
}
```

In the above example, if we don't honestly include `fetchData` in the effect's dependencies, we might encounter bugs when we later add other data dependencies to the `fetchData` function and forget to update the dependencies.

Your first instinct might be to honestly add `fetchData` to the dependencies:

```jsx
function SearchResults() {
  const [data, setData] = useState({ hits: [] });
  const [query, setQuery] = useState('react');
 
  async function fetchData() {
    const result = await axios(
      `https://foo.com/api/search?query=${query}`,
    );
    setData(result.data);
  }
 
  useEffect(() => {
    fetchData();
  }, [fetchData]); // This dependency optimization will always fail because fetchData is different on every render
  // ...
}
```

However, in this example, the effect dependencies optimization will always fail. The effect will re-execute after every render, which is worse for performance than having no dependencies at all—since even the comparison operation costs performance.

This happens because the `fetchData` variable is different on every render. We declared this function inside the component, so it is recreated on every render and depends on that render's data. Recall the concept from earlier chapters—each render has its own props, state, and event handlers.

When our effect depends on a function without special handling, it can cause performance optimization to fail. The solution is not to lie about dependencies. Here are a few ways to address this:

### Move the Function Definition Inside the Effect

Continuing from the above example, if you only use a function inside one effect, you can define it directly inside that effect:

```jsx
function SearchResults() {
  const [data, setData] = useState({ hits: [] });
  const [query, setQuery] = useState('react');
 
  useEffect(() => {
    // Move the function definition inside useEffect
    // This function will only be recreated when the effect runs
    async function fetchData() {
      const result = await axios(
        `https://foo.com/api/search?query=${query}`,
      );
      setData(result.data);
    }
 
    fetchData();
  }, [query]); // Honest dependencies
  // ...
}
```

Moving the function inside the effect ensures it only gets recreated when the effect runs. The function is now dependent directly on the data that needs to trigger the effect—in this case, `query`.

Note that the first argument of `useEffect` cannot be an async function. Therefore, you need to declare an async function inside the effect function and then use the `await` syntax within it. Alternatively, you could use `.then` to handle promises.

### When You Don’t Want to Define the Function Inside the Effect

Sometimes, you might not want to define a function directly inside an effect, such as when the same function is called in different effects within the same component, and you don't want to duplicate the logic:

```jsx
function SearchResults() {
  async function fetchData(query) {
    const result = await axios(
      `https://foo.com/api/search?query=${query}`,
    );
  }
 
  useEffect(() => {
    fetchData('react').then(result => { /* do something with the data */ });
  }, [fetchData]); // Honest, but fetchData changes on every render, so optimization fails
  // ...
 
  useEffect(() => {
    fetchData('vue').then(result => { /* do something with the data */ });
  }, [fetchData]); // Honest, but fetchData changes on every render, so optimization fails
  // ...
}
```

In this example, even though we honestly included `fetchData` in the dependencies, the performance optimization always fails because `fetchData` is recreated on every render.

### Solution 1: Move Non-Component Related Functions Outside the Component

If a function or part of a process does not use any component-specific data or dependencies, you can move it outside the component:

```jsx
async function fetchData(query) {
  const result = await axios(
    `https://foo.com/api/search?query=${query}`,
  );
  return result;
}
 
function SearchResults() {
  useEffect(() => {
    fetchData('react').then(result => { /* do something with the data */ });
  }, []); // Honest dependencies since fetchData is an external function that never changes
  // ...
 
  useEffect(() => {
    fetchData('vue').then(result => { /* do something with the data */ });
  }, []); // Honest dependencies since fetchData is an external function that never changes
  // ...
}
```

By moving the function outside the component, you can omit it from the effect's dependencies since it won't be recreated on every render and won't be affected by the data flow—it cannot directly depend on props or state through closure.

### Solution 2: Wrap the Function with `useCallback`

While you should prioritize moving the function outside the component, sometimes the function may depend on many component data points. Moving it outside would then require passing too many parameters, reducing readability.

In such cases, React provides `useCallback` to help address this issue.

`useCallback` acts as an additional layer of dependency checking in the data flow. When the dependencies in `useCallback` remain the same as the previous render, it returns the previous render's function. The behavior of `useCallback` itself does not help avoid recreating functions on each render because the component still generates a new inline function for `useCallback` each time. However, this mechanism is beneficial when used with `useEffect`.

```jsx
function SearchResults(props) {
  const fetchData = useCallback(
    async (query) => {
      const result = await axios(
        `https://foo.com/api/search?query=${query}&rowsPerPage=${props.rows}`,
      );
      return result;
    },
    [props.rows] // Honest callback dependencies
  );
 
  useEffect(() => {
    fetchData('react').then(result => { /* do something with the data */ });
  }, [fetchData]); // Honest effect dependencies
 
  // ...
}
```

In the example above, we define the `fetchData` function inside the component, where it depends on `props.rows` and is called within the effect. Without `useCallback`, the effect's optimization fails because `fetchData` is different on every render. However, by wrapping `fetchData` in `useCallback`, the function can participate in the component's "dependencies chain."

Only when `props.rows` changes will `fetchData` be recreated, triggering the effect again. If `props.rows` remains unchanged, `useCallback` returns the same function from the previous render, so the effect is skipped. Thus, the effect dependencies optimization works effectively, acting like a chain reaction in the data flow.

With `useCallback` support, functions can fully participate in the data flow. If the data they depend on changes, so will the functions. If the dependencies remain the same, the function will be the same as in the previous render. The same concept applies to `useMemo`.

You don't need to wrap all component functions with `useCallback`. Use it when the function is used in an effect or passed as a prop to `React.memo` for comparison.

### The Concept Clarified:

Functions in function components and hooks are part of the data flow.

`useCallback` and `useMemo` allow derived data to participate in the data flow, maintaining `useEffect` synchronization reliability while also optimizing effect performance.

### Hooks `exhaustive-deps` Linter Rule

We've explored why you should always be honest about hooks dependencies and methods to safely reduce or adjust effect dependencies. However, even with the best intentions, it's easy to miss something during development. Fortunately, React provides a linter rule to detect and even automatically fix hooks dependencies issues. This tool helps catch problems during development through static analysis and is highly recommended for all React developers.


This linter rule is built into Create React App, so if you create your project with it, you should be able to use it in supported editors. You can also install it separately if needed.

### Common Misuses of Dependencies

In previous in-depth discussions on `useEffect`, we have repeatedly emphasized the concept: `useEffect` is for synchronizing data with effects outside React elements, not for lifecycle management. The dependencies of `useEffect` are a performance optimization, intended to skip unnecessary executions, not to control when effects happen based on the component lifecycle or business logic.

More importantly, dependencies as a performance optimization do not guarantee logical execution control. Effects can re-execute at unexpected times, which we'll discuss in more detail.

You might think that setting the dependencies to `[]` means the effect will never re-execute:

```jsx
import { useEffect, useState } from "react";
 
function App() {
  const [count, setCount] = useState(0);
 
  useEffect(() => {
    console.log('effect start'); 
    setCount((prevCount) => prevCount + 1);
  }, []); // This effect may run twice in React 18
 
  return <div>{count}</div>;
}
```

In fact, this effect may execute twice on mount in React 18, which you can try in this CodeSandbox.

This change is a breaking change in React 18 but only happens in Strict mode and the dev version of React. You might wonder why this change was introduced; it is a preemptive check for upcoming React versions. We'll delve into these details in the next section.

React documentation also mentions that hooks' dependencies are a performance optimization, not a logical guarantee. Future versions of React might "forget" the previous values of dependencies to free memory. If your effect uses dependencies for anything other than optimization, it might re-execute unexpectedly, leading to bugs.

So, the takeaway here is: being honest about dependencies isn't just a best practice—it's to ensure your effect's reliability. Going against this principle may break your effects in future React versions, causing unintended behaviors in your application.

### Misuse #1: Mimicking ComponentDidMount in Function Components

You shouldn't use `useEffect` with dishonest dependencies to mimic lifecycle methods like `componentDidMount`. Function components and hooks don't offer lifecycle methods directly. With the design of data flow and effect synchronization, you can meet most business logic needs without relying on lifecycle methods.

Instead of thinking about "executing specific actions at specific times," think about "synchronizing data to effects, ensuring correctness even with repeated synchronizations."

However, if you really need an effect to execute only once during the component's lifecycle, you can use a simple flag with `useRef`:

```jsx
import { useEffect, useState, useRef } from "react";
 
export default function App() {
  const [count, setCount] = useState(0);
  const isEffectCalledRef = useRef(false);
 
  useEffect(() => {
    if (!isEffectCalledRef.current) {
      isEffectCalledRef.current = true;
      console.log('effect start'); 
      setCount((prevCount) => prevCount + 1);
    }
  }, []);
 
  return <div>{count}</div>;
}
```

With the flag implemented using `useRef`, the business logic within the effect will only execute once.

`useRef` can store values across renders that don't affect the UI, such as the flag `isEffectCalledRef` here. Initially set to `false`, it prevents the business logic from running multiple times by flipping to `true` after the first execution.

### Misuse #2: Using Dependencies to Control Effect Execution

Another common misuse is trying to control effect execution with dependencies. For example, if you want to increment `count` whenever `todos` change:

```jsx
function App() {
  const [count, setCount] = useState(0);
  const [todos, setTodos] = useState([]);
 
  useEffect(() => {
    setCount(prevCount => prevCount + 1);
  }, [todos]); // Dishonest dependency, pretending to depend on todos
  // ...
}
```

Here, we're dishonestly pretending the effect depends on `todos`, aiming to control execution based on `todos` changes. This isn't reliable! Future React versions might forget the previous `todos` for performance reasons, causing the effect to run unexpectedly.

When your effect requires business logic conditions, write those conditions yourself, rather than relying on dependencies:

```jsx
function App() {
  const [count, setCount] = useState(0);
  const [todos, setTodos] = useState([]);
  const prevTodosRef = useRef();

  useEffect(() => {
    if (prevTodosRef.current !== todos) {
      setCount(prevCount => prevCount + 1);
    }
  }, [todos]); // Honest dependencies

  useEffect(() => {
    // After rendering and other effects are done, store the current todos
    prevTodosRef.current = todos;
  }, [todos]);
 
  // ...
}
```

Using `useRef`, we remember the previous render's value, allowing us to write genuine conditional logic inside the effect, rather than misusing dependencies to track data changes.

By following these guidelines, you'll avoid common pitfalls and ensure your effects are reliable and performant.

