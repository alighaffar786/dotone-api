require 'csv'

class DotOne::Services::MissingClickHandler
  def self.path
    Rails.root.join('log/missing_click_ids.csv')
  end

  def self.write(id)
    return if exists?(id)

    CSV.open(path, 'a') { |csv| csv << [id] }
  end

  def self.exists?(id)
    return false unless File.exist?(path)

    CSV.foreach(path, headers: false) do |row|
      return true if row[0].to_s == id.to_s && !AffiliateStat.exists?(id: id)
    end

    false
  end
end
