# frozen_string_literal: true
module V1
  module Entities
    class Address < Grape::Entity
      expose :id, :street, :street2, :state, :city, :country, :zipcode
      expose :latitude, as: :xCoordinate
      expose :longitude, as: :yCoordinate
    end
  end
end
