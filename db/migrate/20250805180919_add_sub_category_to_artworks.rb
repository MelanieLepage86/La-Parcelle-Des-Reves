class AddSubCategoryToArtworks < ActiveRecord::Migration[7.1]
  def change
    add_column :artworks, :sub_category, :string
  end
end
