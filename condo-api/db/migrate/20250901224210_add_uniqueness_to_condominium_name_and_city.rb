class AddUniquenessToCondominiumNameAndCity < ActiveRecord::Migration[8.0]
  def change
    add_index :condominia, [:name, :city], unique: true
  end
end
