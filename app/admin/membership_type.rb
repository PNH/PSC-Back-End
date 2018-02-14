# frozen_string_literal: true
ActiveAdmin.register MembershipType do
  menu false

  config.filters = false

  permit_params [:billing_frequency, :level, :tax, :cost, :status,
                 :benefits, :item_id, :benefit_title,
                 item_costs_attributes: [:currency_id, :cost]]

  index do
    column :id
    column :billing_frequency
    column :level
    # column :cost
    # column :tax
    column :status
    actions
  end

  form do |f|
    f.inputs '' do
      f.input :billing_frequency, as: :select2
      f.input :level, as: :select2
      f.input :item_id, label: 'NetSuite Item ID'
      # f.input :tax
      # f.input :cost
      f.inputs 'Price List' do
        f.has_many :item_costs, heading: '', for: [:item_costs, ItemCost.new], new_record: 'Add' do |cb|
          cb.input :currency, label: 'Currency'
          cb.input :cost, label: 'Cost'
        end
        table_for f.resource.item_costs do
          column :currency do |instance|
            instance.currency.title
          end
          column :cost
          column '' do |lt|
            link_to 'Remove', "#{cost_admin_membership_type_path}/?cid=#{lt.id}", method: :delete
          end
        end
      end
      f.input :benefit_title, input_html: { maxlength: 50 }, hint: 'Max Length 50'
      f.input :benefits, as: :rich, config: { width: '76%', height: '400px' }
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
    end
    f.actions
  end

  member_action :cost, method: [:delete] do
    ic = ItemCost.find(params[:cid])
    redirect_to :back if ic.nil?
    mt = MembershipType.find(params[:id])
    mt.item_costs.destroy(ic)
    redirect_to :back, notice: "Cost #{ic.currency.title} removed successfully"
  end

  controller do
    rescue_from RuntimeError do |e|
      flash[:error] = e.message
      redirect_to :back
    end
  end
end
