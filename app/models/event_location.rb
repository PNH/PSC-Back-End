class EventLocation < ActiveRecord::Base

  belongs_to :event

  # geocoding stuff
  reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode
  geocoded_by :full_address
  # after_validation :geocode
  after_validation :geocode, if: ->(obj){ obj.full_address.present? and obj.street_changed? }

  validates :country, presence: true
  validates :state, presence: true
  validates :street, presence: true
  validates :zipcode, presence: true

  attr_accessor :address

  def full_address
    return "#{street.titleize}, #{city.titleize}, #{state.upcase}, #{zipcode}, #{ISO3166::Country.new(country)}"
  end

end
