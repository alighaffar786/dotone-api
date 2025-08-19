##
# Module to equip the class with capabilities
# to handle tokenized contents.
# Any applied tokens will be used when the class'
# attributes is being called with '_tokenized'.
# Example:
# calling email_template.content_tokenized
# will apply any token in email template's content
# and return the tokenized content.

module Tokens::Tokenized
  extend ActiveSupport::Concern

  included do
    # List of tokens for ActiveRecord
    attr_accessor :token_affiliate
    attr_accessor :token_advertiser
    attr_accessor :token_offer
    attr_accessor :token_company
    attr_accessor :token_affiliate_offer
    attr_accessor :token_event_info
    attr_accessor :token_missing_order

    # List of individual tokens
    attr_accessor :token_affiliate_offer_url
    attr_accessor :token_banner_list
    attr_accessor :token_current_time
    attr_accessor :token_email_verification_url
    attr_accessor :token_end_at
    attr_accessor :token_hour_left
    attr_accessor :token_password_reset_url
    attr_accessor :token_payment_info_form_url
    attr_accessor :token_login_url
    attr_accessor :token_recipient_email
    attr_accessor :token_recipient_full_name
    attr_accessor :token_rejected_reason
    attr_accessor :token_start_at
    attr_accessor :token_status
    attr_accessor :token_url_1
    attr_accessor :token_url_2
    attr_accessor :token_url_3
    attr_accessor :token_url_4
    attr_accessor :token_url_5
    attr_accessor :token_request_url
    attr_accessor :token_cta_url
    attr_accessor :token_affiliate_offers_url_block
    attr_accessor :token_cap_percentage_used
    attr_accessor :token_remaining_days
    attr_accessor :token_order_inquiry_url
    attr_accessor :token_data_url
    attr_accessor :token_missing_orders_count
    attr_accessor :token_date
  end

  module ClassMethods
    ##
    # Method to list out the attributes
    # capable of receiving the tokens.
    # These tokenized attributes will then be available
    # by calling #{attributes}_tokenized method.
    def tokenized_attributes(*attrs)
      [attrs].flatten.each do |a|
        class_eval do
          define_method "#{a}_tokenized".to_sym do |render_type|
            token_rendered(send(a), render_type)
          end

          # Translatable module adds some methods that are
          # related to pulling out some contents based
          # on current locale. Handle it here for tokenized
          # version
          if include?(DynamicTranslatable)
            translatable_attribute = "t_#{a}"
            define_method "#{translatable_attribute}_tokenized".to_sym do |render_type|
              token_rendered(send(translatable_attribute), render_type)
            end
          end
        end
      end
    end
  end

  ##
  # Method to set all the token materials that will be used
  # to render the token. This method needs to be called
  # before using the tokenized methods.
  def tokenize(materials = {})
    materials.each_pair do |key, value|
      send("token_#{key}=", value)
    end
  end

  private

  ##
  # Helper to execute the token render routine.
  def token_rendered(content, render_type)
    return if content.blank?

    to_return = content

    [:token_advertiser, :token_affiliate, :token_offer, :token_company,
      :token_affiliate_offer,
      :token_event_info,
      :token_missing_order].each do |_method|
      to_return = send(_method).format_content(to_return, render_type) if send(_method).present?
    end

    [
      :token_recipient_email, :token_recipient_full_name,
      :token_affiliate_offer_url, :token_email_verification_url, :token_password_reset_url,
      :token_payment_info_form_url, :token_login_url,
      :token_url_1, :token_url_2, :token_url_3, :token_url_4, :token_url_5,
      :token_hour_left, :token_current_time,
      :token_status, :token_banner_list, :token_rejected_reason,
      :token_start_at, :token_end_at,
      :token_request_url, :token_cta_url, :token_affiliate_offers_url_block,
      :token_cap_percentage_used, :token_remaining_days, :token_order_inquiry_url,
      :token_data_url, :token_missing_orders_count, :token_date
    ].each do |_method|
      if send(_method).present?
        token_string = _method.to_s.gsub('token_', '')
        to_return = to_return.gsub("-#{token_string}-", send(_method).to_s)
      end
    end

    to_return
  end
end
