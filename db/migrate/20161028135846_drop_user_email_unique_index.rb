# frozen_string_literal: true
class DropUserEmailUniqueIndex < ActiveRecord::Migration
  def change
    remove_index :users, :email
  end
end
