class Ability::AffiliateUser < Ability::Base
  def ability
    @ability ||= begin
      role_class = ConstantProcessor.to_method_name(user.roles).to_s.classify
      "Ability::AffiliateUser::#{role_class}".constantize.new(user)
    end
  end

  def user_rules
    merge(ability)

    unless user.admin? || user.network_manager?
      cannot :create, Affiliate
      cannot :finalize, Order
    end

    unless user.upper_team?
      cannot :read_inactive, Affiliate
      cannot :login_as, [Network, Affiliate] unless user.sales_manager?
    end

    cannot :update, ClientApi, status: ClientApi.status_in_progress

    can :read, Term if can?(:read, EventOffer)
    can :refresh_token, AffiliateUser, when_me
  end

  def rules_description
    {
      ad_slot: rules_description_for(AdSlot),
      advertiser_balance: rules_description_for(AdvertiserBalance),
      affiliate: {
        **rules_description_for(Affiliate),
        login_as: can?(:login_as, Affiliate),
        read_inactive: can?(:read_inactive, Affiliate),
        read_performance: can?(:read_performance, Affiliate),
        recruit: can?(:recruit, Affiliate),
        read_full: cannot?(:manage, Affiliate) && can?(:read_full, Affiliate)
      },
      affiliate_feed: rules_description_for(AffiliateFeed),
      affiliate_log: {
        sales_logs: can?(:sales_logs, AffiliateLog),
        sales_summary: can?(:sales_summary, AffiliateLog),
      },
      affiliate_offer: can?(:read, NetworkOffer) ?
        {
          **rules_description_for(AffiliateOffer),
          read_performance: can?(:read_performance, AffiliateOffer)
        } :
        {},
      affiliate_payment: rules_description_for(AffiliatePayment),
      affiliate_prospect: rules_description_for(AffiliateProspect),
      affiliate_payment_info: rules_description_for(AffiliatePaymentInfo),
      affiliate_search_log: rules_description_for(AffiliateSearchLog),
      affiliate_stat: {
        **rules_description_for(AffiliateStat),
        flag: can?(:flag, AffiliateStat),
        import: can?(:import, AffiliateStat),
      },
      affiliate_user: {
        **custom_rules_description_for(AffiliateUser, :user),
        login_as: can?(:login_as, AffiliateUser),
      },
      alternative_domain: rules_description_for(AlternativeDomain),
      blog: rules_description_for(Blog),
      blog_content: rules_description_for(BlogContent),
      blog_page: rules_description_for(BlogPage),
      blog_tag: custom_rules_description_for(AffiliateTag, :blog),
      bot_stat: rules_description_for(BotStat),
      api_key: rules_description_for(ApiKey),
      app_config: rules_description_for(AppConfig),
      attachment: rules_description_for(Attachment),
      campaign: rules_description_for(Campaign),
      category_group: rules_description_for(CategoryGroup),
      category_parking: custom_rules_description_for(Category, :parking),
      channel: rules_description_for(Channel),
      chatbot_search_log: rules_description_for(AffiliateSearchLog),
      chatbot_step: rules_description_for(ChatbotStep),
      client_api: rules_description_for(ClientApi),
      conversion_step: rules_description_for(ConversionStep),
      contact_list: rules_description_for(ContactList),
      delayed_job: rules_description_for(Delayed::Job),
      download: rules_description_for(Download),
      easy_store_setup: rules_description_for(EasyStoreSetup),
      email_template: rules_description_for(EmailTemplate),
      event_affiliate_offer: can?(:read, EventOffer) ? {
        **custom_rules_description_for(AffiliateOffer, :event),
        download: can?(:download_event, AffiliateOffer),
      } : {},
      event_offer: rules_description_for(EventOffer),
      faq_feed: rules_description_for(FaqFeed),
      group_tag: custom_rules_description_for(AffiliateTag, :group),
      image_creative: rules_description_for(ImageCreative),
      job_status_check: rules_description_for(JobStatusCheck),
      link_tracer: rules_description_for(:link_tracer),
      mkt_site: rules_description_for(MktSite),
      missing_order: rules_description_for(MissingOrder),
      network: {
        **rules_description_for(Network),
        login_as: can?(:login_as, Network),
        recruit: can?(:recruit, Network),
        read_full: cannot?(:manage, Network) && can?(:read_full, Network)
      },
      network_offer: rules_description_for(NetworkOffer),
      newsletter: rules_description_for(Newsletter),
      order: {
        **rules_description_for(Order),
        finalize: can?(:finalize, Order),
      },
      offer_variant: rules_description_for(OfferVariant),
      owner_has_tag: rules_description_for(OwnerHasTag),
      pay_schedule: rules_description_for(PaySchedule),
      platform: rules_description_for(WlCompany),
      popup_feed: rules_description_for(PopupFeed),
      postback: rules_description_for(Postback),
      siteInfo: rules_description_for(SiteInfo),
      skin_map: rules_description_for(SkinMap),
      snippet: rules_description_for(Snippet),
      stat: {
        **rules_description_for(Stat),
        read_affiliation: can?(:read_affiliation, Stat),
      },
      term: rules_description_for(Term),
      text_creative: rules_description_for(TextCreative),
      unique_view_stat: rules_description_for(UniqueViewStat),
      country: rules_description_for(Country),
      upload: rules_description_for(Upload),
      vtm_channel: rules_description_for(VtmChannel),
    }
  end

  private

  def rules_description_for(model)
    {
      create: can?(:create, model),
      read: can?(:read, model),
      update: can?(:update, model),
      destroy: can?(:destroy, model),
      download: can?(:download, model),
    }
  end

  def custom_rules_description_for(model, postfix)
    [:create, :read, :update, :destroy].each_with_object({}) do |action, result|
      result[action] = can?("#{action}_#{postfix}".to_sym, model)
    end
  end
end
