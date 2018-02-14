ActiveAdmin.register BlogPost do
menu false
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :user_id, :content, :status, :privacy, :blog_id, :title, :summary, :thumb_id, tag_ids: [], blog_category_ids: []
filter :title_cont, as: :string, label: 'By Title'
filter :summary_cont, as: :string, label: 'By Summary'

scope "Enabled", :enabled_only, default: true
scope "Pending", :pending_only
scope "Disabled", :disable_only
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  column :id
  column :title
  column :created_at
  column :privacy
  column('View Count') do |post|
    post.views
  end
  column('Comments') do |post|
    if post.blog_post_comments.count > 0
      link_to "#{post.blog_post_comments.count}", "blog_posts/#{post.id}/blog_post_comments"
    else
      "No Comments"
    end
  end
  column :status
  actions
end

form do |f|
  if f.object.new_record?
    f.object.blog_id = Blog.first.id
    f.object.user_id = current_admin_user.id
    f.object.privacy = BlogPost.privacies[:members_only]
    f.object.status = BlogPost.statuses[:enable]
  end
  f.inputs do
    f.input :title
    f.input :summary
    f.input :thumb_id, label: 'Image (Ideal pixel size - 1200x320)', as: :rich_picker, config: {
      style: 'width: 400px !important;', type: 'image'
    }
    f.input :content, as: :rich, config: { width: '75%', height: '400px' }
    f.input :privacy
    # f.inputs do
    #   f.has_many :blog_post_attachments, heading: 'Attachments', for: [:blog_post_attachments, BlogPostAttachment.new], new_record: 'Add' do |df|
    #     df.input :rich_file_id, label: 'File Path', as: :rich_picker, config: {
    #       style: 'width: 400px !important;', type: 'all'
    #     }
    #   end
    # end
    f.input :status
    f.input :tags, as: :select2_multiple, multiple: true, collection: Tag.all.collect{ |f| [f.name, f.id] }, include_blank: true
    render 'blog_post'
    f.input :blog_categories, as: :select2_multiple, multiple: true, collection: BlogCategory.all.collect { |c| [c.name, c.id] }, include_blank: false
  end
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Create Post')
    else
      f.action(:submit, label: 'Update Post')
    end
    f.action(:cancel, label: 'Cancel')
  end
end

before_save do |post|
  post.blog_id = Blog.first.id
  if post.user_id.nil?
    post.user_id = current_admin_user.id
    post.status = BlogPost.statuses[:enable]
  end
end


end
