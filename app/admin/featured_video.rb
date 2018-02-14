ActiveAdmin.register FeaturedVideo do
  config.filters = false
  scope :featured_video, default: true
  actions :all, except: [:destroy, :new, :show, :edit]
  menu false

  index do
    column :id
    column :title
    column :file_type
    actions do |resource|
      item 'Remove', disregard_admin_featured_video_path(resource), class: 'member_link'
    end
  end

  member_action :disregard, method: [:get] do
    video = FeaturedVideo.find(params[:id])
    video.featured = false
    video.save!
    redirect_to :back
  end
end
