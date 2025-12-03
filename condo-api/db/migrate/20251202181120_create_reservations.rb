class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.belongs_to :facility, null: false, foreign_key: true
      t.belongs_to :apartment, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.date :scheduled_date

      t.timestamps
      t.index [:facility_id, :scheduled_date], unique: true
    end
  end
end
