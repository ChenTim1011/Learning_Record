### Common Misuses of Dependencies

In the previous chapters, we have thoroughly analyzed the correct concepts and usage of `useEffect`, repeatedly emphasizing that `useEffect` is for synchronizing data to effects outside of React elements, and that dependencies are a form of performance optimization to "skip unnecessary executions."

The dependencies of `useEffect` as a performance optimization do not guarantee logical control. Effects may re-execute unexpectedly. Therefore, being honest with dependencies is not just a best practice but essential because if you try to go against it, future versions of React might break your effects, causing unexpected behavior in your application. Let’s dive deeper into this issue, starting with changes in `useEffect` behavior in React 18.

### React 18: `useEffect` Executes Twice on Mount?

You might think that if you set the dependencies to `[]`, the effect will never re-execute during the lifecycle:

```jsx
function App() {
  const [count, setCount] = useState(0);
 
  useEffect(() => {
    console.log('effect start'); 
    setCount((prevCount) => prevCount + 1);
    
    return () => {
      console.log('effect cleanup');
    }
  }, []); // This effect might run twice on mount in React 18
 
  return <div>{count}</div>;
}
```

However, in React 18, this effect might execute twice on mount in development mode with strict mode enabled. You can try it yourself in this [CodeSanbox](https://codesandbox.io/). This is a breaking change introduced in React 18, but it only occurs in development builds with strict mode enabled. When strict mode is not enabled, or when running a production build of React, this behavior does not occur:

```jsx
import { StrictMode } from 'react';
import ReactDOM from "react-dom/client";
import App from './App';

const root = ReactDOM.createRoot(document.getElementById("root-container"));
root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
```

### Why This Change in React 18?

You might find it strange that the effect execution count differs between development and production. The primary purpose of this change is to help developers "check for unsafe effect behaviors." To explain why this strict check is necessary, we need to introduce a new concept planned for future versions of React: Reusable State.

### Reusable State

In future versions of React, many new features will require developers' components to be designed with enough flexibility to handle multiple mounts and unmounts without breaking. In most cases, our components' declarative part is straightforward. However, if a component's effect breaks under repeated execution, it will not meet this requirement.

One commonly used feature relying on this flexibility is Fast Refresh, often known by its predecessor name, Hot Module Replacement. This feature is prevalent in React development environments like Create React App or Next.js. It allows your browser to apply changes to your React components in real-time without a full page refresh whenever you save a file. This process involves unmounting your component and immediately remounting it with the updated code while preserving the component's state.

Future features like the Offscreen API will require this kind of flexibility. The Offscreen API allows React to retain the state and real DOM elements of components during UI transitions, temporarily hiding them instead of removing them. When these components need to be displayed again, React can remount them with the preserved state, improving performance during frequent UI transitions.

This ability to preserve a component's state for future remounts is known as reusable state. Consequently, future versions of React may cause components to "mount and unmount multiple times within their lifecycle."

Given the prevalence of unsafe effect design since the introduction of hooks, React 18's strict mode now simulates the "mount ⇒ unmount ⇒ mount" process to help developers check if their components' effects can handle repeated execution.

If your React project contains effects that lack this flexibility, consider temporarily disabling strict mode after upgrading to React 18 to avoid development issues. However, to take full advantage of new features and benefits, we should start designing effects and cleanups in safer, more reliable ways, gradually adjusting the project's effects for better flexibility.

### Shifting the Thought Process

This shift in mindset is challenging, but once you internalize these concepts, you'll be able to create intuitive and reliable code in practice. In the next chapter, the final one on `useEffect`, we'll introduce and share design techniques for effects and cleanups in common scenarios, helping you handle practical applications more effectively and design components with the required flexibility and reliability.

---

### Designing Robust Effects and Cleanups

In the previous chapters, we emphasized the importance of designing effects to function correctly even when executed multiple times. If you are not familiar with this concept, I strongly recommend reading the earlier sections of this series for a deep dive into `useEffect`. In this final chapter on the `useEffect` topic, we will introduce and share some common scenarios and design techniques for effects and cleanups, helping you navigate practical applications more effectively.

The ideal design for effects is declarative and reversible. Here are some common effect design issues:

- **Cumulative Operations vs. Overwriting Operations:** When the impact of an effect accumulates with each execution rather than being overwritten, not designing an appropriate cleanup to cancel or reverse these effects can lead to unexpected results.
- **Race Conditions:** When effects involve asynchronous operations, multiple executions of the effect might lead to a race condition where the order of execution does not match the order of responses from asynchronous events.
- **Memory Leaks:** If your effect initiates persistent listeners or subscriptions without handling their corresponding unsubscriptions, it might continue to operate even after the component unmounts, causing a memory leak.

Generally, these issues can be resolved by implementing a cleanup function for the effect. Cleanups should stop or reverse the impact of the effects, ensuring that your effects function correctly even when executed multiple times and preventing memory leaks.

### Fetch API

Calling `fetch` to request a backend API is perhaps the most common effect encountered in practice:

```jsx
useEffect(() => {
  async function startFetching() {
    const json = await fetchTodos(userId);
    setTodos(json);
  }

  startFetching();
}, [userId]);
```

In this example, the dependencies are honest. When `userId` changes during re-render, the effect re-executes correctly. However, since `fetchTodos` is asynchronous, if the effect executes consecutively, the results of the first execution might return later than the results of the subsequent execution, leading to a race condition. Here’s a potential scenario:

```jsx
// First render with userId 1, effect starts fetchTodos
fetchTodos(1);

// Second render with userId 2, triggering the effect again
fetchTodos(2);

// After some time, fetchTodos(2) completes first and sets todos
setTodos([ /* ...todos for userId 2 */ ]);

// Then fetchTodos(1) completes and incorrectly overwrites the state
setTodos([ /* ...todos for userId 1 */ ]);
```

To handle race conditions in fetch requests, you can use an abort controller or a simple flag to ignore outdated results:

```jsx
useEffect(() => {
  let ignore = false;

  async function startFetching() {
    const json = await fetchTodos(userId);
    if (!ignore) {
      setTodos(json);
    }
  }

  startFetching();

  return () => {
    ignore = true;
  };
}, [userId]);
```

The principle here is simple: each render's effect remembers whether it should ignore the fetch result through a flag. The flag `ignore` defaults to `false` at the beginning of each effect execution. However, before the effect re-executes in the next render, the previous effect’s cleanup sets `ignore` to `true`. Thus, even if an earlier fetch returns later, it will not execute `setTodos`:

```jsx
// First render with userId 1, effect starts fetchTodos
ignore = false;
fetchTodos(1);

// Second render with userId 2, first effect’s cleanup runs before the new effect
ignore = true; // for the first render’s effect
ignore = false; // for the second render’s effect
fetchTodos(2);

// fetchTodos(2) completes and sets todos correctly
setTodos([ /* ...todos for userId 2 */ ]);

// fetchTodos(1) completes but does nothing since ignore is true
```

This cleanup will also run on unmount, preventing the fetch from attempting to update state after the component has unmounted, avoiding memory leaks.

### Third-Party Solutions

For handling API requests in practice, it is recommended to use mainstream third-party libraries. These popular libraries typically handle race conditions, caching mechanisms, and performance optimizations:

- **React Query**
- **SWR**
- **React Apollo**

### Controlling External Plugins

Sometimes, we use external libraries that are not based on React, such as integrating with a third-party map API:

```jsx
useEffect(() => {
  if (!mapRef.current) {
    mapRef.current = new FooMap();
  }
}, []);
```

In this example, the effect is fine to execute multiple times since it initializes the map only once. However, a better approach is to initialize the map at the top level of the React app or even outside React to ensure it only runs once in the entire app, avoiding multiple `FooMap` instances. Minimizing repeated initialization of third-party libraries is a best practice.

In the following example, the effect synchronizes the map's zoom level. It’s safe to execute this effect multiple times:

```jsx
useEffect(() => {
  const map = mapRef.current;
  map.setZoomLevel(zoomLevel);
}, [zoomLevel]);
```

If frequent changes to `zoomLevel` cause performance issues, consider adding throttling to

 optimize it.

Here’s another example where the effect controls an external library. If the operation is not reversible, you should execute cleanup to reverse the effect's impact:

```jsx
useEffect(() => {
  const dialog = dialogRef.current;
  dialog.showModal();
  return () => dialog.close();
}, []);
```

### Listening to Events or Subscriptions

Subscribing to DOM or custom events is another common effect scenario:

```jsx
useEffect(() => {
  window.addEventListener('scroll', (e) => {
    console.log(e.clientX, e.clientY);
  });

  // ❌ This should implement corresponding cleanup to remove event listeners
}, []);
```

If we do not handle unsubscriptions in cleanups, the subscription will continue to run after the component unmounts, causing a memory leak.

```jsx
useEffect(() => {
  function handleScroll(e) {
    console.log(e.clientX, e.clientY);
  }

  window.addEventListener('scroll', handleScroll);

  // ✅ Cleanup handles event unsubscription
  return () => {
    window.removeEventListener('scroll', handleScroll);
  };
}, []);
```

The same applies to `setTimeout` and `setInterval`. If you do not handle unregistering in cleanups, it may cause memory leaks by attempting to execute callbacks after the component unmounts.

```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount((prevCount) => prevCount + 1);
    }, 1000);
    
    // ✅ Cleanup handles interval unregistration
    return () => clearInterval(id);
  }, []);
}
```

### User-Initiated Actions

Sometimes, even if you write cleanup, you can't reverse the impact of an effect, such as making an API call to notify the backend of a purchase. This effect affects the server or database, which cannot be reversed through cleanup. The real problem here is that user actions should not be placed in effects that execute multiple times with renders:

```jsx
useEffect(() => {
  // ❌ This request will be sent twice in React 18's strict mode + dev env
  // It should be triggered by user actions, not by auto-executing effects
  fetch('/api/buy', { method: 'POST' });
}, []);
```

Instead, place it in a user-triggered event, like clicking a "purchase" button:

```jsx
function handleClick() {
  // ✅ User-initiated action triggers the purchase request
  fetch('/api/buy', { method: 'POST' });
}
```

### Summary of `useEffect`

Throughout this series, we have extensively analyzed `useEffect`'s core design concepts and correct usage from various angles. Here are the key takeaways:

- **Purpose of `useEffect`:** Function components do not have lifecycle APIs. `useEffect` is for synchronizing effects outside of React elements based on the current data.
- **Declarative and Reversible:** `useEffect` allows you to synchronize things outside React elements based on current data.
- **Automatic Execution:** `useEffect` is triggered automatically after each render.
- **Performance Optimization:** Dependencies are for performance optimization, not for controlling effect execution based on component lifecycle or business logic timing.
- **Honesty in Dependencies:** Always write conditions within the effect to handle business logic execution. Do not rely on dependencies to control this.
- **Designed for Repeated Execution:** Ensure your `useEffect` works correctly even when executed multiple times.
- **React 18 and Strict Mode:** Components will be mounted twice during their lifecycle in strict mode + dev build to simulate "mount => unmount => mount," helping developers check the flexibility of effect design.
- **Cleanup Functions:** If repeated effect execution causes issues, implement cleanup functions to stop or reverse the effect’s impact. If you want the business logic to execute only under certain conditions, use flags to handle conditional filtering.

With these key points in mind, you can design robust, reliable, and flexible effects in your React applications.