class LessonTool < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list

  belongs_to :lesson, inverse_of: :lesson_tool
end
