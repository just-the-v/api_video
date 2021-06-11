class CreateVideoFormats < ActiveRecord::Migration[6.0]
  def change
    create_table :video_formats do |t|
      t.references :video, null: false, foreign_key: true
      t.string :source
      t.string :resolution, default: '400x400'
      t.string :filename, default: 'video'

      t.timestamps
    end
  end
end
