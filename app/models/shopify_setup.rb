require 'net/https'
require 'open-uri'

class ShopifySetup < DatabaseRecords::PrimaryRecord
  include BecomePartnerStore
  include Relations::LanguageAssociated

  attr_accessor :authorization_code

  mount_uploader :script_tag_file, ScriptUploader

  def platform
    'shopify'
  end

  def api_client
    @api_client ||= DotOne::ApiClient::ApiWorker::Shopify.new(self)
  end

  def get_access_token!
    raise 'No authorization code' if authorization_code.blank?

    if response = api_client.get_access_token
      self.access_token = response['access_token']
      self.scope = response['scope']
      save!
    end

    self
  end

  def install_pixels!(options = {})
    return if !options[:force] && script_tag_id.present?

    generate_script_tag_file! if script_tag_file_url.blank?

    if response = api_client.create_script_tag
      self.script_tag_id = response['script_tag']['id']
      save!
    end

    self
  end

  def install_order_update_webhook!(options = {})
    if options[:force] && order_update_webhook_id.present?
      api_client.delete_webhook(order_update_webhook_id)
    elsif order_update_webhook_id.present?
      return
    end

    if response = api_client.create_order_update_webhook
      self.order_update_webhook_id = response['webhook']['id']
      save!
    end

    self
  end

  def install_order_delete_webhook!(options = {})
    if options[:force] && order_delete_webhook_id.present?
      api_client.delete_webhook(order_delete_webhook_id)
    elsif order_delete_webhook_id.present?
      return
    end

    if response = api_client.create_order_delete_webhook
      self.order_delete_webhook_id = response['webhook']['id']
      save!
    end

    self
  end

  def install_order_cancel_webhook!(options = {})
    if options[:force] && order_cancel_webhook_id.present?
      api_client.delete_webhook(order_cancel_webhook_id)
    elsif order_cancel_webhook_id.present?
      return
    end

    if response = api_client.create_order_cancel_webhook
      self.order_cancel_webhook_id = response['webhook']['id']
      save!
    end

    self
  end

  def generate_script_tag_file!
    return if browse_pixel_string.blank?

    require 'tempfile'
    file = Tempfile.new(["shopify.script.tag.#{id}", '.js'])
    file.write(browse_pixel_string)
    file.close
    self.script_tag_file = file
    save!
    file.unlink
    script_tag_file_url
  end

  def deploy_assets!
    install_pixels!
    install_order_update_webhook!
    install_order_delete_webhook!
    install_order_cancel_webhook!
  end
end
