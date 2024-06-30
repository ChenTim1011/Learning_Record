### Understanding JSX in React

We've thoroughly explored the core concepts and methods related to React elements. However, if you look at the code of most React projects, you'll notice that `React.createElement()` is rarely used. Instead, you'll often see a syntax called JSX.

JSX looks a lot like HTML tags, and many React tutorials or courses may claim that "JSX is HTML in JavaScript." However, this statement is quite misleading. This misconception can lead many React beginners to believe that JSX is some kind of React-specific "black magic," making it a technical enigma—they see its appearance but have no idea about its essence.

Let's dive into the essence of JSX syntax from scratch and understand how to use it effectively.

### JSX Syntax Sugar

Let's return to React elements. Although the `React.createElement()` method allows us to create React elements conveniently and clearly specify the desired DOM tree structure, it's still quite different from the experience of writing HTML tags.

React provides a syntax called "JSX," which lets us define the structure of React elements in a way that feels similar to writing HTML. When developing, we write JSX, and specialized tools automatically convert it into `React.createElement()` syntax.

Let's look at an example to see the practical effect:

```jsx
// Defining a React element using the React.createElement() method
const reactElement = React.createElement(
  'div',
  { id: 'wrapper', className: 'foo' },
  React.createElement(
    'ul',
    { id: 'list-01' },
    React.createElement('li', { className: 'list-item' }, 'item 1'), // Third parameter as child element
    React.createElement('li', { className: 'list-item' }, 'item 2'), // Fourth parameter as second child
    React.createElement('li', { className: 'list-item' }, 'item 3')  // Fifth parameter as third child
  ),
  React.createElement(
    'button',
    { id: 'button1' },
    'I am a button'
  )
);

// Defining a React element using JSX syntax
const reactElementWithJSX = (
  <div id="wrapper" className="foo">
    <ul id="list-01">
      <li className="list-item">item 1</li>
      <li className="list-item">item 2</li>
      <li className="list-item">item 3</li>
    </ul>
    <button id="button1">I am a button</button>
  </div>
);

```

In the above example, the JSX syntax in `reactElementWithJSX` returns a React element, and this React element is exactly the same as the one created with `React.createElement()`. After automatic conversion by development tools, the JSX syntax becomes the `React.createElement()` syntax without any differences. Therefore, writing JSX is essentially writing `React.createElement()`.

You could develop a React app entirely without JSX, using only `React.createElement()`. However, defining the UI tree structure with JSX is more concise and similar to the familiar HTML syntax. For better readability and development experience, we recommend using JSX to define React elements most of the time. Of course, remember the differences between React element props and HTML syntax, such as `class` becoming `className`.

### JSX is a Syntactic Sugar for React.createElement(), Not HTML in JavaScript!

So, the essence of JSX is simply calls to `React.createElement()`. It looks like HTML because it’s designed to mimic the writing and development experience of HTML, but it's fundamentally different from HTML!

For example, your component function returns JSX, which means it returns a React element:

```jsx
function HelloWorld(props) {
  return (
    <div>
      <h1>Hello world!</h1>
      <h2>My name is {props.name}</h2>
    </div>
  );
}

// Translated JSX:
function HelloWorld(props) {
  return React.createElement(
    'div',
    null,
    React.createElement('h1', null, 'Hello world!'),
    React.createElement('h2', null, 'My name is ', props.name)
  );
}

```

Therefore, when you see a piece of JSX, it’s expressing a "value." This value isn't an HTML string or a real DOM element, but the return value of calling `React.createElement()`, which is a React element.

### How Does JSX Work in JavaScript Engines?

When we write JSX, it won't run directly in a JavaScript runtime environment because JSX syntax is not valid JavaScript. We need to convert it to `React.createElement()` syntax before execution, which can be done using tools like Babel.

### Babel & JSX Transformer

Babel is a widely used source code transpiler in the JavaScript community. It can convert JavaScript code into another form of JavaScript code, with fully customizable transformation logic through various Babel plugins or custom plugins.

Babel's uses in JavaScript include:

- Converting newer ES syntax to older equivalent syntax to support older browsers.
    - For example, converting arrow functions to traditional anonymous function definitions:
    
    ```jsx
    // Babel input: ES6 arrow function
    [1, 2, 3].map(n => n + 1);
    
    // Babel output: ES5 equivalent
    [1, 2, 3].map(function(n) {
      return n + 1;
    });
    
    ```
    
- Performing custom syntax transformations, such as JSX to `React.createElement()` conversion.
    - Related Babel plugin: [babel-plugin-transform-react-jsx](https://babeljs.io/docs/en/babel-plugin-transform-react-jsx#react-classic-runtime)

For more details on using Babel, refer to the resources provided in the earlier parts of this series. Examples in CodeSandbox already have the relevant development environment set up, allowing you to use JSX syntax directly.

You can also try JSX transformation effects in Babel's real-time conversion playground: [Babel REPL](https://babeljs.io/repl).

### Why Import React in Files Using JSX?

In React projects prior to version 17 (≤ 16), you might encounter errors if you don’t include `import React from 'react'` in files using JSX. This is because the Babel JSX transformer would explicitly convert JSX to `React.createElement()`, assuming the `React` variable is present in the scope:

```jsx
// Babel input file
import React from 'react';

const reactElement = <button id="button1">I am a button</button>;

// Babel output file
import React from 'react';

const reactElement = React.createElement(
  'button',
  { id: 'button1' },
  'I am a button'
);

```

If you don’t import React, the runtime will throw an error due to the missing `React` variable.

Starting with React 17, a new JSX transformer supported by React and Babel eliminates the need for these imports. Details can be found in the [official blog post](https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html).

Since this series targets React version 18 and above, we will omit such imports in future examples.

### The Essential Rules and Characteristics of JSX in React

To ensure the correct conversion by transpilers, JSX syntax has some important rules that must be followed. Many people might have heard of these rules but don't fully understand why they exist. In this chapter, we'll explain these rules in detail and the reasons behind them.

### Strict Tag Closure

Unlike HTML, JSX requires strict tag closure. Even elements that are self-closing in HTML must have corresponding closing tags in JSX:

```html
<!-- In HTML, <img> and <input> can be self-closing -->
<img src="./image.jpg" class="foo-image">
<input type="text" name="email">
```

```jsx
// In JSX, all elements must have closing tags, even if they have no children
<img src="./image.jpg" className="foo-image"></img>
<input type="text" name="email"></input>

// Or use self-closing tags
<img src="./image.jpg" className="foo-image" />
<input type="text" name="email" />
```
**Explanation:**

When a tag is not properly closed, the JSX transformer can't parse where the React element ends, resulting in conversion failure due to the missing closing tag.

### Expressions in JSX

JSX allows us to use HTML-like syntax to define React elements, but since it is not a pure string like HTML, we need to use `{}` to embed expressions in JSX:

```jsx
const listId = 'list-01';
const listItems = ['item 1', 'item 2', 'item 3'];

const reactElement = React.createElement(
  'ul',
  { id: listId, className: 'foo' },
  listItems.map(item => (
    React.createElement(
      'li',
      { className: 'list-item' },
      `I am ${item}`
    )
  )),
);

const reactElementWithJSX = (
  <ul id={listId} className="foo">
    {listItems.map(item => (
      <li className="list-item">
        I am {item}
      </li>
    ))}
  </ul>
);
```
**Explanation:**

The two React elements above are equivalent. If a property's value is a static string, it can be enclosed in double quotes like in HTML, e.g., `className="foo"`. For other types or expressions, use `{}` to embed JavaScript expressions.

Similarly, children can be static strings or React elements directly written between opening and closing tags. If they are expressions, they need to be enclosed in `{}`.

### Rendering Logic

Since React elements are ordinary JavaScript objects, we don't need special template instructions for conditional rendering or loops. We can simply use regular JavaScript logic:

```jsx
const items = ['a', 'b', 'c'];
let childElement;
if (items.length >= 1) {
  childElement = <img src="./image.jpg" />;
} else {
  childElement = <input type="text" name="email" />;
}

const appElement = (
  <div>
    {items.map(item => <span>{item}</span>)}
    {childElement}
  </div>
);
```
**Explanation:**

Once you understand that JSX is essentially a call to `React.createElement()`, you can mentally translate the above code to:

```jsx
const items = ['a', 'b', 'c'];
let childElement;

if (items.length >= 1) {
  childElement = React.createElement('img', { src: './image.jpg' });
} else {
  childElement = React.createElement('input', { type: 'text', name: 'email' });
}

const appElement = React.createElement(
  'div',
  null,
  items.map(item => React.createElement('span', null, item)),
  childElement
);
```
It's just regular JavaScript logic manipulating ordinary JavaScript objects—no "black magic" here.

In practice, we often use `&&` or ternary operators for conditional rendering in JSX. For more on this, refer to the [official documentation on Conditional Rendering](https://reactjs.org/docs/conditional-rendering.html).

### Why JSX Must Have One Root Element

When your JSX has multiple top-level React elements, you might encounter an issue:

```jsx
function Foo() {
  // The following JSX is invalid ❌
  return (
    <button>foo</button>
    <div>bar</div>
  );
}
```
**Explanation:**

The above JSX will fail to transpile because a JSX expression must have one parent element. It can only return a single React element. The solution is to wrap the multiple elements in a single parent element:

```jsx
function Foo() {
  // The following JSX is valid ✅
  return (
    <div>
      <button>foo</button>
      <div>bar</div>
    </div>
  );
}

// After JSX transpilation:
function Foo() {
  return React.createElement('div', null,
    React.createElement('button', null, 'foo'),
    React.createElement('div', null, 'bar')
  );
}
```
**Explanation:**

The React element has only one parent element containing the other elements as children.

However, this solution can introduce unnecessary DOM elements. If you don’t want an extra `<div>`, React provides a solution with the `Fragment` component:

```jsx
import { Fragment } from 'react';

function Foo() {
  return (
    <Fragment>
      <button>foo</button>
      <div>bar</div>
    </Fragment>
  );
}
```
**Explanation:**

`Fragment` is a special React component that allows grouping of elements without adding extra nodes to the DOM. It's like a "ghost" container.

You can also use a shorthand syntax for fragments:

```jsx
function Foo() {
  return (
    <>
      <button>foo</button>
      <div>bar</div>
    </>
  );
}
```

### JSX and Components

React elements can describe both DOM elements and user-defined components:

```jsx
const element = <div id="foo" />;

// This JSX gets transpiled to:
const element = React.createElement('div', { id: 'foo' });
```

```jsx
// JSX for a user-defined component
const element = <Welcome name="Zet" />;

// This JSX gets transpiled to:
const element = React.createElement(Welcome, { name: 'Zet' });
```
**Explanation:**

When the first parameter of `React.createElement()` is a function, React treats it as a component and passes the props.

For example, this code will render "Hello, Zet" on the page:

```jsx
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

const element = <Welcome name="Zet" />;

const root = ReactDOM.createRoot(document.getElementById('root-container'));
root.render(element);
```
**Explanation:**

Here's what happens in this example:

1. We call `root.render()` with the React element `<Welcome name="Zet" />`.
2. React calls the `Welcome` component with `{ name: 'Zet' }` as the props.
3. The `Welcome` component returns a React element `<h1>Hello, Zet</h1>`.
4. React DOM updates the real DOM tree within the root to match the React element.

### Why Component Names Must Start with an Uppercase Letter

React elements can be categorized into several types:

- DOM elements: The first parameter of `React.createElement()` is a string representing the element name (e.g., 'div', 'button').
- User-defined components: The first parameter is a function representing the component.
- Special types like `Fragment`.

The transpiler differentiates between these types based on the first letter of the element name:

```jsx
// The tag name "div" is treated as a string and transpiled to React.createElement('div')
const element1 = <div />;

// The tag name "Welcome" is treated as a variable and transpiled to React.createElement(Welcome)
const element2 = <Welcome />;
```
**Explanation:**

- If the tag name starts with a lowercase letter, it's treated as a string and transpiled as a DOM element.
- If the tag name starts with an uppercase letter, it's treated as a variable and transpiled as a component.

This is why custom component names must start with an uppercase letter. It helps the transpiler and developers distinguish between built-in DOM elements and user-defined components. For example, `<Button>` refers to a custom button component, while `<button>` refers to a native DOM element.