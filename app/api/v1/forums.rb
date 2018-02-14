# frozen_string_literal: true
module V1
  class Forums < Grape::API
    prefix 'api'
      namespace 'forums' do
        get do
          authenticate_user
          unless authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end

          forumtopics = ::Forum.where('parent_id is null and status = true')
          {
            status: 200,
            message: '',
            content: Entities::Forums.represent(forumtopics)
          }
        end
       params do
          requires :description, type: String
          requires :status, type: Boolean
          requires :privacy, type: Integer
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
          user_id = current_user.id
          forum_topic = Forum.new(description: params[:description], status: params[:status], privacy: params[:privacy], title: params[:title], user_id: user_id)

          if forum_topic.save
            return {
              status: 200,
              message: 'Topic created',
              content: Entities::Forums.represent(forum_topic)
            }
          else
            return {
              status: 301,
              message: 'Topic not created',
              content: nil
            }
          end

        end
    end
# select count(distinct (fp.user_id)) as "count" from forum_topics as ft, forums as f, forum_posts as fp, forum_post_comments as fpc where ft.id=3 and ft.id=f.forum_topic_id and f.id=fp.forum_id or fp.id=fpc.forum_post_id group by fpc.user_id, fp.user_id;

# select distinct (u.id), u.first_name as "users" from forum_topics as ft, forum_posts as fp, forum_post_comments as fpc, forums as f, users as u where ft.id=5 and ft.user_id=u.id or f.forum_topic_id=5 and f.id=fp.forum_id and fp.user_id=u.id or f.forum_topic_id=5 and f.id=fp.forum_id and fp.id=fpc.forum_post_id and fpc.user_id=u.id group by u.id;

      namespace 'sub-forums/:sub_forum_id' do
        params do
           requires :sub_forum_id, type: Integer
           optional :postLimit, type: Integer
         end
        get do
          response = { status: 401, message: 'Unauthorized', content: nil }
          authenticate_user
          unless authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
          user_id = current_user.id
          subforum_id = params[:sub_forum_id]
          subforum = SubForum.find_by id: subforum_id

          post_limit = params[:postLimit].nil? ? 5 : params[:postLimit]
          
          if subforum.nil?
            response = {
                status: 301,
                message: 'Sub forum not found',
                content: ''
            }
          else
            response = {
              status: 200,
              message: '',
              content: Entities::SubForums.represent(subforum, current_user: current_user, post_limit: post_limit)
            }
          end
          return response
        end
      end


      namespace 'forums/:forum_id/sub-forums' do
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
          forum_id = params[:forum_id]
          forum = ::Forum.find(forum_id)

          if forum.nil?
            return {
                status: 301,
                message: 'Forum not found',
                content: ''
            }
          else
            sub_forums = forum.sub_forums.where('status = true')
            return {
              status: 200,
              message: '',
              content: Entities::SubForums.represent(sub_forums,current_user: current_user)
            }
          end
        end
         params do
            requires :description, type: String
            requires :status, type: Boolean
            requires :privacy, type: Integer
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

            user_id = current_user.id
            forum_id = params[:forum_id]
            forum = ::ForumTopic.find(forum_id)

            if forum_id.nil?
              return {
                  status: 301,
                  message: 'Forum not found',
                  content: ''
              }
            end

            sub_forum = SubForum.new(description: params[:description], status: params[:status], privacy: params[:privacy], title: params[:title], user_id: user_id, parent_id: topic.id)
            if sub_forum.save
              return {
                status: 200,
                message: 'Sub Forum created',
                content: Entities::SubForums.represent(sub_forum, current_user: current_user)
              }
            else
              return {
                status: 301,
                message: 'Sub Forum not created',
                content: nil
              }
            end
        end
      end

  end
end
