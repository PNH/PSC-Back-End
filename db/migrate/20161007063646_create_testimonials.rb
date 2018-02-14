class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.belongs_to :user, foreign_key: true
      t.text :message
      t.timestamps null: false
      t.datetime :deleted_at, index: true
    end
  end
end
