module DotOne::Errors::ClickError
  class BlacklistedSubidError < DotOne::Errors::BaseError
    def initialize(subid_data, params, additional_information = {})
      super(DotOne::I18n.err('click.base'))
      @payload = params.merge(inspect_info: additional_information)
      @details = DotOne::I18n.err(
        'click.blacklisted_subid',
        subid_data: subid_data,
      )
    end
  end

  class BlacklistedRefererDomainError < DotOne::Errors::BaseError
    def initialize(domain, params, additional_information = {})
      super(DotOne::I18n.err('click.base'))
      @payload = params.merge(inspect_info: additional_information)
      @details = DotOne::I18n.err(
        'click.blacklisted_referer_domain',
        domain: domain,
      )
    end
  end

   class InvalidGeoError < DotOne::Errors::BaseError
    def initialize(_advertiser, params, additional_information = {})
      super(DotOne::I18n.err('click.base'))
      @payload = params.merge(inspect_info: additional_information)
      @details = DotOne::I18n.err('click.invalid_geo')
    end
  end
end
