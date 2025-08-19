module NameHelper
  extend ActiveSupport::Concern

  def id_with_name(locale = nil)
    if respond_to?(:t_name)
      "(#{id}) #{t_name(locale)}"
    else
      "(#{id}) #{full_name}"
    end
  end

  def full_name
    fname = first_name rescue nil
    lname = last_name rescue nil
    @full_name = [fname, lname].reject(&:blank?).join(' ')
    @full_name = name rescue nil if @full_name.blank?
    @full_name
  end

  def id_name_role
    if respond_to?(:roles)
      "(#{id}) #{full_name} [#{roles}]"
    else
      "(#{id}) #{full_name}"
    end
  end

  def full_name_with_email
    return full_name unless respond_to?(:email)
    [full_name, "<#{email}>"].reject(&:blank?).join(' ')
  end
end
