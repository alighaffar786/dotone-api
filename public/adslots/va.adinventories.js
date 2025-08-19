var ADTOOLS = {
  qs: (function (a) {
    if (a == "") return {};
    var b = {};
    for (var i = 0; i < a.length; ++i) {
      var p = a[i].split("=");
      if (p.length != 2) continue;
      try {
        b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
      } catch (err) {
        b[p[0]] = decodeURIComponent(escape(p[1].replace(/\+/g, " ")));
      }
    }
    return b;
  })(window.location.search.substr(1).split("&")),

  getJSONP: function (url, success) {
    var ud = "_" + +new Date();
    var script = document.createElement("script");
    var head =
      document.getElementsByTagName("head")[0] || document.documentElement;

    window[ud] = function (data) {
      head.removeChild(script);
      success && success(data);
    };

    script.src = url.replace("callback=?", "callback=" + ud);
    head.appendChild(script);
  },

  getRandomElements: function (arr, n) {
    if (arr && n) {
      var result = [],
        len = arr.length;

      while (result.length < n) {
        var x = Math.floor(Math.random() * len);
        result.push(arr[x]);
      }

      return result;
    } else {
      return [];
    }
  },
};

var ADSETUP = {
  adSlotId: (function () {
    return ADTOOLS.qs["id"];
  })(),

  source: (function (mode) {
    if (mode == "production") return "//t.adotone.com/track/slot.json";
    else if (mode == "staging") return "//staging.vbtrax.com/track/slot.json";
    else return "//localhost:4000/track/slot.json";
  })(ADTOOLS.qs["mode"]),

  dimension: (function () {
    return [ADTOOLS.qs["width"], ADTOOLS.qs["height"]].join("x");
  })(),

  adLength: (function (dimension) {
    if (["300x250", "120x600", "160x600", "728x90"].indexOf(dimension) >= 0) {
      return 2;
    } else if (["750x300"].indexOf(dimension) >= 0) {
      return 4;
    } else {
      return 1;
    }
  })([ADTOOLS.qs["width"], ADTOOLS.qs["height"]].join("x")),
};

var ADSERVER = {
  start: function () {
    ADTOOLS.getJSONP(
      ADSETUP.source + "?id=" + ADSETUP.adSlotId + "&callback=?",
      function (response) {
        var html = [];
        var htmlTemplate = $(".d" + ADSETUP.dimension).html();
        var bannerTemplate = $(".banner").html();
        var chosenAds = ADTOOLS.getRandomElements(
          response.ads,
          ADSETUP.adLength
        );

        for (idx in chosenAds) {
          var ad = chosenAds[idx];

          $.extend(ad, response.global);
          var rendered = null;

          if (ad && ad.type === "ImageCreative") {
            rendered = Mustache.render(bannerTemplate, ad);
            var $html = $($.parseHTML(rendered));
            html.push($("<div>").append($html.clone()).html());
            break;
          } else if (ad && ad.type === "TextCreative") {
            rendered = Mustache.render(htmlTemplate, ad);
            var $html = $($.parseHTML(rendered));

            if (ad.coupon_code && $.trim(ad.coupon_code) !== "") {
              $html.find(".coupon-panel").show();
              $html.find(".price").hide();
            } else {
              $html.find(".coupon-panel").hide();
              $html.find(".price").show();
              var $original = $html.find(".price .original");
              var $discount = $html.find(".price .discount");
              var $separator = $html.find(".info-separator");
              var discountExist = $discount.text().trim() !== "";
              var originalExist = $original.text().trim() !== "";

              if (discountExist) {
                $original.addClass("strike");
                $discount.prev(".info-label").show();
              } else {
                $discount.prev(".info-label").hide();
              }

              if (originalExist) {
                $original.prev(".info-label").show();
              } else {
                $original.prev(".info-label").hide();
              }

              (!originalExist && discountExist) ||
              (originalExist && !discountExist)
                ? $separator.hide()
                : $separator.show();
            }
            html.push($("<div>").append($html.clone()).html());
          }
        }

        $("#canvas").addClass("d" + ADSETUP.dimension);
        $("#canvas .cell-group").html(html);
        $(".textfitable", "#canvas .cell-group").each(function () {
          textFit(this, { alignVert: true, multiLine: true });
        });
      }
    );
  },
};
