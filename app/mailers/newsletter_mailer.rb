class NewsletterMailer < ApplicationMailer
  default from: 'newsletter@laparcelledesreves.com'

  def send_newsletter(subscriber, newsletter)
    @newsletter = newsletter
    @subscriber = subscriber
    mail(
      to: @subscriber.email,
      reply_to: 'newsletter@laparcelledesreves.com',
      subject: newsletter.subject
    )
  end
end
