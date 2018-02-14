class AddStatusToBlog < ActiveRecord::Migration
  def change
    add_column :blogs, :status, :integer, :default => 0
    Blog.create :name => "Blog", :description => "Main Blog", :status => 1
  end
end
