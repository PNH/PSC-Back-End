module V1
  module Entities
    class ContentBlocksPresenter < Grape::Entity
      expose :id
      expose :blocks, using: V1::Entities::BlocksPresenter
    end
  end
end