# frozen_string_literal: true
module V1
  module Entities
    class Level < Grape::Entity
      expose :id, :title, :color
    end
  end
end
