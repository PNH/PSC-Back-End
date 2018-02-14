# frozen_string_literal: true
class Lesson < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title], :if => :deleted_lessson?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  def deleted_lessson?
    deleted_at != nil ? false : true;
  end

  acts_as_paranoid
  acts_as_list scope: [:lesson_category_id], add_new_at: :top

  belongs_to :lesson_category
  has_many :lesson_tool, -> { order(:position) }, inverse_of: :lesson, dependent: :destroy
  has_many :chat_bubbles, dependent: :destroy
  has_many :horse_lessons, dependent: :destroy
  has_many :lesson_resources, -> { order(:position) }, dependent: :destroy
  has_many :document_resources, -> { order(:position).where('lesson_resources.kind' => LessonResource.kinds[:document]) }, class_name: 'LessonResource'
  has_many :audio_resources, -> { order(:position).where('lesson_resources.kind' => LessonResource.kinds[:audio]) }, class_name: 'LessonResource'
  has_many :video_resources, -> { order(:position).where('lesson_resources.kind' => LessonResource.kinds[:video]) }, class_name: 'LessonResource'
  has_many :documents, -> { where('lesson_resources.kind' => LessonResource.kinds[:document]) }, through: :lesson_resources, source: :rich_file
  has_many :videos, -> { where('lesson_resources.kind' => LessonResource.kinds[:video]) }, through: :lesson_resources, source: :rich_file
  has_many :audios, -> { where('lesson_resources.kind' => LessonResource.kinds[:audio]) }, through: :lesson_resources, source: :rich_file

  accepts_nested_attributes_for :chat_bubbles, allow_destroy: true, reject_if:  proc { |attributes| attributes['user_id'].blank? }
  accepts_nested_attributes_for :lesson_tool, allow_destroy: true, reject_if:  proc { |attributes| attributes['title'].blank? }
  accepts_nested_attributes_for :lesson_resources, allow_destroy: true, reject_if:  proc { |attributes| attributes['rich_file_id'].blank? }
  accepts_nested_attributes_for :video_resources, allow_destroy: true, reject_if:  proc { |attributes| attributes['rich_file_id'].blank? }
  accepts_nested_attributes_for :audio_resources, allow_destroy: true, reject_if:  proc { |attributes| attributes['rich_file_id'].blank? }
  accepts_nested_attributes_for :document_resources, allow_destroy: true, reject_if:  proc { |attributes| attributes['rich_file_id'].blank? }

  enum kind: [:default, :fast_track, :sample]

  validates :title, presence: true
  validate :fast_track_limit

  after_initialize do
    self.status = true if new_record?
  end

  private

  def fast_track_limit
    return unless status
    return unless fast_track?
    fast_track_count = if new_record?
                         lesson_category.lessons
                                        .where(kind: Lesson.kinds.values_at(:fast_track))
                                        .where(status: true).count
                       else
                         lesson_category.lessons
                                        .where(kind: Lesson.kinds.values_at(:fast_track))
                                        .where.not('lessons.id = ?', id)
                                        .where(status: true).count
                       end
    if fast_track_count.positive?
      errors.add(:kind, 'Sorry, This Lesson Category already has a fast track lesson')
    end
  end
end
