class CreateSavvyEssentialPublicationSections < ActiveRecord::Migration
  def up
    create_table :savvy_essential_publication_sections do |t|
      t.string :title
      t.text :description
      t.boolean :status

      t.timestamps null: false

      # changed index name because exceed of max langth(63)
      t.references :savvy_essential_publication, index: { name: 'idx_savy_esntial_publction_sctions_on_savy_esntial_publction_id'}, foreign_key: true
      t.references :publication_section, index: { name: 'idx_savy_esntial_publction_sctions_on_publction_sctions_id'}, foreign_key: true
    end

    # changed index name because exceed of max langth(63)
    add_reference :publication_attachments, :savvy_essential_publication_section, index: { name: 'idx_publction_attchmnts_on_savy_esntial_publction_sction_id'}, foreign_key: true
  end

  def down
    drop_table :savvy_essential_publication_sections
    remove_reference :publication_attachments, :savvy_essential_publication_section, index: true, foreign_key: true
  end
end
