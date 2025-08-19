require 'net/https'
require 'digest'

module DotOne::ApiClient::CapturedConversionApi
  module Line
    class Client
      include DotOne::ApiClient::LineShared

      attr_accessor :conversion_stat, :url_format, :parameters

      def initialize(_options = {})
        @conversion_stat = nil
        @url_format = 'https://buy-order-api.line.me/tracking/orderinfo'
        @parameters = {
          site: '2',
          shopid: nil, # value stored at offer's kvp 'line_shop_id'
          authkey: nil, # value stored at offer's kvp 'line_authkey'
        }
        @request_body_format = <<-EOS
          [
            {
              "product": {
                "product_name": "-order_number-",
                "product_type": "normal",
                "product_id": "-order_number-",
                "product_amount": "-order_total_as_integer-",
                "sub_category1": " ",
                "sub_category2": " "
              }
            }
          ]
        EOS
      end

      def send!
        return if conversion_stat.blank? || conversion_stat.conversions.to_i < 1

        post_parameters = @parameters

        post_parameters[:ecid] = @conversion_stat.subid_1.to_s

        order_total = @conversion_stat.order_total.to_i
        order_id = sanitize_order_number(@conversion_stat.order_number)
        order_time = time_zone.from_utc(@conversion_stat.captured_at)&.to_s(:db)

        if offer&.line_use_click_time?
          order_time = time_zone.from_utc(@conversion_stat.recorded_at).to_s(:db)
        end

        time_now = time_zone.from_utc(Time.now.utc)
        timestamp = time_now.to_i

        md5 = Digest::MD5.new
        md5 << order_time
        ordertime_hashkey = md5.hexdigest

        key = ordertime_hashkey
        data = "orderid=#{order_id}&ordertotal=#{order_total}&timestamp=#{timestamp}"
        digest = OpenSSL::Digest.new('sha256')

        hash = OpenSSL::HMAC.hexdigest(digest, key, data)

        post_parameters[:timestamp] = timestamp
        post_parameters[:ordertotal] = order_total
        post_parameters[:hash] = hash
        post_parameters[:orderid] = order_id
        post_parameters[:ordertime] = order_time
        post_parameters[:order_list] = @conversion_stat.format_pixel(@request_body_format)

        # Post any new member information if applicable
        new_member_step_name = offer&.line_is_new_member_step_name
        if new_member_step_name
          post_parameters[:is_new_member] = if new_member_step_name == @conversion_stat.step_name
            1
          else
            0
          end
        end

        post_parameters[:shopid] = offer&.line_shop_id
        post_parameters[:authkey] = offer&.line_authkey

        request = Net::HTTP::Post.new(request_uri.request_uri)
        request.set_form_data(post_parameters)

        response = request_http.request(request)
        {
          url: @url_format,
          parameters: post_parameters,
          request_body: { url: @url_format, parameters: post_parameters },
          response_body: response.body,
        }
      end
    end
  end
end
