ActiveAdmin.register EventCategory do

menu false
actions :all, :except => [:destroy, :new]
config.filters = false
permit_params :title, :description, :parent_id
scope "Categories", :parents_only, default: true
# scope("Sub-Categories") { |scope| scope.where.not(parent_id: params[:event_category_id]) }

# re-writting the breadcrumb
breadcrumb do
 [
   link_to('Admin',               "/admin"),
   link_to('Event Categories',    "/admin/event_categories")
 ]
end

# page overrieds

index do
  # column :id
  column :title
  # column :description
  column('Sub-Categories') do |event_category|
    if event_category.parent_id == nil
      link_to event_category.event_categories.count, "event_sub_categories?event_category_id=#{event_category.id}"
    end
  end
  # column :status
  actions
end

form do |f|
  f.inputs do
    # f.input :parent_id, as: :hidden, :value => nil
    f.input :title
    f.input :description
  end
  f.actions do
    if controller.action_name == 'new'
      f.action(:submit, label: 'Create Event Category')
    else
      f.action(:submit, label: 'Update Event Category')
    end
    f.action(:cancel, label: 'Cancel')
  end
end

end
