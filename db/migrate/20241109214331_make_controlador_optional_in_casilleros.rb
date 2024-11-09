class MakeControladorOptionalInCasilleros < ActiveRecord::Migration[7.1]
  def change
    change_column_null :casilleros, :controlador_id, true
  end
end
