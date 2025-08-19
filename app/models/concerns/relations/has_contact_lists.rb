module Relations::HasContactLists
  extend ActiveSupport::Concern

  included do
    has_many :contact_lists, as: :owner, dependent: :destroy
    has_many :optin_contact_lists, -> { active.email_optin }, class_name: 'ContactList', as: :owner
  end

  def build_mailing_list
    if !respond_to?(:email) || optin_contact_lists.exists?(email: email)
      optin_contact_lists
    else
      [optin_contact_lists, self].flatten
    end
  end

  def contact_list_names_and_emails
    contact_lists.map(&:full_name_with_email)
  end

  def mailing_list
    optin_contact_lists
      .select { |contact_list| contact_list.email.match(REGEX_EMAIL) }
      .map(&:full_name_with_email)
  end

  def full_name_with_email
    "#{full_name} <#{email}>"
  end
end
