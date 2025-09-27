class AddSoldToArtworks < ActiveRecord::Migration[7.1]
  def change
    add_column :artworks, :sold, :boolean
  end
end
