# frozen_string_literal: true
class Horse < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :owner, class_name: 'User', foreign_key: 'user_id'
  has_many :horse_issues, dependent: :destroy
  has_many :issues, through: :horse_issues
  has_many :horse_lessons, dependent: :destroy
  has_many :horse_badges, dependent: :destroy
  belongs_to :level
  belongs_to :goal
  belongs_to :picture, class_name: 'Rich::RichFile', foreign_key: 'rich_file_id'

  enum sex: [:mare, :gelding, :stallion, :filly, :colt]
  enum horsenality: ['Unknown'.to_sym,
                     'Left Brain Extrovert (LBE)'.to_sym,
                    #  'Left Brain Extrovert (not LBE)'.to_sym,
                     'Left Brain Extrovert Axis Point'.to_sym,
                     'Left Brain Extrovert/Introvert Cusp (LBE/LBI)'.to_sym,
                     'Left Brain/Right Brain Extrovert Cusp (LBE/RBE)'.to_sym,
                     'Left Brain Introvert (LBI)'.to_sym,
                    #  'Left Brain Introvert (not LBI)'.to_sym,
                     'Left Brain Introvert Axis Point'.to_sym,
                     'Left Brain Introvert/Extrovert Cusp (LBI/LBE)'.to_sym,
                     'Left Brain/Right Brain Introvert Cusp (LBI/RBI)'.to_sym,
                     'Right Brain Extrovert (RBE)'.to_sym,
                    #  'Right Brain Extrovert (not RBE)'.to_sym,
                     'Right Brain Extrovert Axis Point'.to_sym,
                     'Right Brain Extrovert/Introvert Cusp (RBE/RBI)'.to_sym,
                     'Right Brain Extrovert/Left Brain Extrovert Cusp (RBE/LBE)'.to_sym,
                     'Right Brain Introvert (RBI)'.to_sym,
                    #  'Right Brain Introvert (not RBI)'.to_sym,
                     'Right Brain Introvert Axis Point'.to_sym,
                     'Right Brain Introvert/Extrovert Cusp (RBI/RBE)'.to_sym,
                     'Right Brain Introvert/Left Brain Introvert Cusp (RBI/LBI)'.to_sym]

  #  enum horsenality: ['Extroverted',
  #                     'Introverted',
  #                     'Left Brain Extrovert (not LBE)'.to_sym,
  #                     'Right Brain Extrovert (not RBE)'.to_sym,
  #                     'Left Brain Introvert (not LBI)'.to_sym,
  #                     'Right Brain Introvert (not RBI)'.to_sym,
  #                     'I’m not sure']

  accepts_nested_attributes_for :horse_issues

  def lesson_completed?(lesson)
    horse_lessons.where(completed: true).exists?(lesson: lesson)
  end

  def completed(lesson)
    horse_lesson = horse_lessons.find_or_initialize_by(lesson: lesson)
    horse_lesson.completed = true
    horse_lesson.completed_time = Time.zone.now
    horse_lesson.save!
  end

  def lesson_category_completed_percentage(lesson_category)
    fast_track_completed = lesson_completed?(lesson_category.fast_track_lesson)
    return 100 if fast_track_completed
    completed_lesson_count = horse_lessons.joins(:lesson)
                                          .where(completed: true)
                                          .where('lessons.lesson_category_id = ?', lesson_category.id)
                                          .count
    all_lesson_count = ::Lesson.where(lesson_category: lesson_category)
                               .where(kind: ::Lesson.kinds.values_at(:default))
                               .count
    return 0 if all_lesson_count.eql?(0)
    (completed_lesson_count * 100) / all_lesson_count
  end

  def level_completed_percentage(level)
    scp_array = level.savvies.map do |savvy|
      savvy_completed_percentage(savvy)
    end
    return 0 if scp_array.empty?
    sum = scp_array.reduce(:+).to_f
    return 0 if sum.nan?
    sum / scp_array.size
  end

  def savvy_completed_percentage(savvy)
    lcp_array = savvy.lesson_categories.map do |lc|
      lesson_category_completed_percentage(lc)
    end
    return 0 if lcp_array.empty?
    sum = lcp_array.reduce(:+).to_f
    return 0 if sum.nan?
    sum / lcp_array.size
  end
end
