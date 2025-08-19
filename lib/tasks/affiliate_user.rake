require 'rake_wl'

namespace :wl do
  namespace :affiliate_users do
    desc "Reset affiliate user's column setup"
    task :reset_columns, [:options] => :environment do |_t, _args|
      AffiliateUser.all.each do |affiliate_user|
        print "Resetting columns for Affiliate User: #{affiliate_user.id_with_name}..."
        current_columns = affiliate_user.system_flag(:column_setup)
        if current_columns.present?
          affiliate_user.system_flag(:column_setup, {})
          puts 'DONE'
        else
          puts 'SKIPPED'
        end
      end
    end
  end
end
