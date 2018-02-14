# frozen_string_literal: true
module V1
  class Testimonials < Grape::API
    prefix 'api'
    resource :testimonials do
      get do
        testimonials = Testimonial.includes(:author).all
        {
          status: 200,
          message: '',
          content: TestimonialsPresenter.represent(testimonials)
        }
      end
    end
  end

  class TestimonialsPresenter < Grape::Entity
    expose :id, :message
    expose :author do |instance, _options|
      {
        'name' => instance.author.name,
        'title' => member_title(instance.author),
        'profile_picture' => profile_picture(instance)
      }
    end

    private

    def profile_picture(instance)
      if instance.author.profile_picture.nil?
        file = Rich::RichFile.find(Rails.application.secrets.testimonial_profile_pic)
      else
        file = instance.author.profile_picture
      end
      file.rich_file.url('original')
    end

    def member_title(user)
      return '' unless user.member?
      mt = user.membership_details.last.membership_type
      "Savvy Club Member since #{mt.created_at.strftime('%Y')}"
    end
  end
end
