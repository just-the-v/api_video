class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :views, default: 0
      t.boolean :enabled, default: 0
      t.string :source, default: true
      t.string :name

      t.timestamps
    end
  end
end
