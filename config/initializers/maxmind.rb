require 'maxminddb'

ISP_DB = MaxMindDB.new("#{Rails.root}/data/maxmind/GeoIP2-ISP.mmdb")
GEO_DB = MaxMindDB.new("#{Rails.root}/data/maxmind/GeoLite2-City.mmdb")
