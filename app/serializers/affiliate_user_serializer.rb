class AffiliateUserSerializer < Base::AffiliateUserSerializer
  attributes :id, :avatar_cdn_url, :first_name, :last_name, :full_name, :direct_phone, :mobile_phone, :fax, :email, :line,
    :skype, :wechat, :qq, :roles
end
