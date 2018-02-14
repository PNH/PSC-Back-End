# frozen_string_literal: true
class MemberMinuteResource < ActiveRecord::Base
  self.table_name = 'memberminute_resources'
  acts_as_paranoid
  belongs_to :member_minute_section, foreign_key: 'memberminute_section_id'
  belongs_to :rich_file, class_name: 'Rich::RichFile'

  enum kind: [:video, :audio, :image]
  # validates :title, presence: true
  validates :rich_file_id, presence: true

end
