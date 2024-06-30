### React Component Lifecycle and Data Flow: Understanding useEffect and Function Components

After discussing the core concepts of screen updates in React and the advanced details of `setState`, let's move on to the next major topic—component lifecycle and data flow. As mentioned in the preface, this series will analyze function components with hooks, currently the mainstream approach, focusing on the most confusing and error-prone hook, `useEffect`. In the following articles, we'll help you truly understand the lifecycle of function components and the design context and proper usage of `useEffect`.

We start with function components. Compared to class components, function components have an often-overlooked but crucial characteristic. Consider the following example:

```jsx
function BuyProductButton(props) {
  const showSuccessAlert = () => {
    alert(`Successfully purchased "${props.productName}"!`); 
  };

  const handleClick = () => {
    setTimeout(showSuccessAlert, 3000);
  };

  return (
    <button onClick={handleClick}>Buy</button>
  );
}
```

This function component renders a button. When clicked, it simulates an API request with `setTimeout` and shows an alert upon completion.

Now, let's convert this into a class component:

```jsx
class BuyProductButton extends React.Component {
  showSuccessAlert = () => {
    alert(`Successfully purchased "${this.props.productName}"!`); 
  };

  handleClick = () => {
    setTimeout(this.showSuccessAlert, 3000);
  };

  render() {
    return <button onClick={this.handleClick}>Buy</button>;
  }
}
```

We often think these two component implementations are equivalent. However, they have a critical but sometimes hard-to-notice difference. Let's experiment with a more comprehensive project. Please open this [CodeSandBox](https://codesandbox.io/). You will see a page with a select dropdown for switching products and two purchase buttons implemented with function and class components.

Follow these steps to use the buttons:

1. Select a product from the dropdown.
2. Click the purchase button.
3. Switch the dropdown to another product within three seconds.
4. Observe the alert message.

You will notice a peculiar difference in behavior:

**Function Component:**

1. Initially select the "Laptop" product and click the purchase button.
2. Switch the dropdown to "Smartphone" within three seconds.
3. The alert shows: "Successfully purchased 'Laptop'!"

![Function Component Example](https://i.imgur.com/rVNpj5r.gif)

**Class Component:**

1. Initially select the "Laptop" product and click the purchase button.
2. Switch the dropdown to "Smartphone" within three seconds.
3. The alert shows: "Successfully purchased 'Smartphone'!"

![Class Component Example](https://i.imgur.com/hui3iDC.gif)

In the above examples, the first behavior is correct. When I select a product and submit a purchase, switching to another product page should not affect the earlier purchase. Therefore, the class component's behavior is clearly incorrect.

#### The Pitfall of `this.props` in Asynchronous Events

What causes this difference? Let's examine the `showSuccessAlert` method in the class component:

```jsx
class BuyProductButton extends React.Component {
  showSuccessAlert = () => {
    alert(`Successfully purchased "${this.props.productName}"!`); 
  };

  // ...
}
```

The key issue is here: this method reads the product name from `this.props.productName`. In React, props are immutable, but `this` is not. Every time the class component re-renders, React mutates `this` with the new props, replacing the old ones.

Therefore, when we access props via `this.props` after a re-render, we get the props from the latest render. This behavior can cause bugs when such access occurs in asynchronous event handlers, which should use "old" data but mistakenly read the "new" data.

In the class component example, we expect the alert to show the product name at the moment of the click. However, because the alert is triggered by a `setTimeout`, if the component re-renders with new props before the alert is shown, `this.props` will refer to the new props, resulting in incorrect data.

This issue underscores a critical concept: React follows a unidirectional data flow where the UI is a result of the original data. In React, props or state are the original data, and the component's render method produces React elements. Event handlers defined in the component also access props or state, and you expect the data read by the event to match the version at the moment of the event. Therefore, event handlers should be considered part of the render result, "belonging" to a specific render with particular props and state.

Thus, accessing props in asynchronous events via `this.props` breaks the data flow's consistency and reliability. The `showSuccessAlert` method in the class component is not bound to specific render props data but instead always reads the latest props from `this`.

To fix this issue in class components, you need to decouple props access from `this`:

```jsx
class BuyProductButton extends React.Component {
  showSuccessAlert = (productName) => {
    // Read productName from the parameter, not this.props
    alert(`Successfully purchased "${productName}"!`); 
  };
  
  handleClick = () => {
    // Capture the current prop data from this.props at the moment of the event
    const { productName } = this.props;

    // Use closure to pass productName into the setTimeout callback
    setTimeout(
      () => this.showSuccessAlert(productName),
      3000
    );
  };

  // ...
}
```

This solution successfully fixes the bug. In `handleClick`, we capture the prop data from `this.props` at the moment of the event and pass it into the `setTimeout` callback using a closure. Thus, even if `this.props` is mutated with new props data due to a re-render before the `setTimeout` triggers, the captured old data remains unaffected.

However, this issue is not intuitive, and we often access data directly via `this.props` and `this.state`, leading to frequent bugs in class components. This problem arises because object-oriented programming, inherently mutable, conflicts with React's immutable core concept, potentially disrupting data flow consistency.

Why don't function components encounter this issue?

#### Function Components Automatically Capture Render Data

Let's revisit function components. In the above example, the function component `BuyProductButton` receives props as parameters and uses them in render to generate event handlers:

```jsx
function BuyProductButton(props) {
  // Each render creates a new showSuccessAlert bound to the current props
  const showSuccessAlert = () => {
    alert(`Successfully purchased "${props.productName}"!`); 
  };

  const handleClick = () => {
    setTimeout(showSuccessAlert, 3000);
  };

  return (
    <button onClick={handleClick}>Buy</button>
  );
}
```

Notice the crucial detail: function components receive props as parameters, not attached to a mutable object like `this`. Thus, the props passed into each render are exclusive to that render and independent of other renders. When event handlers use props or state within a render, they bind to the props and state of that specific render.

In the example, each render creates a new `showSuccessAlert` event handler bound to the props of that render. Thus, even if the product is switched immediately after clicking the buy button, the `setTimeout` callback will still use the old data, unlike in class components.

This is the fundamental difference: function components automatically capture the state data used during that render!

This characteristic ensures we don't need to worry about asynchronous events causing props or other data to get mixed up between old and new renders in function components. Event handlers genuinely participate in the unidirectional data flow: "The original data is the source, and event handlers using the original data are part of the render result. When data changes, new event handlers bound to the new data are created."

This behavior also applies to `useState` state data, which we will explore further in subsequent sections on render data flow concepts.

### React Component Lifecycle and Data Flow: Understanding Rendering

Before diving into the complexities of `useEffect`, we need to revisit the essential concept of rendering in the component lifecycle.

### Each Render Has Its Own Props & State

Let's consider the following common counter example:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const handleIncrementButtonClick = () => {
    setCount(count + 1);
  };

  return (
    <div>
      <p>counter: {count}</p>
      <button onClick={handleIncrementButtonClick}>
        +1
      </button>
    </div>
  );
}
```

Notice the line `<p>counter: {count}</p>`. What does it do? Does the `count` variable "observe" state changes and automatically update? This is a common intuition for beginners learning React, but it's a mental model misunderstanding.

In this example, `count` is just a regular number variable. It is not a "data binding," "watcher," or "proxy." It is simply a regular number variable. You can understand it as follows:

```jsx
const count = 100; // The value retrieved from useState, treated as an unchanging constant

// ...
<p>counter: {count}</p>
```

So far, we've frequently mentioned the concept of render. But what exactly does "rendering a function component" mean?

The answer is quite simple: it just re-executes the function.

In this way, we can understand the above example as:

```jsx
// On the first render
function Counter() {
  const count = 0; // Retrieved from useState
  // ...
  <p>counter: {count}</p>
  // ...
}

// After clicking and calling setState, the component function is re-executed
function Counter() {
  const count = 1; // Retrieved from useState
  // ...
  <p>counter: {count}</p>
  // ...
}

// After another click and calling setState, the component function is re-executed again
function Counter() {
  const count = 2; // Retrieved from useState
  // ...
  <p>counter: {count}</p>
  // ...
}
```

The key point is that in each of these different renders, there is a variable named `count`, but in each render, they are entirely unrelated values, just having the same name within the scope.

Therefore, we can conclude that this line does not perform any special data binding or listening actions:

```jsx
<p>counter: {count}</p>
```

It simply places a regular number value into a React element as the output for our screen rendering. Combining this with the core principles we introduced in previous sections, we can explain React's render operation as follows:

- React does not listen for data changes. You must actively inform React (by calling `setState`) that the data needs updating and trigger a re-render.
- Re-rendering means re-executing the component function with the new data (props & state).

The key here is that within any given render, the value of `count` will not change over time or by calling `setState`. Instead, when `setState` is called, React re-calls the component function to re-execute a render. Each render captures its own version of the `count` value, a value that only exists as a constant within that specific render.

### Each Render Has Its Own Event Handlers

Now that we understand that each render has its own props and state, what about event handlers? In the previous section, we already touched on this concept. Let's extend this understanding with a similar example:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const handleIncrementButtonClick = () => {
    setCount(count + 1);
  };

  const handleAlertButtonClick = () => {
    setTimeout(() => {
      alert(`You clicked the alert button when the counter was ${count}`);
    }, 3000);
  };

  return (
    <div>
      <p>counter: {count}</p>
      <button onClick={handleIncrementButtonClick}>
        +1
      </button>
      <button onClick={handleAlertButtonClick}>
        Show alert
      </button>
    </div>
  );
}
```

You can try this in [this CodeSandbox](https://codesandbox.io/):

1. Increase the counter to 2.
2. Click the "Show alert" button.
3. Quickly increase the counter to 4 before the `setTimeout` callback triggers.
4. Observe the alert message.

What do you think the alert will show, 2 or 4?

Let's see the result:

![Example Result](https://i.imgur.com/vVALd02.gif)

You can see that the alert shows 2, not the latest state value of 4 when the alert pops up. This is not due to any special React magic but due to the core JavaScript feature known as closures.

As a reminder: if you are unsure or confused about the concept of closures, it is highly recommended to fully understand this core JavaScript feature before continuing with React—React's core concepts and mechanisms heavily rely on it.

We now know that "each render has its own props and state, which remain constant within that render." Therefore, when we define event handlers within the component function, these event handler functions, due to closures, "remember" the props and state they used:

```jsx
const [count, setCount] = useState(0);

const handleAlertButtonClick = () => {
  setTimeout(() => {
    // This callback will always remember the location of the count variable and can read it,
    // and within each render, count is a constant that does not change
    alert(`You clicked the alert button when the counter was ${count}`);
  }, 3000);
};

// ...
```

When the counter state value is 2, the alert button is bound to an event handler associated with "the render where the count value was 2." Due to closures, this event handler remembers the count variable as 2. Therefore, even after clicking the button to increase the counter and before the `setTimeout` callback executes, the callback still remembers the count value from "the render where the count value was 2":

```jsx
// Simulating the render where the count state value is 2

const count = 2; // Retrieved from useState

const handleAlertButtonClick = () => {
  setTimeout(() => {
    // This callback will always remember the count variable from the version where the value is 2
    alert(`You clicked the alert button when the counter was ${count}`);
  }, 3000);
};

// ...
// This is the handleAlertButtonClick where the count inside is from the version where count is 2
<button onClick={handleAlertButtonClick}>
  Show alert
</button>

// ...
```

This explains why event handlers defined within the component function "belong" to a specific render:

- Props and state between different renders are independent and do not affect each other.
- Props and state within each render remain constant, like local constants when the component function executes.
- Event handlers are a type of data derived from the original data (props & state). Extending this concept, each render has its own event handlers.

This also explains why we need to maintain and ensure the immutability of data when the state contains objects or arrays. This allows each render's state to remain independent and unaffected when the event handler uses data from an old render.

**References:**
- [A Complete Guide to useEffect - Overreacted](https://overreacted.io/a-complete-guide-to-useeffect/)