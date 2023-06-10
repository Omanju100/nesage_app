class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :cost_price
      t.decimal :break_even_point
      t.decimal :markdown_price
      t.datetime :markdown_time

      t.timestamps
    end
  end
end
