### When to Use `useCallback` and `useMemo` in React

Apart from the core `useState` and `useEffect`, the most commonly used built-in hooks in React are `useCallback` and `useMemo`. However, many developers are unsure about the situations in which these hooks should be used. In this chapter, we will deeply analyze the correct usage scenarios for these hooks.

### `useCallback`

Let's start with the more frequently used `useCallback`. Contrary to many people's intuition, the primary purpose of `useCallback` is not performance optimization. In fact, using `useCallback` can make performance worse. However, although it is not inherently a performance optimization tool, its characteristics can assist other performance optimization methods in functioning correctly.

First, let's look at how `useCallback` is invoked:

```jsx
function App() {
  const doSomething = useCallback(() => {
    console.log(props.foo);
  }, [....]);
}
```

As seen in the code above, if we create an inline function during each render and pass it as the first argument to `useCallback`, we do not save the cost of "unnecessary function creation" because we still create the function before passing it to `useCallback`. If all the dependencies are the same as in the previous render, `useCallback` will ignore the new function passed in this render and return the function from the previous render.

This is why `useCallback` itself cannot provide performance optimization and can even slow down performance. It cannot prevent function creation in each render, and comparing dependencies also consumes performance (though this cost is usually negligible).

So, what is the true purpose of `useCallback`? Conceptually, it helps our component "sense changes in the data flow." What does this mean? Let’s explore two common practical usage scenarios to clarify:

#### Maintaining the Hooks Dependencies Chain

When a function in a component is called within an effect, that function is considered a dependency of the effect:

```jsx
function SearchResults(props) {
  async function fetchData(query) {
    const result = await axios(`https://foo.com/api/search?query=${query}&rowsPerPage=${props.rows}`);
  }

  useEffect(() => {
    fetchData('react').then(result => { /* Perform some operations with data */ });
  }, [fetchData]);
}
```

If the `fetchData` function, as in the example above, is not wrapped with `useCallback`, it will be a new version every time the component re-renders. Therefore, the effect’s dependencies will always change, causing the effect to execute every render, making the performance optimization of `useEffect` dependencies ineffective.

The essence of `useEffect` dependencies is to "sense changes in the data flow to optimize performance." The effect should re-execute if the dependencies change and skip execution if they don’t. When functions defined within the component are recreated in each render, the effects that call these functions lose their ability to "correctly sense changes in the data flow," failing to achieve the performance optimization.

This is where `useCallback` comes in. It helps your component functions "sense changes in the data flow and reflect those changes on themselves," allowing other hooks using these functions to continue sensing the data flow, creating a "dependencies chain":

```jsx
function SearchResults(props) {
  const fetchData = useCallback(async (query) => {
    const result = await axios(`https://foo.com/api/search?query=${query}&rowsPerPage=${props.rows}`);
    return result;
  }, [props.rows]);

  useEffect(() => {
    fetchData('react').then(result => { /* Perform some operations with data */ });
  }, [fetchData]);
}
```

In this example, we define `fetchData` directly in the component, where it depends on `props.rows` and is called within an effect. If `fetchData` is not wrapped with `useCallback`, the effect will always execute because `fetchData` is different in each render. Wrapping `fetchData` with `useCallback` allows it to participate in the component's "dependencies chain."

Only when `props.rows` changes will `useCallback` return a new version of `fetchData`, causing the effect to re-execute. If `props.rows` doesn’t change, `useCallback` will return the same function as in the previous render, causing the effect to be skipped. This makes the performance optimization of effect dependencies effective, creating a chain reaction of data flow.

With the help of `useCallback`, functions can fully participate in the data flow. If the data they depend on changes, the function will change accordingly. If the dependencies don’t change, the function will remain the same as in the previous render.

If your function logic is used in only one effect, you can write that logic directly in the effect. Refer to previous chapters for detailed techniques on effect design: [Day 23] Maintain Data Flow — Do Not Cheat Hooks Dependencies (Part 2).

#### Using with React.memo: Skipping Component Render for Performance Optimization

Besides `useEffect`, which can skip execution for optimization, a component's render itself can also be optimized using `React.memo`:

```jsx
import React from 'react';

function Child(props) {
  return (
    <>
      <div>Hello, {props.name}</div>
      <button onClick={props.onAlertButtonClick}>alert</button>
    </>
  );
}

const MemoizedChild = React.memo(Child);
```

`React.memo` is a higher-order component. If your component renders the same output with the same props, you can wrap it in `React.memo` to cache the render result for performance optimization. This means if the component’s props are the same as the previous render, React will skip the render process and return the previous render’s result. This is another form of sensing data changes, helping the component determine whether it can skip a render.

However, `React.memo`, like `useEffect`, faces a similar problem. If a memoized component's props include a function that changes every render, the performance optimization will never succeed:

```jsx
import React from 'react';

function Child(props) {
  return (
    <>
      <div>Hello, {props.name}</div>
      <button onClick={props.showAlert}>alert</button>
    </>
  );
}

const MemoizedChild = React.memo(Child);

function Parent() {
  const showAlert = () => alert('hi');
  return (
    <MemoizedChild name="zet" showAlert={showAlert} />
  );
}
```

In this example, the `showAlert` function in `<Parent>` changes every render. As a prop passed to the memoized child component `<MemoizedChild>`, the props comparison will always fail, making the optimization ineffective.

Yes! This is where `useCallback` can help:

```jsx
import React, { useCallback } from 'react';

function Child(props) {
  return (
    <>
      <div>Hello, {props.name}</div>
      <button onClick={props.showAlert}>alert</button>
    </>
  );
}

const MemoizedChild = React.memo(Child);

function Parent() {
  const showAlert = useCallback(() => alert('hi'), []);

  return (
    <MemoizedChild name="zet" showAlert={showAlert} />
  );
}
```

By wrapping the `showAlert` function in `<Parent>` with `useCallback` and adding honest dependencies, the function can participate in sensing data changes and assist `React.memo` in correctly sensing data flow changes.

In summary, if a function in a component is called within an effect or passed as a prop to a memoized child component, it is recommended to wrap that function with `useCallback`. Always ensure that the dependencies are honest to maintain reliable data flow sensing.

