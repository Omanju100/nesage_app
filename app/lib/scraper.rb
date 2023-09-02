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
    @wait.until { @driver.find_element(:xpath, '//*[@id="__next"]/div/header/div/div/div[4]/nav/div/div[1]/div[1]/div/button').displayed? }
    @driver.find_element(:xpath, '//*[@id="__next"]/div/header/div/div/div[4]/nav/div/div[1]/div[1]/div/button').click
    
    # 「メール・電話番号でログイン」リンクをクリック
    #@wait.until { @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/div[1]/a').displayed? }
    #@driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/div[1]/a').click
    
    # メールアドレスを入力するフィールドを見つけて、値を送信
    @wait.until { @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/form/div[1]/div/label/div/input').displayed? }
    email_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/form/div[1]/div/label/div/input')
    email_field.send_keys(email)
    
    # パスワードを入力するフィールドを見つけて、値を送信
    password_field = @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/form/div[2]/div/label/div/input')
    password_field.send_keys(password)
    
    # ログインボタンをクリック
    @driver.find_element(:xpath, '//*[@id="root"]/div/div/div/main/div/div/div[2]/form/div[3]/button').click
    @wait.until { @driver.current_url.include?('https://jp.mercari.com/') }
    
    # ユーザーの商品一覧ページにアクセス
    @driver.get('https://jp.mercari.com/mypage/listings')
    sleep(1)  # ページが完全に読み込まれるのを待つ

    # 設定値: 一度に処理する最大の商品数
    @max_products_count = 200  
    processed_products_count = 0     # 処理が完了した商品数のカウンタ
    last_processed_product_index = 0 # 前回のループで最後に処理した商品のインデックス
    products_loaded = 0              # 「もっと見る」ボタンをクリックして追加で読み込まれた商品数

    # メインループ: 設定した最大数に達するか、商品一覧の終わりに達するまで続ける
    while processed_products_count < @max_products_count
      # 商品一覧ページから商品の要素を取得
      products = @driver.find_elements(:xpath, '//*[@id="currentListing"]/div[1]/div')
      products_count = products.size

      # 商品一覧をループ: 設定した最大数に達したらループを終了
      (last_processed_product_index..products_count).each do |n|
        break if processed_products_count >= @max_products_count

        # 選択する商品の要素を取得
        begin
          element = @wait.until { @driver.find_element(:xpath, "//*[@id='currentListing']/div[1]/div[#{n+1}]") }
        rescue Selenium::WebDriver::Error::NoSuchElementError
          # 次の商品が見つからない場合、「もっと見る」ボタンをクリックして商品を追加ロード
          begin
            more_button = @wait.until { @driver.find_element(:xpath, '//*[@id="currentListing"]/div[2]/div/button') }
            more_button.click
            sleep(5)
            products_loaded += 50  # 「もっと見る」ボタンは通常50件の商品を追加でロードすると仮定
          rescue Selenium::WebDriver::Error::NoSuchElementError
            break # "もっと見る"ボタンがなければ、ループを終了
          end
          retry
        end

        # スクロールして選択した商品をクリック
        @driver.execute_script("arguments[0].scrollIntoView(true);", element)
        @driver.execute_script("arguments[0].click();", element)
        sleep(2)

        # 「商品の編集」ボタンをクリック
        @wait.until { @driver.find_element(:xpath, '//*[@id="item-info"]/section[1]/div[2]/div') }.click
        sleep(2)

        # 商品価格の入力フィールドを取得
        price_field = @wait.until { @driver.find_element(:xpath, '//*[@id="main"]/form/section[5]/div[2]/div[1]/div/label/div/input') }

        # 現在の価格を取得
        current_price = price_field.attribute('value').to_i

        # 新しい価格を計算 (ユーザーが指定した金額を現在の価格から引く)
        new_price = current_price - price_drop

        # フィールドの内容をクリアし、新しい価格を入力
        price_field.click()
        @driver.action.key_down(:control).send_keys('a').key_up(:control).send_keys(:delete).perform
        price_field.send_keys(new_price.to_s)

        # 「変更」ボタンをクリックして価格を更新
        @wait.until { @driver.find_element(:xpath, '//*[@id="main"]/form/div[2]/div[1]') }.click
        sleep(2)

        # 処理した商品数をカウントアップ
        processed_products_count += 1
        last_processed_product_index = n - products_loaded

        # 商品一覧ページに戻る
        @driver.get('https://jp.mercari.com/mypage/listings')
        sleep(2)
      end
    end
        
 end
end
