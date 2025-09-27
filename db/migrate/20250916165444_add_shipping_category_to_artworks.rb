class AddShippingCategoryToArtworks < ActiveRecord::Migration[7.1]
  def change
    add_column :artworks, :shipping_category, :integer
  end
end
