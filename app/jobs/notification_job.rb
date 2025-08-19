# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :email_notification
end
