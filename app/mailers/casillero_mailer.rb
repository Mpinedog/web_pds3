class CasilleroMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def notificar_dueno(casillero)
    @casillero = casillero
    @usuario = casillero.usuario
    @clave = casillero.clave
    mail(to: @usuario.email, subject: "Notificación de Casillero Asignado")
  end

  def notificar_apertura(casillero)
    @casillero = casillero
    @usuario = casillero.usuario
    mail(to: @usuario.email, subject: 'Notificación de Apertura de Casillero')
  end
end
