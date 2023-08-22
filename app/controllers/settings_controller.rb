class SettingsController < ApplicationController
  # すべてのアクションでユーザーがログインしているかを確認。
  before_action :authenticate_user!

  # 指定されたアクションの前に設定をセットアップする。
  before_action :set_setting, only: [:index, :update, :show]

  # 各ユーザーに紐づく設定を表示する。
  def index
    if current_user
      @setting = current_user.setting || current_user.build_setting
    else
      # ログアウト状態の場合はログインページにリダイレクトする。
      redirect_to new_user_session_path, alert: "ログインしてください。"
    end
  end
  
  


  # 現在のユーザーに関連する設定を更新する
  def update
    # 設定が既に存在するかどうかを確認
    if @setting.persisted? 
      if @setting.update(setting_params)
        redirect_to settings_path, notice: '設定が更新されました。'
      else
        render :show
      end
    else
      # 設定が存在しない場合、新しい設定を保存する
      @setting.assign_attributes(setting_params)
      if @setting.save
        redirect_to settings_path, notice: '設定が保存されました。'
      else
        render :show
      end
    end
  end

  # 現在のユーザーに関連する設定を表示する
  def show
    # @setting は before_action :set_setting でセットアップされる
  end

  # 指定された設定を削除する
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy
    redirect_to settings_path, notice: '設定が削除されました。'
  end

  # 価格の設定を取得する
  def price_drop_amount
    setting = Setting.first
    setting.price_drop_amount
  end 

  private

  # 現在のユーザーに関連する設定をセットアップする
  def set_setting
    if user_signed_in?
      @setting = current_user.setting || current_user.build_setting
    else
      @setting = Setting.first_or_initialize
    end
  end

  # 許可された設定のパラメータを取得する
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
