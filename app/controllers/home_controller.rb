class HomeController < ApplicationController
  before_action :authenticate_usuario!

  def index
    @casilleros = Casillero.all  
    @controladores = Controlador.all 
    @modelos = Modelo.all 
    @usuario = current_usuario 
  end
  
end
