As described in the official documentation, React is a tool for "building UIs." In the browser, the medium through which we present the UI is the DOM. The DOM is tied to the browser's rendering engine, so manipulating the DOM will directly update the rendered output. In modern front-end solutions like React, we generally don't manipulate the DOM directly; instead, we rely on an abstraction layer provided by React to manage the DOM for us. Most of the time, we only need to interact with the APIs that React provides.

To truly understand how React works from the ground up, we must start by examining the relationship between the DOM and React's abstract layer.

---

# **DOM**

Before diving into React itself, let's briefly review the DOM in the context of the browser.

The DOM (Document Object Model) is a tree-like data structure that exists within the browser's JavaScript environment to describe the nodes in the browser's display. Each node is essentially a JavaScript object containing attributes and providing interfaces (methods) for inserting and manipulating the DOM.

Since DOM nodes are tied to the browser's rendering engine, manipulating the DOM triggers a series of updates to the display. Thus, DOM operations are relatively expensive in terms of performance. When there are many DOM updates in a short period, it can cause noticeable lag in the display. Therefore, minimizing DOM operations—or more specifically, achieving the desired display results with as few DOM operations as possible—is crucial for front-end performance optimization.

---

# **Virtual DOM**

Before jumping into React itself, we need to introduce an important concept that underpins React's core mechanism: the Virtual DOM.

As mentioned earlier, manipulating the DOM is a performance-intensive operation because it directly involves the browser's rendering engine. To mitigate the performance issues associated with manipulating the "real" DOM, the concept of the "Virtual DOM" was developed. Conceptually, the Virtual DOM is an abstract representation of the real DOM, also organized as a tree structure.

**Each Virtual DOM element is a plain JavaScript object that attempts to describe what a real DOM element is supposed to look like** (including the element type, attributes, children, etc.). By using rendering logic, we can convert Virtual DOM elements into actual DOM elements to update the browser's display.

A common misconception when learning React is that the "Virtual DOM is a copy of the real DOM." However, the truth is quite the opposite:

We first define the desired UI structure using the Virtual DOM, then convert this structure into a real DOM Tree (manipulating the real DOM Tree to match the Virtual DOM). Hence, the synchronization between the two should be **one-way from Virtual DOM to DOM**. Developers interact with and manage the Virtual DOM, while the synchronization from Virtual DOM to real DOM is handled automatically.

So, what's the benefit of adding this extra layer of processing?

You can think of the Virtual DOM as a rehearsal stage for generating the display. Whenever there's a need to update the UI, we can follow this process to update the display:

!https://miro.medium.com/max/1400/1*ZXE-64hJcWYfNjmWAjiRmw.png

1. **Generate a new Virtual DOM Tree using predefined templates as the new rehearsal result**
2. **Compare this new Virtual DOM Tree with the previous one to identify the differences, which are the parts that need updating**
3. Update the real DOM Tree only where there are differences, to refresh the browser display

This process minimizes the range of real DOM operations, reducing the performance cost associated with DOM manipulation.

Although generating the Virtual DOM and comparing it with the old one has its performance costs, these operations are done on plain JavaScript objects. Unlike the real DOM, the Virtual DOM isn't tied to the browser's rendering engine, making the overall performance cost much lower than frequent and extensive real DOM manipulations.

Many mainstream front-end frameworks and solutions use this concept to implement and manage their abstraction layers, including our main topic: React. Different frameworks might have different implementations and comparison methods for the Virtual DOM, but they all share this idea of using an abstract layer to handle DOM processing. Since this is a series about React, the above description is based on the concepts adopted by React.

If you find these concepts a bit abstract and hard to imagine in actual code, don't worry! This introduction is meant to provide a foundational understanding of the Virtual DOM's concept and design rationale. In the following sections, we'll dive deeper into the role of the Virtual DOM in React's update process and map these concepts to actual code, helping you gain a deeper appreciation and understanding of how it all works.