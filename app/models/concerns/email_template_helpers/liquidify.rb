module EmailTemplateHelpers::Liquidify
  extend ActiveSupport::Concern

  TRANSLATED_ATTRIBUTES = [:subject, :content, :footer].freeze
  UNTRANSLATED_ATTRIBUTES = [:sender, :recipient].freeze
  LIQUID_ATTRIBUTES = TRANSLATED_ATTRIBUTES + UNTRANSLATED_ATTRIBUTES

  LIQUID_ATTRIBUTES.each do |attr|
    define_method("render_#{attr}") do |options = {}|
      attr_name = TRANSLATED_ATTRIBUTES.include?(attr) ? "t_#{attr}" : attr
      template = Liquid::Template.parse(send(attr_name))
      template.render(options.deep_stringify_keys)
    end
  end

  def render_template(options = {})
    rendered_fields = {}
    LIQUID_ATTRIBUTES.each do |attr|
      rendered_fields[attr] = send("render_#{attr}", options.deep_stringify_keys)
    end
    rendered_fields
  end
end
