class Trace < DatabaseRecords::PrimaryRecord
  VERB_EMAILS = 'emails'
  VERB_CREATES = 'creates'
  VERB_UPDATES = 'updates'
  VERB_ACCESS = 'accesses'
  VERB_LOGINS = 'logins'

  belongs_to :agent_user, polymorphic: true, foreign_type: :agent_type, foreign_key: :agent_id

  scope :for_entity, -> (*args) {
    queries = []
    values = []
    args = args.flatten

    # required entity
    entity = args[0]

    queries << sanitize_sql_for_conditions(
      target_id: entity.id.to_s,
      target_type: entity.class.name,
    )

    queries << sanitize_sql_for_conditions(
      agent_id: entity.id.to_s,
      agent_type: entity.class.name,
    )

    association_hash = args[1] || {}

    included_has_many_entities = association_hash[:has_many].try(:[], :include).to_a.reject(&:blank?)
    excluded_has_many_entities = association_hash[:has_many].try(:[], :exclude).to_a.reject(&:blank?)
    has_many_entities = included_has_many_entities - excluded_has_many_entities

    # included has many entities
    has_many_entities.each do |included_entity|
      class_name = included_entity.to_s.singularize.camelize
      included_entity_instances = entity.send(included_entity)
      ids = if included_entity_instances.is_a?(Array)
        included_entity_instances.flatten.map(&:id)
      elsif included_entity_instances.is_a?(ActiveRecord::Relation)
        included_entity_instances.ids
      elsif included_entity_instances.present?
        [included_entity_instances.id]
      end

      next unless ids.present?

      ids = ids.map(&:to_s)

      queries << sanitize_sql_for_conditions(
        target_id: ids,
        target_type: class_name,
      )

      queries << sanitize_sql_for_conditions(
        agent_id: ids,
        agent_type: class_name,
      )
    end

    included_has_one_entities = association_hash[:has_one].try(:[], :include).to_a.reject(&:blank?)
    excluded_has_one_entities = association_hash[:has_one].try(:[], :exclude).to_a.reject(&:blank?)
    has_one_entities = included_has_one_entities - excluded_has_one_entities

    # included has one entities
    has_one_entities.each do |included_entity|
      class_name = included_entity.to_s.singularize.camelize
      ids = [entity.send(included_entity).id.to_s]
      next unless ids.present?

      queries << sanitize_sql_for_conditions(
        target_id: ids,
        target_type: class_name,
      )

      queries << sanitize_sql_for_conditions(
        agent_id: ids,
        agent_type: class_name,
      )
    end

    select_statements = []
    queries.each do |condition_statement|
      select_statements << select('*').where(condition_statement).to_sql
    end

    excluded_entities = [excluded_has_many_entities, excluded_has_one_entities].flatten
    if excluded_entities.present?
      class_names = excluded_entities.map(&:to_s).map(&:singularize).map(&:camelize)
      reject_statement = sanitize_sql_for_conditions(['target_type NOT IN (?)', class_names])
    end

    # Some entries will be duplicated since
    # agent and target is the same thing. Thus,
    # we need distinct here
    if reject_statement.present?
      where(reject_statement)
        .select('DISTINCT *').from("((#{select_statements.join(') UNION ALL (')})) AS traces")
    else
      select('DISTINCT *').from("((#{select_statements.join(') UNION ALL (')})) AS traces")
    end
  }

  scope :with_verb, -> (*args) {
    where(verb: args) if args[0].present?
  }

  def agent_details
    return agent unless agent_user

    type = DotOne::I18n.predefined_t("trace.agent_type.#{agent_type}")

    "#{type} [#{agent_id}]"
  end

  def details
    [agent_details, verb, target, notes].reject(&:blank?).join(' ')
  end
end
