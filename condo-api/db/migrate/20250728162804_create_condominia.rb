class CreateCondominia < ActiveRecord::Migration[8.0]
  def change
    create_table :condominia do |t|
      t.string :name
      t.string :zip_code
      t.string :address
      t.string :district
      t.string :city
      t.string :state
      t.string :number

      t.timestamps
    end
  end
end
