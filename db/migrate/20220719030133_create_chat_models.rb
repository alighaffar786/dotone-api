class CreateChatModels < ActiveRecord::Migration[6.1]
  def change
    create_table :chat_rooms do |t|
      t.string :name
      t.timestamps
    end

    create_table :chat_participations do |t|
      t.references :chat_room, index: true
      t.references :participant, polymorphic: true
      t.string :participant_role, default: 'participant'
      t.timestamps
    end

    create_table :chat_messages do |t|
      t.references :chat_participation, index: true
      t.text :content
      t.timestamps
    end
  end
end
