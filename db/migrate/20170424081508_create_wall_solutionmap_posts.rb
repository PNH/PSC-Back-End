class CreateWallSolutionmapPosts < ActiveRecord::Migration
  def change
    create_table :wall_solutionmap_posts do |t|
      t.belongs_to :wall, index: true, foreign_key: true
      t.references :horse
      t.text :note
      t.integer :solutionmap_id
    end
  end
end
