class KeywordSets::SaveUrlKeywordsJob < EntityManagementJob
  discard_on ActiveRecord::RecordNotFound

  def perform(entity_klass, entity_id, old_url, new_url)
    entity = entity_klass.constantize.find(entity_id)
    entity.process_save_url_as_keywords(old_url, new_url)
  end
end
