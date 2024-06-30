### Understanding the Principles Behind React Hooks

Since their introduction in early 2019, React hooks have rapidly become the mainstream choice for React development. By using function components, hooks offer significant improvements in data flow predictability and logic reusability compared to the traditional class components.

While the API for hooks is simple and easy to use, many developers still have questions: How do hooks actually work? Where is the data in `useState` stored? Why can’t hooks be written inside conditions or loops? In this chapter, we will delve into these questions to help you understand the inner workings and design philosophy of hooks.

### Fiber Nodes

Before diving into hooks themselves, we need to mention a core mechanism hidden inside React: Fiber nodes.

Have you ever wondered where the local state of a component is stored?

```jsx
function App() {
  // The count state of these two <Counter> instances is independent and doesn't affect each other
  return (
    <>
      <Counter />
      <Counter />
    </>
  );
}

function Counter() {
  // Where is this local state actually stored?
  const [count, setCount] = useState(0);
  return (
    <div>
      <h1>{count}</h1>
      <button onClick={() => setCount(count + 1)}>+1</button>
    </div>
  );
}
```

In the above example, the `<Counter>` component has a `count` state. Each time we call `setCount` to update the state, the component re-renders and retrieves the updated state value. But where is this state value actually stored? Additionally, when there are multiple `<Counter>` components in the `<App>`, their local states are independent and do not affect each other.

In React's abstraction layer, besides using React elements to describe the "UI at a specific point in time," it also creates a "state management node" for each component when it is called. This node is referred to as a fiber node in React. The structure of a fiber node looks something like this:

![Fiber Node](https://i.imgur.com/cAIzR3U.png)

You might wonder about the relationship and difference between Fiber nodes and React elements. Fiber nodes are responsible for maintaining the current state data of the React application, whereas React elements are the product of the render process, describing the UI structure at a specific point in time.

Whenever your React application initiates reconciliation, the reconciler is responsible for scheduling the component's render and updating the data changes to the fiber nodes. It also compares the React elements produced in this render with those from the previous render and hands off the real DOM updates to the renderer. Therefore, fiber nodes are the heart of a React application, storing the core application state, while React elements are disposable products used to describe the UI structure at the time of each render.

Fiber nodes have been around since the class component era, not just from the hooks era. The state declared in a class component and the state declared using function components and `useState` are both stored in fiber nodes. Additionally, queues of pending `setState` calls are also temporarily stored here.

When we render a component and call `useState`, React creates a corresponding fiber node for the component and stores the latest state data related to this `useState` hook in it:

```jsx
function App() {
  const [count, setCount] = useState(100);
  // ...
}
```

When we call `setState`, the data in this fiber node is updated. Therefore, each time our component re-renders and calls `useState`, it tries to "capture" and return the state value at that moment, ensuring the state value retrieved during each render of the function component remains constant.

### Why Hooks Are Dependent on a Fixed Call Order

After understanding the core state storage data of React through fiber nodes, let's explore the principles behind hooks. Developers familiar with hooks know there is a crucial rule: hooks can only be called at the top level of React function components, not inside conditions or loops. Why is this restriction in place?

When we call multiple `useState` hooks in a function component, it looks something like this:

```jsx
function App() {
  const [count, setCount] = useState(100);
  const [name, setName] = useState('default name');
  const [flag, setFlag] = useState(false);
  // ...
}
```

This seems like a common React code snippet. But consider this question: Did we explicitly tell React the names of these states?

You might say yes because the variables are named `count`, `name`, and `flag`. However, notice that `useState` returns an array, and we use array destructuring to rename these values. The above component code is equivalent to:

```jsx
function App() {
  const state1Returns = useState(0);
  const count = state1Returns[0];
  const setCount = state1Returns[1];

  const state2Returns = useState('');
  const name = state2Returns[0];
  const setName = state2Returns[1];

  const state3Returns = useState(false);
  const flag = state3Returns[0];
  const setFlag = state3Returns[1];
  // ...
}
```

We only provide the default values to `useState`, not any other parameters. 

So how does React distinguish between these states internally without custom names or keys? Let's look into the actual fiber node:

![Fiber Node Example](https://i.imgur.com/eECLFqG.png)

Fiber nodes store these state data in a linked list format, with each state connected to the next. This structure shows that hooks are stored based on the order of their calls. When you call multiple hooks in a component, they are sequentially linked and stored:

```jsx
function App() {
  // The first state hook in the component
  const [count, setCount] = useState(100);

  // The second state hook in the component, linked to the first state hook
  const [name, setName] = useState('default name');

  // The third state hook in the component, linked to the second state hook
  const [flag, setFlag] = useState(false);
  // ...
}
```

In the fiber node, the top level stores the first hook's state, which links to the second hook's state, and so on. This data structure means if we skip a hook call in one render, all subsequent hooks may be incorrectly aligned with the hooks from the previous render, causing errors:

```jsx
function App() {
  const [flag, setFlag] = useState(false);

  if (!flag) {
    const [foo, setFoo] = useState('foo');
  }

  const [bar, setBar] = useState('bar');
  const [fizz, setFizz] = useState('fizz');

  const handleClick = () => {
    setFlag(true);
  };
  
  return <button onClick={handleClick}>click me</button>
}
```

In this example, when the button is clicked, triggering a re-render, `const [foo, setFoo] = useState('foo');` will be skipped if `flag` is `true`, causing subsequent hooks to be misaligned with those from the previous render, resulting in an inconsistent hooks chain:

![Hooks Chain Example](https://i.imgur.com/TuOvfpu.png)

React detects the mismatch in the number of hooks called between renders and throws an error. This is why all hooks in a component must be called in the same order on every render. Skipping a hook call in one render causes all subsequent hooks to be misaligned, leading to errors in React's internal state management.

### How to Safely Skip Hooks

Sometimes, we may still want certain hooks to stop executing when not needed. Since hooks must be called in the same order in every render, the only legitimate way to stop hooks from running is to unmount the component that calls these hooks:

```jsx
function App() {
  const [isFoo, setIsFoo] = useState(true);

  return isFoo ? <Foo /> : <Bar />;
}

function Foo() {
  useEffect(() => { /* ... */ });
}
```

When `isFoo` changes from `true` to `false`, the `<Foo>` component will unmount, and the effect inside it will no longer be called during re-renders of `<App>`.

### Why React Designed Hooks with a Fixed Call Order

We now understand that hooks' state data is accessed based on the call order, and we must ensure this order is consistent to maintain the integrity of the internal state management mechanism. But a deeper question remains: Why did React design hooks to be called in order rather than using custom keys or similar methods? In the next chapter, we will delve deeper into the design philosophy and reasoning behind hooks.

### The Problems Hooks Were Created to Solve

Before diving into the design context of hooks, we need to discuss the issues hooks were created to address. First, hooks are designed to work with function components. This is because, under the strategy of rendering everything from scratch, the object-oriented design of class components had many conceptual conflicts. These include issues such as member methods in class components not participating in data flow changes, and `this.props` or `this.state` potentially containing incorrect data in asynchronous events. These topics have been covered in-depth in previous chapters of this series, so we won’t repeat them here.

To better align with core concepts like re-rendering and immutability, React decided to move towards a more functional programming approach. After introducing function components, React needed to design a new mechanism and API to address several important issues:

1. **Enabling State in Function Components**: 
   Function components allow React to render independently without interference, alleviating concerns about asynchronous events reading data from `this.props`. However, UI inherently needs to have "state," and a component might have multiple states simultaneously. The API needs to support multiple states referencing each other and avoid naming conflicts. We need a flexible API that interacts well with developers while maintaining the state in the fiber node.

2. **Reusing Logic Between Components**: 
   Reusing logic between different components has always been a crucial requirement in front-end development. However, throughout the class component era, React never provided an official API for logic reuse between components. This is because state and lifecycle methods in class components must be directly written in a component to define them. Additionally, a feature might require logic in several lifecycle methods, making it challenging to extract and share between multiple components.

   During the class component era, many community-proposed patterns attempted to solve the logic reuse issue, such as higher-order components and render props. However, these approaches had their shortcomings, like naming conflicts and opaque dependencies.

### Design Philosophy and Context of Hooks

The goal of hooks is to provide an API that can define and manage state and facilitate logic reuse, while addressing the issues encountered in previous solutions:

1. **Avoiding Naming Conflicts**: 
   Hooks should prevent naming conflicts, allowing different logic to be freely combined and called without issues.
   
2. **Transparent Dependencies**: 
   The logic being reused should be able to split, combine, and call freely, with clear dependencies.
   
3. **Avoiding Pollution of Rendered React Elements**: 
   Hooks should avoid affecting the structure of the rendered React elements.

To achieve this, the hooks API adopts the following design principles:

#### Function-Based

When we want to share logic or processes, wrapping them in components (like higher-order components) can lead to issues. For example, two components written for reusing logic might both have a `name` prop, leading to naming conflicts if applied to the same target component. Additionally, this approach restricts the flexible interaction between the two pieces of logic, as one can only override the other.

Functions provide maximum flexibility in splitting and calling logic and processes. Functions can freely design parameters and return values, making them ideal for hooks:

```jsx
function App() {
  const [page, setPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [productList, setProductList] = useState([]);
  const [productListLoading, setProductListLoading] = useState(false);

  useEffect(() => {
    let ignore = false;
    setProductListLoading(true);

    const startIndex = (page - 1) * 10;
    const endIndex = (page * 10) - 1;
    ProductAPI.queryList({ startIndex, endIndex }).then((data) => {
      if (!ignore) {
        setProductList(data);
        setProductListLoading(false);
      }
    });

    return () => {
      ignore = true;
    };
  }, [page, rowsPerPage]);

  // ...
}
```

We can extract the logic for "controlling pagination options" and "querying the product list API" into separate functions for reuse:

```jsx
function usePaginationOptions() {
  const [page, setPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  const startIndex = (page - 1) * 10;
  const endIndex = (page * 10) - 1;

  return {
    page,
    rowsPerPage,
    startIndex,
    endIndex,
    setPage,
    setRowsPerPage,
  };
}

function useProductListQuery({ startIndex, endIndex }) {
  const [productList, setProductList] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let ignore = false;
    setLoading(true);

    ProductAPI.queryList({ startIndex, endIndex }).then((data) => {
      if (!ignore) {
        setProductList(data);
        setLoading(false);
      }
    });

    return () => {
      ignore = true;
    };
  }, [startIndex, endIndex]);

  return { productList, loading };
}

function App() {
  const { startIndex, endIndex } = usePaginationOptions();
  const { productList, loading } = useProductListQuery({
    startIndex,
    endIndex,
  });

  // ...
}
```

By extracting this logic into custom hooks, we simplify the main component and enable clear data passing between these hooks. This design helps us achieve the goal of transparent dependencies between logic.

Moreover, since hooks are called during the render process, these state and logic definitions do not rely on independent components. Therefore, no matter how many hooks you call in a component, they will not pollute the rendered React element structure, enhancing the readability of our components.

### Relying on a Fixed Call Order

Defining processes and logic in the form of functions is intuitive and convenient, but defining state data is more nuanced. If a hook defining state data is called in one render but not in subsequent renders, what does that signify? Does it mean the state is no longer needed and should be removed? Should the previously stored data persist if it reappears in later renders? These are complex questions that can lead to misunderstandings.

To address this, we must ensure that all hooks in a component are called in a fixed order during each render. For more details, refer to the previous chapter's analysis.

Why are multiple hooks within the same component designed to rely on order for storage and distinction? Most people would intuitively think of defining them with unique keys:

```jsx
// ❌ Note, this is a hypothetical hooks API and not the actual API design:
// useState(stateKey, defaultValue)

const [name, setName] = useState('name', '');
const [surname, setSurname] = useState('surname', '');
const [width, setWidth] = useState('width', 0);
```

#### Naming Conflict Issues

However, this key-based design has an unavoidable issue: naming conflicts.

You cannot call `useState` with the key 'name' twice in the same component. While this might be manageable within a single component, avoiding duplicate names, it becomes problematic when considering reuse. Whenever you define a state in custom hooks, it could cause conflicts with states in components reusing that custom hook.

Relying on the call order essentially makes the hooks' keys sequential indices. As long as a hook called third in the render process remains the third hook in subsequent renders, the mechanism will function correctly.

#### The Diamond Problem

A key-based hooks design also introduces a notorious issue in programming: the diamond problem, or multiple inheritance problem. This extends the naming conflict issue. Let’s explain with an example:

In the following example, we want to define "players" and "monsters" in game data, both of which have "position coordinates." We want to reuse this logic:

```jsx
function usePosition() {
  // ❌ Note, this is a hypothetical hooks API with keys specified for the hooks
  const [x, setX] = useState('positionX', 0);
  const [y, setY] = useState('positionY', 0);

  return { x, setX, y, setY };
}

function usePlayer() {
  const position = usePosition();

  // ...other player-specific data or methods

  return { ..., position };
}

function useMonster() {
  const position = usePosition();

  // ...other monster-specific data or methods

  return { ..., position };
}

// Component
function GameApp() {
  const player = usePlayer();
  const monster = useMonster();
  // ...
}
```

In this React code, both `usePlayer` and `useMonster` custom hooks reuse the `usePosition` custom hook, which defines states `positionX` and `positionY`. When the `GameApp` component calls both `usePlayer` and `useMonster`, the diamond problem occurs:

![Diamond Problem](https://i.imgur.com/i19xkZI.png)

Calling `usePosition` twice in the same component leads to naming conflicts with the states registered as `positionX` and `positionY`. 

However, using the fixed call order for hooks naturally resolves this issue:

![Fixed Call Order](https://i.imgur.com/XkGcQxY.png)

Pure function calls do not have the diamond problem; they naturally form a tree structure. The component can distinguish and track hooks' state data by the order in which these custom hooks are called. This design allows us to say goodbye to the nightmare of naming conflicts.

### Synchronizing Data Flow with useEffect Instead of Lifecycle API

In previous chapters of this series, we extensively analyzed the concept and correct usage of `useEffect`. We mentioned a

 crucial concept: function components do not provide lifecycle APIs, only `useEffect` for "synchronizing data to effects."

Here, we want to explore why React made this design decision for hooks. What issues did the lifecycle API in class components have?

Firstly, most side effects executed in components aim to synchronize certain data within React with external factors. For example, a common scenario is requesting data from a server based on some parameters and then retrieving the data. These synchronization and data retrieval actions usually require cleanup or reversal when they are no longer running:

```jsx
componentDidMount() {
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

componentWillUnmount() {
  OrderAPI.unsubscribeStatus(this.props.id, this.handleStatusChange);
}
```

In this class component example, the component subscribes to the order status using `props.id` in `componentDidMount` and unsubscribes in `componentWillUnmount`. It seems to work well.

However, if the component re-renders with a new `props.id`, it will not automatically resubscribe to the new order status data or correctly unsubscribe from the original order status. This can lead to memory leaks and other issues. Forgetting to handle `componentDidUpdate` is a common source of bugs in class components.

```jsx
componentDidMount() {
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

// Adding componentDidUpdate to fix the bug
componentDidUpdate(prevProps) {
  // Unsubscribe from the previous order ID
  OrderAPI.unsubscribeStatus(prevProps.id, this.handleStatusChange);

  // Subscribe to the new order ID
  OrderAPI.subscribeStatus(this.props.id, this.handleStatusChange);
}

componentWillUnmount() {
  OrderAPI.unsubscribeStatus(this.props.id, this.handleStatusChange);
}
```

The lifecycle API in class components subtly encourages developers to think of "didMount," "didUpdate," and "willUnmount" as separate scenarios. We must consider which actions to take in which lifecycle methods to achieve the "subscribe to order status based on `this.props.id`" synchronization effect. Any missed scenario results in a buggy component. As applications grow, it's challenging for developers to avoid mistakes, placing high demands on meticulousness and thoroughness.

Moreover, the lifecycle API code in class components is hard to extract and reuse across components. Imagine if two reusable features both needed logic in `componentDidMount`, `componentDidUpdate`, and `componentWillUnmount`. Combining these features in one component would likely cause conflicts and break each other.

In contrast, similar logic in function components requires just one `useEffect` to handle. Describing the synchronization logic and the cleanup for the side effects covers mount, update, and unmount scenarios. Additionally, since it's a function, we can easily extract it into a custom hook for reuse without lifecycle API conflicts:

```jsx
function useOrderStatusSubscribe() {
  useEffect(() => {
    OrderAPI.subscribeStatus(props.id, handleChange);
    return () => {
      OrderAPI.unsubscribeStatus(props.id, handleChange);
    };
  });
}
```

This API design emphasizes "synchronization results" rather than "execution details or timing," allowing us to enjoy the benefits of a declarative style even when dealing with side effects. Developers can focus more on the business logic itself rather than the component's internal lifecycle.

### Conclusion

Hooks were designed to address issues in class components and improve the React development experience. By leveraging function components and hooks, React allows for predictable data flow, logic reuse, and simplified component structures. Understanding the design principles and the rationale behind hooks helps us appreciate their power and use them more effectively in our applications.