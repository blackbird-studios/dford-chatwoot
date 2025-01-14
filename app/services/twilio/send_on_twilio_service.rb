class Twilio::SendOnTwilioService < Base::SendOnChannelService
  private

  def channel_class
    Channel::TwilioSms
  end

  def perform_reply
    twilio_message = client.messages.create(message_params)
    message.update!(source_id: twilio_message.sid)
  end

  def message_params
    params = {
      body: message.content,
      from: channel.phone_number,
      to: contact_inbox.source_id
    }
    params[:media_url] = attachments if accepts_attachments && message.attachments.present?
    params
  end

  def accepts_attachments
    channel.whatsapp? || contact_inbox.source_id.start_with?('+1')
  end

  def attachments
    message.attachments.map(&:file_url)
  end

  def inbox
    @inbox ||= message.inbox
  end

  def channel
    @channel ||= inbox.channel
  end

  def outgoing_message?
    message.outgoing? || message.template?
  end

  def client
    ::Twilio::REST::Client.new(channel.account_sid, channel.auth_token)
  end
end
