class CreateGosts < ActiveRecord::Migration
  def change
    create_table :gosts do |t|
      t.string :message
      t.integer :size
      t.string :file
      t.string :hexdigest
      t.string :signature
      t.string :check

      t.timestamps null: false
    end
  end
end
