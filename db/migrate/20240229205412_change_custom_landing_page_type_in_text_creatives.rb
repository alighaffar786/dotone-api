class ChangeCustomLandingPageTypeInTextCreatives < ActiveRecord::Migration[6.1]
  def up
    change_column :text_creatives, :custom_landing_page, :text
  end

  def down
    change_column :text_creatives, :custom_landing_page, :string
  end
end
