// ==UserScript==
// @name        cawal's Python Docs 2
// @namespace   Violentmonkey Scripts
// @match       https://docs.python.org/*
// @grant       GM_addStyle
// @version     1.0
// @author      https://github.com/cawal/
// @description Cleaner Python docs
// ==/UserScript==

// CAWAL

GM_addStyle(`
    pre {
        background-color: #ffffff00 ! important;
        border: 0px solid #ac9 ! important;
        padding-left: 2em ! important;
    }
    div.body h1,div.body h2,div.body h3,div.body h4,div.body h5{
        padding: 2em 0 0 0
    }
    dl.function {
        margin-top: 4em;
    }
`)
