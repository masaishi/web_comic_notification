class CreateComics < ActiveRecord::Migration[5.2]
  def change
    create_table :comics do |t|
      t.belongs_to :site, index: true
      t.string :name
      t.string :url
      t.string :last_story

      t.timestamps
    end
  end
end
