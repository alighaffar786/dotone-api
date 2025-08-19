module ParamNameHelper
  def relation_name?(param_name)
    param_name.to_s.ends_with?('_id')
  end

  def to_relation_name(param_name)
    return param_name unless relation_name?(param_name)

    param_name.to_s.gsub('_id', '').to_sym
  end

  def to_filter_name(param_name)
    return param_name unless relation_name?(param_name)

    param_name.to_s.pluralize.to_sym
  end
end
