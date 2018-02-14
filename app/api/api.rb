# frozen_string_literal: true
# I know that this code break REST guidelines. but that's what GOD wishes. @oshanz

require 'grape-swagger'

class API < Grape::API
  auth :grape_devise_token_auth, resource_class: :user
  helpers GrapeDeviseTokenAuth::AuthHelpers

  format :json
  prefix 'api'
  version 'v1', using: :path

  mount V1::Testimonials
  mount V1::Settings
  mount V1::ContentBlocks
  mount V1::Goals
  mount V1::Levels
  mount V1::Savvies
  mount V1::LessonCategories
  mount V1::Lessons
  mount V1::Horses
  mount V1::Users
  mount V1::Onboarding
  mount V1::Memberships
  mount V1::LearningLibraries
  mount V1::Playlists
  mount V1::Groups
  mount V1::GroupPosts
  mount V1::ForumTopics
  mount V1::ForumPosts
  mount V1::Forums
  mount V1::Memberminutes
  mount V1::UserConnections
  mount V1::Members
  mount V1::Events
  mount V1::Walls
  mount V1::Notifications
  mount V1::Messages
  mount V1::FullSearch
  mount V1::Privacysettings
  mount V1::Blogs
  mount V1::HorseProgresses
  mount V1::HorseHealths
  mount V1::Pages
  mount V1::Resources
  mount V1::SavvyEssentials
  mount V1::Tags

  add_swagger_documentation
end
