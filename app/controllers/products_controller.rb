#require_relative '../lib/scraper'

class ProductsController < ApplicationController
  before_action :authenticate_user!, only: :scrape

  def index
    scraper = Scraper.new
    scraper.scrape_product_page('メルカリの商品URL', 'メルカリのログインに使用するメールアドレス', 'メルカリのログインパスワード')

    # スクレイピングの結果を取得して、必要な処理を行う
    # 例えば、スクレイピングで取得した商品名や価格をデータベースに保存したり、ビューに表示するためにインスタンス変数に格納したりする

    @products = Product.all
  end

  def scrape
    # スクレイピングの処理を実装する
    # ログインユーザーの認証を行い、必要な情報を取得・処理する
    product_url = params[:product_url]
    
    # メルカリのログイン情報を入力
    email = params[:username]
    password = params[:password]
    
    # Settingからprice_dropを取得
    settings = Setting.first
    price_drop = settings.price_drop_amount
  
    scraper = Scraper.new
    scraped_data = scraper.scrape_product_page(product_url, email, password, price_drop)
  
    render json: scraped_data
  end
  
  

  def scrape_page
    render 'scrape'
  end
end
