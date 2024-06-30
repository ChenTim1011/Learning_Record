### Interacting with Parent and Child Components Using `setState` and Props in React

In React, `state` and `setState` trigger reconciliation, while `props` serve as the medium for data propagation from parent to child components. A common challenge for beginners when learning to split components is understanding how to trigger updates in the parent component's data from within a child component. Let’s explore how to use `setState` and props together to ensure smooth data and UI updates in a split-component structure.

### Props are Read-Only and Immutable

Firstly, component `props` are "read-only and immutable data." Once passed into a component, you should never modify them directly within the component.

Consider the following example:

```jsx
function App(props) {
  // Note: You should not modify props within a component
  props.a = "hello";
  props.b = "world";
  props.c = "new prop";

  return (
    <ul>
      <li>prop a: {props.a}</li>
      <li>prop b: {props.b}</li>
    </ul>
  );
}

// Destructuring props directly in the parameter definition
function App({ a, b }) {
  // Note: You should not modify props within a component
  a = "hello";
  b = "world";

  return (
    <ul>
      <li>prop a: {a}</li>
      <li>prop b: {b}</li>
    </ul>
  );
}
```

In the above examples, modifying the `props` object within the `App` component function is neither allowed nor advisable. Doing so can lead to unexpected issues. This rule ensures that `props` always retain their original values as passed from the parent component, making it easier to track data origins and maintain the reliability of one-way data flow, thus enhancing code maintainability.

If you need to extend the data from `props`, you should store the computed result in a newly declared variable rather than modifying the original `props` object or variables.

### `setState` Always Triggers Re-render of the Owning Component

When a component's `setState` method is passed to another component and called there, it still re-renders the original owning component:

```jsx
import { useState } from 'react';

function IncrementButton({ onClick }) {
  console.log('render IncrementButton');
  return <button onClick={onClick}>+</button>;
}

export default function App() {
  console.log('render App');
  const [count, setCount] = useState(0);

  const decrement = () => {
    setCount(previousCount => previousCount - 1);
  };

  const increment = () => {
    setCount(previousCount => previousCount + 1);
  };

  return (
    <div>
      <button onClick={decrement}>-</button>
      <span>{count}</span>
      <IncrementButton onClick={increment} />
    </div>
  );
}
```

In this example, the `App` component defines the `count` state and passes the `increment` method (which calls `setCount`) to the child component `IncrementButton`. In `IncrementButton`, the method is bound to the `onClick` event of a button.

When clicking the button in `IncrementButton`, you’ll notice that despite `setCount` being executed within `IncrementButton`, the console first logs `render App`, indicating that the reconciliation still triggers `App` to re-render first, followed by the re-rendering of `IncrementButton`.

### Triggering Parent Component State Updates from Child Component

Given the strict one-way data flow in React, when passing state from a parent component to a child component via `props`, you cannot directly modify this data within the child component:

```jsx
import { useState } from 'react';

function Parent() {
  const [name, setName] = useState('Zet');
  return (
    <>
      <h1>Render name in Parent: {name}</h1>
      <Child name={name} />
    </>
  );
}

function Child(props) {
  const repeatName = () => {
    props.name = props.name.repeat(2); // ❌ Illegal operation, props should not be modified
  };
	
  return (
    <>
      <h2>Render name in Child: {props.name}</h2>
      <button onClick={repeatName}>
        repeat the name string
      </button>
    </>
  );
}
```

However, besides passing the state data itself as `props`, you can also pass the `setState` function to the child component and call it from within the child:

```jsx
import { useState } from 'react';

function Parent() {
  const [name, setName] = useState('Zet');
  return (
    <>
      <h1>Render name in Parent: {name}</h1>
      <Child name={name} setName={setName} />
    </>
  );
}

function Child(props) {
  const repeatName = () => {
    props.setName(prevName => prevName.repeat(2));
  };

  return (
    <>
      <h2>Render name in Child: {props.name}</h2>
      <button onClick={repeatName}>
        repeat the name string
      </button>
    </>
  );
}
```

In this example, when `setName` is called within `Child`, you’ll see that `props.name` in `Child` is updated as well. This happens not because calling `setName` directly modifies `props.name`, but due to the fact that calling `setState` always triggers a re-render of the owning component (`Parent` in this case):

1. During the initial render, `Parent` passes the initial `name` state and the `setName` function as `props` to `Child`.
2. When the event handler in `Child` calls the `setName` function, it triggers a re-render of `Parent`.
3. `Parent` re-renders, updating its `name` state, and passes the updated `name` state to `Child`.
4. `Child` receives the updated `name` state via `props` and re-renders with the new data.

### Summary

In summary, when you want to trigger updates to a parent component's data from a child component, the parent component must pass down the `setState` function (or a `dispatch` function from `useReducer`) as a `prop`. This approach embodies the one-way data flow pattern in React:

- Child components cannot directly modify the `props` they receive to update the UI or change parent component data.
- However, if the parent component passes the `setState` function as a `prop`, the child can call this function to trigger updates in the parent component's data and UI.
- When the parent component's state is updated and passed down to the child as `props`, the child component will re-render with the new data.