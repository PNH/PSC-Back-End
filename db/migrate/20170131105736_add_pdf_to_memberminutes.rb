class AddPdfToMemberminutes < ActiveRecord::Migration
  def change
    change_table :memberminutes do |t|
      t.string :pdf_remote_url
      t.integer :pdf_id
      t.boolean :featured
    end
  end
end
