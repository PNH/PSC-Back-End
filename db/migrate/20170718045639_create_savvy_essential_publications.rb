class CreateSavvyEssentialPublications < ActiveRecord::Migration
  def up
    create_table :savvy_essential_publications do |t|
      t.string :title
      t.text :description
      t.date :publication_date
      t.boolean :status

      t.timestamps null: false

      t.references :savvy_essential, index: true, foreign_key: true
    end
  end

  def down
    drop_table :savvy_essential_publications
  end
end
