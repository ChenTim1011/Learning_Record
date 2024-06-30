### Understanding `setState` and Re-rendering in React

In previous sections, we've learned that calling the `setState` method triggers a re-render of the corresponding component defined by the state. But what happens if we call `setState` again after already calling it once? In this section, we will further analyze some characteristics of the `setState` method and the re-rendering mechanism.

### What is Batch Update?

When we call the `setState` method, it triggers a re-render of the component. However, this re-rendering does not happen immediately. This means that when the line `setState(newValue)` is executed and the next line begins, the re-render has not actually started yet. In the following example, we try calling `setState` multiple times in the same event handler, but you will find that it only triggers a re-render once:

```jsx
import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    setCount(1);
    // At this point, the re-render hasn't started yet

    setCount(2);
    // At this point, the re-render hasn't started yet

    setCount(2);
    // Now, with no more code to execute in this event, the re-render starts
  };

  // ...
}
```

**Explanation:**

React waits until all code in the current event is finished before starting the re-render. This is why in the above example, the component only starts re-rendering after all `setState` calls in `handleButtonClick` are completed. Each `setState` call adds an update to a queue, and React batches these updates to calculate the final state and perform a single re-render.

This is similar to editing a blog post draft where you can make multiple changes without them taking effect immediately. Only when you finally hit 'submit' will the post update with all the changes at once.

For instance, in the following example, calling `setState` with different values multiple times in succession will help you understand this concept better:

```jsx
import { useState } from 'react';

export default function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    setCount(1); // Adds "replace with 1" to the queue
    setCount(2); // Adds "replace with 2" to the queue
    setCount(3); // Adds "replace with 3" to the queue

    // At this point, the event callback is done, and React will start re-rendering,
    // calculating the final count state: initial value => 1 => 2 => 3
    // Hence, the final state of count will be updated to 3.
  };

  // ...
}
```

**Explanation:**

In the above example, when you first click the button, the `count` state will not update to 1, 2, and 3 in separate re-renders. Instead, React will update the state to 3 directly in a single re-render:

![Batch Update Example](https://i.imgur.com/U2Jp5VG.png)

This mechanism of batching state updates in a single event to reduce unnecessary re-renders and improve performance is called "batch update" or "automatic batching."

### Additional Notes: Batch Update Supports Mixed State Updates

It's important to note that automatic batching isn't limited to consecutive calls of the same state. It supports mixed calls to `setState` for different states within the same event.

For example, in the following scenario, the component has both `count` and `name` states. We call their `setState` methods in a mixed and consecutive manner:

```jsx
function App() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('Zet');

  const handleClick = () => {
    setCount(1);
    setName('Foo');
    setName('Bar');
    setCount(2);
    setCount(3);

    // The above mixed and consecutive calls to `setState` will result in a single re-render:
    // `count` will be updated to 3, and `name` will be updated to 'Bar'.
  };

  // ...
}
```

### React 18 and Comprehensive Support for Automatic Batching

In versions of React prior to 18 (React ≤ 17), batch updates were only supported in synchronous React events. If `setState` was called multiple times in asynchronous events, multiple re-renders would still occur:

```jsx
// React version ≤ 17

setTimeout(() => {
  setCount(1);
  setCount(2);
  setCount(3);

  // This will trigger three re-renders, one for each `setState` call,
  // as automatic batching is not supported in asynchronous contexts.
}, 1000);
```

**Explanation:**

Other situations, such as calling `setState` in `promise.then()` callbacks or native DOM event callbacks, also did not support automatic batching in React ≤ 17.

However, from React 18 onwards, React fully supports automatic batching for all scenarios:

```jsx
// React version ≥ 18

setTimeout(() => {
  setCount(1);
  setCount(2);
  setCount(3);

  // React will update the count state to 3 and perform only one re-render.
}, 1000);
```

**Explanation:**

You can safely call `setState` multiple times in any context, and React will automatically support batching.

### What if I Don't Want Batch Update: `flushSync()`

In most cases, automatic batching is safe and behaves as expected for your React app. When you call `setState` multiple times within an event callback due to some business logic, you typically don't care about the intermediate states but only about the final result. React's default behavior is to batch the `setState` calls and perform a single re-render to update the UI.

However, in some special cases, you may want to trigger a re-render immediately after a `setState` call to observe the real DOM result. React 18 provides a new API called `flushSync()` for these scenarios:

```jsx
// React version ≥ 18
import { flushSync } from 'react-dom'; // Note: Import from 'react-dom', not 'react'

function App() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('Zet');

  const handleClick = () => {
    flushSync(() => {
      setCount(1);

      // This triggers a re-render for the `setCount(1)` call
    });

    // At this point, React has finished updating the count state and re-rendering the DOM.

    flushSync(() => {
      setName('Foo');

      // This triggers another re-render for the `setName('Foo')` call
    });

    // At this point, React has finished updating the name state and re-rendering the DOM.
  };

  // ...
}
```

**Explanation:**

Even though `flushSync` ensures that the re-render has completed, reading the state value immediately after a `flushSync` call within the same event will still yield the original value. This is because the current event is based on the state of the initial render, and state values remain constant within a single render cycle:

```jsx
import { flushSync } from 'react-dom';

function App() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('Zet');

  const handleClick = () => {
    flushSync(() => {
      setCount(1);

      // This triggers a re-render for the `setCount(1)` call
    });

    // At this point, React has finished updating the count state and re-rendering the DOM.

    // On the first click, reading `count` here will still return 0,
    // because the current handleClick event is based on the initial render where count was 0.
    console.log(count); // 0
  };

  // ...
}
```

**Explanation:**

This means you will only get the updated state values in the next render cycle. We will delve deeper into this concept of data flow in renders in subsequent sections.

### Handling Consecutive `setState` Calls in React

In the previous section, we thoroughly analyzed the automatic batching mechanism when calling `setState` consecutively. Building on that, let's explore a scenario where we want to calculate a new state value based on the existing state and then call `setState` consecutively.

Let's look at the following example. This example attempts to increment the current count value three times each time the button is clicked. You might expect that when the button is clicked for the first time, the counter will increment from its default value of 0 by 1 three times, resulting in an updated value of 3:

```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    setCount(count + 1);
    setCount(count + 1);
    setCount(count + 1);
  };

  return (
    <>
      <h1>{count}</h1>
      <button onClick={handleButtonClick}>+3</button>
    </>
  );
}
```

**Explanation:**

However, in practice, the result is not what you might expect. Instead of updating the count to 3, it only increments by 1, resulting in a count of 1:

![Example](https://i.imgur.com/U2Jp5VG.png)

This happens because each render has its own version of the state value. The state value within a single render is fixed and does not change. Therefore, you can think of the count variable in the Counter component as a constant with a value of 0 when it first renders:

```jsx
function Counter() {
  // This code illustrates the render process when the count state is 0
  const count = 0; // The state value retrieved from useState

  const handleButtonClick = () => {
    // Due to the closure, the count variable in this function scope will always be 0

    setCount(count + 1);
    setCount(count + 1);
    setCount(count + 1);
  };

  // ...
}
```

**Explanation:**

As shown, when we first execute `handleButtonClick`, the value of count is 0. Due to the closure, the count variable within this function scope will always be 0.

When the first `setCount(count + 1)` is called, the `handleButtonClick` function continues to execute within the same render's closure. Hence, the count variable in this scope remains 0. Therefore, these three `setCount` calls are equivalent to calling `setCount(0 + 1)` three times:

```jsx
function Counter() {
  // This code illustrates the render process when the count state is 0
  const count = 0; // The state value retrieved from useState

  const handleButtonClick = () => {
    // Due to the closure, the count variable in this function scope will always be 0

    // The first call adds "replace with 1" to the queue
    setCount(0 + 1);
    
    // The second call adds "replace with 1" to the queue
    setCount(0 + 1);
    
    // The third call adds "replace with 1" to the queue
    setCount(0 + 1);
    
    // The final state update will be 1 after re-render
  };

  // ...
}
```

**Explanation:**

As shown above, each `setState` call executes correctly, but they all effectively execute `setCount(0 + 1)`. Therefore, the final state update will be 1.

To handle this correctly, we can use an updater function when calling `setState`.

### Using Updater Function for `setState`

The `setState` method provided by `useState` can accept an updater function as a parameter instead of directly passing the new value:

```jsx
setCount((prevValue) => prevValue + 1);
```

**Explanation:**

The updater function `(prevValue) => prevValue + 1` is a custom function called the updater function. It takes the previous state value as a parameter and returns a new state value. This means that you are telling React to update the state based on the current state, rather than directly replacing it with a new value.

When calling `setState` with an updater function, the updater function is added to the state update queue. Instead of recording a new value, React records the updater function itself. For clarity, we'll use the variable `n` to denote the parameter passed to the updater function:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    // The first call adds "n => n + 1" to the queue
    setCount((n) => n + 1);
    
    // The second call adds "n => n + 1" to the queue
    setCount((n) => n + 1);
    
    // The third call adds "n => n + 1" to the queue
    setCount((n) => n + 1);
    
    // Once the event callback finishes, React performs a single re-render,
    // calculating the state update queue:
    // initial value => "n => n + 1" => "n => n + 1" => "n => n + 1"
  };

  // ...
}
```

**Explanation:**

![Updater Function](https://i.imgur.com/RKWqWq8.png)

When the first updater function is executed, the current render's state value is passed as the parameter `n`. The result of this computation becomes the parameter `n` for the next updater function in the queue.

For example, when the `count` state is 0, 0 is passed to the first updater function `n => n + 1`, resulting in 1. This result (1) is then passed to the next updater function, and so on:

![Updater Function Execution](https://i.imgur.com/LZhT1XV.png)

This way, we can perform consecutive state updates correctly using updater functions.

### Combining Replacement and Updater Function Calls to `setState`

What happens if we mix calls to `setState` with direct replacement values and updater functions? Consider the following example:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    // The first call adds "replace with count + 3" to the queue
    setCount(count + 3);
    
    // The second call adds "n => n + 5" to the queue
    setCount((n) => n + 5);
    
    // Once the event callback finishes, React performs a single re-render,
    // calculating the state update queue:
    // initial value => "replace with count + 3" => "n => n + 5"
  };

  // ...
}
```

**Explanation:**

The result of "replace with count + 3" is passed as the parameter `n` to the next updater function. Using the initial `count` state of 0 as an example:

![Combining Calls](https://i.imgur.com/mgwFCTH.png)

If you have a direct replacement after an updater function, it will override the previous results:

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  const handleButtonClick = () => {
    // The first call adds "replace with count + 3" to the queue
    setCount(count + 3);
    
    // The second call adds "n => n + 5" to the queue
    setCount((n) => n + 5);
    
    // The third call adds "replace with 100" to the queue
    setCount(100);
    
    // Once the event callback finishes, React performs a single re-render,
    // calculating the state update queue:
    // initial value => "replace with count + 3" => "n => n + 5" => "replace with 100"
  };

  // ...
}
```

**Explanation:**

Using the initial `count` state of 0 as an example:

![Combining Calls Override](https://i.imgur.com/7KOC2Xx.png)

As shown in the flowchart, although the first two operations result in 8, the third operation "replace with 100" directly overrides the result to 100.