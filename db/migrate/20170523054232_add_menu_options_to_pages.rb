class AddMenuOptionsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :menu_title, :string, unique: true
    add_column :pages, :position, :integer, :default => 0
    add_column :pages, :display_type, :integer, :default => 0
  end
end
