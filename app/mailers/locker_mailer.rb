class LockerMailer < ApplicationMailer
  default from: 'no-reply@example.com' 

  def notificate_owner(locker)
    @locker = locker
    @user = locker.user
    @password = locker.password

    mail(to: @user.email, subject: 'Información del Locker')
  end
end
