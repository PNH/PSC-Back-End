class CreateBlogModerators < ActiveRecord::Migration
  def change
    create_table :blog_moderators do |t|
      t.belongs_to :blog, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.integer :moderator_type
      t.timestamps null: false
    end
  end
end
