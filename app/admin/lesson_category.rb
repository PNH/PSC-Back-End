# frozen_string_literal: true
ActiveAdmin.register LessonCategory do
  belongs_to :savvy, optional: true
  permit_params :title, :description, :badge_icon_id, :badge_title
  menu false
  filter :title_cont, label: 'By Title'
  navigation_menu do
    :default
  end
  config.sort_order = 'position_asc'

  # re-writting the breadcrumb
  breadcrumb do
   [
     link_to('Admin',   "/admin"),
     link_to('Level',   "/admin/levels"),
     link_to('Savvies', "/admin/levels/#{session[:breadcrumb]['savvy']['id']}/savvies"),
     link_to('Topics',  "/admin/savvies/#{params[:savvy_id]}/lesson_categories")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:savvy_id]
    }
    # byebug
    session[:breadcrumb][:topic] = data
  end

  index do
    column :id
    column :title, sortable: :title
    column 'Lessons', sortable: :lesson_count do |lc|
      link_to lc.lessons.count, admin_lesson_category_lessons_path(lc)
    end
    actions
    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr])+ "/?rid=#{vr.savvy.id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr])+ "/?rid=#{vr.savvy.id}"
    }
  end

  controller do
    def scoped_collection
      super.select('lesson_categories.*,(select count(l.id) from lessons l where l.lesson_category_id = lesson_categories.id) as  lesson_count')
    end

    def set_item_order
        sv = Savvy.find(params[:rid])
        sv.lesson_categories.order(:position).each_with_index do |ls,order|
          ls.position = order+1
          ls.save!
        end
    end
  end

  form do |f|
    f.inputs 'Lesson Category Information' do
      f.input :title, input_html: { maxlength: 100 }, hint: 'Max Length 100'
      f.input :description, as: :text, input_html: { maxlength: 110 }, hint: 'Max Length 110'
    end
    f.inputs 'Badge Information' do
      f.input :badge_title, label: 'Badge Title'
      # f.input :badge_icon_id, as: :rich_picker, config: {
      #   style: 'width: 400px !important;', type: 'image'
      # }, label: 'Badge Icon'
    end
    f.actions do
      if controller.action_name == 'new'
        f.action(:submit, label: 'Create Lesson Category')
      else
        f.action(:submit, label: 'Update Lesson Category')
      end
      f.action(:cancel, label: 'Cancel')
    end
  end

  member_action :move_to_top, method: [:post] do
    set_item_order
    lc = LessonCategory.find(params[:id])
    lc.move_higher
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = LessonCategory.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end

end
