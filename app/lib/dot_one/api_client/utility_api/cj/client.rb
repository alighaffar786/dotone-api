module DotOne::ApiClient::UtilityApi::Cj
  class Client
    attr_accessor :api_key, :api_affiliate_id, :affiliate_id

    def initialize(options = {})
      @api_key = options[:key]
      @api_affiliate_id = options[:api_affiliate_id]
      @affiliate_id = options[:affiliate_id]
    end

    def retrieve_pid
      cj_pid = nil

      response = graphql_response

      if response.code == '200'
        found = false
        body = JSON.parse(response.body)['data']['promotionalProperties']['resultList']

        if body.count > 0
          body = body.select { |x| x['name'] == cj_name(@affiliate_id) }
          body = body.first
          if body.present?
            cj_pid = body['id']
            found = true
          else
            found = false
          end
        end

        unless found
          response = graphql_response({ method: :assign_pid })

          if response.code == '200'
            affiliate = Affiliate.cached_find(@affiliate_id)
            body = JSON.parse(response.body)['data']['createPromotionalProperty']
            cj_pid = body['id']
            affiliate.flag_cj_pid = cj_pid
          end
        end
      end

      cj_pid
    end

    def search_pid_http_body
      return unless @affiliate_id.present?

      cj_name = cj_name(@affiliate_id)
      {
        query: "{promotionalProperties(publisherId: \"#{api_affiliate_id}\" search:\"#{cj_name}\") { resultList { id, name } } }",
      }
    end

    def assign_pid_http_body
      return unless @affiliate_id.present?

      affiliate = Affiliate.cached_find(@affiliate_id)
      if affiliate.present?
        # CJ has constraint that URL max length is 125
        site_info = affiliate.site_infos.active.select do |si|
          si.url.length <= 125
        end

        site_info = site_info.first

        raise DotOne::Errors::MissingSiteInfoError, affiliate unless site_info.present?

        url = site_info.url

      end

      cj_name = cj_name(@affiliate_id)

      property_input = ['{',
        'name:',
        "\"#{cj_name}\",",
        'publisherId:',
        "\"#{api_affiliate_id}\",",
        'propertyTypeDetails:',
        '{',
        'type:',
        'WEBSITE,',
        'websiteUrl:',
        "\"#{url}\"",
        '},',
        'promotionalModels:',
        '[{type:',
        'CONTENT_BLOG_MEDIA,',
        'isPrimary:',
        'true}],',
        'tags:',
        '[],',
        'status:',
        'ACTIVE,',
        'isPrimary:',
        'false',
        '}'].join(' ')

      {
        query: "mutation { createPromotionalProperty(input: #{property_input}) { id } }",
      }
    end

    def cj_name(affiliate_id)
      cj_name = if Rails.env.development?
        "dev_#{affiliate_id}"
      else
        affiliate_id
      end
    end

    def graph_url
      @http_method = :post

      @http_headers = {}
      @http_headers['Authorization'] = "Bearer #{@api_key}"

      URI::HTTPS.build({
        host: 'accounts.api.cj.com',
        path: '/graphql',
      })
    end
  end
end
