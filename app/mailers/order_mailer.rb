class OrderMailer < ApplicationMailer
  default from: 'no-reply@laparcelledesreves.com'

  def confirmation_email(order)
    @order = order
    mail(
      to: @order.email,
      reply_to: @order.email,
      subject: "Confirmation de votre commande ##{@order.id}"
    )
  end
end
