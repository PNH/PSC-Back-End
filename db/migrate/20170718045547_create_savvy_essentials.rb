class CreateSavvyEssentials < ActiveRecord::Migration
  def up
    create_table :savvy_essentials do |t|
      t.string :title
      t.boolean :status

      t.timestamps null: false
    end
  end

  def down
    drop_table :savvy_essentials
  end
end
