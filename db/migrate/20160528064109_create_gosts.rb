class CreateGosts < ActiveRecord::Migration
  def change
    create_table :gosts do |t|
      t.string :str
      t.string :hash_value

      t.timestamps null: false
    end
  end
end
