module BooleanHelper
  extend self

  def truthy?(val)
    val.to_s.match(/^(1|true|yes)$/i).present?
  end

  def falsy?(val)
    val.to_s.match(/^(0|false|no)$/i).present?
  end

  alias to_boolean truthy?
end
