class CreateBookmarks < ActiveRecord::Migration[5.2]
  def change
    create_table :bookmarks do |t|
      t.integer :user_id
      t.integer :comic_id

      t.timestamps null:false
    end
  add_index :bookmarks, :user_id
  add_index :bookmarks, :comic_id
  add_index :bookmarks, [:user_id, :comic_id], unique: true
  end
end
