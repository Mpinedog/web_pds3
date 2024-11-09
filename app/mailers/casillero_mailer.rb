class CasilleroMailer < ApplicationMailer
  default from: 'no-reply@example.com' 

  def notificar_dueno(casillero)
    @casillero = casillero
    @usuario = casillero.usuario
    @clave = casillero.clave

    mail(to: @usuario.email, subject: 'Información del Casillero')
  end
end
