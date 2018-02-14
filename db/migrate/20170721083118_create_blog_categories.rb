class CreateBlogCategories < ActiveRecord::Migration
  def up
    create_table :blog_categories do |t|
			t.string :name
      t.timestamps null: false
    end
  end

  def down
		drop_table :blog_categories
  end
end
