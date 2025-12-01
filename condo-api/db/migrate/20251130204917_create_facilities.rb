class CreateFacilities < ActiveRecord::Migration[8.0]
  def change
    create_table :facilities do |t|
      t.string :name
      t.string :description
      t.integer :tax
      t.belongs_to :condominium, null: false, foreign_key: true

      t.timestamps
    end
  end
end
