### Managing State with Immutable Data in React

In React, state can hold any type of data that JavaScript supports. This includes not only primitive types like strings, numbers, and booleans, but also more complex types like objects and arrays.

However, when updating object or array state in React, you should not directly modify (mutate) the old object or array. Instead, you should create a new object or array that incorporates the updates you want to make. This concept can be a bit confusing, so let’s explore it with some examples.

#### Understanding "Mutate"

In React, you can store any type of data in state:

```jsx
const [number, setNumber] = useState(0);
const [name, setName] = useState('Zet');
const [isActive, setIsActive] = useState(false);
```

Primitive types in JavaScript (numbers, strings, booleans, etc.) are immutable, meaning their values cannot be changed once created. When you update such data, you generate a new value to replace the old one:

```jsx
setNumber(1); // Generates a new number 1 and replaces the old 0
setName('React'); // Generates a new string 'React' and replaces the old 'Zet'
setIsActive(true); // Generates a new boolean true and replaces the old false
```

**Example Explanation:**

When updating the data, you are reassigning a new value to the variable, not changing the content of the old value itself.

#### Objects and Arrays in State

In JavaScript, objects and arrays are mutable, meaning their contents can be modified:

```jsx
const position = { x: 0, y: 0 };
const names = ['React', 'Vue', 'jQuery'];
```

You can change the contents directly:

```jsx
position.x = 10;
names[0] = 'JavaScript';
```

#### Keeping State Data Immutable

In React, you should treat object and array state as immutable and create a new object or array with the desired updates, just like you do with primitive types.

```jsx
const newPosition = { ...position, x: 10 }; // Create a new object with updated x value
const newNames = names.map(name => name === 'React' ? 'JavaScript' : name); // Create a new array with updated value
```

**Example Explanation:**

In the above example, `newPosition` is a new object created using the spread operator, incorporating the updated `x` value. Similarly, `newNames` is a new array created using the `map` method to replace 'React' with 'JavaScript'.

### Why Mutation is Problematic in React

Let’s explore what happens if you mutate an object or array state directly:

```jsx
import { useState } from 'react';

function App() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleButtonClick = () => {
    position.x = 10; // Mutating the state directly
  };

  return (
    <div>
      <div>position: {position.x}, {position.y}</div>
      <button onClick={handleButtonClick}>click me</button>
    </div>
  );
}
```

**Example Explanation:**

When you click the button, it mutates the `position` object. However, the browser does not update the display. This is because React does not detect the change since you did not call `setPosition`.

Even if you call `setPosition`, the update may still not work as expected:

```jsx
import { useState } from 'react';

function App() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleButtonClick = () => {
    position.x = 10;
    setPosition(position); // Calling setPosition with the mutated object
  };

  return (
    <div>
      <div>position: {position.x}, {position.y}</div>
      <button onClick={handleButtonClick}>click me</button>
    </div>
  );
}
```

**Example Explanation:**

Here, calling `setPosition(position)` does not trigger a re-render. This is because React checks whether the new state is different from the old state using the `Object.is()` method. Since the object reference did not change, React assumes the state is unchanged and skips the re-render.

To correctly trigger a re-render, you need to pass a new object to `setPosition`:

```jsx
import { useState } from 'react';

function App() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleButtonClick = () => {
    setPosition({ ...position, x: 10 }); // Creating a new object with the updated value
  };

  return (
    <div>
      <div>position: {position.x}, {position.y}</div>
      <button onClick={handleButtonClick}>click me</button>
    </div>
  );
}
```

**Example Explanation:**

By passing a new object to `setPosition`, React detects the change and triggers a re-render.

### Conclusion

React relies on the immutability of state to optimize re-renders and ensure the correct functioning of its internal mechanisms. Directly mutating state objects or arrays can lead to unexpected behavior and bugs. Always create new objects or arrays when updating state to maintain immutability.

### Additional Resources:

- [JavaScript Data Types and Data Structures - MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures)
- [Primitive - MDN](https://developer.mozilla.org/en-US/docs/Glossary/Primitive)
- [Object.is() - MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is)


### Immutable State Updates in React

In the previous section, we learned why we should avoid mutating state in React. Instead, when updating objects or arrays, we must use immutable methods. This means creating a new object or array with the desired updates rather than modifying the existing one.

This approach might differ from what you are used to, so let's explore some methods and techniques for updating objects and arrays immutably. To keep the examples simple, we'll focus on the data manipulation itself without involving React state.

### Immutable Updates for Objects

#### Using the Spread Operator to Copy and Update Object Properties

When updating or adding properties to an object immutably, you can break it down into two steps:
1. Create a new empty object and copy all properties from the original object.
2. Add or overwrite the desired properties in the new object.

The ES6 spread operator helps us conveniently copy object properties:

```javascript
const oldObj = { a: 1, b: 2, c: 3 };
const newObj = { ...oldObj, a: 100 };
console.log(oldObj);  // { a: 1, b: 2, c: 3 }
console.log(newObj);  // { a: 100, b: 2, c: 3 }
```

**Explanation:**

In the example above, we use the spread operator to copy all properties from `oldObj` to `newObj` and then overwrite the `a` property with `100`. The log results show that `oldObj` remains unchanged, while `newObj` has the updated `a` property.

When dealing with nested objects, you need to spread properties at each level. For example, to immutably update the `d` property in `oldObj.fooObj`:

```javascript
const oldObj = {
  a: 1,
  b: 2,
  fooObj: {
    c: 3,
    d: 4
  }
};

const newObj = {
  ...oldObj,
  fooObj: {
    ...oldObj.fooObj,
    d: 100
  }
}

console.log(oldObj); // { a: 1, b: 2, fooObj: { c: 3, d: 4 } }
console.log(newObj); // { a: 1, b: 2, fooObj: { c: 3, d: 100 } }
```

**Explanation:**

Here, we spread `oldObj` into `newObj` and then spread `oldObj.fooObj` into `newObj.fooObj`, updating the `d` property.

### Removing Properties with Destructuring and Rest Syntax

To immutably remove a property from an object, use destructuring with the rest syntax:

```javascript
const oldObj = { a: 1, b: 2, c: 3 };
const { a, ...newObj } = oldObj;
console.log(oldObj);  // { a: 1, b: 2, c: 3 }
console.log(newObj);  // { b: 2, c: 3 }
```

**Explanation:**

We destructure `oldObj`, extracting the `a` property and collecting the remaining properties into `newObj`. The log results show `oldObj` is unchanged, while `newObj` does not include the `a` property.

### Immutable Updates for Arrays

Just like objects, arrays are reference types in JavaScript, so you need to update them immutably in React.

#### Adding Items to an Array with the Spread Operator

Use the spread operator to create a new array with additional items:

**Adding items at the beginning:**

```javascript
const oldArr = [123, 456, 789];
const newArr = [0, ...oldArr];
console.log(oldArr);  // [123, 456, 789]
console.log(newArr);  // [0, 123, 456, 789]
```

**Adding items at the end:**

```javascript
const oldArr = [123, 456, 789];
const newArr = [...oldArr, 0];
console.log(oldArr);  // [123, 456, 789]
console.log(newArr);  // [123, 456, 789, 0]
```

**Adding items in the middle:**

To insert items in the middle, use the array `slice()` method to create two separate copies of the array segments:

```javascript
const oldArr = ['a', 'b', 'c', 'd'];

const insertTargetIndex = 2;
const newArr = [
  ...oldArr.slice(0, insertTargetIndex),
  'z',
  ...oldArr.slice(insertTargetIndex)
];

console.log(oldArr);  // ['a', 'b', 'c', 'd']
console.log(newArr);  // ['a', 'b', 'z', 'c', 'd']
```

**Explanation:**

Here, we use `slice()` to get the array segments before and after the insertion index and insert the new item `z` in between.

### Removing Items from an Array

Use the array `filter()` method to immutably remove items from an array:

```javascript
const oldArr = ['a', 'b', 'c', 'd'];

const removeTargetIndex = 2;
const newArr = oldArr.filter((item, index) => index !== removeTargetIndex);

console.log(oldArr);  // ['a', 'b', 'c', 'd']
console.log(newArr);  // ['a', 'b', 'd']
```

**Explanation:**

The `filter()` method creates a new array excluding the item at the specified index.

### Updating or Replacing Items in an Array

Use the array `map()` method to immutably update or replace items:

**Updating even numbers:**

```javascript
const oldArr = [1, 2, 3, 4];
const newArr = oldArr.map(
  number => (number % 2 === 0)
    ? number * 100  // Update even numbers to their 100x value
    : number        // Leave odd numbers unchanged
);

console.log(oldArr);  // [1, 2, 3, 4]
console.log(newArr);  // [1, 200, 3, 400]
```

**Replacing item at a specific index:**

```javascript
const oldArr = ['a', 'b', 'c', 'd'];
const newArr = oldArr.map(
  (item, index) => (index === 2)
    ? 'new item'  // Replace the item at the specified index
    : item        // Leave other items unchanged
);

console.log(oldArr);  // ['a', 'b', 'c', 'd']
console.log(newArr);  // ['a', 'b', 'new item', 'd']
```

### Sorting Arrays

When sorting an array immutably, remember that the built-in `sort()` method mutates the original array. To avoid this, create a copy of the array before sorting:

```javascript
const oldArr = [4, 7, 21, 2];

// Use the spread operator to copy the array, then sort the copy
const newArr = [...oldArr];
newArr.sort((a, b) => a - b);

console.log(oldArr);  // [4, 7, 21, 2] => Remains unchanged
console.log(newArr);  // [2, 4, 7, 21] => Sorted copy
```

**Explanation:**

By creating a copy of the array before sorting, the original array remains unchanged.

**Additional Resources:**
- [JavaScript Array Methods - MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
- [JavaScript Spread Operator - MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax)
- [JavaScript Object Rest/Spread Properties - MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Object_rest_spread)

### Common Pitfalls and Techniques for Immutable Updates in React

In the previous sections, we explored the necessity and basic methods of immutable updates in React. Interestingly, as a front-end interviewer for many years, I've noticed that many engineers struggle with immutable updates and often make the same mistake. Let's look at an example:

```javascript
function App() {
  const [cart, setCart] = useState([
    { productId: 'foo', quantity: 1 },
    { productId: 'bar', quantity: 2 }
  ]);

  const handleQuantityChange = (index, quantity) => {
    // Update the quantity property of the object at the specified index in the cart state array
  }
}
```

Many people would try to do this:

```javascript
// ❌ Incorrect immutable update

const handleQuantityChange = (index, quantity) => {
  // Update the quantity property of the object at the specified index in the cart state array
  const newCart = [...cart];
  newCart[index].quantity = quantity;
}
```

Most people think that since we cannot modify the old state, copying the old state and then modifying the copy should be sufficient to maintain immutability. However, this approach still mutates the original state data. Let's delve into why this happens.

#### Nested Reference Data and Immutable Updates

In the above example, the attempt to copy at the outermost level using the spread operator still mutates the original data. This is because although a new array is created, the items within the array are objects, which are reference types. Consequently, each object in the copied array is the same reference as in the original array. Mutating these objects in the new array also mutates them in the original array. Even though the outermost array is new, ensuring that `setState`'s comparison works correctly, the objects within are mutated, which should be avoided in React.

This is why, in the previous section, we didn't recommend merely copying the outer array/object and then mutating the copy or using methods that mutate the original data. Instead, we suggested using methods like `map`, `filter`, `slice`, and spread/rest syntax, which are inherently immutable. When dealing with nested reference data (like an array containing objects), it's easy to accidentally mutate the original data. Although using these inherently immutable methods might seem verbose, they reduce the likelihood of errors and can be more intuitive when dealing with multi-level reference data.

When updating arrays containing objects or objects containing arrays, not only should the outermost layer be copied, but every nested object or array that needs updating should also be copied to ensure the entire data update is immutable.

**Spread Copies Values or References?**

We often use the ES6 spread syntax to copy object properties. But does it copy values or references?

```javascript
const oldObj = { a: 1, b: 2, c: 3 };
const newObj = { ...oldObj, d: 100 };
console.log(newObj);  // { a: 1, b: 2, c: 3, d: 100 }
```

In the above example, the `a`, `b`, and `c` properties in `newObj` are copied from `oldObj`. Since they are primitive types (numbers), which are inherently immutable, the spread operator creates independent copies of these values. Therefore, `newObj`'s `a`, `b`, and `c` properties are independent of `oldObj`'s corresponding properties and do not affect each other. Naturally, the newly added `d` property is also independent.

However, if an object contains properties that are also objects or arrays:

```javascript
const oldObj = { a: 1, b: 2, c: { foo: 8, bar: 9 } };
const newObj = { ...oldObj, d: 100 };

console.log(newObj);  // { a: 1, b: 2, c: { foo: 8, bar: 9 }, d: 100 }
console.log(Object.is(oldObj.c, newObj.c)); // true
```

When using the spread operator to copy properties from `oldObj` to `newObj`, the primitive type properties are copied as values. However, for arrays or objects (reference types), only the reference (memory address) is copied, not the content. Therefore, `oldObj.c` and `newObj.c` point to the same object reference. Mutating `newObj.c` also mutates `oldObj.c`:

```javascript
const oldObj = { a: 1, b: 2, c: { foo: 8, bar: 9 } };
const newObj = { ...oldObj, d: 100 };

console.log(Object.is(oldObj.c, newObj.c)); // true

newObj.c.foo = 800;
console.log(oldObj.c.foo); // 800
newObj.c.buzz = 1000;
console.log(oldObj.c.buzz); // 1000
```

To immutably update `oldObj.c`'s content, assign a new object to `c` in `newObj`, copying properties from `oldObj.c` and overriding with new properties:

```javascript
const oldObj = { a: 1, b: 2, c: { foo: 8, bar: 9 } };
const newObj = {
  ...oldObj,
  c: {
    ...oldObj.c,
    foo: 800,
    buzz: 1000
  },
  d: 100,
};

console.log(oldObj); // { a: 1, b: 2, c: { foo: 8, bar: 9 } }
console.log(newObj); // { a: 1, b: 2, c: { foo: 800, bar: 9, buzz: 1000 } }

console.log(Object.is(oldObj.c, newObj.c)); // false
```

This way, `oldObj.c` and `newObj.c` are different objects, ensuring immutability. The same logic applies to objects containing arrays, arrays containing objects, or arrays within arrays.

If a property does not need modification, you can reuse the old reference without copying:

```javascript
const oldObj = { a: 1, b: 2, c: { foo: 8 }, d: { bar: 9 } };
const newObj = {
  ...oldObj,
  d: {
    ...oldObj.d,
    buzz: 10
  },
};

console.log(Object.is(oldObj.c, newObj.c)); // true
console.log(Object.is(oldObj.d, newObj.d)); // false
```

In the above example, we only needed to immutably add the `buzz` property to `oldObj.d`. Therefore, we created a new `newObj` and `newObj.d`, adding the new `buzz` property. Since `oldObj.c` did not need modification, it is reused in `newObj`.

**Key Takeaways:**

The essence of immutability is not about entirely copying every part of the data, but rather ensuring the original data always reflects the historical state. Only the parts that change need to be copied to new objects or arrays. Unchanged references can be reused.

Updating deeply nested values immutably can result in verbose code with many layers of spread operations. To manage this complexity, it's best to avoid deeply nested state structures and use third-party libraries that simplify immutable updates, such as Ramda or Immer. However, it's still recommended for beginners to understand and practice basic immutable update concepts and methods using built-in JavaScript techniques.

**Recommended Libraries for Immutable Updates:**

- **Ramda:** A library designed with a functional programming (FP) style that includes a wide range of data and flow manipulation methods. It's the top choice for those who prefer FP style immutable updates.
- **Lodash/fp:** The FP version of the popular Lodash library, with all methods curried and made immutable. If you're accustomed to Lodash, consider this option.
- **Immer:** A popular library that allows developers to write "mutable" update logic while keeping the state immutable:

```javascript
import produce from 'immer';

const nextState = produce(baseState, draft => {
  draft[1].done = true;
  draft.push({ title: 'Tweet about it' });
});
```

**Explanation:**

Immer creates a draft of the original data, acting as a proxy. It listens for any mutations made to this draft and then produces an immutable version of the new data:

![Immer Concept](https://immerjs.github.io/immer/docs/images/immer-produce.png)