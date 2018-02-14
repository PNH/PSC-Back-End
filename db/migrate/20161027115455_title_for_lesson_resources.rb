# frozen_string_literal: true
class TitleForLessonResources < ActiveRecord::Migration
  def change
    change_table :lesson_resources do |t|
      t.string :title
      t.integer :video_sub_id
    end
    add_foreign_key :lesson_resources, :rich_rich_files, column: :video_sub_id
  end
end
