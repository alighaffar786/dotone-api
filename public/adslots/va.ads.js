/*
  possible options for cv_ad_options:
  cv_ad_options = {}
    ad_canvas_id - a string indicates a custom id of HTML element where ad will be displayed.
*/
(function () {
  var protocol = "//";
  // Get current script tag if possible.
  var scriptTag =
    document.currentScript ||
    (function () {
      var scripts = document.getElementsByTagName("script");
      return scripts[scripts.length - 1];
    })();
  var pathToHTML = (function (mode) {
    if (mode == "production") {
      return "cdn.adotone.com/adslots/slot.html";
    } else if (mode == "staging") {
      return "staging.vbtrax.com/adslots/slot-staging.html";
    } else {
      return "localhost:4000/adslots/slot-development.html";
    }
  })(cv_ad_options.mode);

  var iframeURL = [pathToHTML];
  iframeURL.push("?id=" + cv_ad_options.ad_slot_id);
  iframeURL.push("&width=" + cv_ad_options.ad_width);
  iframeURL.push("&height=" + cv_ad_options.ad_height);
  iframeURL.push("&mode=" + cv_ad_options.mode);

  var iframe = document.createElement("iframe");
  iframe.setAttribute("src", protocol + iframeURL.join(""));
  iframe.setAttribute("width", cv_ad_options.ad_width);
  iframe.setAttribute("height", parseInt(cv_ad_options.ad_height) + 9);
  iframe.setAttribute("frameborder", 0);
  iframe.setAttribute("style", "overflow:hidden;");
  iframe.setAttribute("seamless", "seamless"); // HTML5

  var adCanvas = scriptTag.parentNode;
  if (typeof cv_ad_options.ad_canvas_id !== "undefined") {
    adCanvas = document.getElementById(cv_ad_options.ad_canvas_id);
    adCanvas.appendChild(iframe);
  } else {
    adCanvas.insertBefore(iframe, scriptTag);
  }
}).call(this);
