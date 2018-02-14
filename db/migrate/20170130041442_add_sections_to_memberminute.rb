class AddSectionsToMemberminute < ActiveRecord::Migration
  def change
    change_table :memberminutes do |t|
      t.string :memberminute_section
      t.string :savvytime_section
      t.integer :rich_file_id
    end
  end
end
