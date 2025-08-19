class RakeWl
  IMAGE_BASE_PATH = "#{Rails.root}/lib/tasks/populator/assets"
  CDN_BASE_PATH = "https://cdn.adotone.com/populators"

  def self.ask_affiliates(options = {})
    affiliate_ids = options[:affiliate_ids] || ENV["AFFILIATE"]
    return Affiliate.all if affiliate_ids == "ALL"

    affiliates = []
    if affiliate_ids.blank?
      print "AFFILIATE IDS ('ALL' for All Affiliates): "
      affiliate_ids = STDIN.gets.chomp
      return Affiliate.all if affiliate_ids == "ALL"
    end
    affiliate_ids.split(",").each do |affiliate_id|
      affiliates << Affiliate.find(affiliate_id) rescue nil
    end
    affiliates
  end

  def self.ask_offers(options = {})
    offer_ids = options[:offer_ids] || ENV["OFFER"]
    return Offer.all if offer_ids == "ALL"

    offers = []
    if offer_ids.blank?
      print "OFFER IDS ('ALL' for All Offers): "
      offer_ids = STDIN.gets.chomp
      return Offer.all if offer_ids == "ALL"
    end
    offer_ids.split(",").each do |offer_id|
      offers << Offer.find(offer_id) rescue nil
    end
    offers
  end

  def self.ask_dry_run(options = {})
    print "Dry Run (Y/N): "
    dry_run = STDIN.gets.chomp.downcase
    dry_run == "y"
  end

  def self.ask_continue(options = {})
    return true if options[:force] == true
    print "Continue (Y/N): "
    cont = STDIN.gets.chomp.downcase
    raise "Process stopped." if cont != "y"
  end

  def self.ask_data_size(options = {})
    sample_data_count = options[:data_size] || ENV["SIZE"]
    if sample_data_count.blank?
      print "Number of Sample Data: "
      sample_data_count = STDIN.gets.chomp
    end
    sample_data_count.to_i
  end

  def self.ask_date_range(options = {})
    time_zone = options[:time_zone]
    date_range = []
    start_at = options[:start_at] || ENV["START"]
    if start_at.blank?
      print "Start Date (YYYY-MM-DD): "
      start_at = STDIN.gets.chomp
    end
    end_at = options[:end_at] || ENV["END"]
    if end_at.blank?
      print "End Date (YYYY-MM-DD): "
      end_at = STDIN.gets.chomp
    end
    if time_zone.present?
      start_at = time_zone.to_utc(DateTime.parse(start_at).beginning_of_day)
      end_at = time_zone.to_utc(DateTime.parse(end_at).end_of_day)
    end
    [start_at, end_at]
  end

  def self.ask_date_type(options = {})
    date_type = options[:date_type] || ENV["DATETYPE"]
    if date_type.blank?
      puts "Choose a Date Type: "
      puts "Press 1 for recorded_at"
      puts "Press 2 for captured_at"
      puts "Press 3 for published_at"
      puts "Press 4 for converted_at"
      puts "Press 5 for updated_at"
      print "Enter Number: "
      selection = STDIN.gets.chomp
      date_type = if selection == "1"
          "recorded_at"
        elsif selection == "2"
          "captured_at"
        elsif selection == "3"
          "published_at"
        elsif selection == "4"
          "converted_at"
        elsif selection == "5"
          "updated_at"
        else
          nil
        end
    end
    date_type
  end

  def self.ask_min_id(options = {})
    min_id = options[:min_id] || ENV["MINID"]
    if min_id.blank?
      print "Minimum ID: "
      min_id = STDIN.gets.chomp
    end
    min_id
  end

  def self.ask_for(string)
    value = nil
    value = ENV[string]
    if value.blank?
      print "#{string}: "
      value = STDIN.gets.chomp
    end
    value
  end

  def self.when_populator_can_run
    # !!!!! THIS IS IMPORTANT - DO NOT REMOVE THIS. THIS IS
    # TO MAKE SURE THAT DATA ON PRODUCTION DATABASE WILL NOT GET DESTROYED
    # AND CLEANED UP. Staging server is running on production mode. So, it
    # is IMPORTANT to specify its specific database hostname so no other production
    # machine will be able to run this
    db_staging_host = 'staging-vibrantads-com.czvrokt2btwu.us-east-1.rds.amazonaws.com'
    current_db_host = Rails.configuration.database_configuration[Rails.env]['primary']['host']

    able_to_run_populator = %w[staging development].include?(Rails.env) || current_db_host == db_staging_host
    raise 'DB hostname is not staging' unless able_to_run_populator
    yield
  end
end
