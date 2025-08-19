def stop_elastic_search
  system 'sudo pkill -f elastic_search'
end

namespace :es do
  task restart: :environment do
    stop_elastic_search
    system 'god -p 17171 -c config/god/elastic_search.rb'
  end

  task stop: :environment do
    stop_elastic_search
  end
end
