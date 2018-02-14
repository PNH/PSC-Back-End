class AddMemberminuteSectionToMemberminuteResource < ActiveRecord::Migration
  def change
    remove_column :memberminute_resources, :memberminute_id
    change_table :memberminute_resources do |t|
      t.belongs_to :memberminute_section
    end
  end
end
