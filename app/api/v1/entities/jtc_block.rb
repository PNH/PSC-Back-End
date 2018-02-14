# frozen_string_literal: true
module V1
  module Entities
    class JtcBlock < Grape::Entity
      expose :index
      expose :title
      expose :logo
      expose :message

      private

      def index
        object.contents.number.first.data
      end

      def title
        object.contents.string.first.data
      end

      def logo
        object.contents.image.first.data
      end

      def message
        object.contents.text.first.data
      end
    end
  end
end
