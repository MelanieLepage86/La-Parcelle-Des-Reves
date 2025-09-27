class ChangeShippingCategoryToStringInArtworks < ActiveRecord::Migration[7.1]
  def change
    change_column :artworks, :shipping_category, :string
  end
end
