module Scopeable
  extend ActiveSupport::Concern

  NO_RECRUITER = 'No Recruiter'.freeze

  module ClassMethods
    def scope_by_affiliate(attribute = :affiliate_id)
      scope :with_affiliates, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end
          where(attribute => values)
        end
      }

      scope :without_affiliates, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end
          where.not(attribute, values)
        end
      }
    end

    def scope_by_affiliate_offer(attribute = :affiliate_offer_id)
      scope :with_affiliate_offers, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end
          where(attribute => values)
        end
      }
    end

    def scope_by_campaign(attribute = :campaign_id)
      scope :with_campaigns, -> (*args) {
        where(attribute => args.flatten) if args[0].present?
      }
    end

    def scope_by_channel(attribute = :channel_id)
      scope :with_channels, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end
          where(attribute => values)
        end
      }
    end

    def scope_by_image_creative(attribute = :image_creative_id)
      scope :with_image_creatives, -> (*args) {
        where(attribute => args.flatten) if args[0].present?
      }
    end

    def scope_by_network(attribute = :network_id)
      scope :with_networks, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          where(attribute => values)
        end
      }

      scope :without_networks, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          where.not(attribute => values)
        end
      }
    end

    def scope_by_offer(attribute = :offer_id)
      scope :with_offers, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          where(attribute => values)
        end
      }

      scope :without_offers, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          where.not(attribute => values)
        end
      }
    end

    def scope_by_offer_variant(attribute = :offer_variant_id)
      scope :with_offer_variants, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          where(attribute => values)
        end
      }
    end

    def scope_by_category_group(attribute = :id)
      scope :with_category_groups, -> (*args) {
        if Scopeable.args_valid?(args)
          values = if args[0].is_a?(ActiveRecord::Relation)
            args[0]
          else
            args.flatten.map { |x| x.id rescue x }
          end

          joins(:category_groups).where(category_groups: { attribute => values }).distinct
        end
      }
    end

    def scope_by_status(attribute = :status)
      scope :with_statuses, -> (*args) {
        where(attribute => args.flatten) if args[0].present?
      }
    end

    def scope_by_approval(attribute = :approval)
      scope :with_approvals, -> (*args) {
        where(attribute => args.flatten) if args[0].present?
      }
    end

    def scope_by_approval_method(attribute = :approval_method)
      scope :with_approval_methods, -> (*args) {
        where(attribute => args.flatten) if args[0].present?
      }
    end

    def scope_by_device
      scope :with_device_types, -> (*args) {
        where(device_type: args.flatten) if args[0].present?
      }

      scope :with_device_models, -> (*args) {
        where(device_model: args.flatten) if args[0].present?
      }

      scope :with_device_brands, -> (*args) {
        where(device_brand: args.flatten) if args[0].present?
      }
    end

    def scope_by_browser
      scope :with_browsers, -> (*args) {
        where(browser: args.flatten) if args[0].present?
      }

      scope :with_browser_versions, -> (*args) {
        where(browser_version: args.flatten) if args[0].present?
      }
    end

    def scope_by_country(attribute = :country_id)
      scope :with_countries, -> (*args) {
        if args[0].present?
          values = [args, Country.international].flatten
          values = values.map { |x| x.id rescue x }

          # Query using cached values
          if attribute.to_s.match(/cache.*ids/)
            conditions = 1.upto(values.length).map { "FIND_IN_SET(?, #{attribute}) > 0" }
            query = [conditions.join(' OR ')]
            where(query + values)
          # Query using foreign key column
          else
            where(attribute => values)
          end
        end
      }
    end

    def scope_by_step_name(attribute = :step_name)
      scope :with_step_names, -> (*args) {
        if args[0].present?
          values = args.flatten
          if values.include?('no_step')
            where("#{attribute} IS NULL OR #{attribute} = ''")
          else
            where(attribute => values)
          end
        end
      }

      scope :with_conversion_point, -> (*args) {
        if args[0].present?
          conditions = ['conversions > 0']
          if args[0] == Offer.conversion_point_single
            conditions << 'order_id IS NULL'
          elsif args[0] == Offer.conversion_point_multi
            conditions << 'order_id IS NOT NULL'
          end

          where(conditions.join(' AND '))
        end
      }
    end

    def scope_by_recruiter(attribute = :recruiter_id)
      scope :with_recruiters, -> (*args) {
        if args[0].present?
          recruiter_ids = args.flatten.map { |x| x == NO_RECRUITER ? nil : x.try(:id) || x }
          where(attribute => recruiter_ids)
        end
      }
    end

    def scope_by_billing_region(attribute = :billing_region)
      scope :with_billing_regions, -> (*args) {
        if args.flatten.exclude?('all')
          if attribute == :network_id
            if self.name == 'Stat'
              where(network_id: Network.with_billing_regions(args).ids)
            else
              joins(:network).where(networks: Network.with_billing_regions(args))
            end
          else
            where(billing_region: args)
          end
        end
      }
    end
  end

  def self.args_valid?(args)
    args[0].is_a?(ActiveRecord::Relation) || args[0].present?
  end
end
