module V1
  module Entities
    class IssueCategory < Grape::Entity
      expose :id, :title
    end
  end
end
