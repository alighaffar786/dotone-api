class Teams::AffiliateApplicationSerializer < Base::AffiliateApplicationSerializer
  attributes :id, :phone_number, :time_to_call, :company_name, :company_site, :accept_terms, :accept_terms_at,
    :age_confirmed, :age_confirmed_at, :facebook, :twitter, :linkedin, :pinterest,
    :tumbler, :skype, :line, :qq, :wechat
end
