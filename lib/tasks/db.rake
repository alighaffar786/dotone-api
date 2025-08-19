namespace :wl do
  namespace :db do
    task optimize_table: :environment do
      print 'DB Host Name: '
      db_host_name = STDIN.gets.chomp
      print 'Database Name: '
      database_name = STDIN.gets.chomp
      print 'Table Name: '
      table_name = STDIN.gets.chomp
      shell = <<-EOS
        pt-online-schema-change --alter "ENGINE=InnoDB" --recursion-method "none" --set-vars innodb_lock_wait_timeout=60 --execute D=#{database_name},t=#{table_name},h=#{db_host_name},p=88vibrant88,u=vibrantads
      EOS

      puts "Optimizing #{[db_host_name, database_name, table_name].join('.')}..."

      result = system(shell)

      puts(result == true ? 'DONE' : 'FAILS')
    end

    task cache: :environment do
      ENV['CACHE_WRITE_MODE'] = '1'

      DotOne::Setup.wl_company.flush_cache

      klasses = [
        AffiliateOffer,
        Affiliate,
        Blog,
        Campaign,
        Channel,
        ConversionStep,
        Country,
        Currency,
        Language,
        MktSite,
        Network,
        OfferVariant,
        Offer,
        TimeZone,
        WlCompany,
        ImageCreative,
        TextCreative,
      ]

      puts "Cache .find"
      klasses.each do |klass|
        puts "  #{klass}"
        klass.select(:id).find_each do |item|
          record = klass.cached_find(item.id)
          klass.cached_max_updated_at if klass.column_names.include?('updated_at')

          klass.instance_cache_methods.each do |action|
            if klass == Blog && action == :blog_page_with_slug
              record.blog_pages.pluck(:slug).each do |slug|
                record.cached_blog_page_with_slug(slug)
              end
            else
              record.send("cached_#{action}")
            end
          end
        end
      end

      puts "Cache .find_by"
      puts "  Country"
      Country.find_each do |country|
        Country.cached_find_by(name: country.name)
      end

      puts "  TimeZone"
      TimeZone.find_each do |time_zone|
        TimeZone.cached_find_by(gmt: time_zone.gmt)
        TimeZone.cached_find_by(gmt_string: time_zone.gmt_string)
      end

      puts "  Currency"
      Currency.find_each do |currency|
        Currency.cached_find_by(code: currency.code)
      end

      puts "  Language"
      Language.find_each do |language|
        Language.cached_find_by(code: language.code)
      end

      puts "Cache campaigns best match"
      AffiliateOffer.active.find_each do |campaign|
        ckey = DotOne::Utils.to_global_cache_key([campaign.class, campaign.affiliate, campaign.offer], :best_match)
        Rails.cache.write(ckey, campaign)
      end

      puts "MktSite domains and offers map"
      MktSite.cached_domains_map
      MktSite.cached_offers_map

      [DotOne::Setup.tracking_host, *AlternativeDomain.visible.success.tracking.pluck(:host)].each do |domain|
        DotOne::Cache.domain(domain)
      end

      NetworkOffer.cached_for_ad_links
    end
  end
end
