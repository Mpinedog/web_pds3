class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :super_user, :modelo_id])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name, :super_user, :modelo_id])
  end

  def after_sign_out_path_for(resource_or_scope)
    new_usuario_session_path # Redirige a la página de inicio de sesión
  end
end
