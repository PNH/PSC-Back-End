class AddRichFileToMemberminuteSection < ActiveRecord::Migration
  def change
    change_table :memberminute_sections do |t|
      t.integer :file_type
      t.integer :rich_file_id
    end
  end
end
