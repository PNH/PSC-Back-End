class AddOrderingToLearningLibrary < ActiveRecord::Migration
  def change
    change_table :learnging_libraries do |t|
      t.integer :position
    end
  end
end
