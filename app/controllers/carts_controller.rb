class CartsController < ApplicationController
  def add
    session[:cart] ||= []
    session[:cart] << params[:artwork_id].to_i unless session[:cart].include?(params[:artwork_id].to_i)
    redirect_to cart_path, notice: "Ajouté au panier"
  end

  def show
    @artworks = Artwork.find(session[:cart])
    @cart_count = session[:cart].size
  end

  def checkout
    if session[:cart].blank?
      redirect_to cart_path, alert: "Votre panier est vide."
      return
    end

    email = params[:email]
    artworks = Artwork.find(session[:cart])

    total = artworks.sum(&:price)
    order = Order.create!(email: email, total_amount: total)

    artworks.each do |art|
      order.order_items.create!(artwork: art, quantity: 1, unit_price: art.price)
    end

    payment_intent = Stripe::PaymentIntent.create(
      amount: (total * 100).to_i,
      currency: 'eur',
      automatic_payment_methods: { enabled: true }
    )

    order.update!(stripe_payment_intent_id: payment_intent.id)
    session[:cart] = []

    redirect_to order_path(order)
  end

  def remove
    session[:cart] ||= []
    artwork_id = params[:artwork_id].to_i
    session[:cart].delete(artwork_id)
    redirect_to cart_path, notice: "Article retiré du panier"
  end
end
