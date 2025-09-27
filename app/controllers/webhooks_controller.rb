class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError => e
      Rails.logger.error("Webhook JSON parsing error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Webhook signature verification error: #{e.message}")
      return head :bad_request
    end

    case event['type']
    when 'payment_intent.succeeded'
      handle_successful_payment(event['data']['object'])
    when 'transfer.paid'
      handle_transfer_paid(event['data']['object'])
    else
      Rails.logger.info("Webhook reçu pour l'événement : #{event['type']}, non traité")
    end

    render json: { status: 'received' }, status: :ok
  end

  private

  def handle_successful_payment(payment_intent)
    order = Order.find_by(stripe_payment_intent_id: payment_intent['id'])
    return unless order
    return if order.status == 'paid'

    Rails.logger.info("Paiement reçu pour la commande ##{order.id} – début du dispatch...")

    order.order_items.includes(:artwork).each do |item|
      artist = item.artwork.user
      next if artist.stripe_account_id.blank?

      amount = (item.unit_price * 100).to_i

      begin
        Stripe::Transfer.create(
          amount: amount,
          currency: 'eur',
          destination: artist.stripe_account_id,
          metadata: {
            order_id: order.id,
            artist_id: artist.id,
            artwork_id: item.artwork.id
          }
        )
        Rails.logger.info("Transfert de #{amount} centimes à l'artiste ##{artist.id}")
      rescue => e
        Rails.logger.error("Échec du transfert à l’artiste ##{artist.id} : #{e.message}")
      end
    end

    highest_item = order.order_items.includes(:artwork).max_by do |item|
      item.artwork.delivery_category.to_i
    end

    if highest_item
      artist = highest_item.artwork.user
      if artist&.stripe_account_id.present?
        begin
          shipping_amount = (order.shipping_cost.to_f * 100).to_i

          Stripe::Transfer.create(
            amount: shipping_amount,
            currency: 'eur',
            destination: artist.stripe_account_id,
            metadata: {
              order_id: order.id,
              artist_id: artist.id,
              shipping: true
            }
          )
          Rails.logger.info("Transfert de #{shipping_amount} centimes pour frais de port à l'artiste ##{artist.id}")
        rescue => e
          Rails.logger.error("Échec du transfert des frais de port à l’artiste ##{artist.id} : #{e.message}")
        end
      end
    end

    order.update(status: 'paid')
  end

  def handle_transfer_paid(transfer)
    Rails.logger.info("Transfert payé : #{transfer['id']}")
  end
end
