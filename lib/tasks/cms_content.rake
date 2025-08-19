namespace :cms_content do
  task publish_all: :environment do
    CmsContent.all.each do |cms_content|
      print "Publishing Content ID #{cms_content.id}..."
      cms_content.status = CmsContent::STATUS_PUBLISHED
      cms_content.save
      puts 'Done.'
    end
  end
  namespace :image do
    task reprocess_all: :environment do
      CmsContentImage.all.each do |image|
        print "Processing Images for content id #{image.cms_content.id}..."
        image.image.recreate_versions!
        puts 'Done.'
      end
    end
  end
  namespace :hit do
    task reset_cache: :environment do
      CmsContent.all.each do |cms_content|
        print "Reset cache for Content ID #{cms_content.id}..."
        cms_content.view_count = 0
        cms_content.promoted_view_count = 0
        cms_content.save
        puts 'Done.'
      end
    end

    task cache: :environment do
      CmsContentHit.not_cached.each do |hit|
        print "Caching hit ID #{hit.id}..."
        hit.cache_it
        puts 'Done.'
      end
    end

    task assign_cms_user: :environment do
      CmsContentHit.not_promoted.each do |hit|
        print "Assigning User for hit ID #{hit.id}..."
        if hit.cms_content.present?
          hit.cms_user_id = hit.cms_content.cms_user_id
          hit.promoted_by_id = hit.cms_content.cms_user_id
          puts hit.save
        else
          puts 'fails'
        end
      end
    end
  end
end
