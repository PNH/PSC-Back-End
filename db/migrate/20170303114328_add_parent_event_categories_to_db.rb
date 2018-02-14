class AddParentEventCategoriesToDb < ActiveRecord::Migration
  def up
    EventCategory.create :title => 'Official', :description => '', :status => true, :parent_id => nil
    EventCategory.create :title => 'Community', :description => '', :status => true, :parent_id => nil
  end
end
