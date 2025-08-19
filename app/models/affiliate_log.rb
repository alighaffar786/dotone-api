class AffiliateLog < DatabaseRecords::PrimaryRecord
  include LocalTimeZone
  include ConstantProcessor

  TARGETS = [
    'Affiliate',
    'AffiliateUser',
    'Network',
    'Offer'
  ].freeze

  CONTACT_MEDIA = [
    'Email',
    'Phone',
    'Chat',
    'Video',
    'In-Person',
  ].freeze

  CONTACT_STAGES = [
    'Initiation',
    'Introduction',
    'Discussion',
    'Conference Call',
    'Presentation',
  ].freeze

  attr_accessor :owner_grade

  belongs_to :owner, polymorphic: true, inverse_of: :affiliate_logs, touch: true
  belongs_to :agent, polymorphic: true, inverse_of: :affiliate_logs, touch: true

  has_many :crm_infos, inverse_of: :affiliate_log, dependent: :destroy
  has_one :crm_info

  accepts_nested_attributes_for :crm_infos, allow_destroy: true

  validates :notes, :owner, presence: true
  validates :contact_target, :contact_media, :contact_stage, :sales_pipeline, presence: true, if: :sales_log?
  validates :contact_media, inclusion: { in: CONTACT_MEDIA }, allow_blank: true
  validates :contact_stage, inclusion: { in: CONTACT_STAGES }, allow_blank: true
  validates :sales_pipeline, inclusion: { in: Network::SALES_PIPELINES.keys }, allow_blank: true

  before_validation :set_defaults
  after_commit :touch_owner
  after_commit :touch_owner_network

  set_local_time_attributes :created_at

  define_constant_methods TARGETS, :owner_type, prefix_scope: :owner, prefix_instance: :owner
  define_constant_methods TARGETS, :agent_type, prefix_scope: :agent, prefix_instance: :agent
  define_constant_methods CONTACT_MEDIA, :contact_media
  define_constant_methods CONTACT_STAGES, :contact_stage

  default_scope { order(created_at: :desc) }

  scope :sales_logs, -> { owner_network.agent_affiliate_user.where.not(contact_media: nil).where.not(contact_stage: nil)}

  def self.contact_media_with_stages
    basic_stages = [contact_stage_initiation, contact_stage_introduction, contact_stage_discussion]

    {
      contact_media_email => basic_stages,
      contact_media_phone => basic_stages,
      contact_media_chat => basic_stages,
      contact_media_video => [contact_stage_conference_call],
      contact_media_in_person => [contact_stage_presentation],
    }
  end

  def self.sales_metrics
    contact_media_with_stages.flat_map do |contact_media, contact_stages|
      contact_stages.map do |contact_stage|
        ConstantProcessor.to_method_name("#{contact_media}_#{contact_stage}")
      end
    end
  end

  def self.kpi_scores
    {
      contact_stage_initiation => 0,
      contact_stage_introduction => 1,
      contact_stage_discussion => 0.5,
      contact_stage_conference_call => 3,
      contact_stage_presentation => 3,
    }
  end

  def self.sales_summary(options = {})
    users = AffiliateUser
    users = users.where(id: options[:agent_ids]) if options[:agent_ids].present?
    start_date = options[:start_date].presence
    end_date = options[:end_date].presence

    metrics_agg_query = []
    count_agg_query = []
    contact_media_with_stages.each do |contact_media, contact_stages|
      contact_stages.each do |contact_stage|
        metric = ConstantProcessor.to_method_name("#{contact_media}_#{contact_stage}")

        sum = <<-SQL.squish
          SUM(CASE WHEN contact_media = '#{contact_media}' AND contact_stage = '#{contact_stage}' THEN 1 ELSE 0 END)
        SQL

        metrics_agg_query.concat([
          "#{sum} AS #{metric}",
          "(CASE WHEN #{sum} > 0 THEN 1 ELSE 0 END) AS #{metric}_count"
        ])

        count_agg_query.concat([
          "SUM(#{metric}) AS #{metric}",
          "SUM(#{metric}_count) AS #{metric}_count"
        ])
      end
    end

    metrics_agg_query = metrics_agg_query.join(',')
    count_agg_query = count_agg_query.join(',')

    metrics_select_query = sales_metrics.map do |metric|
      <<-SQL.squish
        COALESCE(sales_logs.#{metric}, 0) as #{metric}
      SQL
    end.join(',')

    users
      .select(
        <<-SQL
          affiliate_users.*,
          CAST(
            COALESCE(
              ((sales_logs.email_initiation_count + sales_logs.phone_initiation_count + sales_logs.chat_initiation_count) * #{kpi_scores[contact_stage_initiation]}) +
              ((sales_logs.email_introduction_count + sales_logs.phone_introduction_count + sales_logs.chat_introduction_count) * #{kpi_scores[contact_stage_introduction]}) +
              ((sales_logs.email_discussion_count + sales_logs.phone_discussion_count + sales_logs.chat_discussion_count) * #{kpi_scores[contact_stage_discussion]}) +
              (sales_logs.video_conference_call_count * #{kpi_scores[contact_stage_conference_call]}) +
              (sales_logs.in_person_presentation_count * #{kpi_scores[contact_stage_presentation]}), 0
            )
          AS DECIMAL(10, 2)) AS kpi,
          #{metrics_select_query}
        SQL
      )
      .joins(
        <<-SQL
          LEFT JOIN (
            SELECT agent_id, #{count_agg_query}
            FROM (
              SELECT agent_id, #{metrics_agg_query}
              FROM affiliate_logs
              WHERE affiliate_logs.id IN (#{sales_logs.between(start_date, end_date, :created_at, options[:time_zone], any: true).select(:id).to_sql})
              GROUP BY agent_id, owner_type, owner_id, DATE(created_at)
            ) AS counts GROUP BY agent_id
          ) AS sales_logs ON sales_logs.agent_id = affiliate_users.id
        SQL
      )
  end

  def sales_log?
    owner_network? && agent_affiliate_user?
  end

  def crm_target
    return @crm_target if @crm_target.present?

    @crm_target = crm_info&.crm_target
    @crm_target
  end

  def crm_contact_medias
    @crm_contact_medias ||= crm_infos.map(&:contact_media)
  end

  def touch_owner
    return unless owner.persisted?

    if owner.respond_to?(:note_updated_at)
      owner.touch(:note_updated_at)
    else
      owner.touch
    end
  end

  def touch_owner_network
    return unless sales_log?

    owner.sales_pipeline = sales_pipeline
    owner.grade = owner_grade
    owner.save(validate: false)
  end

  private

  def set_defaults
    if sales_log?
      self.contact_stage = AffiliateLog.contact_stage_conference_call if video?
      self.contact_stage = AffiliateLog.contact_stage_presentation if in_person?
    else
      self.contact_target = nil
      self.contact_media = nil
      self.contact_stage = nil
      self.sales_pipeline = nil
    end
  end
end
