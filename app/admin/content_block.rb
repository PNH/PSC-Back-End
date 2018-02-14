# frozen_string_literal: true
ActiveAdmin.register ContentBlock do
  menu false
  actions :all, except: [:destroy]
  config.filters = false

  permit_params :title, :slug, blocks_attributes: [:id, :_destroy, contents_attributes: [:kind, :data, :id, :_destroy]]

  index do
    column :id
    column :title
    column :slug
    actions
  end

  form do |f|
    f.inputs 'Content Block' do
      f.input :title
      if f.object.new_record?
        f.input :slug
      else
        f.input :slug, input_html: { readonly: true }
      end
      f.has_many :blocks, for: [:blocks, f.object.blocks || Block.new], new_record: 'Add', allow_destroy: true do |block|
        block.has_many :contents, for: [:contents, block.object.contents || Content.new], new_record: 'Add', allow_destroy: true do |content|
          content.input :kind
          case content.object.kind
          when 'html'
            content.input :data, as: :rich, config: { width: '76%', height: '400px' }
          when 'string'
            content.input :data, as: :string
          when 'text'
            content.input :data, as: :text, input_html: content.object.input_html
          when 'number'
            content.input :data, as: :number
          when 'image'
            content.input :data, as: :rich_picker, config: {
              style: 'width: 400px !important;', type: 'image', allowed_styles: [:original]
            }
          when 'video'
            content.input :data, as: :rich_picker, config: {
              style: 'width: 400px !important;', type: 'video'
            }
          when 'file'
            content.input :data, as: :rich_picker, config: {
              style: 'width: 400px !important;', type: 'all'
            }
          end
        end
      end
    end
    f.actions
  end

  controller do
    def update
      super do |_format|
        unless resource.errors.any?
          flash[:notice] = 'update successfully'
          redirect_to edit_admin_content_block_path(resource.id)
          return
        end
      end
    end
  end
end
