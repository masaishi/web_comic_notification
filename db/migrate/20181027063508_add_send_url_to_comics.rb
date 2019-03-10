class AddSendUrlToComics < ActiveRecord::Migration[5.2]
  def change
    add_column :comics, :send_url, :string
  end
end
