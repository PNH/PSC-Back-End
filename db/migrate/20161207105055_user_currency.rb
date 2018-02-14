class UserCurrency < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.belongs_to :currency, foreign_key: true
    end
  end
end
