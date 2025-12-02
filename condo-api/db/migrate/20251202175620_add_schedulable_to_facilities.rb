class AddSchedulableToFacilities < ActiveRecord::Migration[8.0]
  def change
    add_column :facilities, :schedulable, :boolean, default: false, null: false
  end
end
