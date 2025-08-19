class DotOne::Services::CapNotifier
  include ActiveModel::Model

  attr_accessor :instance_to_notify, :notification_type, :cap_ratio_used

  # For consistency, we use standardized
  # cap ratio instead of using real time number
  def cap_percentage_used
    cap_ratio_used.present? ? "#{cap_ratio_used * 100}%" : nil
  end

  ##
  # Method to send depleting email.
  # The deliveries are made multiple times with different
  # set of recipients to conserve resources taken for each call
  # to this method.
  def send_depleting_email(recipients)
    deliver_email(recipients, :depleting)
  end

  ##
  # Method to send depleted email.
  # The deliveries are made multiple times with different
  # set of recipients to conserve resources taken for each call
  # to this method.
  def send_depleted_email(recipients)
    deliver_email(recipients, :depleted)
  end

  ##
  # email_type: 'depleting' or 'depleted'
  def deliver_email(receivers, email_type)
    receivers.each do |receiver|
      AffiliateMailer.send(
        "notify_#{notification_type}_cap_#{email_type}",
        instance_to_notify,
        receiver,
        cap_percentage_used
      ).deliver_later
    end
  end
end
