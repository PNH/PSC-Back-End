# frozen_string_literal: true
ActiveAdmin.register Lesson do
  belongs_to :lesson_category, optional: true
  filter :title_cont, label: 'By Title'
  filter :kind, label: 'By Type', as: :select, collection: proc {
    Lesson.kinds.map do |type|
      title = case type[0]
              when 'default'
                'Lesson'
              when 'fast_track'
                'Self-Assessment'
              else
                'Sample'
              end
      [title, type[1]]
    end
  }
  menu false
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
     link_to('Topics',  "/admin/savvies/#{session[:breadcrumb]['topic']['id']}/lesson_categories"),
     link_to('Lessons', "/admin/lesson_categories/#{params[:lesson_category_id]}/lessons")
   ]
  end

  before_filter :only => :index do |controller|
    session[:breadcrumb] = Hash.new if session[:breadcrumb].nil?
    data = {
      :controller => params[:controller],
      :id => params[:lesson_category_id]
    }
    # byebug
    session[:breadcrumb][:lesson] = data
  end

  permit_params :title, :kind, :description, :slug, :status, :lesson_category_id,
                :objective,
                chat_bubbles_attributes: [:user_id, :message],
                lesson_resources_attributes: [:kind, :rich_file_id, :title, :video_sub_id],
                video_resources_attributes: [:kind, :rich_file_id, :title, :video_sub_id],
                audio_resources_attributes: [:kind, :rich_file_id, :title, :video_sub_id],
                document_resources_attributes: [:kind, :rich_file_id, :title, :video_sub_id],
                lesson_tool_attributes: [:title]

  index do
    column :id
    column :title
    column('Type') do |lesson|
      case lesson.kind
      when 'default'
        'Lesson'
      when 'fast_track'
        'Self-Assessment'
      else
        'Sample'
      end
    end
    actions
    handle_column move_to_top_url: lambda { |vr|
      url_for([:move_to_top, :admin, vr])+ "/?rid=#{vr.lesson_category.id}"
    }, sort_url: lambda { |vr|
      url_for([:sort, :admin, vr])+ "/?rid=#{vr.lesson_category.id}"
    }
  end

  form do |f|
    f.inputs 'Lesson Information' do
      f.input :title
      f.input :description, label: 'Overview & Directions', as: :rich, config: { width: '76%', height: '400px' }
      f.input :slug
      f.input :kind, as: :select2, collection:
        Lesson.kinds.collect { |type|
          title = case type[0]
                  when 'default'
                    'Lesson'
                  when 'fast_track'
                    'Self-Assessment'
                  else
                    'Sample'
                  end
          [title, type[0]]
        }, include_blank: false, label: 'Lesson Type'
      f.input :status, as: :radio, collection: { 'Active' => true, 'Inactive' => false }
    end
    unless f.object.new_record?
      f.inputs 'Video List' do
        f.has_many :video_resources, heading: 'Lesson Resource', for: [:lesson_resources, LessonResource.new], new_record: 'Add' do |dl|
          dl.input :title, input_html: { maxlength: 80 }, hint: 'Max Length 80'
          dl.input :kind, as: :hidden, input_html: { value: 'video' }
          dl.input :rich_file_id, label: 'Video', as: :rich_picker, config: {
            style: 'width: 400px !important;', type: 'video'
          }
          # dl.input :video_sub_id, label: 'Subtitle', as: :rich_picker, config: {
          #   style: 'width: 400px !important;', type: 'all'
          # }
        end
        table_for f.resource.video_resources do
          handle_column move_to_top_url: lambda { |vr|
            resource_sort_admin_lesson_category_lesson_path + "/?position=1&rid=#{vr.id}"
          }, sort_url: lambda { |vr|
            resource_sort_admin_lesson_category_lesson_path + "/?rid=#{vr.id}"
          }
          column 'Title', &:title
          # column 'Subtitle' do |vr|
          #   vr.video_sub.try(:filename)
          # end
          column '' do |vr|
            link_to 'Remove', "#{videos_admin_lesson_category_lesson_path}/?vid=#{vr.rich_file_id}", method: :delete
          end
        end
      end
      f.inputs 'Audio List' do
        f.has_many :audio_resources, heading: 'Lesson Resource', for: [:lesson_resources, LessonResource.new], new_record: 'Add' do |dl|
          dl.input :title
          dl.input :kind, as: :hidden, input_html: { value: 'audio' }
          dl.input :rich_file_id, label: 'Audio', as: :rich_picker, config: {
            style: 'width: 400px !important;', type: 'audio'
          }
        end
        table_for f.resource.audio_resources do
          handle_column move_to_top_url: lambda { |ad|
            resource_sort_admin_lesson_category_lesson_path + "/?position=1&rid=#{ad.id}"
          }, sort_url: lambda { |ad|
            resource_sort_admin_lesson_category_lesson_path + "/?rid=#{ad.id}"
          }
          column 'Title', &:title
          column '' do |ad|
            link_to 'Remove', "#{audios_admin_lesson_category_lesson_path}/?aud_id=#{ad.rich_file_id}", method: :delete
          end
        end
      end
      f.inputs 'Objectives' do
        f.input :objective, label: 'Objective List', as: :rich, config: { width: '76%', height: '400px' }
      end
      f.inputs 'Chat Bubbles' do
        f.has_many :chat_bubbles, heading: 'Chat Bubble', for: [:chat_bubbles, ChatBubble.new], new_record: 'Add' do |cb|
          # cb.input :user, as: :select2, collection: User.member.collect{|u|
          #   [u.name, u.id]
          # }
          cb.input :user_id, as: :search_select, url: autocomplete_user_admin_lesson_category_lessons_path, fields: [:name]
          cb.input :message, input_html: { maxlength: 300 }, hint: 'Max Length 300'
        end
        render 'messages'
      end
      f.inputs 'Tools' do
        f.has_many :lesson_tool, heading: 'Lesson Tools', for: [:lesson_tool, LessonTool.new], new_record: 'Add' do |cb|
          cb.input :title, label: 'Tool'
        end
        table_for f.resource.lesson_tool do
          handle_column move_to_top_url: lambda { |lt|
            tools_sort_admin_lesson_category_lesson_path + "/?position=1&ltid=#{lt.id}"
          }, sort_url: lambda { |lt|
            tools_sort_admin_lesson_category_lesson_path + "/?ltid=#{lt.id}"
          }
          column :title
          column '' do |lt|
            link_to 'Remove', "#{tools_admin_lesson_category_lesson_path}/?lid=#{lt.id}", method: :delete
          end
        end
      end
      f.inputs 'Document List' do
        f.has_many :document_resources, heading: 'Lesson Resource', for: [:lesson_resources, LessonResource.new], new_record: 'Add' do |dl|
          dl.input :title
          dl.input :kind, as: :hidden, input_html: { value: 'document' }
          dl.input :rich_file_id, label: 'Documents', as: :rich_picker, config: {
            style: 'width: 400px !important;', type: 'all'
          }
        end
        table_for f.resource.document_resources do
          handle_column move_to_top_url: lambda { |dr|
            resource_sort_admin_lesson_category_lesson_path + "/?position=1&rid=#{dr.id}"
          }, sort_url: lambda { |dr|
            resource_sort_admin_lesson_category_lesson_path + "/?rid=#{dr.id}"
          }
          column 'Title', &:title
          column '' do |dr|
            link_to 'Remove', "#{documents_admin_lesson_category_lesson_path}/?doc_id=#{dr.rich_file_id}", method: :delete
          end
        end
      end
    end
    f.actions
  end

  controller do
    def set_item_order
        lc = LessonCategory.find(params[:rid])
        lc.lessons.order(:position).each_with_index do |ls,order|
          ls.position = order+1
          ls.save!
        end
    end
  end

  member_action :documents, method: [:delete] do
    document = Rich::RichFile.find(params[:doc_id])
    redirect_to :back if document.nil?
    lesson = Lesson.find(params[:id])
    lesson.documents.destroy(document)
    redirect_to :back, notice: "Document #{document.filename} removed successfully"
  end

  member_action :tools, method: [:delete] do
    tool = LessonTool.find(params[:lid])
    redirect_to :back if tool.nil?
    lesson = Lesson.find(params[:id])
    lesson.lesson_tool.destroy(tool)
    redirect_to :back, notice: "Tool #{tool.title} removed successfully"
  end

  member_action :chat_bubbles, method: [:delete] do
    chat = ChatBubble.find(params[:cb])
    redirect_to :back if chat.nil?
    lesson = Lesson.find(params[:id])
    lesson.chat_bubbles.destroy(chat)
    redirect_to :back, notice: 'Chat Bubble removed successfully'
  end

  member_action :audios, method: [:delete] do
    audio = Rich::RichFile.find(params[:aud_id])
    redirect_to :back if audio.nil?
    lesson = Lesson.find(params[:id])
    lesson.audios.destroy(audio)
    redirect_to :back, notice: "Audio #{audio.filename} removed successfully"
  end

  member_action :videos, method: [:delete] do
    video = Rich::RichFile.find(params[:vid])
    redirect_to :back if video.nil?
    lesson = Lesson.find(params[:id])
    lesson.videos.destroy(video)
    redirect_to :back, notice: "Video #{video.filename} removed successfully"
  end

  member_action :tools_sort, method: [:post] do
    lesson_tool = LessonTool.find(params[:ltid])
    lesson_tool.insert_at(params[:position].to_i)
    redirect_to :edit_admin_lesson_category_lesson
  end

  member_action :resource_sort, method: [:post] do
    lesson_resource = LessonResource.find(params[:rid])
    lesson_resource.insert_at(params[:position].to_i)
    redirect_to :edit_admin_lesson_category_lesson
  end

  collection_action :autocomplete_user, method: [:get] do
    term = params[:q]['groupings']['0']['name_contains']
    users = User.member.where('first_name ILIKE ? or last_name ILIKE ?', "%#{term}%", "%#{term}%")
                .order(:first_name).all
    render json: users.map { |user|
                   {
                     id: user.id,
                     name: user.name
                   }
                 }
  end

  member_action :move_to_top, method: [:post] do
    set_item_order
    lc = Lesson.find(params[:id])
    lc.move_to_top
    redirect_to :back
  end

  member_action :sort, method: [:post] do
    set_item_order
    lc = Lesson.find(params[:id])
    lc.insert_at(params[:position].to_i)
    head :ok
  end
end
