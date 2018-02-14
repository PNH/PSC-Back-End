# frozen_string_literal: true
class UpdateContentBlocks < ActiveRecord::Migration
  def change
    change_table :contents do |t|
      t.boolean :visible
      t.string :input_html
    end
  end
end
