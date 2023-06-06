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
  

  private

  def set_setting
    @setting = Setting.first_or_initialize
  end  

  def setting_params
    params.require(:setting).permit(:price_drop_time, :price_drop_amount)
  end
end
