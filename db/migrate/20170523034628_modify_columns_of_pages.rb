class ModifyColumnsOfPages < ActiveRecord::Migration
  def change
    rename_column :pages, :description, :content
    add_column :pages, :tags, :string
    remove_column :pages, :deleted_at
    change_column :pages, :status, :boolean, :default => true
  end
end
