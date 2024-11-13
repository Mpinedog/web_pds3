class Controlador < ApplicationRecord
  self.table_name = "controladores"
  belongs_to :usuario
  belongs_to :modelo, optional: true
  has_many :casilleros

  after_update :sincronizar_con_esp, if: :saved_change_to_modelo_id?

  private

  def sincronizar_con_esp
    ControladoresController.new.sync_to_esp(self)
  end

end
