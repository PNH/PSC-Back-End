# frozen_string_literal: true
class AddSavvyImage < ActiveRecord::Migration
  def change
    change_table :savvies do |t|
      t.integer :rich_file_id
    end
    add_foreign_key :savvies, :rich_rich_files, column: :rich_file_id
    change_table :levels do |t|
      t.integer :slug
    end
  end
end
