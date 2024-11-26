class LockerMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def notify_owner(locker)
    @locker = locker
    @user = locker.user
    @password = locker.password
    mail(to: @user.email, subject: "Notificación de Casillero Asignado")
  end

  def notify_opening(locker)
    @locker = locker
    @user = locker.user
    mail(to: @user.email, subject: 'Notificación de Apertura de Casillero')
  end
end
