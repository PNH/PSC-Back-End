class AlterGroupColumns < ActiveRecord::Migration
  def self.up
    remove_column :groups, :short_description
    remove_column :groups, :name
    remove_column :groups, :deleted_at
    # additions
    add_column :groups, :privacy_level, :integer
    add_column :groups, :title, :string
    add_column :groups, :rich_file_id, :integer
  end
  def self.down
    add_column :groups, :short_description, :string
    add_column :groups, :name, :string
    add_column :groups, :deleted_at, :datetime
  end

  # def change
  #   change_table :groups do |t|
  #     remove_column :table_name, :column_name
  #   end
  # end
end
