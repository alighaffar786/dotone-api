namespace :wl do
  namespace :postback do
    task migrate_data: :environment do
      Postback.connection.execute(
        <<-SQL.squish
          INSERT INTO dotone_postbacks (id, postback_type, raw_response, raw_request, affiliate_stat_id, created_at, updated_at, recorded_at)
          SELECT id, postback_type, raw_response, raw_request, affiliate_stat_id, created_at, updated_at, COALESCE(recorded_at, created_at) AS recorded_at
          FROM stat_postbacks
        SQL
      )
    end

    task remove_duplicate: :environment do
      duplicates = Postback.select('GROUP_CONCAT(id) AS ids, count(*) AS count, affiliate_stat_id, raw_request, raw_response, postback_type, recorded_at')
        .where('created_at > ?', 3.months.ago)
        .group(:affiliate_stat_id, :raw_request, :raw_response, :postback_type, :recorded_at)
        .having('count > 1').to_a

      CSV.open('tmp/duplicate_postbacks.csv', 'w') do |csv|
        csv << ['ids', 'count', 'affiliate_stat_id', 'raw_request', 'raw_response', 'postback_type', 'recorded_at']

        duplicates.each do |postback|
          csv << [
            postback.ids,
            postback.count,
            postback.affiliate_stat_id,
            postback.raw_request,
            postback.raw_response,
            postback.postback_type,
            postback.recorded_at.to_s(:db),
          ]

          postback_ids = postback.ids.split(',').drop(1)

          Postback.where(id: postback_ids).destroy_all
        end
      end
    end
  end
end
