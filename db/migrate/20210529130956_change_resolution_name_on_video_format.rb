class ChangeResolutionNameOnVideoFormat < ActiveRecord::Migration[6.0]
  def change
    rename_column :video_formats, :filename, :file
  end
end
