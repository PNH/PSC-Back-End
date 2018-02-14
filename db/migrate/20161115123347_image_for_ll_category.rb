# frozen_string_literal: true
class ImageForLlCategory < ActiveRecord::Migration
  def change
    change_table :llcategories do |t|
      t.integer :rich_file_id
    end
    add_foreign_key :llcategories, :rich_rich_files, column: :rich_file_id
  end
end
