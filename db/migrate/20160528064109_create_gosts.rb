class CreateGosts < ActiveRecord::Migration
  def change
    create_table :gosts do |t|
      t.string :message
      t.integer :size

      t.timestamps null: false
    end
  end
end
