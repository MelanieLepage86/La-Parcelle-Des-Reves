class AddDeliveryMethodToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :delivery_method, :string
  end
end
