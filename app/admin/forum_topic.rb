ActiveAdmin.register ForumTopic do

  menu :label => "Topics"

  belongs_to :sub_forum
  menu false
  navigation_menu do
    :default
  end

  permit_params :title, :short_description, :description, :position, :status, :user_id, :forum_sub_topic_id, :is_sticky
  filter :title_cont, label: 'By Title'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',       "/admin"),
     link_to('Forums',      "/admin/forums"),
     link_to('Sub Forums',  "/admin/forums/#{session[:breadcrumb]['forum']['id']}/sub_forums"),
     link_to('Forum Topics',"/admin/sub_forums/#{params[:sub_forum_id]}/forum_topics")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:sub_forum_id]
    }
    # byebug
    session[:breadcrumb][:subforum] = data
  end

  form do |f|
    f.inputs do
      f.object.status = true if f.object.status.nil?
      f.input :title
      f.input :description, as: :rich, config: { width: '76%', height: '400px' }    
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }, :checked => [Active: true]
      f.input :is_sticky, as: :radio, collection: { 'Yes' => true, 'No' => false }, :checked => [No: false]
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Topic')
      else
        f.action(:submit, label: 'Update Topic')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  index do
    column :id
    column :title
    # column('Posts') do |forum_topic|
    #   # forum_topic.inspect
    #    link_to forum_topic.forum_posts.count, '#'
    # end
    actions
  end

  before_create do |forum|
    if forum.forum_moderators.count == 0
      fm = ForumModerator.new
      fm.forum_topic = forum
      fm.user = current_admin_user
      forum.forum_moderators <<  fm
      # forum.forum_moderators << current_admin_user
    end
  end

end
