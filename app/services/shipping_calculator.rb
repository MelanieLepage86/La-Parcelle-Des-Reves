class ShippingCalculator
  def initialize(order)
    @order = order
  end

  def calculate
    return 0.0 if @order.remise_en_main_propre?

    zone = ShippingZoneResolver.zone_for(@order.country)
    Rails.logger.debug("🔍 Zone pour le pays #{@order.country} ➜ #{zone}")

    categorized_items = group_items_by_category
    categorized_items = categorized_items.transform_keys(&:to_s)
    Rails.logger.debug("📦 Catégories groupées : #{categorized_items.inspect}")

    if categorized_items["categorie_4"].to_a.size >= 2
      Rails.logger.debug("⚠️ Cas spécial : au moins 2 œuvres en catégorie 4")
      val = calculate_full_price_for_all_cat4(zone, categorized_items["categorie_4"])
      Rails.logger.debug("→ Frais de port (cas spécial) : #{val}")
      return val
    end

    categorized_items.keys.each do |cat|
      Rails.logger.debug("→ category_order(#{cat.inspect}) = #{category_order(cat.to_s)}")
    end

    highest_cat = categorized_items.keys.max_by do |category|
      order = category_order(category.to_s)
      Rails.logger.debug("→ category_order(#{category}) = #{order}")
      order
    end

    total = 0.0

    if highest_cat
      fp = full_price_for(zone, highest_cat)
      Rails.logger.debug("→ Full price pour #{highest_cat} en zone #{zone} : #{fp}")
      total += fp
    else
      Rails.logger.debug("⚠️ Aucun highest_cat trouvé, total reste 0.0 initial")
    end

    categorized_items.each do |category, items|
      next if category == highest_cat

      rp = reduced_price_for(zone, category)
      Rails.logger.debug("→ Reduced price pour #{category} en zone #{zone} : #{rp} × #{items.size}")
      total += rp * items.size
    end

    val = total.round(2)
    Rails.logger.debug("💰 Résultat frais de port calculés : #{val}")
    val
  end

  private

  def group_items_by_category
    categorized = Hash.new { |h, k| h[k] = [] }

    @order.order_items.includes(:artwork).each do |item|
      category = item.artwork.shipping_category&.to_s
      categorized[category] << item if category.present?
    end

    categorized
  end

  def category_order(category)
    {
      "categorie_1" => 1,
      "categorie_2" => 2,
      "categorie_3" => 3,
      "categorie_4" => 4
    }[category.to_s] || 0
  end

  def category_number(category)
    {
      "categorie_1" => 1,
      "categorie_2" => 2,
      "categorie_3" => 3,
      "categorie_4" => 4
    }.fetch(category.to_s) do
      raise ArgumentError, "Catégorie inconnue : #{category.inspect}"
    end
  end

  def full_price_for(zone, category)
    ShippingRate.find_by!(zone: zone, category: category_number(category)).full_price
  end

  def reduced_price_for(zone, category)
    ShippingRate.find_by!(zone: zone, category: category_number(category)).reduced_price
  end

  def calculate_full_price_for_all_cat4(zone, items)
    rate = ShippingRate.find_by!(zone: zone, category: 4)
    (rate.full_price * items.size).round(2)
  end
end
