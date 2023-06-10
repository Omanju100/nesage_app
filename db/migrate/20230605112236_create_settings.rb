class CreateSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :settings do |t|
      t.time :price_drop_time
      t.decimal :price_drop_amount

      t.timestamps
    end
  end
end
