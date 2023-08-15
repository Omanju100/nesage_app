class SettingsController < ApplicationController
  before_action :set_setting, only: [:index, :update]

  def index
    @settings = Setting.all
    @setting = Setting.first_or_initialize
  end

  def update
    if @setting.update(setting_params)
      redirect_to settings_path, notice: '設定が保存されました。'
    else
      render :index
    end
  end

  def show
    @setting = Setting.find(params[:id])
  end

  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy
    redirect_to settings_path, notice: '設定が削除されました。'
  end

  #価格の設定
  def price_drop_amount
    setting = Setting.first
    setting.price_drop_amount
  end  

  private

  def set_setting
    @setting = Setting.first_or_initialize
  end

  def setting_params
    params.require(:setting).permit(:price_drop_time, :price_drop_amount)
  end

  def login
    agent = Mechanize.new
  
    # メルカリのログインページにアクセス
    login_page = agent.get('https://www.mercari.com/jp/login/')
  
    # ログインフォームを取得
    login_form = login_page.form_with(action: '/jp/login/')
    return unless login_form
  
    # ユーザー名とパスワードを設定
    login_form.field_with(name: 'email').value = 'your_username'
    login_form.field_with(name: 'password').value = 'your_password'
  
    # ログインボタンをクリックしてログイン処理を実行
    logged_in_page = login_form.submit
  
    # ログイン成功の判定
    if logged_in_page.uri.to_s == 'https://www.mercari.com/jp/login/'
      # ログインに失敗した場合の処理
      redirect_to settings_path, alert: 'ログインに失敗しました。'
    else
      # ログインに成功した場合の処理
      redirect_to settings_path, notice: 'ログインに成功しました。'
    end
  end
end
