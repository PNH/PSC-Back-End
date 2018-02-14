# frozen_string_literal: true
module V1
  class Onboarding < Grape::API
    prefix 'api'
    resource :onboarding do
      params do
        optional :user, type: Hash do
          optional :email, allow_blank: false, regexp: /.+@.+/
          optional :name, type: String
          optional :ridingStyle, type: Integer, values: User.equestrain_styles.values, allow_blank: true
        end
        optional :horse, type: Hash do
          optional :name, type: String
          optional :breed, type: String
          optional :age, type: String
          optional :sex, type: Integer, values: Horse.sexes.values
        end
        requires :issues, type: Array[Integer]
        requires :goal, type: Integer
      end
      post do
        user = nil
        authenticate_user
        if authenticated?
          user = current_user
          cookies[:user_email] = user.email
        else
          user = User.find_by(email: params[:user][:email])
          if user.nil?
            user = build_user(params[:user])
          else
            authenticate_user
            unless authenticated?
              return {
                status: 401,
                message: 'Unauthorized',
                content: ''
              }
            end
          end
        end

        user.horses.destroy_all unless user.member?
        horse = if params[:horse].blank?
                  user.get_temp_horse
                else
                  build_horse(params[:horse])
                end
        horse.horse_issues.build(
          params[:issues].map do |id|
            { issue_id: id }
          end
        )
        goal = Goal.find_by_id(params[:goal])
        horse.goal = goal
        user.horses << horse
        user.save!
        {
          status: 201,
          message: '',
          content: horse.id
        }
      end
    end

    helpers do
      def build_user(user_params)
        user = User.new

        if user_params.nil? || user_params[:email].nil?
          user =  build_blank_user
        else
          user.email =  user_params[:email]
        end

        names =  user_params[:name].nil? ? ['tempuser','tempuser'] : user_params[:name].split(/\s+/)
        user.equestrain_style = User.equestrain_styles.keys[user_params[:ridingStyle]] unless user_params[:ridingStyle].blank?
        user.first_name = names.first
        user.last_name = names.last if names.size > 1
        # user.email =
        user.password = Devise.friendly_token.first(8)
        user
      end

      def build_horse(horse_params)
        horse = Horse.new
        horse.sex = horse_params[:sex]
        horse.name = horse_params[:name]
        horse.age = horse_params[:age]
        horse.breed = horse_params[:breed]
        horse
      end

      def build_blank_user
        user = User.new
        user.email = "guest_#{Time.now.to_i}#{rand(100)}@example.com"
        user.password = Devise.friendly_token.first(8)
        return user
      end
    end
  end
end
