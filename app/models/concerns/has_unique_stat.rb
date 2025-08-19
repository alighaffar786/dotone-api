module HasUniqueStat
  extend ActiveSupport::Concern
  include ModelCacheable

  included do
    set_instance_cache_methods :unique_stat
  end

  module ClassMethods
    def define_unique_stat(key:)
      define_method :unique_stat do
        AffiliateStat.find_by(adv_uniq_id: [key, id].join('-'))
      end
    end
  end

  def transaction_subid_1
    cached_unique_stat&.subid_1
  end

  def transaction_subid_2
    cached_unique_stat&.subid_2
  end

  def transaction_subid_3
    cached_unique_stat&.subid_3
  end

  def transaction_subid_4
    cached_unique_stat&.subid_4
  end

  def transaction_subid_5
    cached_unique_stat&.subid_5
  end

  def transaction_affiliate
    cached_unique_stat&.cached_affiliate
  end
end
