class CreatePrivacysettings < ActiveRecord::Migration
  def change
    create_table :privacysettings do |t|      
      t.integer :privacy_type
      t.integer :status
      t.belongs_to :user, foreign_key: true
    end
  end
end
