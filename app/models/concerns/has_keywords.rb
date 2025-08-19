module HasKeywords
  extend ActiveSupport::Concern

  included do
    has_one :keyword_set, as: :owner, autosave: true, dependent: :destroy
  end

  def keywords
    keyword_set&.keywords
  end

  def keywords=(value)
    return if keyword_set.nil? && value.blank?
    self.keyword_set ||= build_keyword_set
    keyword_set.keywords = value
  end

  def internal_keywords
    keyword_set&.internal_keywords
  end

  def save_url_as_keywords(old_url, new_url)
    KeywordSets::SaveUrlKeywordsJob.perform_later(self.class.name, id, old_url, new_url)
  end

  def process_save_url_as_keywords(old_url, new_url)
    old_url = old_url&.strip.presence
    new_url = new_url&.strip.presence

    self_keywords = internal_keywords.to_s.split(',').map(&:strip)
    self_keywords -= url_to_keywords(old_url) if old_url.present?
    self_keywords |= url_to_keywords(new_url) if new_url.present?

    self.keyword_set ||= build_keyword_set
    self.keyword_set.update(internal_keywords: self_keywords.compact_blank.uniq.join(', '))
  end

  private

  def url_to_keywords(url)
    [
      DotOne::Utils::Url.domain_name(url),
      DotOne::Utils::Url.domain_name_without_tld(url),
      DotOne::Utils::Url.host_name(url),
    ].compact_blank.uniq
  end
end
