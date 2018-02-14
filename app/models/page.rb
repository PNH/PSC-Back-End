# frozen_string_literal: true
class Page < ActiveRecord::Base
  # acts_as_paranoid
  acts_as_list

  has_many :page_tags, dependent: :destroy
  has_many :tags, through: :page_tags

  has_many :page_attachments, :dependent => :destroy
  accepts_nested_attributes_for :page_attachments, :allow_destroy => true

  validates :title, presence: true
  validates :content, presence: true

  # scope :promotions_only, -> { where(display_type: self.display_types[:promotion]) }
  scope :menus_only, -> { where(display_type: self.display_types[:menu_item]) }
  scope :other_only, -> { where(display_type: self.display_types[:custom_page]) }

  validates_length_of :menu_title, :minimum => 5, :maximum => 20, :allow_blank => true
  validates :slug, uniqueness: true
  
  enum display_type: [
    :menu_item,
    :custom_page
  ]

  after_initialize do
    self.status = true if new_record?
  end
end
