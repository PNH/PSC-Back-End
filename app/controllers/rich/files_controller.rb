module Rich
  class FilesController < ApplicationController
    before_filter :authenticate_rich_user
    before_filter :set_rich_file, only: [:show, :update, :destroy]

    layout 'rich/application'

    def index
      @type = params[:type]

      @items =  case @type
                when 'image'
                  RichFile.images
                when 'audio'
                  RichFile.audios
                when 'video'
                  RichFile.videos
                when 'file'
                  RichFile.files
                else
                  RichFile.all
                end

      if params[:scoped] == 'true'
        @items = @items.where('owner_type = ? AND owner_id = ?', params[:scope_type], params[:scope_id])
      end

      if params[:search].present?
        @items = @items.where('rich_file_file_name LIKE ?', "%#{params[:search]}%")
      end

      @items = if params[:alpha].present?
                 @items.order('rich_file_file_name ASC')
               else
                 @items.order('created_at DESC')
               end

      @items = @items.page params[:page]

      # stub for new file
      @rich_asset = RichFile.new

      respond_to do |format|
        format.html
        format.js
      end
    end

    def show
      # show is used to retrieve single files through XHR requests after a file has been uploaded

      if params[:id]
        # list all files
        @file = @rich_file
        render layout: false
      else
        render text: 'File not found'
      end
    end

    def create
      
      vidtypes = ["mp4","mov","m4v", "video"]
      audtypes = ["mp3","wmv","aac", "audio"]
      @file = RichFile.new(simplified_type: params[:simplified_type])
      # use the file from Rack Raw Upload
      file_params = params[:file] || params[:qqfile]

      if file_params
        file_params.content_type = Mime::Type.lookup_by_extension(file_params.original_filename.split('.').last.to_sym)

      if file_params.content_type.to_s.include? "image" 
        @file = RichFile.new(simplified_type: "image")
      elsif vidtypes.any? {|ext| file_params.content_type.to_s.include? ext }
        @file = RichFile.new(simplified_type: "video")
      elsif audtypes.any? {|ext| file_params.content_type.to_s.include? ext }
        @file = RichFile.new(simplified_type: "audio")      
      end

      if params[:scoped] == 'true'
        @file.owner_type = params[:scope_type]
        @file.owner_id = params[:scope_id].to_i
      end


        @file.rich_file = file_params
      end

      if @file.save

        if vidtypes.any? {|ext| @file.rich_file_content_type.include? ext }
          transcode = Transcoder.new(@file)
          transcode.create
        elsif audtypes.any? {|ext| @file.rich_file_content_type.include? ext }
          transcode = Transcoder.new(@file)
          transcode.create_audio
        end
        
        response = { success: true, rich_id: @file.id }
      else
        response = { success: false,
                     error: "Could not upload your file:\n- " + @file.errors.to_a[-1].to_s,
                     params: params.inspect }
      end

      render json: response, content_type: 'text/html'
    end

    def update
      new_filename_without_extension = params[:filename].parameterize
      if new_filename_without_extension.present?
        new_filename = @rich_file.rename!(new_filename_without_extension)
        render json: { success: true, filename: new_filename, uris: @rich_file.uri_cache }
      else
        render nothing: true, status: 500
      end
    end

    def destroy
      if params[:id]
        begin
          @rich_file.destroy
          @fileid = params[:id]
        rescue Exception
           render text: "alert('Could not delete this file!. Please make sure it is not attached to any internal resources')", content_type: 'text/javascript'          
        end        
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_rich_file
      @rich_file = RichFile.find(params[:id])
    end
  end
end
