ActiveAdmin.register EventPricing do
belongs_to :event
# menu false

scope("Pricings", default: true) { |scope| scope.where(event_id: params[:event_id]) }

permit_params :event_id, :title, :description, :price

# re-writting the breadcrumb
# breadcrumb do
#  [
#    link_to('Admin',           "/admin"),
#    link_to('Events',          "/admin/events"),
#    link_to('Event Pricings',  "/admin/event_pricings?event_id=#{params[:event_id]}")
#  ]
# end

before_filter :only => :index do |controller|
  session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
  data = {
    :controller => params[:controller],
    :id => params[:event_id]
  }
  # byebug
  session[:breadcrumb][:eventpricings] = data
end

end
