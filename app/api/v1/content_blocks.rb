# frozen_string_literal: true
module V1
  class ContentBlocks < Grape::API
    prefix 'api'
    resource :content_blocks do
    end

    namespace 'content_blocks/join_the_club' do
      get do
        join_the_club = ContentBlock.find_by(slug: 'join_the_club')
        {
          status: 200,
          message: '',
          content: Entities::JoinTheClub.represent(join_the_club)
        }
      end
    end

    namespace 'content_blocks/testimonials' do
      get do
        testimonial_background = ContentBlock.find_by(slug: 'testimonial_background')
        {
          status: 200,
          message: '',
          content: Entities::ContentBlocksPresenter.represent(testimonial_background)
        }
      end
    end

  end
end
