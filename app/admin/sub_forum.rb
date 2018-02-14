# frozen_string_literal: true
ActiveAdmin.register SubForum do

  belongs_to :forum, optional: true

  menu false
  navigation_menu do
    :default
  end

  permit_params :title, :description, :privacy, :user_id, :status
  filter :title_cont, label: 'By Title'
  # filter :user, label: 'User Name', collection: proc { User.where.not(role: User.roles.values_at(:guest)) }

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',       "/admin"),
     link_to('Forums',      "/admin/forums"),
     link_to('Sub Forums',  "/admin/forums/#{params[:forum_id]}/sub_forums")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:forum_id]
    }
    # byebug
    session[:breadcrumb][:forum] = data
  end

  form do |f|
    f.inputs do
      f.object.status = true if f.object.status.nil?
      f.object.user = current_admin_user if f.object.user.nil?
      f.input :title
      # f.input :description
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }, :checked => ['Active', true]
      f.input :user_id, as: :hidden
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Sub Forum')
      else
        f.action(:submit, label: 'Update Sub Forum')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  # before_destroy do |sub_topic|
  #   if sub_topic.forum_topics.count > 0
  #     # errors.add(:base, I18n.t('model.validation.product_has_still_topics_assigned'))
  #     return false
  #   end
  # end

  # private

  index do
    column :id
    column :title
    column('Topics') do |subforum|
      link_to subforum.forum_topics.count, admin_sub_forum_forum_topics_path(subforum)
    end
    column('User') { |t| t.user.nil? ? '' : t.user.name }
    actions
  end


end
