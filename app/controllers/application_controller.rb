class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :super_user, :predictor_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name, :super_user, :predictor_id])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || authenticated_root_path
  end
end
