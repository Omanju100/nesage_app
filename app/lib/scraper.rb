class Scraper
  def initialize
    options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument('--headless') # ヘッドレスモードでブラウザを起動するオプション

    @driver = Selenium::WebDriver.for(
      :remote,
      options: options,
      url: "http://selenium_chrome:4444/wd/hub" # selenium_chromeコンテナにつなげてあげる
      # desired_capabilities: :chrome # これは不要です！！
    )
  end

  def scrape_product_page(product_url, email, password)
     # メルカリのログインページに移動
     @driver.get('https://jp.mercari.com/')
     sleep(1)
 
     # ログインリンクをクリック
     @driver.find_element(:xpath, '//*[@id="__next"]/div/header/div[1]/div/div[4]/nav/div/div[1]/div[2]/div/button').click
     sleep(1)
 
     # 「メール・電話番号でログイン」リンクをクリック
     @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div/mer-button[1]/a').click
     sleep(1)
 
     # メールアドレスを入力するフィールドを見つけて、値を送信
     email_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/mer-text-input[1]/div/label/div[2]/input')
     email_field.send_keys('08035423344')
 
     # パスワードを入力するフィールドを見つけて、値を送信
     password_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/mer-text-input[2]/div/label/div[2]/input')
     password_field.send_keys(19890212)
 
     # ログインボタンをクリック
     @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/mer-button/button').click
     sleep(25)    

     @driver.get('https://jp.mercari.com/mypage/listings')
     sleep(1)
     
     @max_products_count = 200  # 一度に処理する最大の商品数
     processed_products_count = 0
     last_processed_product_index = 0
     products_loaded = 0
     
     while processed_products_count < @max_products_count
       products = @driver.find_elements(:xpath, '//*[@id="currentListing"]/div[1]/div')
       products_count = products.size
     
       (last_processed_product_index..products_count).each do |n|
         break if processed_products_count >= @max_products_count
     
         # 商品を選ぶ
         begin
           element = @driver.find_element(:xpath, "//*[@id='currentListing']/div[1]/div[#{n+1}]")
         rescue Selenium::WebDriver::Error::NoSuchElementError
           break
         end
     
         @driver.execute_script("arguments[0].scrollIntoView(true);", element)
         @driver.execute_script("arguments[0].click();", element)
         sleep(2)
     
         # 商品の編集を押す
         @driver.find_element(:xpath, '//*[@id="item-info"]/section[1]/div[2]/div').click
         sleep(2)
     

         
         # 商品価格を取得するフィールドを見つける
         price_field = @driver.find_element(:xpath, '//*[@id="main"]/form/section[5]/div[2]/div[1]/div/label/div/input')
        
         # 現在の価格を取得
         current_price = price_field.attribute('value').to_i
 
         # 新しい価格を計算 (現在の価格から100を引く)
         new_price = current_price - 100
 
         # フィールドをクリアしてから新しい価格を送信
         price_field.click()
         @driver.action.key_down(:control).send_keys('a').key_up(:control).send_keys(:delete).perform
         price_field.send_keys(new_price.to_s)


         # 変更ボタンを押す
         @driver.find_element(:xpath, '//*[@id="main"]/form/div[2]/div[1]').click
         sleep(2)
     
         processed_products_count += 1
         last_processed_product_index = n - products_loaded
     
         # 商品一覧ページに戻る
         @driver.get('https://jp.mercari.com/mypage/listings')
         sleep(1)
       end
     
       # もっと見るボタンを押す
       begin
         more_button = @driver.find_element(:xpath, '//*[@id="currentListing"]/div[2]/div/button')
         more_button.click
         sleep(3)
         products_loaded += 50  # assume 'more' button loads 50 more products
       rescue Selenium::WebDriver::Error::NoSuchElementError
         break # "もっと見る"ボタンが見つからなければループを抜ける
       end
     end
     
     
     

  end
end
