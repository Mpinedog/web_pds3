class CasillerosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_controlador, only: [:show, :new, :create, :edit, :update, :destroy], if: -> { params[:controlador_id].present? }
  before_action :set_casillero, only: [:show, :edit, :update, :destroy]

  def index
    @casilleros = Casillero.all
  end

  def show
  end

  def new
    @casillero = @controlador ? @controlador.casilleros.build : Casillero.new
  end

  def create
    @casillero = @controlador ? @controlador.casilleros.build(casillero_params.except(:dueño_email)) : Casillero.new(casillero_params.except(:dueño_email))
    
    user_email = casillero_params[:dueño_email]
    @casillero.usuario = Usuario.find_by(email: user_email) if user_email.present?

    @casillero.metrica ||= Metrica.create(cant_aperturas: 0, cant_intentos_fallidos: 0, cant_cambios_contrasena: 0)

    if @casillero.save
      CasilleroMailer.notificar_dueno(@casillero).deliver_now
      redirect_to casillero_path(@casillero), notice: 'Casillero agregado exitosamente.'
    else
      render :new
    end
  end
  
  def edit
  end

  def update
    assign_user_to_casillero # Cambiado de assign_user_by_email a assign_user_to_casillero
  
    if @casillero.update(casillero_params.except(:dueño_email))
      enviar_correo_casillero(@casillero) # Envía el correo al usuario asignado
      redirect_to casillero_path(@casillero), notice: 'Casillero actualizado exitosamente y notificación enviada al dueño.'
    else
      render :edit
    end
  end

  def destroy
    @casillero.destroy
    redirect_to casilleros_path, notice: 'Casillero eliminado exitosamente.'
  end

  private

  def set_casillero
    @casillero = Casillero.find(params[:id])
  end

  def assign_user_to_casillero
    email = params[:casillero][:dueño_email]
    if email.present?
      usuario = Usuario.find_by(email: email)
      if usuario
        @casillero.usuario = usuario
      else
        @casillero.errors.add(:dueño_email, 'No se encontró un usuario con ese correo electrónico')
      end
    end
  end

  def enviar_correo_casillero(casillero)
    CasilleroMailer.notificar_dueno(casillero).deliver_now
  end
  

  def casillero_params
    params.require(:casillero).permit(:nombre, :apertura, :clave, :controlador_id, :dueño_email)
  end  

  def set_controlador
    @controlador = Controlador.find(params[:controlador_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to controladores_path, alert: "Controlador no encontrado."
  end
end
