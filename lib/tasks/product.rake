namespace :wl do
  namespace :products do
    desc 'Export products to csv file'
    task export: :environment do
      print 'Offer IDs: '
      offer_ids = STDIN.gets.chomp
      offer_ids = offer_ids.split(',').map { |x| x.strip }
      offers = Offer.where(id: offer_ids) rescue nil
      raise 'No offer is found' if offers.blank?

      print 'Affiliate ID: '
      affiliate_id = STDIN.gets.chomp
      affiliate = Affiliate.find(affiliate_id) rescue nil
      raise 'No affiliate is found' if affiliate.blank?

      offers.compact.each do |offer|
        offer_id = offer.id

        campaign = AffiliateOffer.active_best_match(
          affiliate,
          offer,
        )

        tmp_file = "#{Rails.root}/tmp/products-oid#{offer_id}-aid#{affiliate_id}.csv"

        rotation = 0

        CSV.open(tmp_file, 'wb') do |csv|
          header_written = false
          Product.where(offer_id: offer_id)
            .order('updated_at DESC')
            .find_in_batches(batch_size: 10_000) do |products|
            rotation += 1
            break if rotation >= 50

            hash = Product.collection_to_json_string_hash(products, campaign)

            unless header_written
              csv << hash[:products].first.keys
              header_written = true
            end

            hash[:products].each do |product_hash|
              csv << product_hash.values
            end
          end
        end

        download = Download.create({
          name: "Product Download Affiliate: #{affiliate_id} for Offer: #{offer_id}",
          file_type: 'Product',
          notes: "Prepared on #{Time.now}",
          status: Download.status_in_progress,
          owner_id: affiliate_id,
          owner_type: 'Affiliate',
          downloaded_by: 'System',
        })

        File.open(tmp_file, 'rb') { |file| download.file = file }
        File.delete(tmp_file)
        download.status = Download.status_ready
        download.save
      end
    end

    task :remove_duplicates, [:options] => :environment do |_t, _args|
      sql = <<-SQL
      SELECT
        uniq_key, COUNT(uniq_key)
      FROM
        products
      GROUP BY
        uniq_key
      HAVING
        COUNT(uniq_key) > 1
      LIMIT 50000;
      SQL

      rotation = 1

      loop do
        results = Product.connection.exec_query(sql)

        id_collection = results.entries.map(&:uniq_key)

        id_collection.each do |uniq_key|
          puts "[ROTATION: #{rotation}] Deleting duplicates for Product: #{uniq_key}..."
          to_delete = Product.where(uniq_key: uniq_key).order('updated_at desc')
          to_keep = to_delete.first
          to_delete = to_delete[1, to_delete.length - 1]

          if to_delete.present? && to_keep.present?
            puts "  Size to Delete: #{to_delete.length}"
            results = Product.where(uniq_key: uniq_key).where('updated_at <> ?', to_keep.updated_at).delete_all
            puts '  DONE'
          else
            puts '  Skipped'
          end
        end

        rotation += 1

        break if id_collection.blank?
      end
    end

    task :cleanup, [:options] => :environment do |_t, _args|
      threshold_time = Time.now - 360.days

      rotation = 0

      Product.where('updated_at <= ?', threshold_time).order('updated_at ASC')
        .find_in_batches(batch_size: 10_000) do |products|
        index = 0
        rotation += 1
        products.each do |p|
          index += 1
          puts "[Rotation #{rotation}] #{index} of #{products.length} Destroying product #{p.uniq_key} with updated_at #{p.updated_at}... #{p.destroy.present?}"
        end
      end
    end

    task report_not_indexed: :environment do
      path = Rails.root.join("tmp/unindexed_product_ids_#{Time.now.to_s(:db)}.csv")

      CSV.open(path, 'w') do |csv|
        csv << ['uniq_key']
        Product.unindexed_ids do |ids|
          ids.each { |id| csv << [id] }
        end
      end
    end

    task create_not_found_index: :environment do
      Product.unindexed_ids do |ids|
        Product
          .preload_es_relations
          .where(uniq_key: ids)
          .es_bulk_update
      end
    end
  end
end
