# frozen_string_literal: true
class MemberMinute < ActiveRecord::Base
    self.table_name = 'memberminutes'
    acts_as_paranoid
    belongs_to :rich_file, class_name: 'Rich::RichFile'
    belongs_to :pdf, class_name: 'Rich::RichFile', foreign_key: 'pdf_id'
    has_many :member_minute_sections, dependent: :destroy, foreign_key: 'memberminute_id'
    validates :title, presence: true
    validates :publish_date, presence: true
    validates :pdf_remote_url, presence: true
    validates :pdf_id, presence: true
    validates :memberminute_section, presence: true
    validates :savvytime_section, presence: true
    # validates_format_of :publish_date, :with => /\d{2}\/\d{2}\/\d{4}/, :message => "Date must be in the following format: mm/dd/yyyy"

    def publish_date=(val)
      write_attribute(:publish_date,Date.strptime(val, "%m/%d/%Y")) unless val.empty?
    end
end
