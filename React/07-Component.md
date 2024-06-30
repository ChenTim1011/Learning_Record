Leveraging setState and Props for Effective Component Interaction in React
In React, state data and the setState method serve as the primary triggers for reconciliation, while props act as the medium for data transmission between components. Many React beginners struggle with the concept of "how to update parent component data from a child component." Let's explore how to effectively use setState and props to ensure smooth data and UI updates in a component-based structure.

Props are Read-Only and Immutable
First, it's crucial to understand that props in React are "read-only and immutable." Once props are passed into a component, their contents should never be directly modified within that component.

Consider the following example:

jsx
複製程式碼
function App(props) {
  // Avoid directly modifying props inside the component
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

// Destructuring props
function App({ a, b }) {
  // Avoid directly modifying props inside the component
  a = "hello";
  b = "world";

  return (
    <ul>
      <li>prop a: {a}</li>
      <li>prop b: {b}</li>
    </ul>
  );
}
In the examples above, modifying the props object inside the App component is not recommended and can lead to unexpected issues. This rule ensures that props always remain in their original state as passed from the parent component, aiding in maintaining a reliable unidirectional data flow and improving code maintainability.

If you need to perform calculations or derive new values based on props, you should store the results in new variables rather than modifying the props directly.

setState Triggers Re-rendering of the Original Component
When a component's setState method is passed down to another component and called, the original component that owns the state will be the one re-rendered:

jsx
複製程式碼
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
In this example, we define a count state in the App component and pass the increment function (which calls setCount) to the IncrementButton component via props. When the IncrementButton is clicked, it calls the increment function. Despite the setCount call happening within the IncrementButton, it triggers a re-render in the App component, which then leads to a re-render of the IncrementButton:


Updating Parent State from a Child Component
Given the immutability of props, direct modification of parent data from a child component is not possible. However, you can pass the setState function as a prop to the child component and call it from there:

jsx
複製程式碼
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
      <button onClick={repeatName}>Repeat the name string</button>
    </>
  );
}
In this example, calling setName within the Child component triggers a state update in the Parent component. This update causes the Parent to re-render, passing the new state down to the Child component, which then re-renders with the updated name prop:


Initial Render: The Parent component initializes the name state and passes it, along with the setName function, to the Child component as props.
Event Handling in Child: When the repeatName function in the Child component calls props.setName(newName), it triggers a state update in the Parent component.
Re-render Parent: The Parent re-renders with the updated state.
Re-render Child: The Child re-renders with the updated name prop, reflecting the new state in the UI.