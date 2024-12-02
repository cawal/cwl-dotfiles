
// ==UserScript==
// @name        Environment Marker Monolith
// @namespace   Violentmonkey Scripts
// @match       https://*.libercapital.com.br/*
// @exclude-match https://*staging.libercapital.com.br/*
// @grant       GM_addStyle
// @version     1.0
// @author      https://github.com/cawal/
// @description Never execute anything in production
// ==/UserScript==


GM_addStyle(`
    #enviroment-marker {
        background-color: #ff0000 !important;
        border: 0px solid #ac9 !important;
        padding-left: 2em !important;
        position: fixed;
        min-height: 30px;
        min-width: 100%;
        z-index: 1000;
	}
`)


const body = document.querySelector("body");
const container = document.createElement("div");
const label = document.createElement("p");
label.innerHtml = "PRODUÇÃO"
container.setAttribute("id", "enviroment-marker");
body.insertBefore(container, body.childNodes[0]);
container.appendChild(label);
