module V1
  class Groups < Grape::API
    prefix 'api'

    namespace 'groups/:id' do
      params do
        requires :id, type: Integer
      end
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          group = Group.find_by(id: params[:id])
          if !group.nil?
            response = { status: 200, message: 'Group Found', content: Entities::Group.represent(group, current_user: current_user) }
          else
            response = { status: 404, message: 'Group Not Found', content: nil }
          end
        end
        return response
      end

      params do
        requires :description, type: String
        requires :status, type: Integer
        requires :privacyLevel, type: Integer
        requires :title, type: String
        optional :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
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
        user_id = current_user.id
        # user_id = 110

        group = Group.new(description: params[:description], status: params[:status], privacy_level: params[:privacyLevel], title: params[:title])

        if !params[:image].nil?
          _banner_img = Rich::RichFile.new(simplified_type: 'image')
          # _banner_img.id = Rich::RichFile.last.id + 1
          _file_attrs = params[:image]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          _banner_img.rich_file = _file_params
          group.image = _banner_img
        end

        if group.save
          # make him a moderator
          moderator = GroupModerator.new(group_id: group.id, user_id: user_id)
          # make her a member
          member = GroupMember.new(group_id: group.id, user_id: user_id)
          if moderator.save && member.save

            moderators = GroupModerator.where group_id: group.id
            moderators.each do |moderator|
              if moderator.user_id === user_id
                group.ismoderator = true
                break
              else
                group.ismoderator = false
              end
            end

            members = GroupMember.where group_id: group.id
            members.each do |member|
              if member.user_id === user_id
                group.ismember = true
                break
              else
                group.ismember = false
              end
            end

            return {
              status: 200,
              message: 'Groups created',
              content: Entities::Group.represent(group, current_user: current_user)
            }
          else
            GroupModerator.where(group_id: group.id, user_id: user_id).delete_all
            GroupMember.where(group_id: group.id, user_id: user_id).delete_all
            group.destroy
            return {
              status: 301,
              message: 'moderator not assigned',
              content: nil
            }
          end
        else
          return {
            status: 301,
            message: group.errors.full_messages,
            content: nil
          }
        end
      end

      params do
        requires :id, type: Integer
        requires :description, type: String
        requires :status, type: Integer
        requires :privacyLevel, type: Integer
        requires :title, type: String
        optional :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
      end
      put do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110
        moderators = GroupModerator.where group_id: params[:id], user_id: user_id
        if !moderators.empty?
          group = Group.find_by_id params[:id]
          if !group.nil?

            success = false

            if !params[:image].nil?
              _banner_img = Rich::RichFile.new(simplified_type: 'image')
              # _banner_img.id = Rich::RichFile.last.id + 1
              _file_attrs = params[:image]
              _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
              _banner_img.rich_file = _file_params

              success = group.update(description: params[:description], status: params[:status], privacy_level: params[:privacyLevel], title: params[:title], image: _banner_img)
            else
              success = group.update(description: params[:description], status: params[:status], privacy_level: params[:privacyLevel], title: params[:title])
            end

            moderators = GroupModerator.where group_id: group.id
            moderators.each do |moderator|
              if moderator.user_id === user_id
                group.ismoderator = true
                break
              else
                group.ismoderator = false
              end
            end

            members = GroupMember.where group_id: group.id
            members.each do |member|
              if member.user_id === user_id
                group.ismember = true
                break
              else
                group.ismember = false
              end
            end

            if success
              return {
                status: 200,
                message: 'Groups updated',
                content: Entities::Group.represent(group, current_user: current_user)
              }
            else
              return {
                status: 301,
                message: group.errors.full_messages,
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Groups not found',
              content: nil
            }
          end
        else
          return {
            status: 400,
            message: 'You are not a group moderator',
            content: nil
          }
        end
      end

      params do
        requires :id, type: Integer
      end
      delete do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110
        moderators = GroupModerator.where group_id: params[:id], user_id: user_id
        if !moderators.empty?
          group = Group.find_by_id params[:id]
          if !group.nil?
            if group.destroy
              return {
                status: 200,
                message: 'Groups deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete group',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Groups not found',
              content: nil
            }
          end
        else
          return {
            status: 404,
            message: 'You are not a moderator',
            content: nil
          }
        end
      end
    end

    namespace 'groups/:id/image' do
      params do
        requires :id, type: Integer
        requires :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
      end
      post do
        response = nil
        authenticate_user
        unless authenticated?
          response = {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110

        moderators = GroupModerator.where group_id: params[:id], user_id: user_id
        if !moderators.empty?
          group = Group.find params[:id]
          if !group.nil?
            # new_file = ActionDispatch::Http::UploadedFile.new(params[:image])
            _banner_img = Rich::RichFile.new(simplified_type: 'image')
            _file_attrs = params[:image]
            _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
            _banner_img.rich_file = _file_params
            group.image = _banner_img
            success = group.save!

            moderators = GroupModerator.where group_id: group.id
            moderators.each do |moderator|
              if moderator.user_id === user_id
                group.ismoderator = true
                break
              else
                group.ismoderator = false
              end
            end

            members = GroupMember.where group_id: group.id
            members.each do |member|
              if member.user_id === user_id
                group.ismember = true
                break
              else
                group.ismember = false
              end
            end

            success = true

            if success
              response = {
                status: 200,
                message: 'Group image updated',
                content: Entities::Group.represent(group, current_user: current_user)
              }
            else
              response = {
                status: 200,
                message: 'Failed to update group image',
                content: Entities::Group.represent(group, current_user: current_user)
              }
            end
          else
            response = {
              status: 404,
              message: 'Group not found',
              content: nil
            }
          end
        else
          response = {
            status: 400,
            message: 'You are not a moderator of this group',
            content: nil
          }
        end
        return response

      end
    end

    namespace 'groups/:type/filtered' do
      params do
        requires :type, type: String
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :order, type: String
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
        user_id = current_user.id
        # user_id = 110
        groups = []

        case params[:type]
        when "all"
          if !params[:order].nil?
            case params[:order]
            when 'asc'
              groups = Group.where(status: true).order(created_at: :asc, id: :asc).page(params[:page]).per(params[:limit])
            when 'updated'
              groups = Group.where(status: true).order(updated_at: :desc, id: :asc).page(params[:page]).per(params[:limit])
            else
              groups = Group.where(status: true).order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])
            end
          else
            groups = Group.where(status: true).order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])
          end
        when "my"
          # moderators = (GroupModerator.where user: current_user.id)
          groups = current_user.group.order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])
          # moderators = (GroupModerator.where user: user_id)
          # moderators.each do |moderator|
          #   groups << Group.find_by(id: moderator.group_id)
          # end
        else
          groups = nil
        end

        # groups.each do |group|
        #   # moderators = GroupModerator.where group_id: group.id
        #   # moderators.each do |moderator|
        #   #   if moderator.user_id === user_id
        #   #     group.ismoderator = true
        #   #     break
        #   #   else
        #   #     group.ismoderator = false
        #   #   end
        #   # end
        #   #
        #   # members = GroupMember.where group_id: group.id
        #   # members.each do |member|
        #   #   if member.user_id === user_id
        #   #     group.ismember = true
        #   #     break
        #   #   else
        #   #     group.ismember = false
        #   #   end
        #   # end
        #
        #   # group.membercount = members.count
        # end

        if !groups.nil? && groups.count > 0
          return {
            status: 200,
            message: 'Groups found',
            content: Entities::Group.represent(groups, current_user: current_user)
          }
        else
          return {
            status: 200,
            message: 'Groups not found',
            content: nil
          }
        end
      end
    end

    namespace 'groups/:id/join' do
      params do
        requires :id, type: Integer
      end
      post do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110
        group = Group.find_by id: params[:id]
        if !group.nil?
          exmembers = GroupMember.where group_id: params[:id], user_id: user_id
          if exmembers.empty?
            member = GroupMember.new(group_id: params[:id], user_id: user_id)
            if member.save

              # check ismember
              members = GroupMember.where group_id: group.id
              members.each do |member|
                if member.user_id === user_id
                  group.ismember = true
                  break
                else
                  group.ismember = false
                end
              end

              response = {
                status: 200,
                message: 'You have successfully joined the group',
                content: Entities::Group.represent(group, current_user: current_user)
              }
            else
              response = {
                status: 300,
                message: 'Failed to joined the group',
                content: nil
              }
            end
          else
            response = {
              status: 200,
              message: 'You are already a member',
              content: Entities::Group.represent(group, current_user: current_user)
            }
          end
        else
          response = {
            status: 404,
            message: 'Group not found',
            content: nil
          }
        end
        return response
      end

      params do
        requires :id, type: Integer
      end
      delete do
        response = nil
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user_id = current_user.id
        # user_id = 110
        group = Group.find_by id: params[:id]
        if !group.nil?
          exmembers = GroupMember.where group_id: params[:id], user_id: user_id
          if !exmembers.empty?
            member = exmembers.first
            if member.delete

              # check ismember
              members = GroupMember.where group_id: group.id
              members.each do |member|
                if member.user_id === user_id
                  group.ismember = true
                  break
                else
                  group.ismember = false
                end
              end

              response = {
                status: 200,
                message: 'You have left the group',
                content: Entities::Group.represent(group, current_user: current_user)
              }
            else
              response = {
                status: 300,
                message: 'Failed to leave the group',
                content: nil
              }
            end
          else
            response = {
              status: 200,
              message: 'You are not a member of this group',
              content: nil
            }
          end
        else
          response = {
            status: 404,
            message: 'Group not found',
            content: nil
          }
        end
        return response
      end
    end

    namespace 'user/groups/search' do
      params do
        requires :query, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?

          query = params[:query].downcase
          groups = Group.joins(:group_members).where("lower(title) LIKE ?", "%#{query}%").where(group_members: {:user_id => current_user.id}).order(title: :desc).limit(10)
          if groups.count > 0
            response = { status: 200, message: "#{groups.count} group(s) found", content: Entities::Group.represent(groups, current_user: current_user) }
          else
            response = { status: 200, message: 'No results', content: nil }
          end
        end

        return response
      end
    end
  end
end
