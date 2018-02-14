# frozen_string_literal: true
module V1
  module Entities
    class FullSearch < Grape::Entity
      expose :id
      expose :searchable_type, as: :type
      expose :content
      expose :object do |instance, options|
        current_user = options[:current_user]
        _object = nil
        case instance.searchable_type
        when "User"
          _user = instance.searchable
          if _user
            _object = Entities::User.userPublicMiniTemplate(_user, current_user)
          end
        when "Event"
          _event = instance.searchable
          if _event
            _object = Entities::Events.represent(_event, current_user: current_user)
          end
        when "Group"
          _group = instance.searchable
          if _group
            _object = Entities::Group.represent(_group, current_user: current_user)
          end
        when "Lesson"
          _lesson = instance.searchable
          if _lesson
            _object = Entities::Lesson.represent(_lesson, current_user: current_user)
          end
        when "LearngingLibrary"
          _learninglib = instance.searchable
          if _learninglib
            case _learninglib.file_type
            when LearngingLibrary.file_types[:MP4]
              _object = Entities::LearningLibrary::Video.represent(_learninglib, current_user: current_user)
            when LearngingLibrary.file_types[:MP3]
              _object = Entities::LearningLibrary::Audio.represent(_learninglib, current_user: current_user)
            else
              _object = Entities::LearningLibrary::Document.represent(_learninglib, current_user: current_user)
            end
          end
        when "Forum"
          _forum = instance.searchable
          if _forum
            _object = Entities::Forums.represent(_forum, current_user: current_user)
          end
        when "Blog"
          _blog = instance.searchable
          if _blog
            _blog
          end
        when "ForumTopic"
          _forum_topic = instance.searchable
          if _forum_topic
            _object = Entities::ForumTopic.represent(_forum_topic, current_user: current_user)
          end

        end

        _object
      end
    end
  end
end
