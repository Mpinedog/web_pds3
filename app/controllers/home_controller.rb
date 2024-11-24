class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @lockers = Locker.all
    @managers = Manager.all
    @predictors = Predictor.all
    @user = current_user
  end
end
