class AddPolymorphicAssociationsToNotifications < ActiveRecord::Migration
  def up
		add_reference :notifications, :notifiable, polymorphic: true, index: true
  end

  def down
		remove_reference :notifications, :notifiable, polymorphic: true, index: true
  end
end
