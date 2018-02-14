require 'cgi'
require 'mime/types'
require 'kaminari'

module Rich
  class RichFile < ActiveRecord::Base
    include Backends::Paperclip

    scope :images,  -> { where("rich_rich_files.simplified_type = 'image'") }
    scope :files,   -> { where("rich_rich_files.simplified_type = 'file'") }
    scope :audios, -> { where("rich_rich_files.simplified_type = 'audio'") }
    scope :videos, -> { where("rich_rich_files.simplified_type = 'video'") }

    paginates_per Rich.options[:paginates_per]
  end
end