ActiveAdmin.register EventCategory, as: 'EventSubCategory' do
# belongs_to :event_category
menu false

config.filters = false

permit_params :title, :description, :parent_id
# scope "Categories", :parents_only, default: true
scope("Sub-Categories", default: true) { |scope| scope.where(parent_id: params[:event_category_id]) }

# re-writting the breadcrumb
breadcrumb do
 [
   link_to('Admin',               "/admin"),
   link_to('Event Categories',    "/admin/event_categories"),
   link_to('Event Sub-Categories',  "/admin/event_sub_categories?event_category_id=#{params[:event_category_id]}")
 ]
end

before_filter :only => :index do |controller|
  session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
  data = {
    :controller => params[:controller],
    :id => params[:event_category_id]
  }
  # byebug
  session[:breadcrumb][:eventsubcategories] = data
end

# page overrieds

index do
  column :id
  column :title
  # column :description
  # column('Sub-Categories') do |event_category|
  #   if event_category.parent_id == nil
  #     link_to event_category.event_categories.count, "admin/event_categories/#{event_category.id}"
  #   end
  # end
  # column :status
  actions
end

form do |f|
  f.inputs do
    f.input :parent_id, as: :select,  collection: EventCategory.where(parent_id: nil).map {|e| [e.title, e.id]}
    # unless !f.object.new_record?
    # end
    # f.input :parent_id, as: :hidden, :value => params[:event_category_id]
    f.input :title
    # f.input :description
  end
  f.semantic_errors *f.object.errors.keys
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Create Event Sub-Category')
    else
      f.action(:submit, label: 'Update Event Sub-Category')
    end
    f.action(:cancel, label: 'Cancel')
  end
end

end
