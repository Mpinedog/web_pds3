class AddDeviseToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :email,              null: false, default: ""       # Campo para el correo electrónico
      t.string :encrypted_password, null: false, default: ""       # Campo para la contraseña encriptada

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.integer  :sign_in_count, default: 0, null: false           # Contador de inicios de sesión
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end

    # Asegura unicidad en los índices
    add_index :users, :email,                unique: true       # Índice único para el correo electrónico
    add_index :users, :reset_password_token, unique: true       # Índice único para el token de recuperación
  end
end

