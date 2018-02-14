# frozen_string_literal: true
module V1
  module Entities
    class Currency < Grape::Entity
      expose :id, :title, :country, :symbol
    end
  end
end
