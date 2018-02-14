class Event < ActiveRecord::Base
  include PgSearch
  multisearchable :against => [:title], :using => {:tsearch => {:prefix => true, :dictionary => "english", :normalization => 7, :any_word => true}}

  has_one :event_location, :dependent => :destroy
  has_one :event_organizer, :dependent => :destroy
  has_many :event_instructors, :dependent => :destroy
  has_many :event_participants, :dependent => :destroy
  has_many :event_pricings, :dependent => :destroy
  has_many :event_category_mappings, :dependent => :destroy

  scope :open_events, -> { where(status: 1).reject { |event| event.end_date.past? } }
  scope :recent_added_events, -> (limit) { where(status: 1).order(created_at: :desc).limit(limit) }

  accepts_nested_attributes_for :event_category_mappings, :allow_destroy => true
  accepts_nested_attributes_for :event_pricings, :allow_destroy => true
  accepts_nested_attributes_for :event_instructors, :allow_destroy => true
  accepts_nested_attributes_for :event_location, :allow_destroy => true
  accepts_nested_attributes_for :event_organizer, :allow_destroy => true
  accepts_nested_attributes_for :event_participants, :allow_destroy => true

  attr_accessor :start_time
  attr_accessor :end_time
  attr_accessor :registration_opening_time
  attr_accessor :registration_closing_time

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  # validates :registration_opening_date, presence: true
  # validates :registration_closing_date, presence: true
  # validates :url, presence: true

  enum status: {
    open: 1,
    canceled: 2,
    ended: 3,
    unknown: -1
  }

  # # limiting to one mapping
  # validate :has_one_instructor
  # def has_one_instructor
  #   if self.event_instructors.select {|t| !t.marked_for_destruction?}.size > 1
  #     errors.add(:event_instructors, "- Can only have one instructor")
  #   end
  #   # if self.event_instructors.select {|t| !t.marked_for_destruction?}.size == 0
  #   #   errors.add(:event_instructors, "- Event should have an instructor assigned to it")
  #   # end
  # end

  # limiting to only one primary instructor
  validate :has_only_one_primary
  def has_only_one_primary
    _pry_instructors = self.event_instructors.select {|t| EventInstructor.join_types[t.join_type] == EventInstructor.join_types[:primary]}
    if !_pry_instructors.empty? && _pry_instructors.count > 1
      errors.add("EventInstructor", "- should have only one primary instructor")
    end
  end

  # limiting to one mapping
  validate :has_one_category_mappings
  def has_one_category_mappings
    if self.event_category_mappings.select {|t| !t.marked_for_destruction?}.size > 1
      errors.add(:event_category_mappings, "- Can only have one categroy")
    end
    if self.event_category_mappings.select {|t| !t.marked_for_destruction?}.size == 0
      errors.add("Event Category", "- Event should have a category assigned to it")
    end
  end

  validate :has_one_location
  def has_one_location
    if self.event_location.nil?
      errors.add(:event_location, "- Event should have a location")
    end
  end

  before_validation :smart_add_url_protocol

  protected

  def smart_add_url_protocol
    if !self.url.nil? && self.url.length > 0
      unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
        self.url = "http://#{self.url}"
      end
    end
  end

end
