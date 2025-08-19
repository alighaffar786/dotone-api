# frozen_string_literal: true

class TimeZoneSerializer < ApplicationSerializer
  translatable_attributes(*TimeZone.static_translatable_attributes)

  attributes :id, :name, :gmt, :gmt_string_short, :gmt_offset

  def name
    object.t_gmt_string
  end

  def gmt_offset
    object.gmt_string
  end
end
