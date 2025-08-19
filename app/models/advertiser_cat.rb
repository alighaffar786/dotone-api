class AdvertiserCat < DatabaseRecords::PrimaryRecord
  belongs_to :category_group, inverse_of: :advertiser_cats
  belongs_to :advertiser, inverse_of: :advertiser_cats, class_name: 'Network', foreign_key: :network_id, touch: true
end
