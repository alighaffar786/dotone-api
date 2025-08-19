# Module to be included to any model class
# whose attributes need to be tokenized
module Tokens::Tokenable
  extend ActiveSupport::Concern

  included do
    cattr_accessor :token_prefix
  end

  module ClassMethods
    def set_token_prefix(param)
      self.token_prefix = param
    end
  end

  def generate_translatable_key(key)
    translatable_key = "t_#{key}"

    return translatable_key if respond_to?(translatable_key)

    key
  end

  ##
  # Format content to populate included model's infos
  # Parameters:
  # content - The content string containing the tokens to replace
  # type - What this formatted content is used for
  # setup_options - any options used for the setup token
  # kvp_tag - used by kvp token to select which value - if any - to be used
  def format_content(content, type, setup_options = {}, kvp_tag = nil)
    return if content.blank?

    content = content.gsub(/\r\n/, '') unless type == :email
    content.gsub(/-#{token_prefix}_(\w+)_*(\(.+\))?-/) do |_x|
      arg = ::Regexp.last_match(1)
      parameters = ::Regexp.last_match(2)
      # Cleanup any parantheses
      parameters = parameters.gsub(/[()]/, '').split(',') rescue nil

      is_decoded_requested = arg.match(/_decoded$/i).present?
      key = arg.gsub(/_decoded$/i, '')

      if key.present? && key.match(/^setup_/)
        key = key.gsub(/^setup_/, '')
        val = send(key.to_sym, setup_options.setup[key])
        val = CGI.escape(val) rescue nil if type == :url && !is_decoded_requested
        val.to_s
      elsif key.present? && key.match(/^kvp_/)
        send(key, kvp_tag)
      elsif key.present?
        key = generate_translatable_key(key)
        val = if parameters.present?
          send(key, *parameters)
        else
          send(key)
        end
        val = CGI.escape(val.to_s) rescue nil if type == :url && !is_decoded_requested
        val.to_s
      end
    end
  end
end
