class HorseProfilePicture < ActiveRecord::Migration
  def change
    change_table :horses do |t|
      t.integer :rich_file_id
    end
    add_foreign_key :horses, :rich_rich_files, column: :rich_file_id
  end
end
