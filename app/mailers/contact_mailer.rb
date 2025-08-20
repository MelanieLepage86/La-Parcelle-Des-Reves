class ContactMailer < ApplicationMailer
  default to: 'laparcelledesreves.art@gmail.com'

  def new_message
    @contact_message = params[:contact_message]
    mail(
      from: @contact_message.email,
      subject: "Nouveau message de #{@contact_message.firstname} #{@contact_message.name}"
    )
  end
end
