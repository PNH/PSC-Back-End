class CreatePublicationSections < ActiveRecord::Migration
  def up
    create_table :publication_sections do |t|
      t.string :title
      t.text :description
      t.boolean :status

      t.timestamps null: false
    end
  end

  def down
    drop_table :publication_sections
  end
end
