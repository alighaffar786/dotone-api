module Relations::AffiliateStatAssociated
  extend ActiveSupport::Concern

  module ClassMethods
    def has_many_affiliate_stats(**options)
      association_options = {
        inverse_of: name.underscore,
      }.merge(options)

      [AffiliateStat, *AffiliateStat::PARTITIONS, BotStat].each do |partition|
        has_many partition.name.tableize.to_sym, -> { limit(100) }, **association_options
      end
    end

    def belongs_to_affiliate_stat(**options)
      association_options = {
        inverse_of: name.tableize,
      }.merge(options)

      [AffiliateStat, *AffiliateStat::PARTITIONS, BotStat].each do |partition|
        belongs_to partition.name.underscore.to_sym, **association_options
      end
    end
  end

  def touch_stat_partitions
    affiliate_stat&.delayed_touch
    affiliate_stat&.touch_partitions
  end
end
