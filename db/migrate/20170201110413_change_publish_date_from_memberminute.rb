class ChangePublishDateFromMemberminute < ActiveRecord::Migration
  def change
    change_column :memberminutes, :publish_date, :datetime
  end
end
