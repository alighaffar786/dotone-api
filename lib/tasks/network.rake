require 'rake_wl'

namespace :wl do
  namespace :networks do
    desc "Reset advertiser's column setup"
    task :reset_columns, [:options] => :environment do |_t, _args|
      Network.all.each do |network|
        print "Resetting columns for advertiser: #{network.id_with_name}..."
        current_columns = network.system_flag(:column_setup)
        if current_columns.present?
          network.system_flag(:column_setup, {})
          puts 'DONE'
        else
          puts 'SKIPPED'
        end
      end
    end
  end
end
