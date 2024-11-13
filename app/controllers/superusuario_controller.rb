class SuperusuarioController < ApplicationController
    def index
        @cantidad_usuarios = Usuario.count

        @casilleros = Casillero.includes(:metrica) 

        @cantidad_controladores = Controlador.count 

        @aperturas_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
        hash[casillero.id] = casillero.metrica&.cant_aperturas || 0
        end

        @intentos_fallidos_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
        hash[casillero.id] = casillero.metrica&.cant_intentos_fallidos || 0
        end

        @cambios_contrasena_por_casillero = @casilleros.each_with_object({}) do |casillero, hash|
        hash[casillero.id] = casillero.metrica&.cant_cambios_contrasena || 0
        end

        @total_cambios_contrasena = @casilleros.sum do |casillero|
            casillero.metrica&.cant_cambios_contrasena || 0
        end

        @porcentaje_exito_aperturas = calcular_porcentaje_exito_aperturas
        @casilleros_abiertos = @casilleros.where(apertura: true).count
    end

    def calcular_porcentaje_exito_aperturas
        total_aperturas = @casilleros.sum { |casillero| casillero.metricas&.cant_aperturas.to_i }
        total_intentos = total_aperturas + @casilleros.sum { |casillero| casillero.metricas&.cant_intentos_fallidos.to_i }
        total_intentos > 0 ? (total_aperturas / total_intentos.to_f * 100).round(2) : 0
    end

end