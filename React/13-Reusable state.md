### Common Misuses of Dependencies

In previous chapters, we have thoroughly analyzed the correct concept and usage of `useEffect`, repeatedly emphasizing that `useEffect` is for synchronizing data to effects outside of React elements, and that dependencies are a form of performance optimization to "skip unnecessary executions."

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

However, in React 18, this effect might execute twice on mount in development mode with strict mode enabled. You can try it yourself in this CodeSandbox. This is a breaking change introduced in React 18, but it only occurs in development builds with strict mode enabled. When strict mode is not enabled, or when running a production build of React, this behavior does not occur:

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