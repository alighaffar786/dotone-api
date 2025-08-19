# frozen_string_literal: true

class ApiPullJob < ApplicationJob
  queue_as :api_pull
end
