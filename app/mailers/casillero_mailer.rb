class CasilleroMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def notificar_dueno(casillero)
    @casillero = casillero
    @usuario = casillero.usuario
    @clave = casillero.clave
    mail(to: @usuario.email, subject: "Notificación de Casillero Asignado")
  end
end
