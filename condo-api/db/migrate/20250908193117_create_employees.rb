class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :condominium, null: false, foreign_key: true
      t.string :role, null: false, default: "collaborator"
      t.string :description

      t.timestamps
    end

    add_index :employees, [:user_id, :condominium_id], unique: true
  end
end
