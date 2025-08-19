var ADLINKS = ADLINKS || {

  source: function (mode) {
    if (mode === 'production') {
      return 'https://api.pub.affiliates.one/api/v2/affiliates/links/generate';
    } else if (mode === 'staging') {
      return 'http://staging.api.affiliates.com.tw/api/v1/affiliates/links/generate';
    } else {
      return 'http://localhost:4000/api/v2/affiliates/links/generate';
    }
  },

  debounceMap: new Map(),

  debounce: function(func, key) {
    key = key || 'timeout'
    var thisAdLink = this;
    var delay = 3000

    if (thisAdLink.debounceMap.has(key)) {
      clearTimeout(thisAdLink.debounceMap.get(key))
    }

    var timeout = setTimeout(function() {
      func()
      thisAdLink.debounceMap.delete(key)
    }, delay)

    thisAdLink.debounceMap.set(key, timeout)
  },

  mergeObj: function () {
    var obj = {},
      i = 0,
      il = arguments.length,
      key;
    for (; i < il; i++) {
      for (key in arguments[i]) {
        if (arguments[i].hasOwnProperty(key)) {
          obj[key] = arguments[i][key];
        }
      }
    }
    return obj;
  },

  needToRefresh: function (fromPage, fromStorage) {
    var isInvalid = window.localStorage.getItem('adLinkInvalid') === '1';

    if (isInvalid) return false

    for (var i = 0; i < fromPage.length; ++i) {
      if (fromStorage.indexOf(fromPage[i]) < 0) {
        return true;
      }
    }

    return false;
  },

  observeDOM: (function () {
    var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

    return function (obj, callback) {
      if (!obj || obj.nodeType !== 1) return;

      if (MutationObserver) {
        // define a new observer
        var mutationObserver = new MutationObserver(callback)

        // have the observer observe foo for changes in children
        mutationObserver.observe(obj, { childList: true, subtree: true })
        return mutationObserver
      }

      // browser support fallback
      else if (window.addEventListener) {
        obj.addEventListener('DOMNodeInserted', callback, false)
        obj.addEventListener('DOMNodeRemoved', callback, false)
      }
    }
  })(),

  getAdLinkUrls: function () {
    var currentDay = new Date().getDay().toString();
    var adLinkExpiration = window.localStorage.getItem('adLinkExpiration');

    if (adLinkExpiration && adLinkExpiration === currentDay) {
      return JSON.parse(window.localStorage.getItem('adLinkUrls'));
    } else {
      window.localStorage.removeItem('adLinkUrls');
      return {};
    }
  },

  setAdLinkUrls: function (data) {
    var existingData = this.getAdLinkUrls();
    window.localStorage.setItem('adLinkUrls', JSON.stringify(this.mergeObj(existingData, data)));
    window.localStorage.setItem('adLinkExpiration', new Date().getDay());
  },

  getTrackingLinks: function (originalUrls, data, customData) {
    var url = ADLINKS.source(data.mode);
    var additionalData = {};
    var thisClass = this;

    if (typeof customData === "object") {
      additionalData = customData;
    }

    var xhr = new XMLHttpRequest;

    // IE friendly for onloadstart, otherwise
    // it will throw invalid state error
    xhr.onloadstart = function (ev) {
      xhr.responseType = 'json';
    }

    xhr.addEventListener('load', function () {
      if (xhr.status === 201) {
        // On IE, xhr.response is a string
        if (typeof xhr.response === "string") {
          var jsonResponse = JSON.parse(xhr.response);
          if (jsonResponse.data) {
            thisClass.setAdLinkUrls(jsonResponse.data);
          }
        } else {
          thisClass.setAdLinkUrls(xhr.response.data);
        }
      } else if (xhr.status === 404) {
        window.localStorage.setItem('adLinkInvalid', '1')
      } else {
        console.log(xhr.status + ': ' + xhr.statusText);
      }
    });

    xhr.open('POST', url);
    xhr.setRequestHeader('Content-type', 'application/json');

    var body = JSON.stringify({
      hostname: window.location.href,
      affiliate_id: data.affiliateId,
      channel_id: additionalData.channelId,
      original_urls: originalUrls
    });

    xhr.send(body);
  },

  renderAdLinks: function (data, customData) {
    var links = document.getElementsByTagName('a');
    var originalUrls = {};
    var linkWasClicked = false;
    var buttonDown = false;
    var clickedLink = null;
    var domainsFromThisPage = {};

    var parser = document.createElement('a');

    for (var index = 0; index < links.length; index++) {
      var l = links[index];
      var thisClass = this;

      parser.href = l.href;
      host = parser.host.replace(/^www\./, '');

      if (host) {
        domainsFromThisPage[host] = domainsFromThisPage[host] ?
          domainsFromThisPage[host] + 1 :
          1;
      }

      var linkId = 'converly-' + index;

      l.setAttribute('data-adlink-id', linkId);
      l.setAttribute('data-adlink-host', host);
      l.setAttribute('data-adlink-original', l.href);

      originalUrls[linkId] = l.href;

      l.onmousedown = function (e) {
        try {
          var baseUrl = thisClass.getAdLinkUrls()[this.getAttribute('data-adlink-host')].tracking_url;

          if (baseUrl) {
            trackingUrl = baseUrl;
            var encodedHref = encodeURIComponent(this.href);
            var url = trackingUrl.replace('-href-', encodedHref);
            url = url.replace('-link-id-', linkId);

            linkWasClicked = true;

            if (e.button !== 2) {
              // on right click, do not need to wait for button up to reset href
              buttonDown = true;
            }

            clickedLink = this;
            this.href = url;
          }
        } catch (err) { };
      };
    }

    document.onmouseup = function () {
      buttonDown = false;
    }

    document.onmousemove = function () {
      if (linkWasClicked && !buttonDown && clickedLink) {
        clickedLink.href = clickedLink.getAttribute('data-adlink-original');
        linkWasClicked = false;
        clickedLink = null;
      }
    };

    try {
      // Check if we need to get tracking links from API
      var adlinkUrls = this.getAdLinkUrls();
      var clientKeys = Object.keys(domainsFromThisPage);
      var storageKeys = adlinkUrls && Object.keys(adlinkUrls);

      console.log('AdLink is rendered');

      if (this.needToRefresh(clientKeys, storageKeys)) {
        console.log('AdLink is refreshed');
        this.getTrackingLinks(originalUrls, data, customData);
      }
    } catch (err) {
      console.log(err);
      this.getTrackingLinks(originalUrls, data, customData);
    }
  },

  getLinks: function (data, customData) {
    console.log("AdLink is active");
    var thisAdLink = this;

    function renderAdLinks() {
      console.log('AdLink is run')
      thisAdLink.renderAdLinks(data, customData)
    }

    thisAdLink.debounce(renderAdLinks)

    // Listen for any changes in DOM for new links
    var t = document.querySelector('body');
    thisAdLink.observeDOM(t, function (mutations) {
      mutations.forEach(function (m) {
        for (var index = 0; index < m.addedNodes.length; index++) {
          var node = m.addedNodes[index];

          if (node.nodeName === 'A') {
            thisAdLink.debounce(renderAdLinks)
            break;
          }
        }
      });
    });
  }
};
