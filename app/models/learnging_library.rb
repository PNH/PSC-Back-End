# frozen_string_literal: true
class LearngingLibrary < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title], :if => :searchable_lib?, :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}, :associated_against => {
    :category => [:title]
  }

  def searchable_lib?
    category != nil && file !=nil && status == true ? true : false;
  end

  belongs_to :category, class_name: 'Llcategory', foreign_key: 'llcategory_id'
  belongs_to :file, class_name: 'Rich::RichFile', foreign_key: 'file_id'
  belongs_to :thumbnail, class_name: 'Rich::RichFile', foreign_key: 'thumb_id'
  has_many :playlist_resource

  acts_as_list scope: [:llcategory_id], add_new_at: :top


  enum file_type: [:PDF, :DOCX, :PPT, :MP4, :MP3, :DOC]

  after_initialize do
    self.status = true if new_record?
  end
  validates :title, :file_id, presence: true

  def kind
    return 'VIDEO' if MP4?
    return 'AUDIO' if MP3?
    'DOCUMENT'
  end

  scope :active, -> { where(status: true) }

  scope :videos, -> { where(file_type: LearngingLibrary.file_types.values_at(:MP4)) }
  scope :audios, -> { where(file_type: LearngingLibrary.file_types.values_at(:MP3)) }
  scope :documents, -> { where(file_type: LearngingLibrary.file_types.values_at(:PDF, :DOCX, :PPT, :DOC)) }
end
