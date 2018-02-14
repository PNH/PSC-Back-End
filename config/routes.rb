# frozen_string_literal: true

Rails.application.routes.draw do
  resources :group_post_comment_attachments
  resources :forum_post_comment_attachments
  resources :wall_post_comment_attachments
  resources :page_attachments
  resources :user_instructors
  resources :user_equestrain_interests
  resources :membership_cancellations
  resources :horse_healths
  resources :horse_progress_logs
  resources :horse_progresses
  resources :wall_solutionmap_posts
  resources :blog_moderators
  resources :event_category_mappings
  resources :event_categories
  resources :event_participants
  resources :event_pricings
  resources :event_instructors
  resources :event_organizers
  resources :event_locations
  # resources :events

  get 'api/v1/events/countries' => 'events#getCountries', :defaults => { :format => 'json' }
  get 'api/v1/events/countries/:code' => 'events#getStates', :defaults => { :format => 'json' }

  # resources :user_connections
  resources :group_post_likes
  resources :group_post_attachments
  resources :group_post_comments
  resources :group_posts
  resources :level_checklists
  # mount RailsAdmin::Engine => '/admin', as: 'rails_admin
  mount Rich::Engine => '/rich', :as => 'rich'

  root to: 'admin/dashboard#index'

  # devise_for :users
  devise_for :admin_users, {
    class_name: 'User'
  }.merge(ActiveAdmin::Devise.config)

  ActiveAdmin.routes(self)

  mount_devise_token_auth_for 'User', at: 'api/auth', controllers: {
    sessions:  'overrides/sessions',
    token_validations:  'overrides/token_validations',
    passwords: 'overrides/passwords'
  }

  mount API => '/'
  devise_scope :user do
    post '/api/auth/passwords/reset', to: 'overrides/passwords#resetviaemail'
  end
end
