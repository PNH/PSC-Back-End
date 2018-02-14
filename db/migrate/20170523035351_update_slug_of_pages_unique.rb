class UpdateSlugOfPagesUnique < ActiveRecord::Migration
  def change
    Page.all.delete_all
    add_index :pages, :slug, unique: true, :name => 'unique_index_pages_on_slug'
  end
end
