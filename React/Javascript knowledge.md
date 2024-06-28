### React 的難易點

- **JavaScript 基礎：** React 大量機制依賴 JavaScript 核心特性，JavaScript 基礎不穩會導致學習困難。因此，我建議先鞏固 JavaScript 基本功再學習 React。
- **思想模型認知：** React 設計基於許多設計模式（design patterns），這些概念與傳統前端開發思維差異大。如果不理解這些 patterns，會覺得 React 的設計不直覺且難以掌握。

### 理解 React 的關鍵

### 核心思想與概念：

掌握 React 設計背後的思想，能讓 React 的設計變得直覺且一脈相承。理解錯誤會導致後續進階概念學習困難，反之，理解正確則能讓一切迎刃而解。

### 實作與理解融合：

需要投入時間理解設計思想並融會貫通，將其內化到思考模型中，這樣的學習才有意義且能長久。

### 1. Closure

- **必要的知識或概念**：在 function component 中，closure 會大量應用於定義 event handlers 以及與 hooks 配合，保持資料流。因此，完全掌握 closure 是理解 React 核心概念的基礎。

### 介紹閉包 (Closure)

### 範圍鏈 (Scope Chain)

在介紹閉包之前，我們先來談談「範圍鏈」的觀念。

- JavaScript 中，變數的作用範圍最小單位是函式 (`function`)。
- 例如下面這段程式碼：

```jsx
function outer() {
  var b = a * 2;

  function inner(c) {
    console.log(a, b, c);
  }

  inner(b * 3);
}

var a = 1;
outer(a);

```

在這段程式碼中：

- `inner` 函式可以讀取 `outer` 函式內部的變數 `b`，以及全域變數 `a`，但 `outer` 函式不能讀取 `inner` 函式內部的變數 `c`。
- 如果變數在當前範圍內找不到，會一層一層往外尋找，直到全域範圍。

修改上面範例，如果在 `outer` 函式中的 `b` 沒有使用 `var` 宣告，會發生什麼事？

```jsx
function outer() {
  b = a * 2;

  function inner(c) {
    console.log(a, b, c);
  }

  inner(b * 3);
}

var a = 1;
outer(a);

```

在這種情況下：

- 變數 `b` 會變成全域變數，因為範圍鏈的關係，未宣告的變數會往外尋找，最終在全域層級創建。

### 測驗

考慮以下範例：

```jsx
var msg = "global.";

function outer() {
  var msg = "local.";

  function inner() {
    return msg;
  }

  return inner;
}

var innerFunc = outer();
var result = innerFunc();

console.log(result); // ?

```

解釋：

- 最後的 `console.log(result)` 會輸出 `"local."`。
- 因為範圍鏈是在函式被定義時決定的，而不是在函式被呼叫時決定的。當 `outer` 函式被呼叫並返回 `inner` 函式時，`inner` 函式的範圍鏈已經確定包含 `outer` 函式內部的 `msg` 變數。

### 閉包 (Closure)

閉包就是當內部函式被回傳後，除了自己的程式碼外，也可以取得當時環境的變數值，記住執行時的環境。這就是閉包。

### 例子

考慮以下使用 IIFE (立即被呼叫的函式) 的例子：

```jsx
for (var i = 0; i < 5; i++) {
  (function(i) {
    window.setTimeout(function() {
      console.log(i);
    }, 1000 * i);
  })(i);
}

```

在這裡，閉包的環境狀態被儲存，每次迴圈執行 `setTimeout` 時，會將當時的 `i` 鎖定並延長其生命。

### 閉包範例

讓我們比較一下使用閉包與不使用閉包的差異。

### 不使用閉包的計數器

```jsx
var count = 0;

function counter() {
  return ++count;
}

console.log(counter()); // 1
console.log(counter()); // 2
console.log(counter()); // 3

```

這種方式會利用全域變數來儲存 `count`，可能會導致變數名稱衝突及無法回收的問題。

### 使用閉包的計數器

```jsx
function counter() {
  var count = 0;

  function innerCounter() {
    return ++count;
  }

  return innerCounter;
}

var countFunc = counter();

console.log(countFunc()); // 1
console.log(countFunc()); // 2
console.log(countFunc()); // 3

```

在這裡，`count` 被封裝在 `counter` 函式中，不會暴露在全域環境中，確保內部 `count` 變數的私密性和安全性。

### 簡化的閉包計數器

```jsx
function counter() {
  var count = 0;

  return function() {
    return ++count;
  }
}

var counter = () => {
  var count = 0;
  return () => ++count;
}

```

使用箭頭函數 (Arrow Function) 簡化後的版本：

```jsx
var counter = () => {
  var count = 0;
  return () => ++count;
}

```

### 多個計數器實例

使用閉包可以創建獨立的計數器實例：

```jsx
var countFunc = counter();
var countFunc2 = counter();

console.log(countFunc()); // 1
console.log(countFunc()); // 2
console.log(countFunc()); // 3

console.log(countFunc2()); // 1
console.log(countFunc2()); // 2

```

這樣，`countFunc` 與 `countFunc2` 分別是獨立的計數器，彼此不會互相干擾。

### 總結

閉包讓內部函式能夠存取其外部函式作用域中的變數，這種特性被稱為「內神通外鬼」

### 閉包的特徵

1. **內部函式**：閉包是一個在另一個函式內部定義的函式。
2. **詞法作用域**：內部函式能夠訪問其外部函式的變數，即使外部函式已經執行完畢。
3. **持久的變數狀態**：內部函式可以持續訪問和修改外部函式的變數。

### 

2:Arrow function

- function component 中會很常以 arrow function 來方便的定義 event handlers 或 effect

### 箭頭函式運算式 (Arrow Function Expression)

箭頭函式運算式擁有比傳統函式運算式更簡短的語法。它沒有自己的 `this`、`arguments`、`super`、`new.target` 等語法，適用於非方法的函式，但不能用作建構式（constructor）。

### 基本語法

```jsx

(參數1, 參數2, …, 參數N) => { 陳述式; }
(參數1, 參數2, …, 參數N) => 表示式; // 等同於 (參數1, 參數2, …, 參數N) => { return 表示式; }

// 只有一個參數時,括號可以省略:
單一參數 => { 陳述式; }

// 無參數時，括號不可省略:
() => { statements }

```

### 進階語法

```jsx

// 返回一個物件字面值:
params => ({foo: bar})

// 支援其餘參數與預設參數
(param1, param2, ...rest) => { statements }
(param1 = defaultValue1, param2, …, paramN = defaultValueN) => { statements }

// 支援參數解構
var f = ([a, b] = [1, 2], {x: c} = {x: a + b}) => a + b + c; f(); // 6

```

### 特性

1. **更短的函式寫法**
    
    ```jsx
    
    var elements = ["Hydrogen", "Helium", "Lithium", "Beryllium"];
    
    elements.map(function (element) {
      return element.length;
    }); // [8, 6, 7, 9]
    
    elements.map((element) => {
      return element.length;
    }); // [8, 6, 7, 9]
    
    elements.map(element => element.length); // [8, 6, 7, 9]
    
    elements.map(({ length }) => length); // [8, 6, 7, 9]
    
    ```
    
2. **`this` 變數的非綁定**
    
    箭頭函式沒有自己的 `this`，`this` 來自封閉的上下文：
    
    ```jsx
    
    function Person() {
      this.age = 0;
    
      setInterval(() => {
        this.age++; // this 適切的參考了 Person 建構式所建立的物件
      }, 1000);
    }
    
    var p = new Person();
    
    ```
    
3. **不綁定 `arguments`**
    
    箭頭函式沒有自己的 `arguments` 物件：
    
    ```jsx
    
    var arguments = [1, 2, 3];
    var arr = () => arguments[0];
    
    arr(); // 1
    
    function foo(n) {
      var f = (...args) => args[0] + n;
      return f(10);
    }
    
    foo(1); // 11
    
    ```
    
4. **不能用作建構式**
    
    箭頭函式不可作為建構式使用：
    
    ```jsx
    
    var Foo = () => {};
    var foo = new Foo(); // TypeError: Foo is not a constructor
    
    ```
    
5. **沒有 `prototype` 屬性**
    
    ```jsx
    
    var Foo = () => {};
    console.log(Foo.prototype); // undefined
    
    ```
    
6. **不能使用 `yield`**
    
    箭頭函式不能用於 generator 函式的 `yield`。
    

### 函式主體 (Function Body)

- **Concise Body**：只需要輸入運算式，會自動返回結果。
    
    ```jsx
    
    var func = (x) => x * x;
    
    ```
    
- **Block Body**：需要明確的 `return` ：
    
    ```jsx
    
    var func = (x, y) => {
      return x + y;
    };
    
    ```
    

### 回傳物件字面值

```jsx
javascript複製程式碼
var func = () => ({ foo: 1 });

```

### 其他注意事項

- **換行**：箭頭函式不可以在參數及箭頭間包含換行。
    
    ```jsx
    
    var func = ()
               => 1; // SyntaxError: expected expression, got '=>'
    
    ```
    
- **Parsing Order**：箭頭函式有特殊解析規則。
    
    ```jsx
    
    let callback;
    
    callback = callback || function() {}; // ok
    callback = callback || () => {};      // SyntaxError: invalid arrow-function arguments
    callback = callback || (() => {});    // ok
    
    ```
    

這些特性使得箭頭函式在 JavaScript 中變得非常實用和簡潔。

Primitive types & Object types

- 由於 React 是以 immutable 的概念來設計資料流的，因此對於 object types 以及其 compare 的觀念掌握是不可或缺的基本功

### JavaScript 變數處理與型別

在 JavaScript 世界，變數處理主要包括複製、傳值、比較和變更。JavaScript 的型別分為兩大類：原始型別 (Primitive type) 和物件型別 (Object type)。

### TL;DR 結論

- **原始型別**：以值 (by value) 方式操作。
- **物件型別**：以參考 (by reference) 方式操作。

### 原始型別 (Primitive Type)

原始型別是以值 (by value) 來處理的。包括以下成員：

- `String`
- `Number`
- `Boolean`
- `Null`
- `Undefined`

**複製**：當宣告一個新變數並賦值給它時，是複製原變數的值。

```jsx

let x = 2;
// Copy by value
let y = x;
y += 5;
console.log(y, x); // 7, 2

```

**比較**：以真實的值進行比較。

**傳值**：將變數作為參數傳入函數時，也是複製變數的值。

**字串的特殊性**：字串是不可變 (immutable) 的，使用字串方法不會改變原字串。

```jsx

let s = 'macbook';
s.toUpperCase();
s.slice(-4);
s.concat('pro');
s[3] = 'r';
console.log(s);  // 'macbook'

```

### 物件型別 (Object Type)

物件型別是以參考 (by reference) 來處理的。包括以下成員：

- `Object`
- `Function`
- `Array`
- `Set`

**by reference**：物件型別操作時，是對記憶體位置進行操作。

```jsx

let arr1 = [1, 2, 3];
let arr2 = arr1; // arr2 參考同一個記憶體位置
arr2.push(4);
console.log(arr1); // [1, 2, 3, 4]

```

**比較**：即使兩個物件內容相同，因為記憶體位置不同，比較結果也是 `false`。

**複製物件型別**：

- **Array**：
    
    ```jsx
    
    let arr1 = [1, 2, 3];
    let arr2 = [...arr1]; // 使用展開運算符
    
    ```
    
- **Object**：
    
    ```jsx
    
    let obj1 = { a: 1, b: 2 };
    let obj2 = { ...obj1 }; // 使用展開運算符
    
    ```
    

**注意**：對於巢狀結構的物件，以上方法仍然是淺層複製 (shallow copy)。可以使用深層複製 (deep copy) 方法：

```jsx

let obj1 = { a: 1, b: { c: 2 } };
let obj2 = JSON.parse(JSON.stringify(obj1)); // 深層複製

```

### 重點整理

1. **原始型別**：
    - **操作方式**：by value
    - **成員**：String, Number, Boolean, Null, Undefined
    - **特性**：值複製、不可變字串
2. **物件型別**：
    - **操作方式**：by reference
    - **成員**：Object, Function, Array, Set
    - **特性**：記憶體位置複製、比較時不同位置視為不同物件
    - **複製方法**：展開運算符 (shallow copy)，深層複製需要特別方法 (如 JSON.parse 和 JSON.stringify)
    - 

這些概念對理解 JavaScript 中的變數操作和型別處理非常重要，有助於寫出更穩定和高效的程式碼。

陣列內建方法：map、filter、slice

- 在資料的 immutable update 操作時會大量使用到這些資料操作方法

`map()` 方法會建立一個新的陣列，其內容為原陣列的每一個元素經由回呼函式運算後所回傳的結果之集合。

### 語法

```jsx

let new_array = arr.map(function callback(currentValue[, index[, array]]) {
    // return element for new_array
}[, thisArg])

```

### 參數

- `callback`：呼叫原陣列所有元素的回呼函式。新數值會在每次執行 `callback` 時加到 `new_array`。
    - `currentValue`：原陣列目前所迭代處理中的元素。
    - `index`（選擇性）：原陣列目前所迭代處理中的元素之索引。
    - `array`（選擇性）：呼叫 `map` 方法的陣列。
- `thisArg`（選擇性）：執行 `callback` 回呼函式的 `this` 值。

### 回傳值

- 一個所有元素皆為回呼函式運算結果的新陣列。

### 描述

- `map` 會將所有陣列中的元素依序分別傳入一次至 `callback` 函式當中，並以此回呼函式每一次被呼叫的回傳值來建構一個新的陣列。
- `map` 只會於陣列目前迭代之索引有指派值時（包含 `undefined`）被調用，而在該陣列索引沒有元素時（即未被設定的索引：已被刪除或從未被賦值）並不會呼叫回呼函式。

### 什麼時候不要用 `map()`

- 因為 `map` 會建立新的陣列，如果不需要新陣列時，應該使用 `forEach` 或 `for-of`。
- 以下情況不應該使用 `map`：
    - 不使用回傳的新陣列。
    - 不需要回傳新陣列。

### 範例

1. **數字陣列轉換成開根號後的數字陣列**
    
    ```jsx
    
    var numbers = [1, 4, 9];
    var roots = numbers.map(Math.sqrt); // [1, 2, 3]
    // numbers 仍然是 [1, 4, 9]
    
    ```
    
2. **將陣列中的物件變更格式**
    
    ```jsx
    
    var kvArray = [
      { key: 1, value: 10 },
      { key: 2, value: 20 },
      { key: 3, value: 30 },
    ];
    
    var reformattedArray = kvArray.map(function (obj) {
      var rObj = {};
      rObj[obj.key] = obj.value;
      return rObj;
    });
    // reformattedArray 是 [{1: 10}, {2: 20}, {3: 30}]
    // kvArray 仍然是原樣
    
    ```
    
3. **帶參數的函式將數字陣列進行對應**
    
    ```jsx
    
    var numbers = [1, 4, 9];
    var doubles = numbers.map(function (num) {
      return num * 2;
    });
    // doubles 是 [2, 8, 18]
    // numbers 仍然是 [1, 4, 9]
    
    ```
    
4. **將 String 陣列轉換為 byte 陣列**
    
    ```jsx
    
    var map = Array.prototype.map;
    var a = map.call("Hello World", function (x) {
      return x.charCodeAt(0);
    });
    // a 是 [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100]
    
    ```
    
5. **使用 `map` 遍歷 `querySelectorAll`**
    
    ```jsx
    
    var elems = document.querySelectorAll("select option:checked");
    var values = Array.prototype.map.call(elems, function (obj) {
      return obj.value;
    });
    
    ```
    
6. **使用 `parseInt` 的注意事項**
    
    ```jsx
    
    ["1", "2", "3"].map(parseInt); // [1, NaN, NaN]
    
    function returnInt(element) {
      return parseInt(element, 10);
    }
    
    ["1", "2", "3"].map(returnInt); // [1, 2, 3]
    ["1", "2", "3"].map((str) => parseInt(str)); // [1, 2, 3]
    ["1", "2", "3"].map(Number); // [1, 2, 3]
    ["1.1", "2.2e2", "3e300"].map(Number); // [1.1, 220, 3e+300]
    
    ```
    

### 重點整理

- `map()` 方法用於將陣列中的每個元素經過回呼函式運算後，產生一個新陣列。
- `map` 不會修改原陣列，產生的新陣列與原陣列無關。
- 適合用於需要對陣列中的每個元素進行相同操作並返回新陣列的情況。
- 若不需要新陣列，應該使用 `forEach` 或其他迭代方法以避免反模式。
- 在使用 `map` 時，注意回呼函式的參數和 `this` 的使用，避免不必要的錯誤。

陣列 / 物件的解構賦值、spread、rest

- 在 props 資料解構和拆分、`useState` 返回值解構、物件 state immutable update 等地方，都會頻繁的使用到這些陣列與物件的操作語法

### JavaScript Array.prototype.filter()

`filter()` 方法會建立一個經指定之函式運算後，由原陣列中通過該函式檢驗之元素所構成的新陣列。

### 語法

```jsx

var newArray = arr.filter(callback(element[, index[, array]])[, thisArg])

```

### 參數

- `callback`：用於測試陣列中每個元素的斷言函式，回傳值為 `true` 時保留該元素，`false` 則不保留。可以傳入三個參數：
    - `element`：原陣列目前所迭代處理中的元素。
    - `index`（選擇性）：原陣列目前所迭代處理中的元素之索引。
    - `array`（選擇性）：呼叫 `filter` 方法的陣列。
- `thisArg`（選擇性）：執行 `callback` 回呼函式的 `this` 值。

### 回傳值

- 一個包含通過回呼函式檢驗之元素的新陣列。

### 描述

- `filter()` 會將所有陣列中的元素分別傳入 `callback` 函式當中，並將所有回傳 `true` 的元素建構成一個新的陣列。
- `filter()` 不會修改呼叫它的原始陣列。
- 回傳的新陣列在 `callback` 函式第一次被調用之前就已經被設定。新增至原始陣列的元素不會傳入 `callback`。

### 範例

1. **過濾所有的小數字**
    
    ```jsx
    
    function isBigEnough(value) {
      return value >= 10;
    }
    
    var filtered = [12, 5, 8, 130, 44].filter(isBigEnough);
    // filtered is [12, 130, 44]
    
    ```
    
2. **從 JSON 過濾無效的項目**
    
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
    
    console.log("過濾好的陣列\n", arrByID);
    // 過濾好的陣列
    // [{ id: 15 }, { id: -1 }, { id: 0 }, { id: 3 }, { id: 12.2 }]
    
    console.log("無效的元素數量 = ", invalidEntries);
    // 無效的元素數量 = 4
    
    ```
    
3. **在陣列中搜尋**
    
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
    
4. **ES2015 實作方式**
    
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
    

### 重點整理

- `filter()` 方法用於過濾陣列中的元素，並返回一個新的陣列，該陣列包含通過回呼函式檢驗的元素。
- `callback` 函式會對每個元素進行測試，若回傳 `true` 則保留該元素，否則不保留。
- `filter()` 不會修改原始陣列，且新增至原始陣列的元素不會傳入 `callback`。
- 常用於篩選符合條件的元素，例如過濾小數字、過濾無效項目、搜尋符合條件的元素等。

### JavaScript `Array.prototype.slice()`

`slice()` 方法會回傳一個新陣列物件，為原陣列選擇之 `begin` 至 `end`（不含 `end`）部分的淺拷貝（shallow copy）。原本的陣列將不會被修改。

### 語法

```jsx

arr.slice([begin[, end]])

```

### 參數

- `begin`（選擇性）：自哪一個索引（起始為 0）開始提取拷貝。可使用負數索引，表示由陣列的最末項開始提取。假如 `begin` 為 `undefined`，則 `slice` 會從索引 0 開始提取。
- `end`（選擇性）：至哪一個索引（起始為 0）之前停止提取。`slice` 提取但不包含至索引 `end`。可使用負數索引，表示由陣列的最末項開始提取。若省略了 `end`，則 `slice` 會提取至陣列的最後一個元素（`arr.length`）。

### 回傳值

- 一個包含提取之元素的新陣列。

### 說明

- `slice` 不會修改原本的陣列，而是回傳由原本的陣列淺層複製的元素。
- 如果元素是個對象引用（不是實際的對象），`slice` 會拷貝這個對象引用到新的陣列內。兩個對象引用都引用了同一個對象。如果被引用的對象發生改變，則新的和原來的陣列中的這個元素也會發生改變。
- 對於字串、數字、布林來說（不是 `String`、`Number` 或者 `Boolean` 對象），`slice` 會拷貝這些值到新的陣列內。在別的陣列內修改這些字串、數字或是布林，將不會影響另一個陣列。
- 如果添加了新的元素到另一個陣列內，則另一個不會受到影響。

### 範例

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
    
3. **類陣列（Array-like）物件**
    
    ```jsx
    
    function list() {
      return Array.prototype.slice.call(arguments);
    }
    
    var list1 = list(1, 2, 3); // [1, 2, 3]
    
    ```
    

### 重點整理

- `slice()` 方法會回傳一個新陣列，包含原陣列中從 `begin` 到 `end`（不含 `end`）的元素。
- `slice()` 不會修改原本的陣列。
- `begin` 和 `end` 參數可為負數，表示從陣列末尾開始計算。
- 若省略 `end` 參數，則會提取至陣列的最後一個元素。
- `slice()` 方法對於對象引用會進行淺層拷貝，即引用相同對象，對於字串、數字和布林值會拷貝其值。
- 可以用於類陣列物件，如 `arguments`。

### 解構賦值（Destructuring Assignment）

解構賦值語法是一種 JavaScript 運算式，可以將陣列或物件中的資料解開並擷取成為獨立變數。

### 基本語法

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

### 陣列解構

1. **基本變數指定**
    
    ```jsx
    const foo = ["one", "two", "three"];
    const [red, yellow, green] = foo;
    console.log(red); // "one"
    console.log(yellow); // "two"
    console.log(green); // "three"
    
    ```
    
2. **宣告指派分開敘述**
    
    ```jsx
    let a, b;
    [a, b] = [1, 2];
    console.log(a); // 1
    console.log(b); // 2
    
    ```
    
3. **預設值**
    
    ```jsx
    let a, b;
    [a = 5, b = 7] = [1];
    console.log(a); // 1
    console.log(b); // 7
    
    ```
    
4. **變數交換**
    
    ```jsx
    let a = 1;
    let b = 3;
    [a, b] = [b, a];
    console.log(a); // 3
    console.log(b); // 1
    
    ```
    
5. **解析函式回傳的陣列**
    
    ```jsx
    function f() {
      return [1, 2];
    }
    let a, b;
    [a, b] = f();
    console.log(a); // 1
    console.log(b); // 2
    
    ```
    
6. **忽略某些回傳值**
    
    ```jsx
    function f() {
      return [1, 2, 3];
    }
    const [a, , b] = f();
    console.log(a); // 1
    console.log(b); // 3
    
    ```
    
7. **解構剩餘部分到變數**
    
    ```jsx
    const [a, ...b] = [1, 2, 3];
    console.log(a); // 1
    console.log(b); // [2, 3]
    
    ```
    

### 物件解構

1. **基本指派**
    
    ```jsx
    const o = { p: 42, q: true };
    const { p, q } = o;
    console.log(p); // 42
    console.log(q); // true
    
    ```
    
2. **無宣告指派**
    
    ```jsx
    let a, b;
    ({ a, b } = { a: 1, b: 2 });
    
    ```
    
3. **指派到新變數名稱**
    
    ```jsx
    const o = { p: 42, q: true };
    const { p: foo, q: bar } = o;
    console.log(foo); // 42
    console.log(bar); // true
    
    ```
    
4. **預設值**
    
    ```jsx
    const { a = 10, b = 5 } = { a: 3 };
    console.log(a); // 3
    console.log(b); // 5
    
    ```
    
5. **指定新變數名稱及預設值**
    
    ```jsx
    const { a: aa = 10, b: bb = 5 } = { a: 3 };
    console.log(aa); // 3
    console.log(bb); // 5
    
    ```
    
6. **從函式參數的物件中提取屬性**
    
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
    
7. **設定函式參數的預設值**
    
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
    
8. **巢狀物件或陣列解構**
    
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
    
9. **循環取出解構**
    
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
    
10. **以物件運算屬性名稱解構**
    
    ```jsx
    let key = "z";
    let { [key]: foo } = { z: "bar" };
    console.log(foo); // "bar"
    
    ```
    
11. **在物件解構時使用其餘變數**
    
    ```jsx
    let { a, b, ...rest } = { a: 10, b: 20, c: 30, d: 40 };
    console.log(a); // 10
    console.log(b); // 20
    console.log(rest); // { c: 30, d: 40 }
    
    ```
    
12. **解出不符合識別字的屬性**
    
    ```jsx
    const foo = { "fizz-buzz": true };
    const { "fizz-buzz": fizzBuzz } = foo;
    console.log(fizzBuzz); // true
    
    ```
    
13. **混合使用陣列及物件解構**
    
    ```jsx
    const props = [
      { id: 1, name: "Fizz" },
      { id: 2, name: "Buzz" },
      { id: 3, name: "FizzBuzz" },
    ];
    
    const [, , { name }] = props;
    console.log(name); // "FizzBuzz"
    
    ```
    

### 總結

解構賦值是 JavaScript 中非常有用的語法，能夠簡化從陣列和物件中提取資料的過程，使程式碼更加簡潔和可讀。理解並掌握解構賦值，能夠提升開發效率並減少出錯機會。

ES module &import/export

- React 非常早就擁抱了現代化前端工程中的重要技術：模組化。尤其是在基於 component base 的開發方式下，我們很常會將不同的 component 拆分成不同的檔案，並且互不干擾，只有在有需要時才手動相互引用。ES module 作為目前標準的 JS 模組系統也是必須先熟悉掌握的技術

### **瀏覽器中運行**

如果要在瀏覽器運行模組化，可以在 `<script>` 標籤加上 `type="module"`，接下來無論是使用行內或是外部的 JS 都能運用模組功能。

```html
<script type="module"></script>
```

當然，這樣的模組功能並非所有瀏覽器都能夠運行，如果要同時兼顧新舊瀏覽器，可以改用以下做法：

```html
<!-- 支援 module 語法的新瀏覽器 -->
<script type="module" src="module.js"></script>

<!-- 不支援 module 語法此段會被新型瀏覽器忽略 -->
script nomodule src="IENotGood.js"></script>

```

## **Export 匯出**

`export` 可以將函式、物件甚至是純值匯出，大部分運用上都是匯出物件（函式）為主，畢竟純值作為模組意義並不大。

export 又可區分為兩種，這兩種的匯出手法略有不同，也會影響到 import 的運用，所以在運用前請先明確區分這兩種的差異（非常重要）：

- named export（具名匯出）：可匯獨立的物件、變數、函式等等，**匯出前必須給予特定名稱**，而匯入時也必須使用相同的名稱。另外，一個檔案中可以有**多個** `named export`。
- default export（預設匯出）：一個檔案僅能有**唯一**的 `default export`，而此類型不需要給予名稱。

除此之外，兩者也可共存於同一個檔案內，只不過 `default export` 僅能有一個。

### **default export（預設匯出）**

`default export` 匯出時不需要預先賦予名稱，可以在 `import` 時另外賦予，但要特別注意 `export default` 每個檔案僅能有一個。

直接匯出純值或表達式結果。

```
export default 1;
```

預先定義一個變數並匯出，這種方式結果與上述的純值一樣。

```
const a = 1
export default a;

```

export default 匯出物件是最常見的使用方式，此方法通常也會搭配物件的縮寫形式（Object shorthand）。

```
const obj = { name: 'obj' };
const obj2 = { name: 'obj2' };
exportdefault { obj, obj2 };
```

上段介紹的具名匯出所匯出的函式必須使用**函數陳述式**，而 `export default` 則可以直接使用匿名函式的形式匯出，就不需要預先定義。

```
// 匯出匿名函式
export default function() {
  console.log('這是一段函式');
}

// 匯出 
class export defaultclass {
constructor(name) {
    this.name = name;
  }
callName() {
    console.log(this.name);
  }
}
```

### **named export（具名匯出）**

`named export` 是將物件、函式等等預先賦予在特定的名稱上才能匯出，並且在 `import` 時也必須使用**相同的名稱**才能取到相同的變數或物件。

方法 1：具名匯出是需要將變數、物件預先宣告後再進行匯出，因此可以在 `export` 後緊接 `let`、`const` 宣告後再進行匯出。

```
// let, const 純值
export let a = 1;
export let obj = { name: 'obj'};

```

方法 2（使用率高）：使用函式陳述式匯出，這種方式與上述概念是相近的，一樣是先宣告再匯出。

```
// 具名方法
export function fn() {
  console.log('這是一段函式')
}

```

方法 3（使用率高）：使用物件縮寫的形式（Object shorthand）匯出物件，算是較為普遍運用的方式，可預先定義好所有的物件、方法後，在文件的結尾統一匯出。

```
const b = 2;
const obj2 = { name: 'obj2' };
const obj3 = { name: 'obj3' };

export { b, obj2, obj3 };

```

小技巧：再匯出前可另外使用 `as` 修改名稱。

```
const obj2 = { name: 'obj2' };
export { obj2as objNewName };

```

### **並存**

具名、預設匯出兩種方法可以並存在同一個檔案內，預設匯出僅能有一個。

```
exportconst obj = { name: 'obj' };
exportdefaultfunction() {
  console.log('這是一段函式');
}

```

## **Import 匯入**

匯入的方式會與因為匯出方法不同而改變，因此必須清楚外部資源的匯出方式，如果是第三方資源則可以透過文件了解該如何匯入。

### **匯入 default export 並賦予名稱**

預設匯出每個檔案僅會有一個，並且不會給予名稱，這種匯入方式會將預設匯出的模組引入，並且重新賦予一個變數名稱。

```
// export file 
export default function() {
  console.log('這是一段函式');
}

// import file 
import fn from './defaultModule.js';
fn();// 直接執行函式解釋

```

### **匯入 named export**

具名的匯出方式，則需要使用**解構的語法**將特定的模組取出（命名需與匯出的名稱一致），並且只有被匯入的原始碼片段才能夠被執行。

```
// export file
export const obj = { name: 'obj'};// 此段如果沒有被匯入，則無法運作
export function fn() {
  console.log('這是一段函式')
}

// import file
import { fn } from './module.js';
fn();
```

也可以透過解構同時匯入多個物件、變數、函式等等。

```
// import file
import { fn, obj }from './module.js';
fn();
console.log(obj)

```

### **重新命名**

具名匯出的物件、變數本身就帶有固定的名稱，如果要避免與當前的作用域產生衝突，則可以使用 `as`(alias) 來重新命名匯入的名稱。

可以在解構時針對單一的物件、變數重新賦予名稱：

```
// export file
export const obj = { name: 'obj'};
export function fn() {
  console.log('這是一段函式')
}

// import file
import { fn as newFn }from './module.js';
newFn();

```

具名匯入亦可使用 `*` 來全部匯入，這時候就必須搭配 `as` 指向一個新的物件變數，此物件的屬性則會帶上所匯入的內容。

```
// import file 全部匯入並賦予至一個物件上
import * as name from './module.js';
name.fn();
console.log(name.obj);

```

### **同時匯入預設、具名**

匯出時可同時存在兩種形式，因此匯入時也同樣支援。以下片段來說，在匯入時前者是帶入 `default export`，逗點後方則是帶入 `named export`：

```
import defaultExport, * as name from "module-name";
```

以下程式碼分別執行了：

1. 匯入 `default export` 並賦予 `fn` 的名稱
2. 匯入全部的 `named export`，並給賦予至 `named` 的物件上
    
    ```
    // export file
    export const obj = { name: 'obj' };
    export default function() {
      console.log('這是一段函式');
    }
    
    // import file
    import fn, *as named from './defaultModule.js';
    fn();
    console.log(named.obj);解釋
    
    ```
    

### **匯入 Side Effect 模組**

有些模組並沒有實作 `export`，例如可直接執行的函式檔案，載入後會直接執行，不需要例外的呼叫即可作為 **Side Effect 模組**。

常見案例如早期版本的框架，直接將方法綁定於 window，因此不需要另外呼叫即可運作，如：`jQuery`、`angularJs` 就屬於此類型。

範例如下：模組檔案不需要進行匯出，直接 `import` 後就能運行。

```
// module file
(function() {
  console.log('IIFE');
})();

// import file
import './fn.js';

```

## **要用 `default` 或 `named`**

`default` 是非常易於使用的，針對只有單一元件、模組的檔案匯出上相對直覺很多。

但在針對此議題來說，也有查閱過部分的文件，許多都是提到 export default 有管理上的問題，如：

- 具名匯入時，命名須完全一致才可匯入，增加開發的嚴謹性
- 預設匯入時，無法確認該模組內是否有特定變數

因此在開發大型專案、開源套件、眾多模組時，大多都會推薦使用 `named export` 的形式，不過這並非強制性的要求，大家也可以是自己開發上的需求做選擇。

### 什麼是 async？什麼是 await？

在 JavaScript 的世界，同步 sync 和非同步 async 的愛恨情仇，就如同偶像劇一般的剪不斷理還亂，特別像是`setTimeout`、`setInterval`、`MLHttpRequest`或`fetch`這些同步非同步混雜的用法，都會讓人一個頭兩個大，幸好 ES6 出現了 promise，ES7 出現了 async、await，幫助我們可以更容易的進行程式邏輯的撰寫。

> 同步：在「同一個步道」比賽「接力賽跑」，當棒子沒有交給我，我就得等你，不能跑。
> 
> 
> 非同步：在「不 ( 非 ) 同步道」比賽「賽跑」，誰都不等誰，只要輪到我跑，我就開始跑。
> 

!https://www.oxxostudio.tw/img/articles/201706/javascript-promise-settimeout-1.jpg

在 ES7 裡頭 async 的本質是 promise 的語法糖 ( 包裝得甜甜的比較好吃下肚 )，***只要 function 標記為 async，就表示裡頭可以撰寫 await 的同步語法***，而 await 顧名思義就是「等待」，它會確保一個 promise 物件都解決 ( resolve ) 或出錯 ( reject ) 後才會進行下一步，當 async function 的內容全都結束後，會返回一個 promise，這表示後方可以使用`.then`語法來做連接，基本的程式長相就像下面這樣：

```jsx
async function a(){
  await b();
  .....// 等 b() 完成後才會執行await c();
  .....// 等 c() 完成後才會執行await new Promise(resolve=>{
    .....
  });
  .....// 上方的 promise 完成後才會執行
}
a();
a().then(()=>{
  .....// 等 a() 完成後接著執行
});

```

# 利用 async 和 await 做個「漂亮的等待」

如果我們把上面的範例修改為 async 和 await 的寫法，突然就發現程式碼看起來非常的乾淨，因為 ***await 會等待收到 resolve 之後才會進行後面的動作，如果沒有收到就會一直處在等待的狀態***，所以什麼時候該等待，什麼時候該做下一步，就會非常清楚明瞭，這也就是我所謂「漂亮的等待」。

> 注意，await 一定得運行在 async function 內！
> 

```jsx
~async function{// ~ 開頭表示直接執行這個 function，結尾有 ()const delay = (s) => {
    return new Promise(function(resolve){// 回傳一個 promisesetTimeout(resolve,s);// 等待多少秒之後 resolve()
    });
  };

  console.log(1);// 顯示 1
  await delay(1000);// 延遲ㄧ秒
  console.log(2);// 顯示 2
  await delay(2000);// 延遲二秒console.log(3);// 顯示 3
}();
解釋

```

# 搭配 Promise

基本上只要有 async 和 await 的地方，就一定有 promise 的存在，promise 顧名思義就是「保證執行之後才會做什麼事情」，剛剛使用了 async、await 和 promise 改善`setTimeout`這個容易出錯的非同步等待，針對`setInterval`，也能用同樣的做法修改，舉例來說，下面的程式碼執行之後，並「***不會***」如我們預期的「***先顯示 1，再顯示 haha0...haha5，最後再顯示 2***」，而是「***先顯示 1 和 2，然後再出現 haha0...haha5***」，因為雖然程式邏輯是從上往下，但在 count function 裏頭是非同步的語法，導致自己走自己的路，也造成了結果的不如預期。

```jsx
const count = (t,s) => {
  let a = 0;
  let timer = setInterval(() => {
    console.log(`${t}${a}`);
    a = a + 1;
    if(a>5){
      clearInterval(timer);
    }
  },s);
};

console.log(1);
count('haha', 100);
console.log(2);

```

!https://www.oxxostudio.tw/img/articles/201908/js-async-await-01.jpg

這時我們可以透過 async、await 和 promise 進行修正，在顯示 1 之後，會「***等待***」count function 結束後再顯示 2。

```jsx
~async function(){
  const count = (t,s) => {
      return new Promise(resolve => {
        let a = 0;
        let timer = setInterval(() => {
          console.log(`${t}${a}`);
          a = a + 1;
          if(a>5){
            clearInterval(timer);
            resolve();// 表示完成
          }
        },s);
      });
    };

  console.log(1);
  await count('haha', 100);
  console.log(2);
}();

```

!https://www.oxxostudio.tw/img/articles/201908/js-async-await-02.jpg

除了`setTimeout`和`setInterval`，這也可以用於像是「***輸入文字***」的情境，過去我們要做到「***連續輸入***」文字，可能要層層疊疊寫個好幾個 callback，現在如果使用 async 和 await，就能夠很簡單的實現連續輸入的情境，程式碼看起來也更乾淨簡潔。

```jsx
// HTML 為一個輸入框、一個按鈕和一個 h1 標籤// <input id="a"></input><button id="b">send</button>// <h1 id="h"></h1>

~async function(){
  const input = () => {
    return new Promise(resolve =>{
      const btnClick = () =>{
        h.insertAdjacentHTML('beforeend', a.value + '<br/>');// 輸入後在 h1 裡添加內容
        a.value = '';// 清空輸入框
        a.focus();// 將焦點移至輸入框
        b.removeEventListener('click', btnClick);// removeEventListener 避免重複綁定事件
        resolve();// 完成
      };
      b.addEventListener('click', btnClick);// 綁定按鈕事件
    });
  };
  h.insertAdjacentHTML('beforeend', '開始<br/>');
  await input();//  等待輸入，輸入後才會進行下一步await input();
  await input();
  h.insertAdjacentHTML('beforeend', '結束');
}();

```

!https://www.oxxostudio.tw/img/articles/201908/js-async-await-03.gif

# 搭配 Fetch

`fetch`最後回傳的是 promise，理所當然的透過 async 和 await 操作是最恰當不過的。

複製 JSON 格式的連結 ( 需要註冊登入才能看得到連結 )，透過`fetch`的`json()`方法處理檔案，目標顯示出「高雄市的即時氣溫」。

透過 async 和 await 的美化程式碼，得到的結果完全不需要 callback 的輔助，就能按照我們所期望的順序進行。( 先顯示「開始抓氣象」，接著顯示「高雄市的氣溫」，最後顯示「總算結束了」 )

```jsx
~async function(){
    console.log('開始抓氣象');// 先顯示「開始抓氣象」await fetch('氣象局 json 網址')// 帶有 await 的 fetch
    .then(res => {
        return res.json();
    }).then(result => {
        let city = result.cwbopendata.location[14].parameter[0].parameterValue;
        let temp = result.cwbopendata.location[14].weatherElement[3].elementValue.value;
        console.log(`${city}的氣溫為 ${temp} 度 C`);
    });
    console.log('總算結束了');// 抓完氣象之後再顯示「總算結束了」
}();
```
