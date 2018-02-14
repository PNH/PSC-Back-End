# frozen_string_literal: true
module V1
  module Entities
    class Playlist < Grape::Entity
      expose :id, :title
    end
  end
end
