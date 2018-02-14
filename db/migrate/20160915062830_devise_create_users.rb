class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      # t.string     :current_sign_in_ip
      t.inet     :last_sign_in_ip
      # t.string     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false

      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.integer :gender
      t.string :music
      t.string :books
      t.string :website
      t.string :telephone
      t.integer :relationship
      t.integer :equestrain_style
      t.integer :equestrain_interest
      t.integer :riding_style
      t.text :bio
      t.datetime :deleted_at, index: true
      t.integer :home_address_id
      t.integer :billing_address_id
      t.integer :role
      t.integer :profile_picture_id
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
    add_foreign_key :users, :addresses, column: :home_address_id
    add_foreign_key :users, :addresses, column: :billing_address_id
    add_foreign_key :users, :rich_rich_files, column: :profile_picture_id
  end
end
