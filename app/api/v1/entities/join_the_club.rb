module V1
  module Entities
    class JoinTheClub < Grape::Entity
      expose :blocks, using: V1::Entities::JtcBlock
    end
  end
end
