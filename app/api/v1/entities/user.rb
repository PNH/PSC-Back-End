# frozen_string_literal: true
module V1
  module Entities
    class User < Grape::Entity

      def self.userPublicMiniTemplate (user, current_user)
        _userObj = nil
        if user
          _conn_status = user.connection_status(current_user.id)
          _distance_from_me = user.home_address.distance_from([current_user.home_address.latitude, current_user.home_address.longitude])
          _ns_role = nil

          if user.is_instructor || user.is_instructor_junior
            _ns_role = "Instructor"
          elsif user.is_staff_member
            _ns_role = "Staff"
          else
            _ns_role = user.role
          end

          _userObj = {
            'id' => user.id,
            'firstName' => user.first_name,
            'lastName' => user.last_name,
            'profileImage' => user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : user.profile_picture.url('thumb'),
            # 'isConnected' => user.is_connected(current_user.id),
            'createdAt' => user.created_at,
            'isInstructor' => user.is_instructor ? true : false,
            'role' => _ns_role.downcase,
            'connectionStatus' => {
              'connected' => user.is_connected(current_user.id),
              'label' => _conn_status.empty? ? "not connected" : _conn_status.first.connection_status,
              'status' => _conn_status.empty? ? 0 : UserConnection.connection_statuses[_conn_status.first.connection_status]
            },
            'distance' => _distance_from_me,
            'unread_messages_count' => user.unread_sent_messages_count_to_current_user(current_user),
            'wall_posts_count' => user.wall_posts_count,
            'connections_count' => user.connections_count
          }
        else
          _userObj = {
            'firstName' => "Deleted",
            'lastName' => "User",
            'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
          }
        end
        return _userObj
      end

    end
  end
end
