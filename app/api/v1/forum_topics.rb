module V1
  class ForumTopics < Grape::API
    prefix 'api'

    namespace 'forum-topics/:forum_topic_id' do
      params do
        requires :forum_topic_id, type: String
        optional :postLimit, type: Integer
        optional :commentLimit, type: Integer
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
          topic_id = params[:forum_topic_id]
          topic = ::ForumTopic.find_by_id(topic_id)
          commentLimit = params[:commentLimit].nil? ? 5 : params[:commentLimit]
          postLimit = params[:postLimit].nil? ? 5 : params[:postLimit]

          response = nil

          if !topic.nil?
            # topic.isowner = current_user.id === topic.user.id ? true : false
            response = {
              status: 200,
              message: '',
              content: Entities::TopicDetail.represent(topic, current_user: current_user, post_limit: postLimit, commnet_limit: commentLimit)
            }
          else
            response = {
              status: 404,
              message: 'Topic not found',
              content: nil
            }
          end
          response
        end
    end

    namespace 'forums/:forum_id/forum-topics/:topic_id' do
      params do
        requires :forum_id, type: Integer
        requires :topic_id, type: Integer
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
        forumtopics = ForumTopic.where id: params[:topic_id], user_id: user_id
        if forumtopics.present? || current_user.admin? || current_user.super_admin?

          topic = ForumTopic.find_by_id params[:topic_id]

          unless topic.nil?
            if topic.destroy!
              return {
                status: 200,
                message: 'Topic deleted',
                content: nil
              }
            else
              return {
                status: 301,
                message: 'Failed to delete topic',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Topic not found',
              content: nil
            }
          end
        else
          return {
            status: 404,
            message: 'Permission denied',
            content: nil
          }
        end
      end
    end



    namespace 'forums/:forum_topic_id/forum-topics' do

      params do
        requires :page, type: Integer
        requires :limit, type: Integer
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
          topic_id = params[:forum_topic_id]
          subforum = ::SubForum.find_by_id(topic_id)
          if subforum.nil?
            return {
                status: 301,
                message: 'Sub forum not found',
                content: ''
            }
          end
          topics = subforum.forum_topics.where('status = true').order(created_at: :desc, id: :asc).page(params[:page]).per(params[:limit])
          if topics.nil?
          return {
                status: 301,
                message: 'Topic not found',
                content: ''
            }
          end
          topics.each do |topic|
            if topic.forum_moderators.count > 0 && topic.forum_moderators.first.user_id === user_id
              topic.isowner = true
              next
            else
              topic.isowner = false
            end
          end

          {
            status: 200,
            message: '',
            content: Entities::ForumTopic.represent(topics)
          }
        end

      params do
        requires :description, type: String
        requires :status, type: Integer
        requires :privacy, type: Integer
        requires :title, type: String
        optional :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
        optional :short_description, type: String
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
        topic_id = params[:forum_topic_id]
        topic = ::SubForum.find_by_id(topic_id)
        if topic.nil?
            return {
                status: 301,
                message: 'Sub forum not found',
                content: ''
            }
        end
        forum = ForumTopic.new(description: params[:description], status: params[:status], privacy: params[:privacy], title: params[:title], user_id: user_id)
        forum.sub_forum = topic

        if !params[:image].nil?
          _banner_img = Rich::RichFile.new(simplified_type: 'image')
          _file_attrs = params[:image]
          _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
          _banner_img.rich_file = _file_params
          forum.image = _banner_img
        end

        if forum.save
          # make him a moderator
          moderator = ForumModerator.new(forum_id: forum.id, user_id: user_id)
          # make her a member
          member = ForumMember.new(forum_id: forum.id, user_id: user_id)
          if moderator.save && member.save

            moderators = ForumModerator.where forum_id: forum.id
            moderators.each do |moderator|
              if moderator.user_id === user_id
                forum.ismoderator = true
                break
              else
                forum.ismoderator = false
              end
            end

            members = ForumMember.where forum_id: forum.id
            members.each do |member|
              if member.user_id === user_id
                forum.isowner = true
                break
              else
                forum.isowner = false
              end
            end

            return {
              status: 200,
              message: 'Topic created',
              content: Entities::ForumTopic.represent(forum)
            }
          else
            forum.delete
            return {
              status: 301,
              message: 'moderator not assigned',
              content: nil
            }
          end
        else
          return {
            status: 301,
            message: 'Topic not created',
            content: nil
          }
        end
      end

      params do
        requires :id, type: Integer
        requires :description, type: String
        requires :status, type: Integer
        requires :privacy, type: Integer
        requires :title, type: String
        optional :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
        optional :short_description, type: String
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
         forumtopics = ForumTopic.where id: params[:id], user_id: user_id
         if forumtopics.present? || current_user.admin? || current_user.super_admin?
          topic = ForumTopic.find_by_id params[:id]
          if !topic.nil?

            success = false

            if !params[:image].nil?
              _banner_img = Rich::RichFile.new(simplified_type: 'image')
              _file_attrs = params[:image]
              _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
              _banner_img.rich_file = _file_params

              success = topic.update(description: params[:description], status: params[:status], privacy: params[:privacy], title: params[:title], image: _banner_img)
            else
              success = topic.update(description: params[:description], status: params[:status], privacy: params[:privacy], title: params[:title])
            end

            moderators = ForumModerator.where forum_id: topic.id
            moderators.each do |moderator|
              if moderator.user_id === user_id
                topic.ismoderator = true
                break
              else
                topic.ismoderator = false
              end
            end

            members = ForumMember.where forum_id: topic.id
            members.each do |member|
              if member.user_id === user_id
                topic.ismember = true
                break
              else
                topic.ismember = false
              end
            end

            if success
              return {
                status: 200,
                message: 'Topic updated',
                content: Entities::TopicDetail.represent(topic, current_user: current_user)
              }
            else
              return {
                status: 301,
                message: 'Failed to update forum',
                content: nil
              }
            end
          else
            return {
              status: 404,
              message: 'Forums not found',
              content: nil
            }
          end
        else
          return {
            status: 400,
            message: 'Permission denied',
            content: nil
          }
        end
      end


    # resource :forums do
    #   params do
    #     requires :id, type: Integer
    #   end
    #   delete do
    #     authenticate_user
    #     unless authenticated?
    #       return {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     user_id = current_user.id
    #     # user_id = 110
    #     moderators = ForumModerator.where forum_id: params[:id], user_id: user_id
    #     if !moderators.empty?
    #       forum = Forum.find_by_id params[:id]
    #       if !forum.nil?
    #         if forum.delete
    #           return {
    #             status: 200,
    #             message: 'Forums deleted',
    #             content: nil
    #           }
    #         else
    #           return {
    #             status: 301,
    #             message: 'Failed to delete forum',
    #             content: nil
    #           }
    #         end
    #       else
    #         return {
    #           status: 404,
    #           message: 'Forums not found',
    #           content: nil
    #         }
    #       end
    #     else
    #       return {
    #         status: 404,
    #         message: 'You are not a moderator',
    #         content: nil
    #       }
    #     end
    #   end
    # end


    # namespace 'topics/:id/image' do
    #   params do
    #     requires :id, type: Integer
    #     requires :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
    #   end
    #   post do
    #     response = nil
    #     authenticate_user
    #     unless authenticated?
    #       response = {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     user_id = current_user.id
    #     # user_id = 110

    #     moderators = ForumModerator.where forum_id: params[:id], user_id: user_id
    #     if !moderators.empty?
    #       forum = Forum.find params[:id]
    #       if !forum.nil?
    #         # new_file = ActionDispatch::Http::UploadedFile.new(params[:image])
    #         _banner_img = Rich::RichFile.new(simplified_type: 'image')
    #         _file_attrs = params[:image]
    #         _file_params = Rack::Multipart::UploadedFile.new _file_attrs[:tempfile].path, _file_attrs[:type]
    #         _banner_img.rich_file = _file_params
    #         forum.image = _banner_img
    #         success = forum.save!

    #         moderators = ForumModerator.where forum_id: forum.id
    #         moderators.each do |moderator|
    #           if moderator.user_id === user_id
    #             forum.ismoderator = true
    #             break
    #           else
    #             forum.ismoderator = false
    #           end
    #         end

    #         members = ForumMember.where forum_id: forum.id
    #         members.each do |member|
    #           if member.user_id === user_id
    #             forum.ismember = true
    #             break
    #           else
    #             forum.ismember = false
    #           end
    #         end

    #         success = true

    #         if success
    #           response = {
    #             status: 200,
    #             message: 'Forum image updated',
    #             content: Entities::Forums.represent(forum)
    #           }
    #         else
    #           response = {
    #             status: 200,
    #             message: 'Failed to update forum image',
    #             content: Entities::Forums.represent(forum)
    #           }
    #         end
    #       else
    #         response = {
    #           status: 404,
    #           message: 'Forum not found',
    #           content: nil
    #         }
    #       end
    #     else
    #       response = {
    #         status: 400,
    #         message: 'You are not a moderator of this forum',
    #         content: nil
    #       }
    #     end
    #     return response

    #   end
    # end

    # namespace 'topics/:type' do
    #   params do
    #     requires :type, type: String
    #     requires :page, type: Integer
    #     requires :limit, type: Integer
    #     optional :order, type: String
    #   end
    #   get do
    #     authenticate_user
    #     unless authenticated?
    #       return {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     user_id = current_user.id
    #     # user_id = 110
    #     forums = []

    #     case params[:type]
    #     when "all"
    #       if !params[:order].nil?
    #         case params[:order]
    #         when 'asc'
    #           forums = Forum.all.order(created_at: :asc).page(params[:page]).per(params[:limit])
    #         when 'updated'
    #           forums = Forum.all.order(updated_at: :desc).page(params[:page]).per(params[:limit])
    #         else
    #           forums = Forum.all.order(created_at: :desc).page(params[:page]).per(params[:limit])
    #         end
    #       else
    #         forums = Forum.all.order(created_at: :desc).page(params[:page]).per(params[:limit])
    #       end
    #     when "my"
    #       # moderators = (GroupModerator.where user: current_user.id)
    #       forums = current_user.forums.order(created_at: :desc).page(params[:page]).per(params[:limit])
    #       # moderators = (GroupModerator.where user: user_id)
    #       # moderators.each do |moderator|
    #       #   groups << Group.find_by(id: moderator.group_id)
    #       # end
    #     else
    #       forums = nil
    #     end

    #     forums.each do |forum|
    #       moderators = ForumModerator.where group_id: forum.id
    #       moderators.each do |moderator|
    #         if moderator.user_id === user_id
    #           forum.ismoderator = true
    #           break
    #         else
    #           forum.ismoderator = false
    #         end
    #       end

    #       members = ForumMember.where forum_id: forum.id
    #       members.each do |member|
    #         if member.user_id === user_id
    #           forum.ismember = true
    #           break
    #         else
    #           forum.ismember = false
    #         end
    #       end

    #       forum.membercount = members.count
    #     end

    #     if !forums.nil? && forums.count > 0
    #       return {
    #         status: 200,
    #         message: 'Forums found',
    #         content: Entities::Forums.represent(forums)
    #       }
    #     else
    #       return {
    #         status: 200,
    #         message: 'Forums not found',
    #         content: nil
    #       }
    #     end
    #   end
    # end

    # namespace 'topics/:id/join' do
    #   params do
    #     requires :id, type: Integer
    #   end
    #   post do
    #     response = nil
    #     authenticate_user
    #     unless authenticated?
    #       return {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     user_id = current_user.id
    #     # user_id = 110
    #     forum = Forum.find_by id: params[:id]
    #     if !forum.nil?
    #       exmembers = ForumMember.where forum_id: params[:id], user_id: user_id
    #       if exmembers.empty?
    #         member = ForumMember.new(forum_id: params[:id], user_id: user_id)
    #         if member.save

    #           # check ismember
    #           members = ForumMember.where forum_id: forum.id
    #           members.each do |member|
    #             if member.user_id === user_id
    #               forum.ismember = true
    #               break
    #             else
    #               forum.ismember = false
    #             end
    #           end

    #           response = {
    #             status: 200,
    #             message: 'You have successfully joined the forum',
    #             content: Entities::Forums.represent(forum)
    #           }
    #         else
    #           response = {
    #             status: 300,
    #             message: 'Failed to joined the forum',
    #             content: nil
    #           }
    #         end
    #       else
    #         response = {
    #           status: 200,
    #           message: 'You are already a member',
    #           content: Entities::Forums.represent(forum)
    #         }
    #       end
    #     else
    #       response = {
    #         status: 404,
    #         message: 'Forum not found',
    #         content: nil
    #       }
    #     end
    #     return response
    #   end

    #   params do
    #     requires :id, type: Integer
    #   end
    #   delete do
    #     response = nil
    #     authenticate_user
    #     unless authenticated?
    #       return {
    #         status: 401,
    #         message: 'Unauthorized',
    #         content: ''
    #       }
    #     end
    #     user_id = current_user.id
    #     # user_id = 110
    #     forum = Forum.find_by id: params[:id]
    #     if !forum.nil?
    #       exmembers = ForumMember.where forum_id: params[:id], user_id: user_id
    #       if !exmembers.empty?
    #         member = exmembers.first
    #         if member.delete

    #           # check ismember
    #           members = ForumMember.where forum_id: forum.id
    #           members.each do |member|
    #             if member.user_id === user_id
    #               forum.ismember = true
    #               break
    #             else
    #               forum.ismember = false
    #             end
    #           end

    #           response = {
    #             status: 200,
    #             message: 'You have left the forum',
    #             content: Entities::Forums.represent(forum)
    #           }
    #         else
    #           response = {
    #             status: 300,
    #             message: 'Failed to leave the forum',
    #             content: nil
    #           }
    #         end
    #       else
    #         response = {
    #           status: 200,
    #           message: 'You are not a member of this forum',
    #           content: nil
    #         }
    #       end
    #     else
    #       response = {
    #         status: 404,
    #         message: 'Forum not found',
    #         content: nil
    #       }
    #     end
    #     return response
    #   end
    # end
   end
  end
end
