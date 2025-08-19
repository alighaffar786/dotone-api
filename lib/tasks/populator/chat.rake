require 'rake_wl'

namespace :wl do
  namespace :pop do
    task :chats, [:options] => :environment do |_t, args|
      RakeWl.when_populator_can_run do
        options = args[:options] || {}

        puts 'Generate Chat Rooms'

        [ChatRoom, ChatParticipation, ChatMessage].each(&:delete_all)

        ChatRoom.populate 5 do |chat_room|
          chat_room.name = Faker::Lorem.words(number: 3).join(' ')

          ChatParticipation.populate 1 do |chat_participation|
            chat_participation.chat_room_id = chat_room.id
            chat_participation.participant_id = Network.pluck(:id).sample
            chat_participation.participant_type = 'Network'
            chat_participation.participant_role = 'owner'
          end

          ChatParticipation.populate 5 do |chat_participation|
            participant_type = ChatParticipation::PARTICIPANT_TYPES.sample
            participant_id = participant_type.constantize.pluck(:id).sample

            chat_participation.chat_room_id = chat_room.id
            chat_participation.participant_id = participant_id
            chat_participation.participant_type = participant_type
            chat_participation.participant_role = 'participant'

            ChatMessage.populate 5 do |chat_message|
              chat_message.chat_participation_id = chat_participation.id
              chat_message.content = Faker::Lorem.sentences(number: 6).join('<br>')
            end
          end
        end
      end
    end
  end
end
