# frozen_string_literal: true
module V1
  class LearningLibraries < Grape::API
    prefix 'api'
    resource :learning_libraries do
    end

    namespace 'learning_libraries/featured' do
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        resources = ::FeaturedVideo
                    .featured_video
                    .order(updated_at: :desc)
                    .limit(3)
        {
          status: 200,
          message: '',
          content: Entities::LearningLibrary::Video.represent(resources, current_user: current_user)
        }
      end
    end

    namespace 'learning_libraries/categories/:id/resources' do
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        videos = ::LearngingLibrary.videos.active.where(category: params[:id]).order('position asc').joins(:file).merge(Rich::RichFile.where("file_status = ?", 1))
        audios = ::LearngingLibrary.audios.active.where(category: params[:id]).order('position asc').joins(:file).merge(Rich::RichFile.where("file_status = ?", 1))
        documents = ::LearngingLibrary.documents.active.where(category: params[:id]).order('position asc')
        {
          status: 200,
          message: '',
          content: {
            videos: Entities::LearningLibrary::Video.represent(videos, current_user: current_user),
            audios: Entities::LearningLibrary::Audio.represent(audios, current_user: current_user),
            documents: Entities::LearningLibrary::Document.represent(documents)
          }
        }
      end
    end

    namespace 'learning_libraries/titles' do
      params do
        requires :term, type: String
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        titles = ::LearngingLibrary.active.where('title ILIKE ?', "%#{params[:term]}%").uniq.pluck('title')
        {
          status: 200,
          message: '',
          content: titles
        }
      end
    end

    namespace 'learning_libraries/search' do
      params do
        requires :term, type: String
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        videos = ::LearngingLibrary.videos.active.where('title ILIKE ?', "%#{params[:term]}%").joins(:file).merge(Rich::RichFile.where("file_status = ?", 1))
        audios = ::LearngingLibrary.audios.active.where('title ILIKE ?', "%#{params[:term]}%").joins(:file).merge(Rich::RichFile.where("file_status = ?", 1))
        documents = ::LearngingLibrary.documents.active.where('title ILIKE ?', "%#{params[:term]}%")
        {
          status: 200,
          message: '',
          content:  {
            videos: Entities::LearningLibrary::Video.represent(videos, current_user: current_user),
            audios: Entities::LearningLibrary::Audio.represent(audios, current_user: current_user),
            documents: Entities::LearningLibrary::Document.represent(documents)
          }
        }
      end
    end

    namespace 'learning_libraries/categories/:id' do
      params do
        requires :id, type: Integer
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        file = Rich::RichFile.find(Rails.application.secrets.video_thumb)
        subtopics = Llcategory.find(params[:id]).children.order('position asc').map do |tc|
          {
            'id' => tc.id,
            'title' => tc.title,
            'thumbnail' => tc.thumbnail.nil? ? file.rich_file.url('thumbl') : tc.thumbnail.rich_file.url('thumbl'),
            'hasChildern' => false
          }
        end
        category = Llcategory.find(params[:id])
        {
          status: 200,
          message: '',
          content: {
            'resourceCount' => children_resource_count(category),
            'list' => subtopics,
            'id' => params[:id],
            'title' => category.title
          }
        }
      end
    end

    namespace 'learning_libraries/categories' do
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        file = Rich::RichFile.find(Rails.application.secrets.video_thumb)
        level_savvies = LevelAndSavvy.level_savvies.order('position asc').map do |tc|
          {
            'id' => tc.id,
            'title' => tc.title,
            'position' => tc.position,
            'thumbnail' => tc.thumbnail.nil? ? file.rich_file.url('thumbl') : tc.thumbnail.rich_file.url('thumbl'),
            'hasChildern' => true
          }
        end
        auditions = AuditionAssesment.auditions.order('position asc').map do |tc|
          {
            'id' => tc.id,
            'title' => tc.title,
            'position' => tc.position,
            'thumbnail' => tc.thumbnail.nil? ? file.rich_file.url('thumbl') : tc.thumbnail.rich_file.url('thumbl'),
            'hasChildern' => true
          }
        end
        archives = Archive.archives.order('position asc').map do |tc|
          {
            'id' => tc.id,
            'title' => tc.title,
            'position' => tc.position,
            'thumbnail' => tc.thumbnail.nil? ? file.rich_file.url('thumbl') : tc.thumbnail.rich_file.url('thumbl'),
            'hasChildern' => true
          }
        end
        interestes = Interest.interests.order('position asc').map do |tc|
          {
            'id' => tc.id,
            'title' => tc.title,
            'position' => tc.position,
            'thumbnail' => tc.thumbnail.nil? ? file.rich_file.url('thumbl') : tc.thumbnail.rich_file.url('thumbl'),
            'hasChildern' => true
          }
        end
          {
          status: 200,
          message: '',
          content: {
            'Archives' => {
              'resourceCount' => grandchildren_resource_count(Llcategory.archive),
              'list' => archives
            }
          }
        }
        # {
        #   status: 200,
        #   message: '',
        #   content: {
        #     'Level & Savvy' => {
        #       'resourceCount' => grandchildren_resource_count(Llcategory.level_savvy),
        #       'list' => level_savvies
        #     },
        #     'Auditions & Self-Assessments' => {
        #       'resourceCount' => grandchildren_resource_count(Llcategory.audition),
        #       'list' => auditions
        #     },
        #     'Archives' => {
        #       'resourceCount' => grandchildren_resource_count(Llcategory.archive),
        #       'list' => archives
        #     },
        #     'Interest' => {
        #       'resourceCount' => grandchildren_resource_count(Llcategory.interest),
        #       'list' => interestes
        #     }
        #   }
        # }
      end
    end

    helpers do
      def children_resource_count(parents)
        all_resources = 0
        parents.children.each do |child|
          all_resources += ::LearngingLibrary
                           .where(category: child)
                           .active
                           .count
        end
        all_resources
      end

      def grandchildren_resource_count(parents)
        all_resources = 0
        parents.each do |parent|
          parent.children.each do |child|
            all_resources += ::LearngingLibrary
                             .where(category: child)
                             .active
                             .count
          end
        end
        all_resources
      end
    end
  end
end
