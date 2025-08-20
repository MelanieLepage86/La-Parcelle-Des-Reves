class NewsletterMailer < ApplicationMailer
  def send_newsletter(subscriber, newsletter)
    @newsletter = newsletter
    @subscriber = subscriber
    mail(to: @subscriber.email, subject: newsletter.subject)
  end
end
