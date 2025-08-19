namespace :wl do
  namespace :legacy_migration do
    task migrate_avatar_cdn_url: :environment do
      [Affiliate, Network, AffiliateUser].each do |klass|
        klass.disable_purgeable_file = true
      end

      placeholder_image = '/images/no-profile-300x300.jpg'
      puts 'start...'

      puts 'start updating affiliates...'
      Affiliate.joins(:avatar).find_each do |affiliate|
        puts "updating #{affiliate.id_with_name}..."

        avatar_cdn_url = affiliate.avatar.cdn_url
        avatar_cdn_url = nil if avatar_cdn_url == placeholder_image

        affiliate.update(avatar_cdn_url: avatar_cdn_url)
      end
      puts 'end updating affiliates...'

      puts 'start updating networks...'
      Network.joins(:avatar).find_each do |network|
        puts "updating #{network.id_with_name}..."

        avatar_cdn_url = network.avatar.cdn_url
        avatar_cdn_url = nil if avatar_cdn_url == placeholder_image

        network.update(avatar_cdn_url: avatar_cdn_url)
      end
      puts 'end updating networks...'

      puts 'start updating affiliate users'
      AffiliateUser.where.not(avatar: nil).find_each do |affiliate_user|
        puts "updating #{affiliate_user.id}..."

        affiliate_user.update(avatar_cdn_url: affiliate_user.avatar_cdn_url)
      end
      puts 'end updating affiliate users'

      puts 'end...'
    end

    task revert_avatar_cdn_url: :environment do
      [Affiliate, Network, AffiliateUser].each do |klass|
        klass.disable_purgeable_file = true
      end

      puts 'start updating affiliates...'
      Affiliate.joins(:avatar).find_each do |affiliate|
        next unless affiliate.avatar && affiliate.avatar.cdn_url == affiliate.avatar_cdn_url

        puts "updating #{affiliate.id_with_name}..."
        affiliate.update(avatar_cdn_url: nil)
      end
      puts 'end updating affiliates...'

      puts 'start updating networks...'
      Network.joins(:avatar).find_each do |network|
        next unless network.avatar && network.avatar.cdn_url == network.avatar_cdn_url

        puts "updating #{network.id_with_name}..."
        network.update(avatar_cdn_url: nil)
      end
      puts 'end updating networks...'

      puts 'start updating affiliate users'
      AffiliateUser.where.not(avatar: nil).find_each do |affiliate_user|
        next unless affiliate_user.avatar.url == affiliate_user.avatar_cdn_url

        puts "updating #{affiliate_user.id}..."
        affiliate_user.update(avatar_cdn_url: nil)
      end
      puts 'end updating affiliate users'
    end

    task assign_feed_country_from_token: :environment do
      puts 'start...'

      AffiliateFeed.find_each do |feed|
        if feed.network?
          feed.update(country_ids: [])
        elsif feed.affiliate?
          offer_ids = feed.content_offer_ids

          puts "Processing feed #{feed.id}"
          offers = NetworkOffer.where(id: offer_ids)

          country_ids = offers.flat_map(&:country_ids)
          country_ids += feed.country_ids
          country_ids.push(Country.international.id) if country_ids.empty?
          country_ids.uniq!

          puts "Assigning country_ids #{country_ids} to feed #{feed.id}"
          feed.update(country_ids: country_ids)
        end
      end

      puts 'done...'
    end

    task migrate_screenshot_cdn_url: :environment do
      puts 'start...'

      MissingOrder.joins(:screenshot).find_each do |missing_order|
        puts "updating #{missing_order.id}..."
        screenshot_cdn_url = missing_order.screenshot.cdn_url

        missing_order.update_column(:screenshot_cdn_url, screenshot_cdn_url)
      end

      puts 'done...'
    end

    task restore_avatar: :environment do
      puts 'start...'

      bucket = Aws::S3::Bucket.new(ENV.fetch('AWS_S3_PUBLIC_BUCKET'))

      AffiliateUser.find_each do |user|
        next if user.avatar_cdn_url.blank?

        puts "Restoring #{user.id}..."

        dir_url, original_name = Pathname.new(user.avatar_cdn_url).split.map(&:to_s)
        uri = URI.parse(dir_url)
        dir_key = uri.path.sub('/', '')

        original_key = "#{dir_key}/#{original_name}"
        thumb_key = "#{dir_key}/thumb_#{original_name}"

        thumb = bucket.object(thumb_key)
        original = bucket.object(original_key)

        if original.exists?
          puts "Original file #{original_key} already exists"
        elsif thumb.exists?
          puts "Copying #{thumb_key} to #{original_key}"
          thumb.copy_to(original)
        else
          puts "Thumb file #{thumb_key} does not exist"
        end
      end

      puts 'end...'
    end

    task assign_affiliate_id_to_site_infos: :environment do
      puts 'start...'
      query = <<-SQL.squish
        UPDATE site_infos
          INNER JOIN affiliate_sites ON affiliate_sites.site_info_id = site_infos.id
          INNER JOIN affiliate_applications ON affiliate_applications.id = affiliate_sites.affiliate_application_id
          INNER JOIN affiliates ON affiliates.id = affiliate_applications.affiliate_id
          SET site_infos.affiliate_id = affiliates.id
      SQL

      DatabaseRecords::PrimaryRecord.connection.execute(query)

      puts 'end'
    end

    task remove_flag_from_translations: :environment do
      Translation.where(field: 'flag_offer_name').update_all(field: 'offer_name')
      Translation.where(field: 'flag_custom_approval_message').update_all(field: 'custom_approval_message')
    end
  end
end
