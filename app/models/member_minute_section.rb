# frozen_string_literal: true
class MemberMinuteSection < ActiveRecord::Base
  self.table_name = 'memberminute_sections'
    acts_as_paranoid
    belongs_to :member_minute, foreign_key: 'memberminute_id'
    belongs_to :rich_file, class_name: 'Rich::RichFile'
    has_many :member_minute_resources, dependent: :destroy, foreign_key: 'memberminute_section_id'
    enum categoryselect: [:member_minute, :savvy_time]
    # accepts_nested_attributes_for :memberminute_resources, allow_destroy: true, reject_if:  proc { |attributes| attributes['rich_file_id'].blank? }
    scope :member_minute, -> {where(kind: MemberMinuteSection.categoryselects.values_at(:member_minute))}
    scope :savvy_time, -> {where(kind: MemberMinuteSection.categoryselects.values_at(:savvy_time))} 

    enum file_type: [:video, :audio, :image]
    validates :rich_file_id, presence: true
    validates :title, presence: true
end

   