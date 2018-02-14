class Goal < ActiveRecord::Base
  acts_as_paranoid

  has_many :issue_categories, dependent: :destroy
  has_many :issues, through: :issue_categories
  has_many :goal_lesson, dependent: :destroy
  has_many :sample_lessons, through: :goal_lesson, source: :lesson
  belongs_to :image, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  accepts_nested_attributes_for :goal_lesson, allow_destroy: true

  validate :lesson_duplicate
  validates :goal_lesson, :title, presence: true

  after_initialize do
    self.status = true if new_record?
  end

  private

  def lesson_duplicate
    ids = []
    goal_lesson.each do |gl|
      next if gl.lesson.nil?
      raise "Lesson '#{gl.lesson.title}' has already been taken" if ids.include?(gl.lesson_id)
      ids << gl.lesson_id
    end
  end
end
