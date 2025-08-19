require 'rake_wl'

namespace :wl do
  desc 'Create a white label client'
  task create: :environment do
    print 'Username: '
    username = STDIN.gets.chomp
    user = User.find_by_username(username) rescue nil
    raise 'No User found.' if user.blank?

    print 'WL Type (1: Tracking, 2: Affiliate): '
    wl_label_type = STDIN.gets.chomp
    if wl_label_type.to_s == '2'
      wl_label_type = 'Affiliate'
    elsif wl_label_type.to_s == '1'
      wl_label_type = 'Tracking'
    else
      raise 'Invalid choice.'
    end

    print 'WL Language ID: '
    wl_language_id = STDIN.gets.chomp
    language = Language.cached_find(wl_language_id) rescue nil
    raise 'No Language found.' if language.blank?

    print 'WL Currency ID: '
    wl_currency_id = STDIN.gets.chomp
    currency = Language.cached_find(wl_currency_id) rescue nil
    raise 'No Currency found.' if currency.blank?

    print 'WL Name: '
    wl_name = STDIN.gets.chomp
    print 'WL Domain: '
    wl_domain = STDIN.gets.chomp
    print 'WL Affiliate Domain: '
    wl_affiliate_domain = STDIN.gets.chomp
    print 'WL Advertiser Domain: '
    wl_advertiser_domain = STDIN.gets.chomp
    print 'WL Owner Domain: '
    wl_owner_domain = STDIN.gets.chomp

    wl_company = WlCompany.new(language_id: language.id,
      name: wl_name, domain_name: wl_domain,
      currency_id: currency.id,
      label_type: wl_label_type,
      affiliate_domain_name: wl_affiliate_domain,
      advertiser_domain_name: wl_advertiser_domain,
      owner_domain_name: wl_owner_domain)

    wl_company.user = user

    raise wl_company.errors.full_messages.join(',') unless wl_company.save

    puts 'DONE'
  end

  desc 'White Label Client DB CREATE from Master'
  task db_create: :environment do
    print 'WL Company ID: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_create(:console) if wl_company.present?
    end
  end

  desc 'White Label Client DB COPY from Master'
  task db_copy: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_copy(:console) if wl_company.present?
    end
  end

  desc 'All White Label Client DB COPY from Master'
  task db_copy_all: :environment do
    WlCompany.platform.each do |wl_company|
      wl_company.db_copy(:console)
    rescue Exception => e
      puts "Error: #{e.backtrace}"
    end
  end

  desc 'White Label Client DB UPDATE from Master'
  task db_update: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_update(:console) if wl_company.present?
    end
  end

  desc 'All White Label Client DB UPDATE from Master'
  task db_update_all: :environment do
    WlCompany.platform.each do |wl_company|
      wl_company.db_update(:console)
    rescue Exception => e
      puts "Error: #{e.message} #{e.backtrace}"
    end
  end

  desc 'White Label Client Column Change from Master'
  task db_change_column: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_change_column(:console) if wl_company.present?
    end
  end

  desc 'White Label Client Column Change from Master'
  task db_change_column_all: :environment do
    WlCompany.platform.each do |_wl_company|
      WlCompany.platform.each do |wl_company|
        wl_company.db_change_column(:console)
      rescue Exception => e
        puts "Error: #{e.backtrace}"
      end
    end
  end

  desc 'White Label Client DB index from Master'
  task db_index: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_index(console: true) if wl_company.present?
    end
  end

  desc 'All White Label Client DB index from Master'
  task db_index_all: :environment do
    WlCompany.platform.each do |wl_company|
      wl_company.db_index(console: true)
    rescue Exception => e
      puts "Error: #{e.backtrace}"
    end
  end

  task db_seed: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      wl_company.db_seed(:console) if wl_company.present?
    end
  end

  task db_seed_all: :environment do
    WlCompany.platform.each do |wl_company|
      wl_company.db_seed(:console)
    rescue Exception => e
      puts "Error: e.message #{e.backtrace}"
    end
  end

  task db_reseed: :environment do
    print 'WL Company IDs: '
    company_ids = STDIN.gets.chomp
    print 'Classes: '
    klasses = STDIN.gets.chomp.split(',') rescue nil
    company_ids.split(',').each do |company_id|
      wl_company = WlCompany.find(company_id) rescue nil
      if wl_company.present?
        if klasses.present?
          klasses = klasses.map(&:constantize)
          wl_company.db_reseed(:console, klasses)
        else
          wl_company.db_reseed(:console)
        end
      end
    end
  end

  task switch: :environment do
    wl_company = WlCompany.find_by_name('Convertrack Demo')
    user = wl_company.user
    wl_company.label_type = wl_company.label_type == WlCompany::LABEL_TYPE_AFFILIATE ? WlCompany::LABEL_TYPE_TRACKING : WlCompany::LABEL_TYPE_AFFILIATE
    wl_company.save
    user.roles = user.roles == Role::NAME_MEDIA_BUYER ? [Role.find_by_name(Role::NAME_NETWORK_OWNER)] : [Role.find_by_name(Role::NAME_MEDIA_BUYER)]
    user.save
  end

  task one_timer: :environment do
    wl_company = DotOne::Setup.wl_company
    file_name = ENV.fetch('FILE', nil)
    wl_company.one_timer(file_name)
  end

  task one_timer_all: :environment do
    wl_company = DotOne::Setup.wl_company
    file_name = ENV.fetch('FILE', nil)
    wl_company.one_timer(file_name)
  end

  desc 'Generate invoice at the beginning of every month on all clients'
  task create_invoices: :environment do
    raise 'Not the correct server type.' unless SERVER_TYPE == 'SUPPORT'

    wl = DotOne::Setup.wl_company
    puts "Creating invoice for Wl Company id #{wl.id}"
    Invoice.generate!(
      Time.now.strftime('%Y').to_i,
      Time.now.strftime('%m').to_i,
      wl.id, { auto_deliver: true }
    )
  rescue StandardError => e
    puts "There is an error while attempting to create invoice for WlCompany #{wl.id}"
    puts "#{e.message}"
  end

  desc 'White Label Client DB ALTER from Master'
  task db_alter: :environment do
    print 'WL Company ID: '
    company_id = STDIN.gets.chomp
    wl_company = WlCompany.find(company_id) rescue nil
    if wl_company.present?
      puts "=== Altering database #{wl_company.db_name} ==="
      wl_company.db_models.each do |klass|
        next unless klass.table_exists?

        master = wl_company.db_client(client_for: :master)
        sql = "SHOW COLUMNS FROM #{wl_company.db_name(:master)}.#{klass.table_name};"
        master_columns = master.query(sql).map { |x| x }
        client = wl_company.db_client
        sql = "SHOW COLUMNS FROM #{wl_company.db_name}.#{klass.table_name};"
        client_columns = client.query(sql).map { |x| x }

        # Change column from master
        master_columns.each_with_index do |master_col, index|
          client_col = client_columns[index]
          next if master_col == client_col

          definition = master_col
          data_type = definition['Type']
          null_option = definition['Null'] == 'No' ? 'NOT NULL' : 'NULL'
          default_value = definition['Default'].present? ? "DEFAULT #{definition['Default']}" : ''
          auto_increment = definition['Extra'].include?('auto_increment') ? 'AUTO_INCREMENT' : ''
          primary_key = definition['Key'] == 'PRI' ? 'PRIMARY KEY' : ''
          print "Altering column #{client_col['Field']} to #{wl_company.db_name}..."
          sql = <<-EOS
                ALTER TABLE #{wl_company.db_name}.#{klass.table_name}
                MODIFY COLUMN #{client_col['Field']} #{data_type} #{null_option} #{default_value}
                #{auto_increment} #{primary_key}
          EOS
          client.query(sql)
          puts 'DONE'
        end
      end
    end
  end

  desc 'Reset columns for all users on all user types'
  task reset_columns: :environment do
    options = {
      wl: ENV.fetch('WL', nil),
    }
    Rake::Task['wl:users:reset_columns'].invoke(options)
    Rake::Task['wl:affiliate_users:reset_columns'].invoke(options)
    Rake::Task['wl:networks:reset_columns'].invoke(options)
    Rake::Task['wl:affiliates:reset_columns'].invoke(options)
  end
end
