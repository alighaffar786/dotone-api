# frozen_string_literal: true

class Networks::CleanupNoEngagementsJob < MaintenanceJob
  def perform
    no_engagements = query_no_engagements.to_a

    NETWORK_RAKE_LOGGER.warn "Advertiser count to cleanup: #{no_engagements.length}"

    no_engagements.each do |network|
      NETWORK_RAKE_LOGGER.warn "Clean up manager assignment for Advertiser #{network.id}"
      network.affiliate_users = network.affiliate_users.reject(&:sales_manager?)
    end
  end

  def query_no_engagements
    manager_table = <<-SQL.squish
      (
        SELECT affiliate_assignments.network_id, COUNT(*) AS manager_count
        FROM affiliate_assignments
        INNER JOIN affiliate_users ON affiliate_users.id = affiliate_assignments.affiliate_user_id
        WHERE affiliate_users.roles = '#{AffiliateUser.roles_sales_manager}'
        GROUP BY affiliate_assignments.network_id
      ) AS managers
    SQL

    Network
      .considered_pending
      .where(contact_name: nil)
      .joins("LEFT OUTER JOIN #{manager_table} ON managers.network_id = networks.id")
      .where('managers.manager_count > 0')
  end
end
