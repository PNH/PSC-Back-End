class CreateMemberMinuteResource < ActiveRecord::Migration
  def change
    create_table :memberminute_resources do |t|
      t.belongs_to :memberminute, foreign_key: true
      t.integer :rich_file_id
      t.string :external_url
      t.string :title
      t.integer :kind
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
    add_foreign_key :memberminute_resources, :rich_rich_files, column: :rich_file_id
  end
end
