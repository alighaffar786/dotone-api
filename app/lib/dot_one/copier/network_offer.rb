class DotOne::Copier::NetworkOffer < DotOne::Copier::Offer
  private

  def image_object_path
    "#{Rails.env}/dotone/network_offer/affiliate_user/#{user.id}/"
  end
end
