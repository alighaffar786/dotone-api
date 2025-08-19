FactoryBot.define do
  factory :wl_company do
    name { 'ConverTrack test' }
    label_type { 'Affiliate' }
    affiliate_domain_name { 'test.affiliate.convertrack.com' }
    advertiser_domain_name { 'test.advertiser.convertrack.com' }
    owner_domain_name { 'test.owner.convertrack.com' }
    api_domain_name { 'test.api.convertrack.com' }
    currency { Currency.find_by_name('US Dollar') || create(:currency) }
    language { Language.find_by_code('en-US') || create(:language, :en_us) }
  end
end
