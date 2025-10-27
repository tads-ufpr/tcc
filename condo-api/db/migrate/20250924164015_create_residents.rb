class CreateResidents < ActiveRecord::Migration[8.0]
  def change
    create_table :residents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :apartment, null: false, foreign_key: true

      t.boolean :owner, null: false, default: false

      t.timestamps
    end
  end
end
