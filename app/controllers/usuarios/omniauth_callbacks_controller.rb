# frozen_string_literal: true

class Usuarios::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    usuario = Usuario.from_omniauth(auth)

    if usuario.present?
      sign_out_all_scopes
      flash[:success] = t('devise.omniauth_callbacks.success', kind: 'Google')
      sign_in_and_redirect usuario, event: :authentication
    else
      flash[:error] = t('devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized.")
      redirect_to new_usuario_session_path
    end
  end

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
