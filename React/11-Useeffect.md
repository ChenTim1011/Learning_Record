### React Component Lifecycle and Data Flow: Understanding useEffect

Continuing from the previous chapter, we have understood that each render has its own props, state, and event handlers. Now, let's dive into how `useEffect` works in this context.

### Each Render Has Its Own Effects

Consider the classic example from the React documentation, which updates the document title with the counter state on each render:

```jsx
function Example() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    // Update the document title using the browser API
    document.title = `You clicked ${count} times`;
  });

  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}

```

Again, a similar situation arises. How does this effect know what the value of `count` is?

You'll find that the concept is essentially the same as the event handlers discussed in the previous chapter:

1. `count` is a value retrieved from state, and within each render, the `count` variable is always constant.
2. The effect function passed to `useEffect` is a function that is recreated during each render and uses the `count` variable of that render.
3. Due to the nature of closures, the effect function remembers the `count` of the render it was created in and does not change with subsequent re-renders of the component.

In essence, for each render, a new, specific version of the effect function is created, each capturing its own `props` and `state`:

```jsx
function Example() {
  const [count, setCount] = useState(0);

  // Notice here, we're passing an inline function to useEffect as the effect function,
  // so a new effect function is created on each re-render,
  // meaning the effect function of the same useEffect is different across renders.
  useEffect(() => {
    document.title = `You clicked ${count} times`;
  });

  // ...
}

```

Let's understand this concept by simulating each render step-by-step:

```jsx
// On the first render
function Example() {
  const count = 0; // Retrieved from useState

  useEffect(() => {
    document.title = `You clicked ${0} times`;
  });
  // ...
}

// After a click, the component function is re-executed
function Example() {
  const count = 1; // Retrieved from useState

  useEffect(() => {
    document.title = `You clicked ${1} times`;
  });
  // ...
}

// After another click, the component function is re-executed again
function Example() {
  const count = 2; // Retrieved from useState

  useEffect(() => {
    document.title = `You clicked ${2} times`;
  });
  // ...
}

```

Conceptually, you can think of effects as byproducts of the render output, each specific to a particular render and remembering the props and state of that render.

### Each Render Has Its Own Effect Cleanup Function

Some effects may need cleanup to avoid unintended issues, such as effects that perform subscriptions needing to unsubscribe. Let's look at a simple example:

```jsx
useEffect(() => {
  OrderAPI.subscribeStatus(props.id, handleChange);
  return () => {
    OrderAPI.unsubscribeStatus(props.id, handleChange);
  };
});

```

This is an effect that subscribes to order status updates. Suppose the props are `{ id: 1 }` on the first render and `{ id: 2 }` on the second render:

```jsx
// On the first render, props are { id: 1 }
function Example(props) {
  // ...
  useEffect(() => {
    OrderAPI.subscribeStatus(1, handleChange);
    return () => {
      OrderAPI.unsubscribeStatus(1, handleChange);
    };
  });
  // ...
}

// On the second render, props are { id: 2 }
function Example(props) {
  // ...
  useEffect(() => {
    OrderAPI.subscribeStatus(2, handleChange);
    return () => {
      OrderAPI.unsubscribeStatus(2, handleChange);
    };
  });
  // ...
}

```

We need to explain the timing and flow of effect and cleanup in the render process:

1. React generates the UI corresponding to the current render's props and state, i.e., React elements.
2. The browser completes the rendering of the screen, and we can see the result in the browser.
3. The cleanup function for the previous render's effect is executed.
    - Of course, there is no cleanup on the first render.
4. The effect function for the current render is executed.

From the flow above, we can see that effects occur after the browser has updated the actual screen, which enhances your app's performance since most effects do not need to block screen updates. Therefore, screen rendering should usually be prioritized.

Additionally, cleanup does not occur immediately after the effect function completes but before the next render's effect executes. Thus, the example can be broken down as follows:

**On the first render with props `{ id: 1 }`:**

1. Generate React elements based on props `{ id: 1 }`.
2. The browser completes the screen rendering; we see the screen result for props `{ id: 1 }`.
3. Execute the effect for the current render where props are `{ id: 1 }`.

**On the second render with props `{ id: 2 }`:**

1. Generate React elements based on props `{ id: 2 }`.
2. The browser completes the screen rendering; we see the screen result for props `{ id: 2 }`.
3. Cleanup the previous render's effect: execute the cleanup function for the render where props were `{ id: 1 }`.
4. Execute the effect for the current render where props are `{ id: 2 }`.

So, on the second render, the cleanup function for the first render's effect is executed. Here comes a similar question: will the `props.id` obtained in the cleanup function be 1 or the latest value 2?

After going through many similar situations, you can probably infer that the cleanup function is also a byproduct of a specific render. It is created anew in each render and relies on the props and state of that render, which are immutable. Thus, no matter how long it takes for the cleanup function to be executed, it will always find the fixed props and state of the render it was created in.

So, in the example above, although the first render's effect cleanup is executed during the second render, this cleanup function already "remembers" the props `{ id: 1 }` through closure from when it was created in the first render:

```jsx
// The cleanup function for the effect created on the first render with props { id: 1 }
return () => {
  OrderAPI.unsubscribeStatus(1, handleChange);
};

```

### Summarizing Key Concepts

Every render of a component has its own props and state, and their values are immutable. Functions defined and created within a render, including event handlers, effects, and cleanups, "capture and remember" the props and state of that specific render. Therefore, no matter when these functions are executed, they always find the fixed props and state of the render they were created in.

### Immutable Data and Reliable Closures

From the analysis above, you can see that the key points are immutable data and closures. Achieving this effect requires both.

Let's revisit the "key difference between class components and function components" mentioned in previous chapters to help solidify this concept:

```jsx
class BuyProductButton extends React.Component {
  showSuccessAlert = () => {
    alert(`Successfully purchased "${this.props.productName}"!`);
  };

  handleClick = () => {
    setTimeout(this.showSuccessAlert, 3000);
  };

  // ...
}

```

In class components, if we retrieve props data using `this.props.xxxx`, we cannot guarantee that the result of executing `showSuccessAlert` at any time will be consistent. When props update, React mutates the `this` object. Therefore, if asynchronous events cause `showSuccessAlert` to be executed when `this.props` has already been replaced by React, we might mistakenly get the latest data.

The root of this issue is that "this is not a guarantee of immutable data"; it can be modified at any time by external forces, making it difficult to ensure that functions using `this` will have consistent results over multiple executions. The behavior of closures "remembering" variables outside the function is hard to predict because you cannot fully control when the data might be modified elsewhere. Thus, it is difficult to ensure that the function's results are fixed and predictable.

Why don't function components encounter this problem?

```jsx
function BuyProductButton(props) {
  const showSuccessAlert = () => {
    alert(`Successfully purchased "${props.productName}"!`);
  };

  const handleClick = () => {
    setTimeout(showSuccessAlert, 3000);
  };

  // ...
}

```

In function components, props and state are re-obtained through injection during each render (props are received as parameters, and state is returned from calling `useState`). Props and state between renders are independent and immutable. In the example above, the props object received in each render is a different instance. Thus, when the component re-renders and props change, it does not mutate the props object of the previous render but rather receives a new props object.

The `showSuccessAlert` function is recreated in each render, capturing the specific props of that render. Therefore, whenever and wherever this function is executed, the `props.productName` it remembers is always the version from the render it was created

in.

Thus, function components perfectly solve this issue because "the data captured and remembered by closures in various functions within the render are immutable and will never change." This makes these functions' execution effects stable and predictable. They become part of the unidirectional data flow of the component, meaning "when the original data changes, the function's execution effect also changes accordingly," applicable to event handlers, effects, cleanups, and more.

This is why understanding the characteristics of closures is crucial for learning React, as it is omnipresent in React development. The designs and concepts analyzed above are not unique technologies or magic of React but rely on fundamental JavaScript features that have always existed.

When the external variables that functions rely on are immutable, the characteristics of closures are reliable and beneficial, making the perception of data flow simpler and more intuitive for developers, as the function's execution effect is always fixed and predictable.

**References:**

- [A Complete Guide to useEffect - Overreacted](https://overreacted.io/a-complete-guide-to-useeffect/)

### Deep Dive into useEffect: Understanding the Core Concepts

After the previous two chapters, you should now have a solid understanding of function component rendering concepts. Let's move on to the main topic of this stage: `useEffect`.

`useEffect` is an API that many who have learned React hooks might find confusing, especially those who were previously familiar with class components. Including myself, many React developers have tried to simulate the lifecycle APIs like `componentDidMount` or `componentDidUpdate` in function components using `useEffect`. However, this is not the correct model of thinking or usage for `useEffect`. Even years after hooks were introduced, many React developers still misunderstand the real purpose of `useEffect`.

Let’s extend the concepts of render data flow from the previous chapters and dive into a proper understanding of `useEffect`.

### Declarative Synchronization, Not Lifecycle API

Whenever we call `setState` to update data, React re-executes the render with the latest data, generating corresponding React elements and automatically syncing them to the DOM. For the render itself, this process does not differ between "mount" or "update."

This action of "syncing the original data to the rendered result" essentially maintains the operation of unidirectional data flow. The concept we explored in the previous chapter, "each render has its own effects," is an extension of this idea. The effect function is regenerated on each render and depends on the raw data version of that render via closures. Hence, we can extend the understanding that `useEffect` is used to "sync the original data to effects outside the rendered result":

```jsx
function Example() {
  const [count, setCount] = useState(0);

  // This effect syncs the count data to the browser's page title
  useEffect(() => {
    document.title = `You clicked ${count} times`;
  });

  return (
    <button onClick={() => setCount(count + 1)}>
      Click me
    </button>
  );
}
```

### Declarative vs. Imperative Programming

In this synchronization action, React does not care whether it is the first render (commonly referred to as mount) or any subsequent render (referred to as update). The effect's task is to sync the `count` data to the browser's page title in either case.

This concept in programming paradigms is known as "declarative," meaning we only care about whether the result is correct, not how the details of the process are handled. The design of Virtual DOM and React elements introduced in previous chapters is React’s approach to UI management in a declarative manner: we don't care about the differences in details between the new and old screens. We only tell React what the new screen (i.e., the result) should look like. The actual DOM operations required to update the screen (the process) are automatically handled by React, without our intervention.

In contrast, the "imperative" concept focuses on "how to achieve the goal through detailed processes," making it harder to intuitively understand if the execution results are as expected. For example, when you manually manipulate the DOM to update the screen, you must be very clear about which specific parts of the DOM tree need modification, ensuring nothing is missed to achieve the correct result. Merely looking at the code, it's challenging to predict the expected outcome since the results are accumulated through various process operations and can only be confirmed by running the code.

Therefore, in scenarios requiring high synchronization, the declarative approach is easier to maintain and predict the execution results, which is why most modern front-end solutions prefer a declarative style for UI development, with React being a prime example.

### Understanding `useEffect` Through Declarative Synchronization

`useEffect` is designed under the same concept. It doesn’t care if the effect process is executed during mount or update or how many times it is repeated; it only cares about the final synchronization of the original data to the effect being correct.

Strictly speaking, `useEffect` is not a lifecycle API for function components. Although its execution timing is similar to `componentDidMount` and `componentDidUpdate` (with some slight differences), it is designed not to let you execute a custom callback at specific moments in React’s operation. Instead, it has a clear, specified purpose: to synchronize original data to something other than React elements. Ideally, regardless of how many times the effect is executed due to re-renders, your program should maintain synchronization and function correctly.

This approach is quite different from the mount/update/unmount model familiar to developers with class component experience. If you try to write an effect that behaves differently based on whether it's the component’s first render, you violate the intended design philosophy of `useEffect`. If your execution relies on the "process" rather than the "destination," you might end up with code that has synchronization issues.

### Why Effects & Cleanups Execute After Every Render

By default, effects execute after every render. After understanding the concept of "synchronization," it should be clear: effects are part of the unidirectional data flow, so they can be considered byproducts of the render result.

However, sometimes repeating behaviors in effects can cause unexpected issues, requiring cleanup functions to remove or reset the impact of these effects. Like effects, cleanups execute after every render, not just during unmount, ensuring repeated effect executions don’t cause accumulative issues.

Consider the following class component example:

```jsx
componentDidMount() {
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

componentWillUnmount() {
  OrderAPI.unsubscribeStatus(this.props.id, this.handleStatusChange);
}
```

This class component subscribes to the order status with `props.id` in `componentDidMount` and unsubscribes in `componentWillUnmount`. It seems fine, right?

However, if the order status displays on the screen and we switch to view another order, causing the component to re-render with a new `props.id`, the component will incorrectly display the status of the previous order. When unmounting, it won’t correctly unsubscribe from the original order status, leading to memory leaks.

In class components, we need to add `componentDidUpdate` to handle this situation. Forgetting to handle `componentDidUpdate` properly is a common source of bugs in React development.

```jsx
componentDidMount() {
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

// Adding componentDidUpdate to fix the bug
componentDidUpdate(prevProps) {
  // Unsubscribe from the previous order id
  OrderAPI.unsubscribeStatus(prevProps.id, this.handleStatusChange);

  // Subscribe to the next order id
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

componentWillUnmount() {
  OrderAPI.unsubscribeStatus(this.props.id, this.handleStatusChange);
}
```

In function components, since `useEffect` handles synchronization by default after each render, there’s no need to separately manage the mount and update flows. Before executing the next effect, it executes cleanup for the previous render’s effect:

```jsx
useEffect(() => {
  OrderAPI.subscribeStatus(props.id, handleChange);
  return () => {
    OrderAPI.unsubscribeStatus(props.id, handleChange);
  };
});
```

Simulating the execution flow over multiple renders:

```jsx
// -- Mount with { id: 1 } props ---
// Execute the first effect
OrderAPI.subscribeStatus(1, handleChange);

// --- Update with { id: 2 } props ---
// Clean up the previous effect
OrderAPI.unsubscribeStatus(1, handleChange);
// Execute the next effect
OrderAPI.subscribeStatus(2, handleChange);

// --- Update with { id: 3 } props ---
// Clean up the previous effect
OrderAPI.unsubscribeStatus(2, handleChange);
// Execute the next effect
OrderAPI.subscribeStatus(3, handleChange);

// --- Unmount ---
// Clean up the previous effect
OrderAPI.unsubscribeStatus(3, handleChange);
```

### Dependencies: Optimization, Not Logic Control

By default, every render should execute the corresponding effect to ensure synchronization. However, components might re-render due to data updates unrelated to the effect, causing unnecessary effect executions. Consider the following example:

```jsx
function Example({ name }) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = 'Hello, ' + name;
  });

  return (
    <>
      <h1>Hello, {name}</h1>
      <button onClick={() => setCount(count + 1)}>
        +1
      </button>
    </>
  );
}
```

In this example, the effect syncs the `name` prop to the browser’s page title. However, clicking the button to increment `count` triggers a re-render, causing the effect to execute again even though it’s unrelated to `count`. Although the effect is designed to handle repeated executions correctly, unnecessary synchronizations are redundant and should be avoided for performance reasons.

We can provide dependencies to the effect, informing React that the effect depends on specific data. If the dependencies list's data hasn’t changed since the last render, React can safely skip the effect, optimizing performance.

```jsx
function Example({ name }) {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = 'Hello, ' + name;
  }, [name]); // Specify dependencies that the effect relies on

  return (
    <>
      <h1>Hello, {name}</h1>
      <button onClick={() => setCount(count + 1)}>
        +1
      </button>
    </>
  );
}
```

Now, the effect in this example will skip execution if `name` remains the same between renders.

### Understanding Dependencies: Optimization, Not Logic Control

Understanding that "dependencies are a performance optimization, not a logic control" is crucial for mastering `useEffect`. Dependencies

 inform React when it’s safe to skip unnecessary executions because the underlying data hasn’t changed. They are not intended to control when the effect should occur based on component lifecycle or business logic conditions. You should always honestly specify the dependencies based on the actual data dependencies, not manipulate them to achieve certain effects (e.g., specifying an empty array to simulate `componentDidMount`).

Lying about dependencies often leads to subtle, hard-to-trace bugs in your application. If your effect has issues when executed multiple times, consider writing an effective cleanup for the effect. If the effect should only execute under certain business logic conditions, implement those conditions within the effect itself rather than relying on the dependency skipping mechanism.

Since dependencies are a performance optimization, think of them in terms of performance principles: "Even without this optimization, the application should function correctly." To ensure your effects are safe and reliable, design your effects to function correctly even if they execute after every render without dependencies.

When designing effect logic, don’t think about "which renders will execute this effect" but rather that the logic should function correctly even if executed after every render. The goal is not to control which render executes the effect or how many renders are needed to complete the effect's task but to ensure the effect's final execution result accurately synchronizes data changes.

React’s documentation also mentions that hooks dependencies are only a performance optimization and not a semantic guarantee. In the future, React might "forget" old dependency values to free up memory. Therefore, if you misuse dependencies beyond optimization, your effect logic might be unexpectedly re-executed.

### Summary of useEffect Core Concepts

Here’s a summary of the core concepts discussed regarding `useEffect`:

1. Function components do not have lifecycle APIs, only `useEffect` for "synchronizing data to effects."
2. `useEffect` lets you synchronize anything outside React elements (the UI) with the current data.
3. Typically, `useEffect` executes after each component render, once the browser updates the DOM and paints the screen, to avoid blocking the render process and screen painting.
4. Exception: In React 18, if a render is triggered by `flushSync` wrapped `setState`, the effect executes before the browser’s screen layout and painting.
5. Conceptually, `useEffect` doesn’t distinguish between mount and update; they’re treated as the same situation.
6. By default, `useEffect` should execute after every render to ensure correct and complete synchronization.
7. Ideally, the effect should function correctly even if executed multiple times with each render.
8. Dependencies are a performance optimization to skip unnecessary executions, not to control effect execution based on component lifecycle or business logic timing.

**References:**
- [Using the Effect Hook - React Docs](https://reactjs.org/docs/hooks-effect.html)
- [A Complete Guide to useEffect - Overreacted](https://overreacted.io/a-complete-guide-to-useeffect/)