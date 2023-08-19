class Scraper
  def initialize
    options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument('--headless') # ヘッドレスモードでブラウザを起動するオプション
    options.add_argument('--disable-gpu') # ハードウェアアクセラレーションを無効にする
    options.add_argument('--disable-webgl') # WebGLを無効にする

    @driver = Selenium::WebDriver.for(
      :remote,
      options: options,
      url: "http://selenium_chrome:4444/wd/hub" # selenium_chromeコンテナにつなげてあげる
    )

    # Settingからprice_drop_amountを取得
    setting = Setting.first
    @price_drop_amount = setting.price_drop_amount
    # Initialize @wait
    @wait = Selenium::WebDriver::Wait.new(timeout: 120)  # 10秒待つ場合
  end

  def scrape_product_page(product_url, email, password, price_drop)
    # メルカリのログインページに移動
    @driver.get('https://jp.mercari.com/')
  
    # ログインリンクをクリック
    @wait.until { @driver.find_element(:xpath, '//*[@id="__next"]/div/header/div[1]/div/div[4]/nav/div/div[1]/div[2]/div/button').displayed? }
    @driver.find_element(:xpath, '//*[@id="__next"]/div/header/div[1]/div/div[4]/nav/div/div[1]/div[2]/div/button').click
    
    # 「メール・電話番号でログイン」リンクをクリック
    @wait.until { @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/div[1]/a').displayed? }
    @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/div[1]/a').click
    
    # メールアドレスを入力するフィールドを見つけて、値を送信
    @wait.until { @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/div[1]/div/label/div/input').displayed? }
    email_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/div[1]/div/label/div/input')
    email_field.send_keys('08035423344')
    
    # パスワードを入力するフィールドを見つけて、値を送信
    password_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/div[2]/div/label/div/input')
    password_field.send_keys(19890212)
    
    # ログインボタンをクリック
    @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/form/div[3]/button').click
    @wait.until { @driver.current_url.include?('https://jp.mercari.com/') }
    
    # 商品ページに移動
    @driver.get('https://jp.mercari.com/mypage/listings')
    
    @max_products_count = 50  # 一度に処理する最大の商品数
    processed_products_count = 0
  
    while processed_products_count < @max_products_count
      # 商品の一覧を取得
      products = @wait.until { @driver.find_elements(:xpath, '//*[@id="currentListing"]/div[1]/div') }
      
      # 商品の数を取得
      products_count = products.size
      
      # 処理する商品の数が指定の最大数を超えた場合の対応
      products_count = @max_products_count - processed_products_count if (processed_products_count + products_count) > @max_products_count 
      
      1.upto(products_count) do |n|
        # 商品を選ぶ
        element = @wait.until { @driver.find_element(:xpath, "//*[@id='currentListing']/div[1]/div[#{n}]") }
        @driver.execute_script("arguments[0].scrollIntoView(true);", element)
        @driver.execute_script("arguments[0].click();", element)
        
        # 商品の編集を押す
        @wait.until { @driver.find_element(:xpath, '//*[@id="item-info"]/section[1]/div[2]/div').displayed? }
        @driver.find_element(:xpath, '//*[@id="item-info"]/section[1]/div[2]/div').click
        
        # 商品価格を取得するフィールドを見つける
        price_field = @wait.until { @driver.find_element(:xpath, '//*[@id="main"]/form/section[5]/div[2]/div[1]/div/label/div/input') }
        
        # 現在の価格を取得
        current_price = price_field.attribute('value').to_i
  
        # 新しい価格を計算 (現在の価格からユーザが選択した金額を引く)
        new_price = current_price - price_drop
        
        # フィールドをクリアしてから新しい価格を送信
        price_field.click()
        @driver.action.key_down(:control).send_keys('a').key_up(:control).send_keys(:delete).perform
        price_field.send_keys(new_price.to_s)
        
        # 変更ボタンを押す
        @driver.find_element(:xpath, '//*[@id="main"]/form/div[2]/div[1]').click
        @wait.until { @driver.current_url.include?('mypage/listings') } # Assuming you are redirected back to listings after change
  
        processed_products_count += 1
        
        # 商品一覧ページに戻る
        @driver.get('https://jp.mercari.com/mypage/listings')
      end
  
      # もっと見るボタンを押す
      begin
        more_button = @wait.until { @driver.find_element(:xpath, '//*[@id="currentListing"]/div[2]/div/button') }
        more_button.click
        @wait.until { @driver.find_elements(:xpath, '//*[@id="currentListing"]/div[1]/div').length > products_count } # Assumes new products get loaded
      rescue Selenium::WebDriver::Error::NoSuchElementError
        break # "もっと見る"ボタンが見つからなければループを抜ける
      end
    end  
  end
end  