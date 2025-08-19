# frozen_string_literal: true

class KinesisJob < ApplicationJob
  queue_as :kinesis
end
