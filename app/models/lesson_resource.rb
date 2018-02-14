# frozen_string_literal: true
class LessonResource < ActiveRecord::Base
  acts_as_paranoid
  acts_as_list scope: [:kind]

  belongs_to :lesson
  belongs_to :rich_file, class_name: 'Rich::RichFile'
  belongs_to :video_sub, class_name: 'Rich::RichFile'

  enum kind: [:video, :audio, :document]

  def title
    return nil if new_record?
    t = read_attribute(:title)
    return t unless t.blank?
    rich_file.filename.split('.')[0].titleize
  end
end
