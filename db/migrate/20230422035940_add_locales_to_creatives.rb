class AddLocalesToCreatives < ActiveRecord::Migration[6.1]
  def up
    add_column :text_creatives, :locales, :json, array: true
    add_column :image_creatives, :locales, :json, array: true

    TextCreative.where(locale: 'en-US').update_all(locales: ['en-US'])
    TextCreative.where(locale: 'zh-TW').update_all(locales: ['zh-TW'])

    ImageCreative.where(locale: 'en-US').update_all(locales: ['en-US'])
    ImageCreative.where(locale: 'zh-TW').update_all(locales: ['zh-TW'])
  end

  def down
    remove_column :text_creatives, :locales
    remove_column :image_creatives, :locales
  end
end
