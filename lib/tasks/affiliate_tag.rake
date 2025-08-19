require 'rake_wl'

namespace :wl do
  namespace :affiliate_tag do
    namespace :media_category do
      task sort: :environment do
        touch = -> (name) {
          AffiliateTag.media_categories.find_by(name: name).touch
          sleep 1
        }

        ['Facebook', 'Instagram', 'Twitter', 'XiaohongShu', 'Weibo', 'Other Social Media'].reverse.each(&touch)

        ['Youtube', 'TikTok', 'Bilibili', 'Youku', 'Vimeo', 'Twitch', 'Metacafe', 'Other Video Content'].reverse.each(&touch)
      end
    end
  end
end
