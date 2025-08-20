class AddAvatarFilenameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :avatar_filename, :string
  end
end
