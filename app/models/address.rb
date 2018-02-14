class Address < ActiveRecord::Base
  acts_as_paranoid

  has_one :user, foreign_key: :home_address_id, class_name: 'User'

  reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode
  geocoded_by :full_address
  # after_validation :geocode
  after_validation :geocode, if: ->(obj){ obj.full_address.present? and obj.street_changed? }

  attr_accessor :address

  def full_address
    return "#{street}, #{zipcode}, #{city}, #{country}"
  end
end
