# Railsなのでこれは不要！！
# require 'selenium-webdriver'
# require 'selenium-webdriver'

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
    @driver.get('https://www.mercari.com/jp/login/')

    # ログインフォームに入力情報を送信
    email_input = @driver.find_element(name: 'email')
    email_input.send_keys(email)
    password_input = @driver.find_element(name: 'password')
    password_input.send_keys(password)
    submit_button = @driver.find_element(css: '.login-submit')
    submit_button.click()

    # ログイン後の処理を実装する
    # 例えば、商品ページに移動してスクレイピングを行うなど
    @driver.get(product_url)

    # スクレイピング処理をここに記述する
    product_name = @driver.find_element(:css, 'h1').text
    price = @driver.find_element(:css, '.price').text

    puts "商品名: #{product_name}"
    puts "価格: #{price}"

    # スクレイピングの結果を返す（必要に応じて変更してください）
    scraped_data = { product_name: product_name, price: price }

    @driver.quit
    return scraped_data
  end
end