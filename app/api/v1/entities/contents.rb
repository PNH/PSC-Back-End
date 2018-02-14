module V1
  module Entities
    class Contents < Grape::Entity
      expose :kind, as: :type
      expose :data
    end
  end
end