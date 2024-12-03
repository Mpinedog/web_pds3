class UserMailer < ApplicationMailer
  def notify_disconection(user, manager)
    @manager = manager
    @user = manager.user
    mail(to: @user.email, subject: 'Desconexión de Casillero')
  end
end