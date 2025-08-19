class AlternativeDomain < DatabaseRecords::SecondaryRecord
  include ConstantProcessor

  HOST_REGEX = /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]+\z/ix

  TRACKING_AUTO_SCALING_GROUP = ENV.fetch('TRACKING_AUTO_SCALING_GROUP', 'ASG - Track')

  HOST_TYPES = [
    'Owner',
    'Admin',
    'Affiliate',
    'Advertiser',
    'API',
    'PartnerApp',
    'Tracking',
  ].freeze

  STATUSES = [
    'In Progress',
    'Hosted',
    'Certificate Requested',
    'Pending Validation',
    'Pending Load Balancer',
    'Success',
    'Failed',
    'Pending Delete',
    'Deleted',
  ].freeze

  serialize :name_servers
  serialize :validation_record

  belongs_to :wl_company, inverse_of: :alternative_domains, touch: true

  has_many :stats, class_name: 'AlternativeDomainStat', inverse_of: :alternative_domain, dependent: :destroy

  validates :host, uniqueness: true, presence: true, format: { with: HOST_REGEX }
  validates :host_type, inclusion: { in: HOST_TYPES }
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  before_validation :set_defaults

  scope :visible, -> { where(visible: true) }
  scope :with_domain, -> (domain) {
    success.tracking
      .merge(AlternativeDomain.permanent.or(AlternativeDomain.not_expired))
      .where('host LIKE ? OR host LIKE ?', domain, "%.#{domain}")
  }

  # Temporary domains are used as a short-term
  # solution to work around the traffic source's
  # blacklist - such as Facebook blacklist
  scope :temporary, -> { where.not(expired_at: nil) }
  scope :permanent, -> { where(expired_at: nil) }
  scope :not_expired, -> { where('NOW() <= DATE_SUB(expired_at, INTERVAL 60 DAY)') }
  scope :expired, -> { where('expired_at <= ?', Time.current) }
  scope :for_panel, -> {
    where(host_type: ['Owner', 'Admin', 'Affiliate', 'Advertiser', 'API', 'PartnerApp'])
  }
  scope :adult_only, -> { where(adult_only: true) }
  scope :mainstream, -> { where(adult_only: false) }
  scope :with_statuses, -> (*args) { where(status: args[0]) if args[0].present? }

  define_constant_methods HOST_TYPES, :host_type
  define_constant_methods STATUSES, :status

  def self.tracking_domain_hosts
    success.visible.permanent.tracking.mainstream.pluck(:host)
  end

  def self.adult_tracking_domain_hosts
    success.visible.permanent.tracking.adult_only.pluck(:host)
  end

  def self.temporary_tracking_domain_hosts
    success.temporary.tracking.visible.not_expired.mainstream.pluck(:host)
  end

  def self.conversion_domain?(domain)
    [DotOne::Setup.tracking_host, 'twcouponcenter.com'].include?(domain)
  end

  def temporary?
    expired_at.present?
  end

  def permanent?
    !temporary?
  end

  def can_deploy?
    status.blank?
  end

  def can_destroy?
    status.blank? || success? || failed?
  end

  def certificate_shared_domains
    AlternativeDomain
      .where(certificate_arn: certificate_arn)
      .where('id <> ?', id)
  end

  def hosted_zone_client
    @hosted_zone_client ||= DotOne::Aws::HostedZone.new
  end

  def acm_client
    @acm_client ||= DotOne::Aws::Acm.new
  end

  def load_balancer_client
    @load_balancer_client ||= DotOne::Aws::LoadBalancerV2.new
  end

  def auto_scaling_client
    @auto_scaling_client ||= DotOne::Aws::AutoScaling.new
  end

  def hosted_zone
    return if hosted_zone_id.blank?

    @hosted_zone ||= hosted_zone_client.get(hosted_zone_id)
  end

  def certificate
    return if certificate_arn.blank?

    @certificate ||= acm_client.describe(certificate_arn)
  end

  def load_balancer
    return if load_balancer_dns_name.blank?

    @load_balancer ||= load_balancer_client.get(load_balancer_arn)
  end

  def load_balancer_alias_record
    return if load_balancer_dns_name.blank?

    {
      name: host,
      type: 'A',
      value: "dualstack.#{load_balancer_dns_name}",
      hosted_zone_id: load_balancer.canonical_hosted_zone_id,
    }
  end

  def load_balancer_tracking_record
    return if load_balancer_dns_name.blank?

    {
      name: "track.#{host}",
      type: 'CNAME',
      value: load_balancer_dns_name,
    }
  end

  def create_hosted_zone!
    return if hosted_zone_id.present?

    resp = hosted_zone_client.create({
      name: host,
      caller_reference: caller_reference,
    })

    self.status = AlternativeDomain.status_hosted
    self.hosted_zone_id = resp[:hosted_zone_id]
    self.name_servers = resp[:name_servers]
    save!
  end

  def create_certificate!
    return if certificate_arn.present?

    resp = acm_client.create(
      domain_name: domain_name,
      idempotency_token: idempotency_token,
      alternative_names: alternative_names,
    )

    self.status = AlternativeDomain.status_certificate_requested
    self.certificate_arn = resp.certificate_arn
    save!
  end

  def create_load_balancer!(options = {})
    if load_balancer_dns_name.blank? && load_balancer_arn.blank?
      lb = load_balancer_client.create(name: load_balancer_name)
      update_columns(load_balancer_dns_name: lb.dns_name, load_balancer_arn: lb.load_balancer_arn)
    end

    if target_group_arn.blank?
      tg = load_balancer_client.create_target_group(name: target_group_name)
      update_column(:target_group_arn, tg.target_group_arn)
    end

    if target_group_arn.present?
      load_balancer_client.modify_target_group(target_group_arn: target_group_arn)
    end

    if listener_http_arn.blank? && listener_https_arn.blank?
      listeners = load_balancer_client.create_listeners(
        target_group_arn: target_group_arn,
        load_balancer_arn: load_balancer_arn,
        certificate_arn: certificate_arn,
      )
      update_columns(listeners)
    end

    add_to_auto_scaling_group! unless options[:skip_auto_scaling_group]

    self.status = AlternativeDomain.status_success
    save!
  end

  def add_to_auto_scaling_group!
    auto_scaling_client.attach_load_balancers(
      auto_scaling_group_name: TRACKING_AUTO_SCALING_GROUP,
      target_group_arns: [target_group_arn],
    )
  end

  def add_load_balancer_alias_record!
    return if load_balancer_alias_record.blank?

    hosted_zone_client.add_alias_target(load_balancer_alias_record, hosted_zone_id)
  end

  def add_load_balancer_tracking_record!
    return if load_balancer_tracking_record.blank?

    hosted_zone_client.add_record(load_balancer_tracking_record, hosted_zone_id)
  end

  def add_validation_record!(certificate = nil)
    certificate ||= self.certificate
    validation_option = certificate.domain_validation_options.to_a.find do |option|
      option.validation_domain == domain_name
    end

    record = validation_option.try(:resource_record)

    return unless record.present?

    hosted_zone_client.add_record(record, hosted_zone_id)
    self.status = AlternativeDomain.status_pending_validation
    self.validation_record = record.to_h
    save!
  end

  def validate_certificate!
    return if certificate_arn.blank?

    resp = acm_client.describe(certificate_arn)

    case resp.status
    when 'PENDING_VALIDATION'
      add_validation_record!(resp)
    when 'ISSUED'
      add_validation_record!(resp) if validation_record.blank?
      self.status = AlternativeDomain.status_pending_load_balancer
      save!
    else
      self.status = AlternativeDomain.status_failed
      self.error_reason = "#{resp.status}: #{resp.failure_reason}"
      save!
    end
  end

  def poll_validation!
    attempt = 0

    while attempt < 10
      validate_certificate!
      break unless certificate_requested?

      attempt += 1
      sleep 30
    end
  end

  def delete_hosted_records!
    records = hosted_zone_client.list_records(hosted_zone_id)
    records.each do |record|
      next if ['NS', 'SOA'].include?(record.type)

      hosted_zone_client.delete_record(record, hosted_zone_id)
    end
  end

  def delete_hosted_zone!
    return if hosted_zone_id.blank?

    delete_hosted_records!
    hosted_zone_client.delete(hosted_zone_id)
    self.hosted_zone_id = nil
    self.name_servers = nil
    save!
  end

  def delete_from_auto_scaling_group!
    auto_scaling_client.detach_load_balancers(
      auto_scaling_group_name: TRACKING_AUTO_SCALING_GROUP,
      target_group_arns: [target_group_arn],
    )
  end

  def delete_listeners_from_load_balancer!
    listeners = load_balancer_client.get_listeners(load_balancer_arn)

    listeners.each do |listener|
      load_balancer_client.delete_listener(listener.listener_arn)
    end

    self.listener_https_arn = nil
    self.listener_http_arn = nil
    save!
  end

  def delete_target_group!
    return if target_group_arn.blank?

    delete_from_auto_scaling_group!
    load_balancer_client.delete_target_group(target_group_arn)

    self.target_group_arn = nil
    save!
  end

  def delete_load_balancer!
    return if load_balancer_dns_name.blank?

    delete_listeners_from_load_balancer!
    load_balancer_client.delete(load_balancer_arn)
    self.load_balancer_dns_name = nil
    self.load_balancer_arn = nil
    save!
  end

  def delete_certificate!(options = {})
    return if certificate_arn.blank?

    acm_client.delete(certificate_arn, options) unless certificate_shared_domains.any?
    self.certificate_arn = nil
    save!
  end

  def destroy
    return if pending_delete?

    update!(status: AlternativeDomain.status_pending_delete)

    handle_safely(log: true) do
      delete_hosted_zone!
      delete_load_balancer!
      delete_target_group!
      delete_certificate!(retry: true)
      update(status: AlternativeDomain.status_deleted)
    end
  end

  def queue_destroy(options = {})
    return if options[:force] != true && !can_destroy?

    AlternativeDomains::DestroyJob.perform_later(id)
  end

  def deploy
    return if in_progress?

    update!(status: AlternativeDomain.status_in_progress)

    handle_safely(log: true) do
      create_hosted_zone!
      create_certificate!
      poll_validation!
    end
  end

  def queue_deploy
    return unless can_deploy?

    AlternativeDomains::DeployJob.perform_later(id)
  end

  def record_tracking_usage!
    return unless tracking?

    record_stat!(:tracking_usage_count)
  end

  def record_tracking_clicks!
    return unless tracking?

    record_stat!(:tracking_click_count)
  end

  def record_stat!(stat_name)
    stat = stats.where(date: Time.now.utc.to_date).first_or_initialize
    stat[stat_name] += 1
    stat.save!
  end

  def tracking_usage_within_past_days(days = 60)
    stat_within_past_days(:tracking_usage_count, days)
  end

  def tracking_clicks_within_past_days(days = 60)
    stat_within_past_days(:tracking_click_count, days)
  end

  def stat_within_past_days(stat_name, days = 60)
    range = (days.to_i - 1).days.ago.to_date..Time.now.utc.to_date
    stat_map = stats.where(date: range).group(:date).sum(stat_name)
    stat_counts = range.map { |date| stat_map[date].to_i }
    [stat_counts.sum, stat_counts.join(',')]
  end

  def caller_reference
    "caller_reference_#{id}_#{updated_at.to_i}"
  end

  def idempotency_token
    "idempotency_token_#{id}_#{created_at.to_i}"
  end

  def load_balancer_name
    "LB-TRACK-#{host.gsub(/[^0-9A-Za-z]/, '-')}".upcase
  end

  def target_group_name
    "TG-TRACK-#{host.gsub(/[^0-9A-Za-z]/, '-')}".upcase
  end

  def domain_name
    "*.#{host}"
  end

  def alternative_names
    [domain_name, host]
  end

  def self.bulk_create(params = {})
    hosts = params[:host].to_s.split(/,|\s/).reject(&:blank?)
    create_params = hosts.map { |host| params.merge(host: host) }
    create(create_params)
  end

  def self.record_tracking_usage!(url)
    host = DotOne::Utils::Url.flexible_parse(url.to_s)&.domain
    find_by_host(host)&.record_tracking_usage!
  end

  def self.record_tracking_clicks!(url)
    host = DotOne::Utils::Url.flexible_parse(url.to_s)&.domain
    find_by_host(host)&.record_tracking_clicks!
  end

  def self.queue_record_tracking_usage(url)
    AlternativeDomains::RecordTrackingUsageJob.perform_later(url)
  end

  def self.queue_record_tracking_clicks(url)
    AlternativeDomains::RecordTrackingClicksJob.perform_later(url)
  end

  def self.check_validations
    tracking
      .with_statuses(status_pending_validation, status_pending_load_balancer)
      .each(&:check_validation)
  end

  def check_validation
    return if certificate_arn.blank?

    resp = acm_client.describe(certificate_arn)

    if resp.status == 'ISSUED'
      update(status: AlternativeDomain.status_pending_load_balancer)

      handle_safely do
        create_load_balancer!(skip_auto_scaling_group: true)
        add_load_balancer_tracking_record!
        add_load_balancer_alias_record!

        return if target_group_arn.blank?

        auto_scaling_client.attach_load_balancers(
          auto_scaling_group_name: TRACKING_AUTO_SCALING_GROUP,
          target_group_arns: target_group_arn,
        )
      end
    else
      validations = resp.domain_validation_options

      status =
        if validations.all? { |validation| validation.validation_status == 'SUCCESS' }
          AlternativeDomain.status_pending_load_balancer
        elsif validations.any? { |validation| validation.validation_status == 'FAILED' }
          AlternativeDomain.status_failed
        end

      update(status: status)
    end
  end

  private

  def set_defaults
    self.wl_company = DotOne::Setup.wl_company if wl_company.blank?
  end

  def handle_safely(options = {})
    yield
  rescue DotOne::Errors::AwsError => e
    self.status = AlternativeDomain.status_failed
    self.error_reason = e.message
    save

    if options[:log]
      error_str = e.full_message
      error_str << "\n\t#{e.backtrace.take(6).join("\n\t")}"
      Rails.logger.error error_str
    end

    nil
  end
end
