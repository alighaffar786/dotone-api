# frozen_string_literal: true

class Networks::CleanupInactiveEngagementsJob < MaintenanceJob
  def perform
    inactive_engagements = query_inactive_engagements.to_a

    NETWORK_RAKE_LOGGER.warn "Advertiser count to cleanup: #{inactive_engagements.size}"

    inactive_engagements.each do |network|
      NETWORK_RAKE_LOGGER.warn "Clean up manager assignment for Advertiser #{network.id}"
      network.affiliate_users = network.affiliate_users.reject(&:sales_manager?)
    end
  end

  def query_inactive_engagements
    notes_table = <<-SQL.squish
      (
        SELECT affiliate_logs.owner_type, affiliate_logs.owner_id, COUNT(*) AS note_count
        FROM affiliate_logs
        WHERE DATEDIFF(CURDATE(), affiliate_logs.created_at) <= 90 AND owner_type = 'Network'
        GROUP BY affiliate_logs.owner_type, affiliate_logs.owner_id
      ) AS active_notes
    SQL

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
      .joins("LEFT OUTER JOIN #{notes_table} ON active_notes.owner_id = networks.id")
      .joins("LEFT OUTER JOIN #{manager_table} ON managers.network_id = networks.id")
      .where('active_notes.note_count IS NULL OR active_notes.note_count = 0')
      .where('managers.manager_count > 0')
  end
end
