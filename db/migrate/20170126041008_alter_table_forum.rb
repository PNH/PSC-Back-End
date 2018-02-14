class AlterTableForum < ActiveRecord::Migration
  def change
    add_column :forums, :rich_file_id, :integer
  end
end
