namespace :zip_code do
  task import: :environment do
    require 'csv'
    CSV.foreach("#{Rails.root}/data/ZIP_CODES.txt") do |row|
      ZipCode.create(code: row[0],
        latitude: row[1],
        longitude: row[2],
        city: row[3],
        state: row[4],
        county: row[5],
        zip_class: row[6])
    end
  end
end
