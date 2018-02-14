module V1
  module Entities
    class UserConnections < Grape::Entity
      expose :id
      expose :created_at, as: :createdAt

      # expose :user_requestee do |instance|
      #   _userObj = UserConnections.userTemplate instance.user_requestee
      #   _userObj
      # end
      #
      # expose :user_requester do |instance|
      #   _userObj = UserConnections.userTemplate instance.user_requester
      #   _userObj
      # end

      expose :user do |instance, options|
        current_user = options[:current_user]
        _userObj = nil
        if instance.user_requestee.id === current_user.id
          _userObj = Entities::User.userPublicMiniTemplate instance.user_requester, current_user
        else
          _userObj = Entities::User.userPublicMiniTemplate instance.user_requestee, current_user
        end
        _userObj
      end

      class SearchResult < Grape::Entity
        expose :user do |instance, options|
          current_user = options[:current_user]
          _userObj = Entities::User.userPublicMiniTemplate instance, current_user
          _userObj
        end
      end

      # private stuff

    end
  end
end
