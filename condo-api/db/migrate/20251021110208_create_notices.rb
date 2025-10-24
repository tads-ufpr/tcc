class CreateNotices < ActiveRecord::Migration[8.0]
  def change
    create_table :notices do |t|
      t.references :apartment, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.integer :notice_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.text :description
      t.text :title
      t.text :type_info

      t.timestamps
    end
  end
end
