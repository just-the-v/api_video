class AddDurationToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :videos, :duration, :integer, default: 0
  end
end
