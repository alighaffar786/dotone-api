# require 'encryptor' gem
module DotOne::Track
  class Token
    attr_accessor :image_creative_id, :encrypted_string,
      :affiliate_offer_id, :offer_variant_id, :affiliate_id, :mkt_site_id,
      :text_creative_id, :campaign_id, :channel_id, :v2, :tr

    def initialize(*args)
      return unless args.length == 1

      # Erwin at 06/01/2013:
      # Use Hash if possible... more flexible
      if args.length > 0 && args[0].is_a?(Hash)
        @affiliate_id = args[0][:affiliate_id]
        @affiliate_offer_id = args[0][:affiliate_offer_id]
        @offer_variant_id = args[0][:offer_variant_id]
        @image_creative_id = args[0][:image_creative_id]
        @text_creative_id = args[0][:text_creative_id]
        @mkt_site_id = args[0][:mkt_site_id]
        @campaign_id = args[0][:campaign_id]
        @channel_id = args[0][:channel_id]
        @tr = args[0][:tr]

        # ==================== depcreated ===================
        @user_id = args[0][:user_id]
        @product_offer_id = args[0][:product_offer_id]
        # ===================================================

        encrypt
      elsif args.length == 1
        @encrypted_string = args[0]
        decrypt
      end
    end

    def to_s
      params = []
      params << "ao=#{@affiliate_offer_id}" if @affiliate_offer_id.present?
      params << "ic=#{@image_creative_id}" if @image_creative_id.present?
      params << "tc=#{@text_creative_id}" if @text_creative_id.present?
      params << "af=#{@affiliate_id}" if @affiliate_id.present?
      params << "ov=#{@offer_variant_id}" if @offer_variant_id.present?
      params << "ca=#{@campaign_id}" if @campaign_id.present?
      params << "ch=#{@channel_id}" if @channel_id.present?
      params << "tr=#{@tr}" if @tr.present?
      params << "v2=true"
      params.join('&')
    end

    def decrypt
      decrypted = DotOne::Utils::Encryptor.decrypt(@encrypted_string)
      decrypted.split('&').each do |variables|
        s = variables.split('=')
        @affiliate_offer_id = s[1].to_i if s[0] == 'ao'
        @image_creative_id = s[1].to_i if s[0] == 'ic'
        @text_creative_id = s[1].to_i if s[0] == 'tc'
        @affiliate_id = s[1].to_i if s[0] == 'af'
        @offer_variant_id = s[1].to_i if s[0] == 'ov'
        @campaign_id = s[1].to_i if s[0] == 'ca'
        @channel_id = s[1].to_i if s[0] == 'ch'
        @tr = s[1] if s[0] == 'tr'
        @v2 = s[1] == 'true' if s[0] == 'v2'
      end
    end

    def encrypt
      @encrypted_string = DotOne::Utils::Encryptor.encrypt(to_s)
      @encrypted_string
    end
  end
end
