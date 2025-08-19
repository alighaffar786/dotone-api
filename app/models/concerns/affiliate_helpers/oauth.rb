module AffiliateHelpers::Oauth
  extend ActiveSupport::Concern

  module ClassMethods
    def from_omniauth(auth)
      affiliate = nil

      if auth.info.email.present?
        affiliate = where('email = :email OR google_email = :email OR facebook_email = :email OR line_email = :email', email: auth.info.email).first_or_initialize
      end

      affiliate = try("oauth_#{auth.provider}", auth, affiliate)

      if affiliate.new_record?
        random_string = (0...8).map { rand(97..122).chr }.join
        affiliate.email = auth.info.email
        affiliate.first_name = DotOne::Utils.to_utf8(auth.info.first_name)
        affiliate.last_name = DotOne::Utils.to_utf8(auth.info.last_name)
        affiliate.password = random_string
        affiliate.password_confirmation = random_string
      end

      if auth.extra.raw_info.present?
        affiliate.gender ||= auth.extra.raw_info.gender
        affiliate.birthday ||= auth.extra.raw_info.birthday
      end

      if affiliate.avatar_cdn_url.blank? && auth.info.image
        affiliate.oauth_image_url = auth.info.image
      end

      if location = auth.dig(:extra, :raw_info, :location, :location, :country)
        country = Country.cached_find_by(name: location)
        
        if country
          address = affiliate.affiliate_address || affiliate.build_affiliate_address
          address.country_id = country.id
          affiliate.affiliate_address = address
        end
      end      

      affiliate.set_as_verified
      affiliate
    end

    def oauth_facebook(auth, affiliate = nil)
      if affiliate
        affiliate.facebook_id = auth.uid
      else
        affiliate = find_or_initialize_by(facebook_id: auth.uid)
      end

      affiliate.facebook_email = auth.info.email
      OmniAuth::Fetcher::Facebook.call(auth, affiliate) if affiliate.considered_pending? || affiliate.status.blank?
      affiliate
    end

    def oauth_google_oauth2(auth, affiliate = nil)
      if affiliate
        affiliate.google_id = auth.uid
      else
        affiliate = find_or_initialize_by(google_id: auth.uid)
      end

      affiliate.google_email = auth.info.email
      affiliate
    end

    def oauth_line(auth, affiliate = nil)
      if affiliate
        affiliate.line_id = auth.uid
      else
        affiliate = find_or_initialize_by(line_id: auth.uid)
      end

      affiliate.line_email = auth.info.email
      affiliate
    end
  end
end
