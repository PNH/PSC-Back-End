class AddTitleToPageAttachments < ActiveRecord::Migration
  def change
    add_column :page_attachments, :title, :string
  end
end
