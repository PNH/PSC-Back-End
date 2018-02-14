module V1
  module Entities
    class Wall < Grape::Entity
      expose :id, :status, :updated_at, :created_at, :user_id, :wallposting_type, :privacy
      # expose :user do |instance|
      #   unless instance.user.nil?
      #   owner = {
      #     'id' => instance.user.id,
      #     'firstName' => instance.user.first_name,
      #     'lastName' => instance.user.last_name,
      #     'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('original')
      #   }
      #   else
      #   owner = {
      #     'id' => 0,
      #     'firstName' => 'Deleted',
      #     'lastName' => 'User',
      #     'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
      #   }
      #   end
      # end
      expose :author do |instance|
        unless instance.author.nil?
        owner = {
          'id' => instance.author.id,
          'firstName' => instance.author.first_name,
          'lastName' => instance.author.last_name,
          'profileImage' => instance.author.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.author.profile_picture.rich_file.url('thumb')
        }
        else
        owner = {
          'id' => 0,
          'firstName' => 'Deleted',
          'lastName' => 'User',
          'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
        }
        end
      end

      expose :wallposting do |instance, _options|
        case instance.wallposting_type
        when 'WallPost'
         {
          'ref_id' => instance.wallposting.id,
          'content' => instance.wallposting.content,
          'status' => instance.wallposting.status
         }

        when "HorseProgress"
          progress = nil
          logs = []
          if !instance.wallposting.nil?
            instance.wallposting.horse_progress_logs.each do |log|
              logs << {
                :savvy => log.savvy,
                :level => log.level,
                :time => log.time
              }
            end
          end

          progress = {
            :id => instance.wallposting.id,
            :note => instance.wallposting.note,
            :horse => V1::Entities::Horse.represent(instance.wallposting.horse),
            :logs => logs
          }

          progress

        when "HorseHealth"
          health = nil
          if !instance.wallposting.nil?
            object = instance.wallposting
            health = {
              :id => instance.wallposting.id,
              :healthType => { object.health_type => ::HorseHealth.health_types[object.health_type] },
              :provider => object.provider,
              :visit => object.visit,
              :nextVisit => object.next_visit,
              :visitType => { object.visit_type => ::HorseHealth.visit_types[object.visit_type] },
              :note => object.note,
              :assessment => object.assessment,
              :treatmentOutcome => object.treatment_outcome,
              :treatmentCare => object.post_treatment_care,
              :recommendations => object.recommendations,
              :horse => V1::Entities::Horse.represent(object.horse)
            }
          end
          health

        when "Playlist"
          current_user = _options[:current_user]
          playlist = nil
          if !instance.wallposting.nil?
            playlist = {
              :id => instance.wallposting.id,
              :title => instance.wallposting.title,
              :resources => Entities::PlaylistResource.represent(instance.wallposting.playlist_resources, current_user: current_user)
            }
          end
          playlist

	       when "WallSolutionmapPost"
           post = nil
           post = {
             :id => instance.wallposting.id,
             :note => instance.wallposting.note,
             :horse => V1::Entities::Horse.represent(instance.wallposting.horse),
             :poster => instance.wallposting.poster.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.wallposting.poster.url('original'),
           }

           post

        end
      end

      expose :likes do |instance|
        instance.wall_post_like.count
      end

      expose :liked do |instance,_options|
        current_user = _options[:current_user]
        posts = ::WallPostLike.where(user_id: current_user.id, wall_id: instance.id)
        posts.present? ? true : false
      end

      expose :comment_count do |instance|
        instance.wall_post_comment.count
      end

      expose :wall_post_attachment do |instance|
        attachments = []
        instance.wall_post_attachment.each do |attachment|
          if attachment.resource.present?
            attachments.push(
              'id' => attachment.id,
              'wall_post_id' => attachment.wall_id,
              'title' => attachment.resource.rich_file_file_name,
              'resourceUrl' => attachment.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : attachment.resource.rich_file.url('original'),
              'status' => attachment.status
            )
          end
        end
        attachments
      end

      expose :isowner do |instance, _options|
        current_user = _options[:current_user]
        instance.author.present? && current_user.id == instance.author.id ? true : false
      end

      expose :wall_post_comment do |instance, options|
        current_user = options[:current_user]
        commnet_limit = options[:commnet_limit].nil? ? 5 : options[:commnet_limit]
        _comments = instance.wall_post_comment.order(created_at: :desc).limit(commnet_limit)
        response = V1::Entities::Wall::WallPostComments.represent(_comments, current_user: current_user)
        # instance.wall_post_comment.order(created_at: :desc).limit(commnet_limit).each do |comment|
        #   _comObj = {
        #     'id' => comment.id,
        #     'wall_post_id' => comment.wall_id,
        #     'comment' => comment.comment,
        #     'parent_id' => comment.parent_id,
        #     'created_at' => comment.created_at,
        #     'user_id' => instance.user_id,
        #     'isowner' => current_user.id === comment.user_id ? true : false
        #   }
        #   unless comment.user.nil?
        #   _userObj = {
        #     'id' => comment.user.id,
        #     'firstName' => comment.user.first_name,
        #     'lastName' => comment.user.last_name,
        #     'profileImage' => comment.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : comment.user.profile_picture.rich_file.url('original')
        #   }
        #   else
        #   _userObj = {
        #     'id' => 0,
        #     'firstName' => 'Deleted',
        #     'lastName' => 'User',
        #     'profileImage' =>  Rails.application.config.s3_source_path + 'default/UserDefault.png'
        #   }
        #   end
        #   _comObj[:user] = _userObj
        #   comments.push(
        #     _comObj
        #   )
        # end
        response
      end

      class WallPostLikes < Grape::Entity
        expose :id, :user_id, :status
      end

      class WallPostComments < Grape::Entity
        expose :id, :comment, :parent_id, :updated_at, :created_at, :user_id
        expose :owner, as: :user do |instance|
          unless instance.user.nil?
          owner = {
            'id' => instance.user.id,
            'firstName' => instance.user.first_name,
            'lastName' => instance.user.last_name,
            'profileImage' => instance.user.profile_picture.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.user.profile_picture.rich_file.url('thumb')
          }
        else
          owner = {
            'id' => 0,
            'firstName' => 'Deleted',
            'lastName' => 'User',
            'profileImage' => Rails.application.config.s3_source_path + 'default/UserDefault.png'
          }
        end
        end
        expose :isowner do |instance, options|
          current_user = options[:current_user]
          instance.user.present? && current_user.id === instance.user.id ? true : false
        end
        expose :attachments do |instance, options|
          V1::Entities::Wall::WallPostCommentAttachments.represent(instance.wall_post_comment_attachments)
        end
      end

      class WallPostCommentAttachments < Grape::Entity
        expose :id
        expose :resource, as: :attachment do |instance|
          instance.resource.nil? ? Rails.application.config.s3_source_path + 'default/UserDefault.png' : instance.resource.rich_file.url('original')
        end
        expose 'type' do |instance|
          instance.resource.nil? ? nil : instance.resource.rich_file_content_type
        end
      end

    end
  end
end
