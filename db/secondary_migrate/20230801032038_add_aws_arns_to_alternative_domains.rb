class AddAwsArnsToAlternativeDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :alternative_domains, :target_group_arn, :text, after: :load_balancer_dns_name
    add_column :alternative_domains, :listener_http_arn, :text, after: :load_balancer_dns_name
    add_column :alternative_domains, :listener_https_arn, :text, after: :load_balancer_dns_name
    add_column :alternative_domains, :load_balancer_arn, :text, after: :load_balancer_dns_name
  end
end
