# frozen_string_literal: true
module V1
  class Playlists < Grape::API
    prefix 'api'
    resource :playlists do
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        playlists = ::Playlist.where(user: current_user)
        {
          status: 200,
          message: '',
          content: Entities::Playlist.represent(playlists)
        }
      end

      params do
        requires :title, type: String
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        playlist = ::Playlist.new
        playlist.title = params[:title]
        playlist.user = current_user
        playlist.save!
        {
          status: 201,
          message: '',
          content: playlist.id
        }
      end

      params do
        requires :id, type: Integer
        requires :title, type: String
      end
      put ':id' do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        ::Playlist.where(user: current_user)
                  .where(id: params[:id])
                  .first.update(
                    title: params[:title]
                  )
        {
          status: 200,
          message: '',
          content: ''
        }
      end

      params do
        requires :id, type: Integer
      end
      delete ':id' do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        ::Playlist.where(user: current_user).find(params[:id]).destroy
        {
          status: 200,
          message: '',
          content: ''
        }
      end
    end

    namespace 'playlists/:id/resources' do
      params do
        requires :id, type: Integer
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end

        playlists = Playlist.where user_id: current_user.id, id: params[:id]

        response = nil
        if !playlists.empty?
          playlist = playlists.first
          resources = playlist.playlist_resources
          if !resources.empty?
            response = {
              status: 200,
              message: '',
              content: Entities::PlaylistResource.represent(resources, current_user: current_user)
            }
          else
            response = {
              status: 200,
              message: 'No Resources',
              content: []
            }
          end
        else
          response = {
            status: 404,
            message: 'Playlist not found',
            content: nil
          }
        end

        return response
      end

      params do
        requires :id, type: Integer
        requires :resourceId, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          playlist = ::Playlist.find_by(user_id: current_user.id, id: params[:id])
          if !playlist.nil?
            playlistResource = ::PlaylistResource.find_by(playlist_id: playlist.id, file_id: params[:resourceId])
            if playlistResource.nil?
              resource = Rich::RichFile.find_by(id: params[:resourceId])
              if !resource.nil?
                playlistResource = ::PlaylistResource.new(playlist_id: playlist.id, file_id: resource.id)

                learnging_library = ::LearngingLibrary.find_by file_id: resource.id
                if !learnging_library.nil?
                  playlistResource.title = learnging_library.title
                else
                  playlistResource.title = resource.rich_file_file_name
                end

                lesson_resource = ::LessonResource.find_by rich_file_id: resource.id
                if !lesson_resource.nil?
                  playlistResource.title = lesson_resource.title
                else
                  playlistResource.title = resource.rich_file_file_name
                end

                if playlistResource.save!
                  response = { status: 201, message: 'Resource added to playlist', content: Entities::PlaylistResource.represent(playlistResource, current_user: current_user) }
                else
                  resource = { status: 500, message: 'Failed to add resource', content: nil }
                end
              else
                response = { status: 404, message: 'Resource not found', content: nil }
              end
            else
              response = { status: 409, message: 'Item is already in playlist', content: Entities::PlaylistResource.represent(playlistResource, current_user: current_user) }
            end
          else
            response = { status: 404, message: 'Playlist not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :id, type: Integer
        requires :resourceId, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          playlist = ::Playlist.find_by(user_id: current_user.id, id: params[:id])
          if !playlist.nil?
            playlistResource = ::PlaylistResource.find_by(playlist_id: playlist.id, file_id: params[:resourceId])
            if !playlistResource.nil?
              if playlistResource.delete
                response = { status: 200, message: 'Resource removed from playlist', content: Entities::Playlist.represent(playlist) }
              else
                resource = { status: 500, message: 'Failed to remove resource from playlist', content: nil }
              end
            else
              response = { status: 404, message: 'Resource not found', content: nil }
            end
          else
            response = { status: 404, message: 'Playlist not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'member/:user_id/playlists' do
      params do
        requires :user_id, type: Integer
      end
      get do

        response = nil

        user = User.find_by(id: params[:user_id])

        if !user.nil?
          playlists = Playlist.where user_id: user.id

          if !playlists.empty?
            response = {
              status: 200,
              message: 'Playlists found',
              content: Entities::Playlist.represent(playlists)
            }
          else
            response = {
              status: 200,
              message: 'No Playlists for User',
              content: nil
            }
          end
        else
          response = {
            status: 200,
            message: 'User not found',
            content: nil
          }
        end
        return response
      end

    end

    namespace 'member/:user_id/playlists/:id/resources' do
      params do
        requires :user_id, type: Integer
        requires :id, type: Integer
      end
      get do
        response = nil

        user = User.find_by(id: params[:user_id])

        if !user.nil?
          playlists = Playlist.where user_id: user.id, id: params[:id]

          if !playlists.empty?
            playlist = playlists.first
            resources = playlist.playlist_resources
            if !resources.empty?
              response = {
                status: 200,
                message: 'Resources found',
                content: Entities::PlaylistResourceAPI.represent(resources, current_user: user)
              }
            else
              response = {
                status: 200,
                message: 'No resource for playlist',
                content: nil
              }
            end

          else
            response = {
              status: 200,
              message: 'Playlist not found',
              content: nil
            }
          end
        else
          response = {
            status: 200,
            message: 'User not found',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'playlists/:playlist/walls/:wall/share/:id' do
      params do
        requires :playlist, type: Integer
        requires :wall, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          playlist = ::Playlist.find_by(:id => params[:playlist])
          if !playlist.nil?

            user_id = params[:wall]
            if user_id < 1
              user_id = current_user.id
            end

            user = User.find_by(:id => user_id)

            if !user.nil?
              wall = ::Wall.new(
                user_id: user_id,
                author_id: current_user.id,
                status: 1,
                privacy: current_user.wall_privacy,
                wallposting: playlist
              )
              if wall.save!
                response = { status: 201, message: 'Playlist shared', content: Entities::Wall.represent(wall, current_user: current_user, commnet_limit: 5) }
              else
                response = { status: 409, message: 'Failed to share playlist', content: nil }
              end
            else
              response = { status: 404, message: 'User not found', content: nil }
            end
          else
            response = { status: 404, message: 'Playlist not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :playlist, type: Integer
        requires :wall, type: Integer
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          wall = ::Wall.find_by(:id => params[:id], :author_id => current_user.id)
          if !wall.nil?
            if wall.delete!
              response = { status: 200, message: 'Wall post removed', content: nil }
            else
              response = { status: 409, message: 'Failed to remove wall post', content: nil }
            end
          else
            response = { status: 404, message: 'Wall post not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'playlists/:playlist/groups/:group/share/:id' do
      params do
        requires :playlist, type: Integer
        requires :group, type: Integer
        optional :content, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          playlist = ::Playlist.find_by(:id => params[:playlist])
          if !playlist.nil?

            members = GroupMember.where group_id: params[:group], user_id: current_user.id
            moderators = GroupModerator.where group_id: params[:group], user_id: current_user.id
            if !members.empty? || !moderators.empty?

              _content = params[:content].nil? ? nil : params[:content]
              post = ::GroupPost.new(content: _content, group_id: params[:group], status: 1, user_id: current_user.id, groupposting: playlist)
              if post.save

                group = Group.find params[:group]
                group.touch
                response = { status: 201, message: 'Playlist shared', content: Entities::Group::GroupPost.represent(post, current_user: current_user, commnet_limit: 5) }
              else
                response = { status: 409, message: 'Failed to share playlist', content: nil }
              end
            else
              response = { status: 409, message: 'You are not in this group', content: nil }
            end
          else
            response = { status: 404, message: 'Playlist not found', content: nil }
          end
        end

        return response
      end

      params do
        requires :playlist, type: Integer
        requires :group, type: Integer
        requires :id, type: Integer
      end
      delete do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          post = ::GroupPost.find_by(:id => params[:id], :user_id => current_user.id)
          if !post.nil?
            if post.destroy!
              response = { status: 200, message: 'Group post removed', content: nil }
            else
              response = { status: 409, message: 'Failed to remove group post', content: nil }
            end
          else
            response = { status: 404, message: 'Group post not found', content: nil }
          end
        end

        return response
      end
    end

    namespace 'playlists/:playlist/addtomine' do
      params do
        requires :playlist, type: Integer
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          playlist = ::Playlist.find_by(:id => params[:playlist])
          if !playlist.nil?

            if playlist.user_id != current_user.id

              new_playlist = playlist.dup
              new_playlist.id = nil
              playlist.playlist_resources.each do |resource|
                tmp_resouce = resource.dup
                tmp_resouce.playlist_id = nil
                new_playlist.playlist_resources << tmp_resouce
              end
              new_playlist.user_id = current_user.id
              if new_playlist.save!
                response = { status: 201, message: 'Playlist added to your collection', content: Entities::Playlist.represent(new_playlist) }
              else
                response = { status: 409, message: 'Failed to add the playlist', content: nil }
              end
            else
              response = { status: 409, message: 'You are already the owner of this playlist', content: Entities::Playlist.represent(playlist) }
            end
          else
            response = { status: 404, message: 'Playlist not exists', content: nil }
          end
        end

        return response
      end
    end

  end
end
