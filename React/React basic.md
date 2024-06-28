# **手動建置環境方案**

當專案建置環境有比較客製化的需求時，或為了真正搞懂 React 建置環境的細節，仍然值得去研究並瞭解要如何自己手把手的建立 React 開發環境。因此這裡主要會先點出 React 開發環境的必須元素以及為什麼我們需要它們，至於細節的設定方法網路上有非常多的學習資源可以參考。

# **React 開發環境建置的必要條件**

在嘗試自己動手建置前當然是要先了解 React 開發環境哪些需求是必須要滿足的：

- JSX transformer
    
    在絕大多數情況下，我們都會使用 JSX 語法來進行 React 的開發，因此將 JSX 語法轉換成瀏覽器能夠執行的普通 JS 語法就幾乎成了必要的需求。通常有兩種方式可以做到這件事情：事前靜態轉換，以及 runtime 即時的轉換
    
    - 以 transpiler 進行事前靜態轉換
        - 也就是在開發階段就以專用的轉換工具來將包含 JSX 語法的程式碼轉換成普通的 JS 程式碼，然後瀏覽器實際上就直接吃已經事先轉換好的版本來執行。最主流的 transpiler 選擇像是 [Babel](https://babeljs.io/) 或是 [TypeScript](https://www.typescriptlang.org/) 都有支援 JSX 的轉換功能。這也是我們通常會在開發環境採用的預設方案。並且由於效能考量，這個方式在 production build 時有其必要性
        - 以最常採用的 babel 為例，我們會需要 [@babel/plugin-transform-react-jsx](https://babeljs.io/docs/en/babel-plugin-transform-react-jsx) 這個 plugin 來幫我們做 JSX 的轉換，而我們通常會直接使用已經包含這個 plugin 的 [@babel/preset-react](https://babeljs.io/docs/en/babel-preset-react) 來設定在 babel config 當中
    - 以 CDN 作 runtime 的即時轉換
        - 直接在瀏覽器中讀取尚未被轉換的 JSX 程式碼，並依靠 runtime transpiler 即時的翻譯來轉換成普通 JS
        - 例如 babel 有提供 runtime 版本的 standalone，可以作為 CDN 直接引入。只要在包含 JSX 語法的 `<script>` 標籤上標注 `type="text/jsx"`，babel runtime 就會自動即時將其 JSX 語法進行轉換後再執行：
            
            ```html
            <!DOCTYPE html>
            <html>
              <body>
                <div id="app"></div>
            <!-- 引入 React --><script src="https://unpkg.com/react@18/umd/react.development.js" crossorigin></script>
                <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js" crossorigin></script>
            <!-- 引入 Babel runtime --><script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
                <script type="text/jsx">
                  const root = ReactDOM.createRoot(document.querySelector('#app'));
            // 可以直接在這裡寫 JSX 語法，runtime babel 會即時在瀏覽器端即時轉換後才執行
                  root.render(<h1>Hello, world!</h1>);
                </script>
              </body>
            </html>
            解釋
            
            ```
            
        - 這樣做等同於每次瀏覽器在 JSX 相關的程式執行前都必須花費時間與效能先進行完即時的轉換後，才能開始運行，因此龐大且複雜的應用程式場景時可能有嚴重的效能隱憂
        - 因此非常不建議以這種做法來作為正式的本地開發環境，更完全不應該用於 production build。通常會這樣做是在快速實作一段純演示性質的程式程式的時候才比較合適，例如：在 JSFiddle、codepen 上快速建立一個 React 範例
- 支援 ES6+ 語法
    
    除了 JSX 語法之外，在 React 官方或社群推薦的寫法 best practice 中也處處可見使用到較新的 ES6+ 語法，像是陣列解構、物件解構、spread、rest、arrow function…等等，而這些語法仍然會面臨較老舊瀏覽器的向下相容問題
    
    - 依靠使用者瀏覽器本身原生支援
        - 當然，如果專案本來就完全不打算支援較老舊的瀏覽器，或是也沒有使用到一些更新更潮的語法的話，也可以選擇不處理特別這個問題，讓這些語法在使用者的瀏覽器上直接執行。不過由於通常我們難以控制使用者所使用的瀏覽器種類或版本，時至今日，針對這些近年較新的 ES 語法進行向下相容的轉換仍然有其一定的必要性
    - 以 transpiler 轉換向下相容
        - 如果希望夠過向下相容的轉換來保證能在更多的瀏覽器上執行你的程式碼的話，transpiler 仍然是一個目前推薦的解決方案。如果你使用 babel 的話，通常我們會使用官方已經套裝好的成熟 presets [@babel/preset-env](https://babeljs.io/docs/en/babel-preset-env)，裡面已經內置好所有常見的 ES6+ 語法轉換功能，並且你也可以透過指定目標的瀏覽器支援範圍，來讓他動態的決定哪些語法需要轉換而哪些可以不用
- 支援 ES module
    
    最後，React 也非常早就擁抱了現代化前端工程中的重要技術：模組化。尤其是在基於 component base 的開發方式下，我們很常會將不同的 component 拆分成不同的檔案，並且互不干擾，只有在有需要時才手動相互引用。因此設置一個可以支援 ES module 的環境也是 React 開發幾乎必須的條件
    
    - 用 module bundler 打包
        - 雖然 ES module 語法規格在 2015 年的 ES6 時就已經推出了，但是瀏覽器上的實際原生支援是一直到近兩年才開始慢慢實現，並且相關的整合以及應用也還沒有到非常普及，因此大多情況下我們還是會需要 module bundler 工具來幫我們將本地以 ES module 撰寫的 JS 原始碼們的打包成少數的幾隻 JS 檔案，主流的選擇如：[Webpack](https://webpack.js.org/)、[Parcel](https://parceljs.org/) 以及最近非常火紅的 [Vite](https://vitejs.dev/)