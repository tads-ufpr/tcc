class CreateApartments < ActiveRecord::Migration[8.0]
  def change
    create_table :apartments do |t|
      t.references :condominium, null: false, foreign_key: true

      t.integer :floor, null: false
      t.string :number, null: false
      t.string :tower

      t.timestamps
    end
  end
end
