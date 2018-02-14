ActiveAdmin.register MembershipCancellation do

actions :all, :except => [:new]
# filter :reason_cont, as: :string, label: 'By Reason'
filter :reason, as: :select, collection: ::MembershipCancellation.reasons


# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
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
  column('Member') do |cancelation|
    if cancelation.user.nil?
      "#{cancelation.user.first_name} #{cancelation.user.last_name}"
    else
      "User not found"
    end
  end
  column :reason
  column :note
  column :created_at
end

end
