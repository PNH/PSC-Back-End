class CreatePageTags < ActiveRecord::Migration
  def up
    create_table :page_tags do |t|
			t.belongs_to :page, foreign_key: true
			t.belongs_to :tag, foreign_key: true
      t.timestamps null: false
    end

    # PG::InvalidTextRepresentation: ERROR:  invalid input syntax for integer: "sample, page, index, tags"
    # that is why removed than added
    remove_column :pages, :tags
    add_column :pages, :tags, :integer, default: :null
  end
  def down
    drop_table :page_tags
    remove_column :pages, :tags
    add_column :pages, :tags, :string, default: :null
  end
end
