module V1
  module Entities
    class LevelChecklist < Grape::Entity
      expose :id, :level_id, :title, :content
    end
  end
end
