class WeightsController < ApplicationController
  before_action :set_user_stat, except: %i(index new create)

  def index
    set_chart
  end

  def new
    @user_stat = UserStat.new(user: current_user,
                              date: today,
                              weight: current_user.current_weight)
    @permitted = true
    respond_to do |format|
      format.js { render :edit }
    end
  end

  def create
    @user_stat = UserStat.new(user_stat_params)
    if @user_stat.save
      flash[:notice] = 'Entry successfully created.'
    else
      flash[:error] = 'Failed to add entry'
    end
    set_chart
    respond_to do |format|
      format.js { render 'charts/refresh' }
    end
  end

  def edit
    @permitted = @user_stat.user == current_user
    respond_to do |format|
      format.js
    end
  end

  def update
    respond_to do |format|
      if @user_stat.update(user_stat_params)
        set_chart
        flash[:notice] = 'Entry successfully updated.'
        format.js { render 'charts/refresh' }
      else
        @permitted = true
        format.js { render :edit }
      end
    end
  end

  def destroy
    respond_to do |format|
      @user_stat.destroy
      flash[:notice] = 'Entry successfully deleted.'
      set_chart
      format.js { render 'charts/refresh' }
    end
  end

  private

  def set_user_stat
    @user_stat = UserStat.find(params[:id])
  end

  def set_chart
    @multi_user = true # !params[:user_id]
    if @multi_user
      @chart = WeightChart.new(*User.relevant)
    else
      @user = User.find(params[:user_id])
      @chart = WeightChart.new(@user)
    end
  end

  def user_stat_params
    params.require(:user_stat)
          .permit(:date, :weight, :user_id)
  end
end
