
module V1
  module Entities
    class BlocksPresenter < Grape::Entity
      expose :contents, using: V1::Entities::Contents
    end
  end
end