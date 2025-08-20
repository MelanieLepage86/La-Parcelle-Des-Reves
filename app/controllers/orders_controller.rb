class OrdersController < ApplicationController
  def new
    @artwork = Artwork.find(params[:artwork_id])
    @order = Order.new
  end

  def create
    @artwork = Artwork.find(params[:artwork_id])
    email = params[:order][:email]
    artist = @artwork.user

    @order = Order.create!(
      user: artist,
      email: email,
      total_amount: @artwork.price,
      status: 'pending'
    )

    @order.order_items.create!(
      artwork: @artwork,
      quantity: 1,
      unit_price: @artwork.price
    )

    payment_intent = Stripe::PaymentIntent.create(
      amount: (@artwork.price * 100).to_i,
      currency: 'eur',
      payment_method_types: ['card'],
      transfer_data: {
        destination: @artwork.user.stripe_account_id
      }
    )

    @order.update!(stripe_payment_intent_id: payment_intent.id)

    redirect_to order_path(@order)
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Une erreur est survenue : #{e.message}"
    redirect_to artwork_path(@artwork)
  end

  def show
    @order = Order.find(params[:id])
  end

  def payment_intent
    order = Order.find(params[:id])
    intent = Stripe::PaymentIntent.retrieve(order.stripe_payment_intent_id)
    render json: { client_secret: intent.client_secret }
  end
end
