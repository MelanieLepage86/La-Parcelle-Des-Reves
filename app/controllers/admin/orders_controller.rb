class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_artist!

  def index
    @orders = Order.includes(order_items: :artwork).order(created_at: :desc)
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(status: params[:order][:status])
      redirect_to admin_dashboard_path, notice: "Statut mis à jour"
    else
      redirect_to admin_dashboard_path, alert: "Erreur lors de la mise à jour du statut"
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to admin_dashboard_path, notice: "Commande supprimée avec succès."
  end

  def invoice_catherine
    @order = Order.find(params[:id])
    @items = @order.order_items.select { |oi| oi.artwork.user.email == "cath.barbedienne@gmail.com" }
    render_invoice_pdf("Catherine")
  end

  def invoice_amelie
    @order = Order.find(params[:id])
    @items = @order.order_items.select { |oi| oi.artwork.user.email == "barbedienne.amelie@gmail.com" }
    render_invoice_pdf("Amelie")
  end

  private

  def render_invoice_pdf(artist_name)
    @artist_name = artist_name
    @total_artworks = @items.sum(&:unit_price)
    @shipping_cost = calculate_shipping_for_artist(@order, artist_name)
    @total = @total_artworks + @shipping_cost

    respond_to do |format|
      format.html do
        render "admin/orders/invoice_#{artist_name.downcase}"
      end
      format.pdf do
        render pdf: "facture_#{artist_name.downcase}_#{@order.id}",
               template: "admin/orders/invoice_#{artist_name.downcase}",
               formats: [:html],
               layout: false
      end
    end
  end

  def calculate_shipping_for_artist(order, artist_name)
    artist_email =
      artist_name == "Catherine" ? "cath.barbedienne@gmail.com" : "barbedienne.amelie@gmail.com"

    items = order.order_items.select { |oi| oi.artwork.user.email == artist_email }
    return 0 if items.empty?

    if order.order_items.map { |oi| oi.artwork.user.email }.uniq.size > 1
      highest_item = order.order_items.max_by(&:unit_price)
      return order.shipping_cost if highest_item.artwork.user.email == artist_email
      return 0
    else
      return order.shipping_cost
    end
  end

  def ensure_artist!
    redirect_to root_path, alert: "Accès réservé aux artistes" unless current_user&.admin?
  end
end
