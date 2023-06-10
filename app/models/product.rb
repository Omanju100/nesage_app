class Product < ApplicationRecord
    def perform_auto_pricedown
      if Time.now >= markdown_time
        update(markdown_price: markdown_price)
      end
    end
  end
  