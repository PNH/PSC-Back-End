module V1
  module Entities
    class Lesson < Grape::Entity
      expose :id, :title, :description, :objective, :slug, :kind
    end
  end
end
