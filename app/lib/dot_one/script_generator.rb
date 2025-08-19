class DotOne::ScriptGenerator
  def self.generate_ad_slot_script(ad_slot)
    <<~PIXEL
      <script type="text/javascript">
        cv_ad_options = {
          ad_slot_id: "#{ad_slot.id}",
          ad_width: "#{ad_slot.width}",
          ad_height: "#{ad_slot.height}",
          mode: "#{Rails.env}"
        };
      </script>
      <script text="text/javascript" src="//#{DotOne::Setup.ad_slot_url}"></script>
    PIXEL
  end

  def self.generate_ad_link_file_content(affiliate)
    <<~PIXEL
      (function() {
        var VARemoteLoadOptions = {
          data: {
            wl: #{DotOne::Setup.wl_id},
            affiliateId: #{affiliate.id},
            mode: '#{Rails.env}'
          }
        };
        var VAcustomData = (typeof ConverlyCustomData === "object") ? ConverlyCustomData : {};
        (function(c, o, n, v, e, r, l, y) {
          c['VARemoteLoadOptions'] = e;
          q = ['affiliate_id=' + e.data.affiliateId, 'wl=' + e.data.wl, 'ts=' + Date.now()].join('&');
          y = o.createElement(n), l = o.getElementsByTagName(n)[0];
          y.async = 1;
          y.src = [v, q].join('?');
          l.parentNode.insertBefore(y, l);
          y.onload = function() {
            ADLINKS.getLinks(e.data, r);
          };
        })(window, document, 'script', '#{DotOne::Setup.ad_link_url}', VARemoteLoadOptions, VAcustomData);
      })();
    PIXEL
  end

  def self.generate_ad_link_script(url, options = {})
    return unless url

    channel_id = options[:channel]&.id || 'null'
    <<~PIXEL
      <script>var ConverlyCustomData = {channelId: #{channel_id}};</script>
      <script async defer src="#{url}"></script>
    PIXEL
  end

  def self.generate_gtm_script
    <<~GTM
    /* GTM Order Data Layer */
    var converlyGTMOrderData = {
      orderTotal: 'REPLACE WITH ORDER TOTAL',
      orderNumber: 'REPLACE WITH ORDER NUMBER',
      revenue: 'REPLACE WITH COMMISSION'
    }
    /* End GTM Order Data Layer */
    GTM
  end

  def self.generate_conversion_pixel_script(mkt_site_id, options = {})
    mkt_site = MktSite.cached_find(mkt_site_id)
    is_gtm = BooleanHelper.truthy?(options[:for_gtm])
    is_order = BooleanHelper.truthy?(options[:order])
    conversion_var = []

    conversion_var << 'conversion: true' if BooleanHelper.truthy?(options[:conversions])

    if is_order
      step_name = options[:step_name].presence || mkt_site.offer&.default_conversion_step&.name

      if is_gtm
        conversion_var << <<~EOS
        conversionData: {
              step: '#{step_name}', /* conversion name */
              orderTotal: '{{orderTotal}}', /* order total */
              order: '{{orderNumber}}', /* order number */
            }
        EOS
      else
        conversion_var << <<~EOS
        conversionData: {
              step: '#{step_name}', /* conversion name */
              revenue: '', /* revenue share */
              orderTotal: '', /* order total */
              order: '', /* order number */
              adv_uniq_id: '' /* optional lead id */
            }
        EOS
      end
    end

    remote_load_options = [
      "whiteLabel: { id: #{DotOne::Setup.wl_id}, siteId: #{mkt_site_id}, domain: 't.adotone.com' }",
      *conversion_var.map(&:chomp),
      'locale: \'en-US\'',
      'mkt: true',
    ]

    if BooleanHelper.truthy?(options[:async])
      <<~PIXEL
        <script type="text/javascript">
          (function () {
            var VARemoteLoadOptions = {
              #{remote_load_options.join(",\n    ")}
            };
            (function (c, o, n, v, e, r, l, y) {
              c['VARemoteLoadOptions'] = e; r = o.createElement(n), l = o.getElementsByTagName(n)[0];
              r.async = 1; r.src = v; l.parentNode.insertBefore(r, l);
            })(window, document, 'script', 'https://cdn.adotone.com/javascripts/va.js', VARemoteLoadOptions);
          })();
        </script>
      PIXEL
    else
      <<~PIXEL
        <script type="text/javascript" src="//cdn.adotone.com/javascripts/va.js"></script>
        <script type="text/javascript">
          VA.remoteLoad({
            #{remote_load_options.join(",\n    ")}
          });
        </script>
      PIXEL
    end
  end

  def self.generate_easystore_pixel(site_id)
    <<~PIXEL
      <script type="text/javascript">
        (function () {
          var VARemoteLoadOptions = {
            whiteLabel: { id: #{DotOne::Setup.wl_id}, siteId: #{site_id}, domain: 't.adotone.com' },
            locale: "en-US",
            mkt: true,
            platform: 'easystore',
          };

          (function (c, o, n, v, e, r, l, y) {
            c['VARemoteLoadOptions'] = e; r = o.createElement(n), l = o.getElementsByTagName(n)[0];
            r.async = 1; r.src = v; l.parentNode.insertBefore(r, l);
          })(window, document, 'script', '#{DotOne::Setup.cdn_url}/javascripts/va.js', VARemoteLoadOptions);
        })();
      </script>
    PIXEL
  end

  def self.generate_shopify_pixel(site_id)
    <<~PIXEL
      <script type="text/javascript">
        (function () {
          var VARemoteLoadOptions = {
            whiteLabel: { id: #{DotOne::Setup.wl_id}, siteId: #{site_id}, domain: 't.adotone.com' },
            locale: "en-US",
            mkt: true,
            platform: 'shopify',
            shopify: { api: api },
          };

          (function (c, o, n, v, e, r, l, y) {
            c['VARemoteLoadOptions'] = e; r = o.createElement(n), l = o.getElementsByTagName(n)[0];
            r.async = 1; r.src = v; l.parentNode.insertBefore(r, l);
          })(window, document, 'script', '#{DotOne::Setup.cdn_url}/javascripts/va.js', VARemoteLoadOptions);
        })();
      </script>
    PIXEL
  end
end
