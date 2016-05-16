/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function $() {
	return document.querySelector.apply(document, arguments);
}

if (navigator.userAgent.indexOf("Xcode") != -1) {
	document.documentElement.classList.add("xcode");
}

var jumpTo = $("#jump-to");

if (jumpTo) {
	jumpTo.addEventListener("change", function(e) {
		location.hash = this.options[this.selectedIndex].value;
	});
}

function hashChanged() {
	if (/^#\/\/api\//.test(location.hash)) {
		var element = document.querySelector("a[name='" + location.hash.substring(1) + "']");

		if (!element) {
			return;
		}

		element = element.parentNode;

		element.classList.remove("hide");
		fixScrollPosition(element);
	}
}

function fixScrollPosition(element) {
	var scrollTop = element.offsetTop - 150;
	document.documentElement.scrollTop = scrollTop;
	document.body.scrollTop = scrollTop;
}

[].forEach.call(document.querySelectorAll(".section-method"), function(element) {
	element.classList.add("hide");

	element.querySelector(".method-title a").addEventListener("click", function(e) {
		var info = element.querySelector(".method-info"),
			infoContainer = element.querySelector(".method-info-container");

		element.classList.add("animating");
		info.style.height = (infoContainer.clientHeight + 40) + "px";
		fixScrollPosition(element);
		element.classList.toggle("hide");
		if (element.classList.contains("hide")) {
			e.preventDefault();
		}
		setTimeout(function() {
			element.classList.remove("animating");
		}, 300);
	});
});

window.addEventListener("hashchange", hashChanged);
hashChanged();

// firebase analytics
!function(){
  var analytics=window.analytics=window.analytics||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","group","track","ready","alias","page","once","off","on"];analytics.factory=function(t){return function(){var e=Array.prototype.slice.call(arguments);e.unshift(t);analytics.push(e);return analytics}};for(var t=0;t<analytics.methods.length;t++){var e=analytics.methods[t];analytics[e]=analytics.factory(e)}analytics.load=function(t){var e=document.createElement("script");e.type="text/javascript";e.async=!0;e.src=("https:"===document.location.protocol?"https://":"http://")+"cdn.segment.com/analytics.js/v1/"+t+"/analytics.min.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(e,n)};analytics.SNIPPET_VERSION="3.0.1";

  // switch for prod or staging:
  var domain = location.host.split('.').slice(-2).join('.');
  var key = (domain === 'firebase.com' || domain === 'firebaseio.com') ? 'ru0h6g04hek' : '9ug8ez2ha8';
  analytics.load(key);
  analytics.page();
}}();
// end firebase analytics
