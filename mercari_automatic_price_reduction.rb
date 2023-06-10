require 'mechanize'

# メルカリのログイン情報
USERNAME = 'メルカリのユーザー名'
PASSWORD = 'メルカリのパスワード'

# 商品の値下げ情報
PRICE_REDUCTION_AMOUNT = 100  # 値下げする金額
PRICE_REDUCTION_INTERVAL = 5  # 値下げする間隔（秒）

# Mechanizeを初期化し、メルカリにログインする
agent = Mechanize.new
page = agent.get('https://www.mercari.com/jp/login/')
form = page.forms.first
form.field_with(name: 'email').value = USERNAME
form.field_with(name: 'password').value = PASSWORD
form.submit

# マイページの商品一覧ページにアクセス
mypage_page = agent.get('https://jp.mercari.com/mypage/listings')

# 商品一覧ページから商品の詳細ページにアクセスし、値下げを行う
mypage_page.search('.mypage-item-link').each do |link|
  item_page = link.click

  # 商品の現在の価格を取得
  price_element = item_page.at('.item-price')
  price = price_element.text.gsub(/[^\d]/, '').to_i

  # 値下げ後の価格を計算
  reduced_price = price - PRICE_REDUCTION_AMOUNT

  if reduced_price > 0
    # 値下げ後の価格を反映
    price_element.text = "¥#{reduced_price}"
    item_page.forms.first.submit
    sleep PRICE_REDUCTION_INTERVAL
  end
end
