### JavaScript `Array.prototype.filter()`

The `filter()` method creates a new array with all elements that pass the test implemented by the provided function.

### Syntax

```jsx
var newArray = arr.filter(callback(element[, index[, array]])[, thisArg])

```

### Parameters

- `callback`: Function that is used to test each element of the array. Elements that pass the test return `true` and are kept, while those that fail return `false` and are not kept. It accepts three arguments:
    - `element`: The current element being processed in the array.
    - `index` (optional): The index of the current element being processed in the array.
    - `array` (optional): The array `filter` was called upon.
- `thisArg` (optional): Value to use as `this` when executing the `callback`.

### Return Value

- A new array with the elements that pass the test. If no elements pass the test, an empty array will be returned.

### Description

- The `filter()` method passes each element of the array through the `callback` function, creating a new array with all elements that pass the test.
- The `filter()` method does not mutate the array on which it is called.
- The `filter()` method constructs a new array with elements for which the `callback` returns `true`.

### Examples

1. **Filtering all small numbers**
    
    ```jsx
    function isBigEnough(value) {
      return value >= 10;
    }
    
    var filtered = [12, 5, 8, 130, 44].filter(isBigEnough);
    // filtered is [12, 130, 44]
    
    ```
    
2. **Filtering invalid entries from JSON**
    
    ```jsx
    var arr = [
      { id: 15 },
      { id: -1 },
      { id: 0 },
      { id: 3 },
      { id: 12.2 },
      {},
      { id: null },
      { id: NaN },
      { id: "undefined" },
    ];
    
    var invalidEntries = 0;
    
    function isNumber(obj) {
      return obj !== undefined && typeof obj === "number" && !isNaN(obj);
    }
    
    function filterByID(item) {
      if (isNumber(item.id)) {
        return true;
      }
      invalidEntries++;
      return false;
    }
    
    var arrByID = arr.filter(filterByID);
    
    console.log("Filtered array\\n", arrByID);
    // Filtered array
    // [{ id: 15 }, { id: -1 }, { id: 0 }, { id: 3 }, { id: 12.2 }]
    
    console.log("Number of invalid entries = ", invalidEntries);
    // Number of invalid entries = 4
    
    ```
    
3. **Searching in an array**
    
    ```jsx
    var fruits = ["apple", "banana", "grapes", "mango", "orange"];
    
    function filterItems(query) {
      return fruits.filter(function (el) {
        return el.toLowerCase().indexOf(query.toLowerCase()) > -1;
      });
    }
    
    console.log(filterItems("ap")); // ['apple', 'grapes']
    console.log(filterItems("an")); // ['banana', 'mango', 'orange']
    
    ```
    
4. **ES2015 Implementation**
    
    ```jsx
    const fruits = ["apple", "banana", "grapes", "mango", "orange"];
    
    const filterItems = (query) => {
      return fruits.filter(
        (el) => el.toLowerCase().indexOf(query.toLowerCase()) > -1,
      );
    };
    
    console.log(filterItems("ap")); // ['apple', 'grapes']
    console.log(filterItems("an")); // ['banana', 'mango', 'orange']
    
    ```
    

### Key Points

- The `filter()` method is used to filter elements in an array and returns a new array containing the elements that pass the callback function's test.
- The `callback` function tests each element and returns `true` to keep the element, or `false` to discard it.
- The `filter()` method does not mutate the original array and elements added to the original array after the call to `filter()` won't be tested.
- Common use cases include filtering small numbers, removing invalid items from an array, and searching for elements matching certain criteria.

### JavaScript `Array.prototype.slice()`

The `slice()` method returns a shallow copy of a portion of an array into a new array object selected from `begin` to `end` (end not included). The original array will not be modified.

### Syntax

```jsx
arr.slice([begin[, end]])

```

### Parameters

- `begin` (optional): Zero-based index at which to begin extraction. A negative index can be used, indicating an offset from the end of the sequence. If `begin` is undefined, slice begins from index 0.
- `end` (optional): Zero-based index before which to end extraction. `slice` extracts up to but not including `end`. A negative index can be used, indicating an offset from the end of the sequence. If `end` is omitted, `slice` extracts through the end of the sequence (`arr.length`).

### Return Value

- A new array containing the extracted elements.

### Description

- `slice()` does not mutate the original array, but returns a shallow copy that contains elements from the start index `begin` to the end index `end` (end not included).
- If elements are objects, `slice()` copies references to the objects into the new array. Both the original and new array refer to the same object.
- If a new element is added to either the original or the new array, it will not affect the other.

### Examples

1. **Return a portion of an existing array**
    
    ```jsx
    var fruits = ["Banana", "Orange", "Lemon", "Apple", "Mango"];
    var citrus = fruits.slice(1, 3);
    // fruits contains ['Banana', 'Orange', 'Lemon', 'Apple', 'Mango']
    // citrus contains ['Orange','Lemon']
    
    ```
    
2. **Using slice**
    
    ```jsx
    var myHonda = { color: "red", wheels: 4, engine: { cylinders: 4, size: 2.2 } };
    var myCar = [myHonda, 2, "cherry condition", "purchased 1997"];
    var newCar = myCar.slice(0, 2);
    
    console.log("myCar = " + JSON.stringify(myCar));
    console.log("newCar = " + JSON.stringify(newCar));
    console.log("myCar[0].color = " + myCar[0].color);
    console.log("newCar[0].color = " + newCar[0].color);
    
    myHonda.color = "purple";
    console.log("The new color of my Honda is " + myHonda.color);
    console.log("myCar[0].color = " + myCar[0].color);
    console.log("newCar[0].color = " + newCar[0].color);
    
    ```
    
3. **Array-like objects**
    
    ```jsx
    function list() {
      return Array.prototype.slice.call(arguments);
    }
    
    var list1 = list(1, 2, 3); // [1, 2, 3]
    
    ```
    

### Key Points

- The `slice()` method returns a new array with elements from the `begin` index to the `end` index (not included).
- The `slice()` method does not mutate the original array.
- Both `begin` and `end` parameters can be negative indices, indicating an offset from the end of the array.
- If the `end` parameter is omitted, `slice()` extracts through the end of the array.
- The `slice()` method performs a shallow copy of object references, meaning both arrays refer to the same objects for object elements.
- It can be used on array-like objects, such as `arguments`.

### Destructuring Assignment

Destructuring assignment is a JavaScript expression that makes it possible to unpack values from arrays or properties from objects into distinct variables.

### Basic Syntax

```jsx
let a, b, rest;
[a, b] = [10, 20];
console.log(a); // 10
console.log(b); // 20

[a, b, ...rest] = [10, 20, 30, 40, 50];
console.log(a); // 10
console.log(b); // 20
console.log(rest); // [30, 40, 50]

({ a, b } = { a: 10, b: 20 });
console.log(a); // 10
console.log(b); // 20

({ a, b, ...rest } = { a: 10, b: 20, c: 30, d: 40 });
console.log(a); // 10
console.log(b); // 20
console.log(rest); // {c: 30, d: 40}

```

### Array Destructuring

1. **Basic variable assignment**
    
    ```jsx
    const foo = ["one", "two", "three"];
    const [red, yellow, green] = foo;
    console.log(red); // "one"
    console.log(yellow); // "two"
    console.log(green); // "three"
    
    ```
    
2. **Separate declaration and assignment**
    
    ```jsx
    let a, b;
    [a, b] = [1, 2];
    console.log(a); // 1
    console
    
    ```
    

.log(b); // 2
```

1. **Default values**
    
    ```jsx
    let a, b;
    [a = 5, b = 7] = [1];
    console.log(a); // 1
    console.log(b); // 7
    
    ```
    
2. **Swapping variables**
    
    ```jsx
    let a = 1;
    let b = 3;
    [a, b] = [b, a];
    console.log(a); // 3
    console.log(b); // 1
    
    ```
    
3. **Parsing an array returned from a function**
    
    ```jsx
    function f() {
      return [1, 2];
    }
    let a, b;
    [a, b] = f();
    console.log(a); // 1
    console.log(b); // 2
    
    ```
    
4. **Ignoring some returned values**
    
    ```jsx
    function f() {
      return [1, 2, 3];
    }
    const [a, , b] = f();
    console.log(a); // 1
    console.log(b); // 3
    
    ```
    
5. **Assigning the rest of an array to a variable**
    
    ```jsx
    const [a, ...b] = [1, 2, 3];
    console.log(a); // 1
    console.log(b); // [2, 3]
    
    ```
    

### Object Destructuring

1. **Basic assignment**
    
    ```jsx
    const o = { p: 42, q: true };
    const { p, q } = o;
    console.log(p); // 42
    console.log(q); // true
    
    ```
    
2. **Assignment without declaration**
    
    ```jsx
    let a, b;
    ({ a, b } = { a: 1, b: 2 });
    
    ```
    
3. **Assigning to new variable names**
    
    ```jsx
    const o = { p: 42, q: true };
    const { p: foo, q: bar } = o;
    console.log(foo); // 42
    console.log(bar); // true
    
    ```
    
4. **Default values**
    
    ```jsx
    const { a = 10, b = 5 } = { a: 3 };
    console.log(a); // 3
    console.log(b); // 5
    
    ```
    
5. **Assigning to new variables names and providing default values**
    
    ```jsx
    const { a: aa = 10, b: bb = 5 } = { a: 3 };
    console.log(aa); // 3
    console.log(bb); // 5
    
    ```
    
6. **Extracting properties from a function parameter**
    
    ```jsx
    const user = {
      id: 42,
      displayName: "jdoe",
      fullName: {
        firstName: "John",
        lastName: "Doe",
      },
    };
    
    function userId({ id }) {
      return id;
    }
    
    function whois({ displayName, fullName: { firstName: name } }) {
      return `${displayName} is ${name}`;
    }
    
    console.log(userId(user)); // 42
    console.log(whois(user)); // "jdoe is John"
    
    ```
    
7. **Setting a function parameter's default value**
    
    ```jsx
    function drawChart({
      size = "big",
      coords = { x: 0, y: 0 },
      radius = 25,
    } = {}) {
      console.log(size, coords, radius);
      // do some chart drawing
    }
    
    drawChart({
      coords: { x: 18, y: 30 },
      radius: 30,
    });
    
    ```
    
8. **Nested object and array destructuring**
    
    ```jsx
    const metadata = {
      title: "Scratchpad",
      translations: [
        {
          locale: "de",
          localization_tags: [],
          last_edit: "2014-04-14T08:43:37",
          url: "/de/docs/Tools/Scratchpad",
          title: "JavaScript-Umgebung",
        },
      ],
      url: "/zh-TW/docs/Tools/Scratchpad",
    };
    
    let {
      title: englishTitle, // rename
      translations: [
        {
          title: localeTitle, // rename
        },
      ],
    } = metadata;
    
    console.log(englishTitle); // "Scratchpad"
    console.log(localeTitle); // "JavaScript-Umgebung"
    
    ```
    
9. **For-of loop with destructuring**
    
    ```jsx
    const people = [
      {
        name: "Mike Smith",
        family: {
          mother: "Jane Smith",
          father: "Harry Smith",
          sister: "Samantha Smith",
        },
        age: 35,
      },
      {
        name: "Tom Jones",
        family: {
          mother: "Norah Jones",
          father: "Richard Jones",
          brother: "Howard Jones",
        },
        age: 25,
      },
    ];
    
    for (const {
      name: n,
      family: { father: f },
    } of people) {
      console.log("Name: " + n + ", Father: " + f);
    }
    // "Name: Mike Smith, Father: Harry Smith"
    // "Name: Tom Jones, Father: Richard Jones"
    
    ```
    
10. **Computed object property names and destructuring**
    
    ```jsx
    let key = "z";
    let { [key]: foo } = { z: "bar" };
    console.log(foo); // "bar"
    
    ```
    
11. **Rest in object destructuring**
    
    ```jsx
    let { a, b, ...rest } = { a: 10, b: 20, c: 30, d: 40 };
    console.log(a); // 10
    console.log(b); // 20
    console.log(rest); // { c: 30, d: 40 }
    
    ```
    
12. **Unpacking properties from objects passed as a function parameter**
    
    ```jsx
    const foo = { "fizz-buzz": true };
    const { "fizz-buzz": fizzBuzz } = foo;
    console.log(fizzBuzz); // true
    
    ```
    
13. **Combination of array and object destructuring**
    
    ```jsx
    const props = [
      { id: 1, name: "Fizz" },
      { id: 2, name: "Buzz" },
      { id: 3, name: "FizzBuzz" },
    ];
    
    const [, , { name }] = props;
    console.log(name); // "FizzBuzz"
    
    ```
    

### Summary

Destructuring assignment is a very useful syntax in JavaScript that simplifies the process of extracting values from arrays and objects, making the code more concise and readable. Understanding and mastering destructuring assignment can enhance development efficiency and reduce the chance of errors.

### ES Module & import/export

React has embraced modularization, a key technique in modern frontend engineering, very early on. Especially in a component-based development approach, we often split different components into different files, and they do not interfere with each other, only manually referencing each other when necessary. As the current standard JS module system, ES modules are also essential to master.

### Running in the Browser

To run modules in the browser, add `type="module"` to the `<script>` tag. This allows both inline and external JS to use module functionalities.

```html
<script type="module"></script>

```

Of course, not all browsers support this module functionality. If you need to accommodate both new and old browsers, you can use the following approach:

```html
<!-- Supported by browsers with module syntax -->
<script type="module" src="module.js"></script>

<!-- Ignored by modern browsers -->
<script nomodule src="IENotGood.js"></script>

```

## Exporting

`export` can be used to export functions, objects, or even values. Most commonly, we export objects (functions), as exporting values alone is not very meaningful as a module.

There are two types of exports, which slightly differ in their methods and affect how they are imported, so it's important to distinguish between them before using them (very important):

- Named exports: Individual objects, variables, functions, etc. must be given specific names before being exported, and the same name must be used when importing them. Additionally, a file can have multiple named exports.
- Default exports: A file can only have a single default export, and it does not need to be named.

Both types can coexist in the same file, but there can only be one `default export`.

### Default Export

Default export does not need to be named before export; it can be named during import. However, each file can only have one `export default`.

Exporting a value or expression result directly:

```jsx
export default 1;

```

Defining a variable beforehand and exporting it:

```jsx
const a = 1;
export default a;

```

Exporting an object using the shorthand notation:

```jsx
const obj = { name: 'obj' };
const obj2 = { name: 'obj2' };
export default { obj, obj2 };

```

Using anonymous functions for `export default`:

```jsx
// Export an anonymous function
export default function() {
  console.log('This is a function');
}

// Export a class
export default class {
  constructor(name) {
    this.name = name;
  }
  callName() {
    console.log(this.name);
  }
}

```

### Named Export

Named export requires objects, functions, etc. to be given a specific name before they are exported, and the same name must be used when importing them.

Method 1: Declare variables or objects first and then export them.

```jsx
// let, const values
export let a = 1;
export let obj = { name: 'obj' };

```

Method 2: Use function declaration for export.

```jsx
// Named method
export function fn() {
  console.log('This is a function');
}

```

Method 3: Use object shorthand notation for exporting objects, a common practice.

```jsx
const b = 2;
const obj2 = { name: 'obj2' };
const obj3 = { name: 'obj3' };

export { b, obj2, obj3 };

```

Tip: Rename before exporting using `as`.

```jsx
const obj2 = { name: 'obj2' };
export { obj2 as objNewName };

```

### Coexistence

Both named and default exports can coexist in the same file, but there can only be one `default export`.

```jsx
export const obj = { name: 'obj' };
export default function() {
  console.log('This is a function');
}

```

## Importing

The import method will vary based on the export method, so it's essential to understand the export method of external resources. For third-party resources, you can refer to the documentation to learn how to import them.

### Importing Default Export

Default export can be imported and assigned a name.

```jsx
// export file
export default function() {
  console.log('This is a function');
}

// import file
import fn from './defaultModule.js';
fn(); // Execute the function

```

### Importing Named Export

Named export requires using destructuring syntax to extract specific modules.

```jsx
// export file
export const obj = { name: 'obj' };
export function fn() {
  console.log('This is a function');
}

// import file
import { fn } from './module.js';
fn();

```

Multiple objects, variables, functions, etc. can be imported simultaneously.

```jsx
// import file
import { fn, obj } from './module.js';
fn();
console.log(obj);

```

### Renaming

If there's a naming conflict, `as` (alias) can be used to rename the imported module.

```jsx
// export file
export const obj = { name: 'obj' };
export function fn() {
  console.log('This is a function');
}

// import file
import { fn as newFn } from './module.js';
newFn();

```

Named imports can also use `*` to import everything as an object.

```jsx
// import file
import * as name from './module.js';
name.fn();
console.log(name.obj);

```

### Importing Default and Named Exports

Both default and named exports can coexist, and the import can handle both simultaneously.

```jsx
import defaultExport, * as name from "module-name";

```

### Side Effect Imports

Some modules do not implement `export`, and importing them will execute them directly.

```jsx
// module file
(function() {
  console.log('IIFE');
})();

// import file
import './fn.js';

```

## Should You Use `default` or `named`?

Default export is straightforward and intuitive for exporting a single component or module from a file. However, named exports provide stricter naming conventions and better error detection in large projects and open-source packages.

### What is `async` and `await`?

In JavaScript, synchronous and asynchronous operations can be confusing, especially with methods like `setTimeout`, `setInterval`, `MLHttpRequest`, or `fetch`. Fortunately, ES6 introduced promises, and ES7 introduced `async` and `await`, making it easier to write asynchronous code.

- **Synchronous**: In a "relay race," you wait for the baton before running.
- **Asynchronous**: In a "race," everyone runs independently without waiting.

In ES7, `async` is syntactic sugar for promises. An `async` function allows you to write `await` inside it. The `await` keyword ensures that the code waits for the promise to resolve or reject before moving to the next line. An `async` function always returns a promise, allowing for `.then` chaining.

```jsx
async function a(){
  await b();
  // Waits for b() to complete before proceeding
  await c();
  // Waits for c() to complete before proceeding
  await new Promise(resolve => {
    // Waits for this promise to resolve before proceeding
  });
}
a();
a().then(() => {
  // Executes after a() completes
});

```

### Using async and await for clean code

Using `async` and `await` can make code cleaner and easier to understand. `await` waits for a promise to resolve before proceeding, making it clear when to wait and when to move to the next step.

> Note: await must be used inside an async function!
> 

```jsx
~async function() {
  // ~ indicates the function is immediately invoked
  const delay = (s) => {
    return new Promise(resolve => {
      setTimeout(resolve, s); // Resolves after a delay
    });
  };

  console.log(1); // Logs 1
  await delay(1000); // Delays for 1 second
  console.log(2); // Logs 2
  await delay(2000); // Delays for 2 seconds
  console.log(3); // Logs 3
}();

```

### Combining async and await with Promises

Combining `async` and `await` with promises can help fix issues with asynchronous logic, such as with `setTimeout` or `setInterval`.

```jsx
const count = (t, s) => {
  let a = 0;
  let timer = setInterval(() => {
    console.log(`${t}${a}`);
    a++;
    if (a > 5) {
      clearInterval(timer);
    }
  }, s);
};

console.log(1);
count('haha', 100);
console.log(2);

```

Using `async`, `await`, and promises to handle `setInterval`:

```jsx
~async function() {
  const count = (t, s) => {
    return new Promise(resolve => {
      let a = 0;
      let timer = setInterval(() => {
        console.log(`${t}${a}`);
        a++;
        if (a > 5) {
          clearInterval(timer);
          resolve(); // Resolves the promise
        }
      }, s);
    });
  };

  console.log(1);
  await count('haha', 100);
  console.log(2);
}();

```

### Handling input scenarios with async and await

Using `async` and `await` for handling input scenarios can make the code cleaner and more understandable.

```jsx
~async function() {
  const input = () => {
    return new Promise(resolve => {
      const btnClick = () => {
        h.insertAdjacentHTML('beforeend', a.value + '<br/>');
        a.value = '';
        a.focus();
        b.removeEventListener('click', btnClick);
        resolve(); // Resolves the promise
      };
      b.addEventListener('click', btnClick);
    });
  };
  h.insertAdjacentHTML('beforeend', 'Start<br/>');
  await input(); // Waits for input before proceeding
  await input();
  await input();
  h.insertAdjacentHTML('beforeend', 'End');
}();

```

### Combining async, await, and fetch

`fetch` returns a promise, making it ideal for use with `async` and `await`.

```jsx
~async function() {
  console.log('Start fetching weather data'); // Logs before fetching
  await fetch('weather-api-url')
    .then(res => res.json())
    .then(result => {
      let city = result.location[14].parameter[0].parameterValue;
      let temp = result.location[14].weatherElement[3].elementValue.value;
      console.log(`${city} temperature is ${temp} °C`);
    });
  console.log('Finished fetching'); // Logs after fetching
}();

```

### Summary

- **filter()**: Filters array elements based on a test function, returning a new array of elements that pass the test.
- **slice()**: Creates a shallow copy of a portion of an array, specified by start and end indices.
- **Destructuring**: Unpacks values from arrays or properties from objects into distinct variables.
- **ES Modules**: Use `import` and `export` to manage code modularly, with `default` and `named` exports.
- **async/await**: Simplifies handling asynchronous operations, ensuring a promise resolves before proceeding.

Understanding these concepts enhances JavaScript development, making code cleaner, more modular, and easier to maintain.