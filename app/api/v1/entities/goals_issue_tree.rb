module V1
  module Entities
    class GoalsIssueTree < Grape::Entity
      expose :id, :title
      expose :issues, using: V1::Entities::Issue
    end
  end
end
