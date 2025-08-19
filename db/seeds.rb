# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# =================================
# Currency
# =================================
Currency.create!(name: 'US Dollar', code: 'USD') unless Currency.find_by_name('US Dollar')
Currency.create!(name: 'European Euro', code: 'EUR') unless Currency.find_by_name('European Euro')
Currency.create!(name: 'British Pound', code: 'GBP') unless Currency.find_by_name('British Pound')
Currency.create!(name: 'Australian Dollar', code: 'AUD') unless Currency.find_by_name('Australian Dollar')
Currency.create!(name: 'China Yuan Renminbi', code: 'CNY') unless Currency.find_by_name('China Yuan Renminbi')
Currency.create!(name: 'Indonesian Rupiah', code: 'IDR') unless Currency.find_by_name('Indonesian Rupiah')
Currency.create!(name: 'Malaysian Ringgit', code: 'MYR') unless Currency.find_by_name('Malaysian Ringgit')
Currency.create!(name: 'Thai Baht', code: 'THB') unless Currency.find_by_name('Thai Baht')
Currency.create!(name: 'Taiwan New Dollar', code: 'TWD') unless Currency.find_by_name('Taiwan New Dollar')
Currency.create!(name: 'Canadian Dollar', code: 'CAD') unless Currency.find_by_name('Canadian Dollar')
Currency.create!(name: 'Hong Kong Dollar', code: 'HKD') unless Currency.find_by_name('Hong Kong Dollar')
Currency.create!(name: 'Singapore Dollar', code: 'SGD') unless Currency.find_by_name('Singapore Dollar')
Currency.create!(name: 'Japanese Yen', code: 'JPY') unless Currency.find_by_name('Japanese Yen')

# =================================
# Language
# =================================
[
  { name: 'English', code: 'en-US' },
  # { name: 'English', code: 'en-CA' },
  # { name: 'French', code: 'fr-CA' },
  { name: 'Simplified Chinese', code: 'zh-CN' },
  { name: 'Traditional Chinese', code: 'zh-TW' },
  { name: 'Indonesian', code: 'id-ID' },
  # { name: 'Malaysian', code: 'my-MY' },
  { name: 'Thai', code: 'th-TH' },
  { name: 'Vietnamese', code: 'vi-VN'},
  { name: 'Malay', code: 'ms-MY'},
].each do |language|
  Language.create!(language) unless Language.find_by_code(language[:code])
end

# =====================================
# Time Zones
# =====================================
[
  { gmt: -12.00, gmt_string: '-12:00', name: '(GMT -12:00) Eniwetok, Kwajalein' },
  { gmt: -11.00, gmt_string: '-11:00', name: '(GMT -11:00) Midway Island, Samoa' },
  { gmt: -10.00, gmt_string: '-10:00', name: '(GMT -10:00) Hawaii' },
  { gmt: -9.00, gmt_string: '-09:00', name: '(GMT -9:00) Alaska' },
  { gmt: -8.00, gmt_string: '-08:00', name: '(GMT -8:00) Pacific Time (US & Canada)' },
  { gmt: -7.00, gmt_string: '-07:00', name: '(GMT -7:00) Mountain Time (US & Canada)' },
  { gmt: -6.00, gmt_string: '-06:00', name: '(GMT -6:00) Central Time (US & Canada), Mexico City' },
  { gmt: -5.00, gmt_string: '-05:00', name: '(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima' },
  { gmt: -4.00, gmt_string: '-04:00', name: '(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz' },
  { gmt: -3.50, gmt_string: '-03:30', name: '(GMT -3:30) Newfoundland' },
  { gmt: -3.00, gmt_string: '-03:00', name: '(GMT -3:00) Brazil, Buenos Aires, Georgetown' },
  { gmt: -2.00, gmt_string: '-02:00', name: '(GMT -2:00) Mid-Atlantic' },
  { gmt: -1.00, gmt_string: '-01:00', name: '(GMT -1:00) Azores, Cape Verde Islands' },
  { gmt: 0.00, gmt_string: '+00:00', name: '(GMT) Western Europe Time, London, Lisbon, Casablanca' },
  { gmt: 1.00, gmt_string: '+01:00', name: '(GMT +1:00) Brussels, Copenhagen, Madrid, Paris' },
  { gmt: 2.00, gmt_string: '+02:00', name: '(GMT +2:00) Kaliningrad, South Africa' },
  { gmt: 3.00, gmt_string: '+03:00', name: '(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg' },
  { gmt: 3.50, gmt_string: '+03:30', name: '(GMT +3:30) Tehran' },
  { gmt: 4.00, gmt_string: '+04:00', name: '(GMT +4:00) Abu Dhabi, Muscat, Baku, Tbilisi' },
  { gmt: 4.50, gmt_string: '+04:30', name: '(GMT +4:30) Kabul' },
  { gmt: 5.00, gmt_string: '+05:00', name: '(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent' },
  { gmt: 5.50, gmt_string: '+05:30', name: '(GMT +5:30) Bombay, Calcutta, Madras, New Delhi' },
  { gmt: 5.75, gmt_string: '+05:45', name: '(GMT +5:45) Kathmandu' },
  { gmt: 6.00, gmt_string: '+06:00', name: '(GMT +6:00) Almaty, Dhaka, Colombo' },
  { gmt: 7.00, gmt_string: '+07:00', name: '(GMT +7:00) Bangkok, Hanoi, Jakarta' },
  { gmt: 8.00, gmt_string: '+08:00', name: '(GMT +8:00) Beijing, Perth, Singapore, Hong Kong' },
  { gmt: 9.00, gmt_string: '+09:00', name: '(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk' },
  { gmt: 9.50, gmt_string: '+09:30', name: '(GMT +9:30) Adelaide, Darwin' },
  { gmt: 10.00, gmt_string: '+10:00', name: '(GMT +10:00) Eastern Australia, Guam, Vladivostok' },
  { gmt: 11.00, gmt_string: '+11:00', name: '(GMT +11:00) Magadan, Solomon Islands, New Caledonia' },
  { gmt: 12.00, gmt_string: '+12:00', name: '(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka' }
].each do |time_zone|
  TimeZone.create!(time_zone) unless TimeZone.find_by_gmt(time_zone[:gmt])
end

# =====================================
# Category Groups & Categories
# =====================================
{
  "Adult" => ["Adult Dating", "Adult Toys", "Adult Videos", "Dating & Matchmaking"],
  "Beauty & Skincare" => ["Bath & Body", "Cosmetics", "Face & Body Treatment", "Haircare Treatment", "Nail & Eyelash", "Other Beauty", "Perfume & Fragrance"],
  "Clothing & Apparel" => ["Jewelry Accessories", "Luggage & Handbag", "Men Apparel", "Other Fashions", "Shoe & Footwear", "Sport/Fitness Apparel", "Swimwear & Underwear", "Teen Apparel", "Women Apparel"],
  "Cooking & DIY" => ["Chinese Cuisine", "Dessert / Bakery", "Health / Nutrition", "Lunch Box", "Other Cooking", "Western Cuisine"],
  "Education & Knowledge" => ["Books Sharing", "Career Development", "Graphics Design", "Investment & Financial", "Language Learning", "Marketing Management", "Online Course", "Others Knowledge", "Psychology", "Social Media Tutor", "Software Development"],
  "Electronic & Tech" => ["APP/PC/Console Game", "App & Software", "Cloud Service & SAAS", "Computer Hardware", "Electronic & Peripheral", "eBook"],
  "Family & Kid" => ["Child Education", "Children Book", "Children Toy", "Toddler & Infant"],
  "Food & Drinks" => ["Alcohol/Tobacco", "Dessert & Drink", "Food Delivery", "Groceries", "Local Delicacy", "Other Food & Drink", "Restaurants"],
  "General Merchandise" => ["Online Store", "Tools & Supply"],
  "Gifts & Flowers" => ["Flowers", "Gifts", "Greeting Cards", "Handmade Goods"],
  "Health & Wellness" => ["Dental Care", "Health Supplement", "Massages/Spas", "Other Wellness", "Pharmacy & Supply", "Vision Care", "Weight Loss"],
  "Home & Garden" => ["Bed & Bath", "Furniture & Decoration", "Gardening", "Home Appliance", "Kitchen", "Other Home & Garden"],
  "Pets & Aquarium" => ["Aquarium & Reptile", "Cat & Dog", "Other Pets", "Pet", "Pet Food", "Pet Hotel", "Pet Spa"],
  "Professional Services" => ["Cleaner & Storage", "Credit Cards", "Fundraising/Charitable", "Insurance Service", "Investment", "Loans & Debit", "Other Services", "Video/Photography"],
  "Recreation & Leisure" => ["Board Game", "Car Modification", "Collectibles", "Karaoke/KTV", "Motorcycles Modification", "Other Recreation"],
  "Sport & Fitness" => ["Aquatic Sport", "Dance & Gymnastic", "Fitness Equipment", "Hiking & Outdoor", "Indoor Activity", "Other Sports", "Outdoor Adventure", "Sport & Game", "Yoga & Aerobic"],
  "Travel & Lodging" => ["Camping & Outdoor", "Event/Ticket", "Flight & Hotel", "Other Travel Needs", "Travel & Vacation"]
}.each_pair do |cg, cats|
  unless CategoryGroup.find_by_name(cg); CategoryGroup.create!(:name => cg); end
  group = CategoryGroup.find_by_name(cg)
  cats.each do |cat|
    unless group.categories.map(&:name).include?(cat); Category.create!(:name => cat, :category_group_id => group.id); end
  end
end

# =================================================
# Countries
# For ISO List: http://www.nationsonline.org/oneworld/country_code_list.htm
# =================================================

unless Country.find_by_name("Albania"); Country.create!(:name => "Albania", :iso_2_country_code => "AL", :iso_3_country_code => "ALB"); end
unless Country.find_by_name("Algeria"); Country.create!(:name => "Algeria", :iso_2_country_code => "DZ", :iso_3_country_code => "DZA"); end
unless Country.find_by_name("Argentina"); Country.create!(:name => "Argentina", :iso_2_country_code => "AR", :iso_3_country_code => "ARG"); end
unless Country.find_by_name("Australia"); Country.create!(:name => "Australia", :iso_2_country_code => "AU", :iso_3_country_code => "AUS"); end
unless Country.find_by_name("Austria"); Country.create!(:name => "Austria", :iso_2_country_code => "AT", :iso_3_country_code => "AUT"); end
unless Country.find_by_name("Bahrain"); Country.create!(:name => "Bahrain", :iso_2_country_code => "BH", :iso_3_country_code => "BHR"); end
unless Country.find_by_name("Bangladesh"); Country.create!(:name => "Bangladesh", :iso_2_country_code => "BD", :iso_3_country_code => "BGD"); end
unless Country.find_by_name("Belarus"); Country.create!(:name => "Belarus", :iso_2_country_code => "BY", :iso_3_country_code => "BLR"); end
unless Country.find_by_name("Belgium"); Country.create!(:name => "Belgium", :iso_2_country_code => "BE", :iso_3_country_code => "BEL"); end
unless Country.find_by_name("Bolivia"); Country.create!(:name => "Bolivia", :iso_2_country_code => "BO", :iso_3_country_code => "BOL"); end
unless Country.find_by_name("Brazil"); Country.create!(:name => "Brazil", :iso_2_country_code => "BR", :iso_3_country_code => "BRA"); end
unless Country.find_by_name("Bulgaria"); Country.create!(:name => "Bulgaria", :iso_2_country_code => "BG", :iso_3_country_code => "BGR"); end
unless Country.find_by_name("Canada"); Country.create!(:name => "Canada", :iso_2_country_code => "CA", :iso_3_country_code => "CAN"); end
unless Country.find_by_name("Chile"); Country.create!(:name => "Chile", :iso_2_country_code => "CL", :iso_3_country_code => "CHL"); end
unless Country.find_by_name("China"); Country.create!(:name => "China", :iso_2_country_code => "CN", :iso_3_country_code => "CHN"); end
unless Country.find_by_name("Colombia"); Country.create!(:name => "Colombia", :iso_2_country_code => "CO", :iso_3_country_code => "COL"); end
unless Country.find_by_name("Costa Rica"); Country.create!(:name => "Costa Rica", :iso_2_country_code => "CR", :iso_3_country_code => "CRI"); end
unless Country.find_by_name("Croatia"); Country.create!(:name => "Croatia", :iso_2_country_code => "HR", :iso_3_country_code => "HRV"); end
unless Country.find_by_name("Cyprus"); Country.create!(:name => "Cyprus", :iso_2_country_code => "CY", :iso_3_country_code => "CYP"); end
unless Country.find_by_name("Czech Republic"); Country.create!(:name => "Czech Republic", :iso_2_country_code => "CZ", :iso_3_country_code => "CZE"); end
unless Country.find_by_name("Denmark"); Country.create!(:name => "Denmark", :iso_2_country_code => "DK", :iso_3_country_code => "DNK"); end
unless Country.find_by_name("Dominican Republic"); Country.create!(:name => "Dominican Republic", :iso_2_country_code => "DO", :iso_3_country_code => "DOM"); end
unless Country.find_by_name("Ecuador"); Country.create!(:name => "Ecuador", :iso_2_country_code => "EC", :iso_3_country_code => "ECU"); end
unless Country.find_by_name("Egypt"); Country.create!(:name => "Egypt", :iso_2_country_code => "EG", :iso_3_country_code => "EGY"); end
unless Country.find_by_name("El Salvador"); Country.create!(:name => "El Salvador", :iso_2_country_code => "SV", :iso_3_country_code => "SLV"); end
unless Country.find_by_name("Estonia"); Country.create!(:name => "Estonia", :iso_2_country_code => "EE", :iso_3_country_code => "EST"); end
unless Country.find_by_name("Finland"); Country.create!(:name => "Finland", :iso_2_country_code => "FI", :iso_3_country_code => "FIN"); end
unless Country.find_by_name("France"); Country.create!(:name => "France", :iso_2_country_code => "FR", :iso_3_country_code => "FRA"); end
unless Country.find_by_name("Georgia"); Country.create!(:name => "Georgia", :iso_2_country_code => "GE", :iso_3_country_code => "GEO"); end
unless Country.find_by_name("Germany"); Country.create!(:name => "Germany", :iso_2_country_code => "DE", :iso_3_country_code => "DEU"); end
unless Country.find_by_name("Ghana"); Country.create!(:name => "Ghana", :iso_2_country_code => "GH", :iso_3_country_code => "GHA"); end
unless Country.find_by_name("Greece"); Country.create!(:name => "Greece", :iso_2_country_code => "GR", :iso_3_country_code => "GRC"); end
unless Country.find_by_name("Guatemala"); Country.create!(:name => "Guatemala", :iso_2_country_code => "GT", :iso_3_country_code => "GTM"); end
unless Country.find_by_name("Haiti"); Country.create!(:name => "Haiti", :iso_2_country_code => "HT", :iso_3_country_code => "HTI"); end
unless Country.find_by_name("Honduras"); Country.create!(:name => "Honduras", :iso_2_country_code => "HN", :iso_3_country_code => "HND"); end
unless Country.find_by_name("Hong Kong"); Country.create!(:name => "Hong Kong", :iso_2_country_code => "HK", :iso_3_country_code => "HKG"); end
unless Country.find_by_name("Hungary"); Country.create!(:name => "Hungary", :iso_2_country_code => "HU", :iso_3_country_code => "HUN"); end
unless Country.find_by_name("Iceland"); Country.create!(:name => "Iceland", :iso_2_country_code => "IS", :iso_3_country_code => "ISL"); end
unless Country.find_by_name("India"); Country.create!(:name => "India", :iso_2_country_code => "IO", :iso_3_country_code => "IOT"); end
unless Country.find_by_name("Indonesia"); Country.create!(:name => "Indonesia", :iso_2_country_code => "ID", :iso_3_country_code => "IDN"); end
unless Country.find_by_name("Iran"); Country.create!(:name => "Iran", :iso_2_country_code => "IR", :iso_3_country_code => "IRN"); end
unless Country.find_by_name("Iraq"); Country.create!(:name => "Iraq", :iso_2_country_code => "IQ", :iso_3_country_code => "IRQ"); end
unless Country.find_by_name("Ireland"); Country.create!(:name => "Ireland", :iso_2_country_code => "IE", :iso_3_country_code => "IRL"); end
unless Country.find_by_name("Israel"); Country.create!(:name => "Israel", :iso_2_country_code => "IL", :iso_3_country_code => "ISR"); end
unless Country.find_by_name("Italy"); Country.create!(:name => "Italy", :iso_2_country_code => "IT", :iso_3_country_code => "ITA"); end
unless Country.find_by_name("Japan"); Country.create!(:name => "Japan", :iso_2_country_code => "JP", :iso_3_country_code => "JPN"); end
unless Country.find_by_name("Jordan"); Country.create!(:name => "Jordan", :iso_2_country_code => "JO", :iso_3_country_code => "JOR"); end
unless Country.find_by_name("Kenya"); Country.create!(:name => "Kenya", :iso_2_country_code => "KE", :iso_3_country_code => "KEN"); end
unless Country.find_by_name("Kuwait"); Country.create!(:name => "Kuwait", :iso_2_country_code => "KW", :iso_3_country_code => "KWT"); end
unless Country.find_by_name("Lebanon"); Country.create!(:name => "Lebanon", :iso_2_country_code => "LB", :iso_3_country_code => "LBN"); end
unless Country.find_by_name("Luxembourg"); Country.create!(:name => "Luxembourg", :iso_2_country_code => "LU", :iso_3_country_code => "LUX"); end
unless Country.find_by_name("Macedonia"); Country.create!(:name => "Macedonia", :iso_2_country_code => "MK", :iso_3_country_code => "MKD"); end
unless Country.find_by_name("Malaysia"); Country.create!(:name => "Malaysia", :iso_2_country_code => "MY", :iso_3_country_code => "MYS"); end
unless Country.find_by_name("Mexico"); Country.create!(:name => "Mexico", :iso_2_country_code => "MX", :iso_3_country_code => "MEX"); end
unless Country.find_by_name("Netherlands"); Country.create!(:name => "Netherlands", :iso_2_country_code => "NL", :iso_3_country_code => "NLD"); end
unless Country.find_by_name("New Zealand"); Country.create!(:name => "New Zealand", :iso_2_country_code => "NZ", :iso_3_country_code => "NZL"); end
unless Country.find_by_name("Nicaragua"); Country.create!(:name => "Nicaragua", :iso_2_country_code => "NI", :iso_3_country_code => "NIC"); end
unless Country.find_by_name("Nigeria"); Country.create!(:name => "Nigeria", :iso_2_country_code => "NG", :iso_3_country_code => "NGA"); end
unless Country.find_by_name("Norway"); Country.create!(:name => "Norway", :iso_2_country_code => "NO", :iso_3_country_code => "NOR"); end
unless Country.find_by_name("Oman"); Country.create!(:name => "Oman", :iso_2_country_code => "OM", :iso_3_country_code => "OMN"); end
unless Country.find_by_name("Panama"); Country.create!(:name => "Panama", :iso_2_country_code => "PA", :iso_3_country_code => "PAN"); end
unless Country.find_by_name("Paraguay"); Country.create!(:name => "Paraguay", :iso_2_country_code => "PY", :iso_3_country_code => "PRY"); end
unless Country.find_by_name("Peru"); Country.create!(:name => "Peru", :iso_2_country_code => "PE", :iso_3_country_code => "PER"); end
unless Country.find_by_name("Philippines"); Country.create!(:name => "Philippines", :iso_2_country_code => "PH", :iso_3_country_code => "PHL"); end
unless Country.find_by_name("Poland"); Country.create!(:name => "Poland", :iso_2_country_code => "PL", :iso_3_country_code => "POL"); end
unless Country.find_by_name("Portugal"); Country.create!(:name => "Portugal", :iso_2_country_code => "PT", :iso_3_country_code => "PRT"); end
unless Country.find_by_name("Puerto Rico"); Country.create!(:name => "Puerto Rico", :iso_2_country_code => "PR", :iso_3_country_code => "PRI"); end
unless Country.find_by_name("Qatar"); Country.create!(:name => "Qatar", :iso_2_country_code => "QA", :iso_3_country_code => "QAT"); end
unless Country.find_by_name("Romania"); Country.create!(:name => "Romania", :iso_2_country_code => "RO", :iso_3_country_code => "ROU"); end
unless Country.find_by_name("Russia"); Country.create!(:name => "Russia", :iso_2_country_code => "RU", :iso_3_country_code => "RUS"); end
unless Country.find_by_name("Saudi Arabia"); Country.create!(:name => "Saudi Arabia", :iso_2_country_code => "SA", :iso_3_country_code => "SAU"); end
unless Country.find_by_name("Singapore"); Country.create!(:name => "Singapore", :iso_2_country_code => "SG", :iso_3_country_code => "SGP"); end
unless Country.find_by_name("Slovakia"); Country.create!(:name => "Slovakia", :iso_2_country_code => "SK", :iso_3_country_code => "SVK"); end
unless Country.find_by_name("Slovenia"); Country.create!(:name => "Slovenia", :iso_2_country_code => "SI", :iso_3_country_code => "SVN"); end
unless Country.find_by_name("South Africa"); Country.create!(:name => "South Africa", :iso_2_country_code => "ZA", :iso_3_country_code => "ZAF"); end
unless Country.find_by_name("Spain"); Country.create!(:name => "Spain", :iso_2_country_code => "ES", :iso_3_country_code => "ESP"); end
unless Country.find_by_name("Sri Lanka"); Country.create!(:name => "Sri Lanka", :iso_2_country_code => "LK", :iso_3_country_code => "LKA"); end
unless Country.find_by_name("Sweden"); Country.create!(:name => "Sweden", :iso_2_country_code => "SE", :iso_3_country_code => "SWE"); end
unless Country.find_by_name("Switzerland"); Country.create!(:name => "Switzerland", :iso_2_country_code => "CH", :iso_3_country_code => "CHE"); end
unless Country.find_by_name("Taiwan"); Country.create!(:name => "Taiwan", :iso_2_country_code => "TW", :iso_3_country_code => "TWN"); end
unless Country.find_by_name("Thailand"); Country.create!(:name => "Thailand", :iso_2_country_code => "TH", :iso_3_country_code => "THA"); end
unless Country.find_by_name("Turkey"); Country.create!(:name => "Turkey", :iso_2_country_code => "TR", :iso_3_country_code => "TUR"); end
unless Country.find_by_name("Ukraine"); Country.create!(:name => "Ukraine", :iso_2_country_code => "UA", :iso_3_country_code => "UKR"); end
unless Country.find_by_name("United Arab Emirates"); Country.create!(:name => "United Arab Emirates", :iso_2_country_code => "AE", :iso_3_country_code => "ARE"); end
unless Country.find_by_name("United Kingdom"); Country.create!(:name => "United Kingdom", :iso_2_country_code => "GB", :iso_3_country_code => "GBR"); end
unless Country.find_by_name("United States"); Country.create!(:name => "United States", :iso_2_country_code => "US", :iso_3_country_code => "USA"); end
unless Country.find_by_name("Venezuela"); Country.create!(:name => "Venezuela", :iso_2_country_code => "VE", :iso_3_country_code => "VEN"); end
unless Country.find_by_name("Vietnam"); Country.create!(:name => "Vietnam", :iso_2_country_code => "VN", :iso_3_country_code => "VNM"); end

# ==================================
# Expertises
# ==================================
["Blogger", "Contextual Publisher", "Site Builder",
 "SEO Marketer", "Mailer", "APP Developer",
 "Contextual Media Buyer", "Social Network", "Software Developer", "Incentive Traffic",
 "Forum Moderator/Poster", "Search PPC", "Mobile Media", "Display Banner"].each do |name|
  unless Expertise.find_by_name(name); Expertise.create!(:name => name); end
end

# ===================================
# Affiliate Tags
# ===================================
[
  "Top Offer", "New Offer",
  "300x250 Offer Slot", # offers on 300x250 offer slot
  "300x125 Offer Slot", # offers on 300x125 offer slot
  "Advertiser Prospect",
  "Affiliate Prospect",
].each do |name|
  unless AffiliateTag.find_by_name(name)
    AffiliateTag.create!(
      name: name,
      )
  end
end

# ===================================
# Affiliate Tags - Media Restriction
# ===================================
[
  "Blog Ads", "Video Ads", "Email Ads",
  "SMS/MMS Ads", "Social Media Ads", "Paid Search",
  "Incentivized Ads", "Forum/BBS Ads", "Display Ads",
  "Contextual Ads", "Adult Ads", "In-App Ads", "Chat Messages",
  "Sub-Network", "Others",
].each do |name|
  unless AffiliateTag.find_by_name_and_tag_type(name, AffiliateTag::TAG_TYPES[:media_restriction])
    AffiliateTag.create!(:name => name, :tag_type => AffiliateTag::TAG_TYPES[:media_restriction])
  end
end

# ===================================
# Affiliate Tags - Media Category
# ===================================
[
  ["Text Content", ["Blog", "News", "Review", "Ranking/Comparison", "Forum/BBS"]],
  ["Social Media", ["Facebook", "Instagram", "Twitter", 'Threads', "Weibo", "Xiaohongshu", "Other Social Media"]],
  ["Video Content", ["Bilibili", "Youtube", "TikTok", "Youku", "Vimeo", "Twitch", "Metacafe", "Other Video Content"]],
  ["SMS/MMS/Chat", ["WeChat", "Line", "Whatsapp", "Telegram", "Snapchat", "Other SMS/Chat"]],
  ["Loyalty", ["Cashback", "Points", "Sweepstake", "Offer Wall"]],
  ["Promotion", ["Coupon", "Deals/Discount", "Rebates"]],
  ["Media Buy", ["CPC", "CPM", "CPV", "Programmatic", "Other Ad Channel"]],
  ["Mobile", ["Mobile Web", "App Developer"]],
  ["Network", ["Affiliate Network", "Ad Network", "CPA Network", "Ad Agency"]],
  ["Email", ["Email Marketing", "Newsletter"]],
  ["Others", ["Friends & Family", "Group Buy", "QR Code", "Other"]],
].each do |category|
  # parent category
  parent = AffiliateTag.find_by_name_and_tag_type(category[0], AffiliateTag::TAG_TYPES[:media_category])
  unless parent.present?
    parent = AffiliateTag.create!(name: category[0], tag_type: AffiliateTag::TAG_TYPES[:media_category])
  end

  # child categories
  children = category[1]
  children.each do |c|
    child = AffiliateTag.find_by_name_and_tag_type(c, AffiliateTag::TAG_TYPES[:media_category])
    if child.present?
      child.update(parent_category_id: parent.id)
    else
      child = AffiliateTag.create!(name: c, tag_type: AffiliateTag::TAG_TYPES[:media_category], parent_category_id: parent.id)
    end
  end
end

# ===================================
# Affiliate Tags - System
# ===================================
[
  "Affiliate Referral Target",
].each do |name|
  unless AffiliateTag.find_by_name_and_tag_type(name, AffiliateTag::TAG_TYPES[:system_tag])
    AffiliateTag.create!(:name => name, :tag_type => AffiliateTag::TAG_TYPES[:system_tag])
  end
end

# ===================================
# Affiliate Tags - Traffic Channel
# ===================================
[
  "Facebook",
  "Instagram",
  "Blog",
  "Youtube",
  "Vimeo",
  "TikTok",
  "LINE",
  "Whatsapp",
  "Snapchat",
].each do |name|
  unless AffiliateTag.find_by_name_and_tag_type(name, AffiliateTag::TAG_TYPES[:traffic_channel])
    AffiliateTag.create!(:name => name, :tag_type => AffiliateTag::TAG_TYPES[:traffic_channel])
  end
end

# ===================================
# Affiliate Tags - TopNetworkOffer
# ===================================
[
  "Most Popular",
  "Children",
  "Electronic",
  "Food",
  "Fashion",
  "Health",
  "Living",
  "Travel",
  "Others",
].each do |name|
  unless AffiliateTag.find_by_name_and_tag_type(name, AffiliateTag::TAG_TYPES[:top_network_offer])
    AffiliateTag.create!(:name => name, :tag_type => AffiliateTag::TAG_TYPES[:top_network_offer])
  end
end

# ===================================
# Affiliate Tags - Top Traffic Source
# ===================================
[
  "Blog/Content",
  "Cashback/Loyalty",
  "Chat/SMS",
  "Coupon/Deals",
  "Email",
  "Facebook",
  "Forum",
  "Group Buy",
  "Instagram",
  "Rank/Comparison",
  "Search/SEO",
  "Social Media",
  "Youtube",
].each do |name|
  unless AffiliateTag.find_by_name_and_tag_type(name, AffiliateTag::TAG_TYPES[:top_traffic_source])
    AffiliateTag.create!(:name => name, :tag_type => AffiliateTag::TAG_TYPES[:top_traffic_source])
  end
end

# ===================================
# Email Templates
# ===================================

EMAIL_TEMPLATE_COLLECTION.each_pair do |email_type, email|
  if EmailTemplate.find_by_email_type(email['email_type']).blank?
    EmailTemplate.create(
        email_type: email['email_type'],
        subject: email['subject'],
        sender: email['sender'],
        recipient: email['recipient'],
        status: "Active",
        content: email['content'],
        footer: email['footer']
    )
  end
end

# ===================================
# Affiliate Tags - Target Device
# ===================================

{
  AffiliateTag.tag_type_target_device_type => [
    'Computer',
    'Desktop',
    'Mobile'
  ],
  AffiliateTag.tag_type_target_device_model_name => [
    'Ipad',
    'Iphone',
    'Android'
  ],
  AffiliateTag.tag_type_target_device_brand_name => [
    'Samsung',
    'HTC',
    'Apple'
  ],
  AffiliateTag.tag_type_target_device_os_version => [
    '4.0 and newer',
    '5.0 and newer',
    '6.0 and newer',
    '7.0 and newer',
    '8.0 and newer',
    '9.0 and newer',
  ]
}.each_pair do |tag_type, values|
  values.each do |value|
    AffiliateTag.find_or_create_by(tag_type: tag_type, name: value)
  end
end

# ===================================
# Affiliate Tags - Event Media Category
# ===================================

[
  ['Blog', ['Blog']],
  ['Facebook', ['Facebook', 'FB Video']],
  ['Instagram', ['Instagram', 'IG Reels', 'IG Story']],
  ['TikTok', ['TikTok']],
  ['Threads', ['Threads']],
  ['Twitter', ['Twitter X']],
  ['Youtube', ['Youtube', 'YT Shorts']],
].each do |item|
  parent, children = item

  parent_tag = AffiliateTag.media_categories.find_by(name: parent)
  children.each do |child|
    AffiliateTag.event_media_categories.where(name: child, parent_category: parent_tag).first_or_create
  end
end
