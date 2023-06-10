class AutoPricedownJob < ApplicationJob
  queue_as :default

  def perform
    # 値下げ処理の実装
    setting = Setting.first
    products = Product.all

    products.each do |product|
      if product.markdown_time <= Time.current
        new_price = product.cost_price - setting.price_drop_amount
        product.update(markdown_price: new_price)
      end
    end
  end
end
