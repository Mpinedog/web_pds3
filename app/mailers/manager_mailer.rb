class ManagerMailer < ApplicationMailer
  def predictor_one_email(user,locker)
    @locker = locker
    @predictor = locker.manager.predictor
    @user = locker.user
    @password = locker.password
    mail(to: @locker.user.email, subject: 'Se le asigno un locker')
  end

  def predictor_two_email(user, locker)
    @locker = locker
    @predictor = locker.manager.predictor
    @user = locker.user
    @password = locker.password
    mail(to: @locker.user.email, subject: 'Se le asigno un locker')
  end
end
