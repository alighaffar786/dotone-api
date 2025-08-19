class DotOne::Constraints::SkinDomainConstraint
  def matches?(request)
    SkinMap.with_hostname(request.host).exists?
  end
end
