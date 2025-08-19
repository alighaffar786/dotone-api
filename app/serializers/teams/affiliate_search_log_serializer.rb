class Teams::AffiliateSearchLogSerializer < ApplicationSerializer
  attributes :keyword, :count, :popularity

  def keyword
    object.try(:keyword)
  end

  def count
    object.try(:count).to_i
  end

  def popularity
    object.try(:popularity).to_f
  end
end
