class AddLowQualityVideoDownloadpathToRichFiles < ActiveRecord::Migration
  def change
    add_column :rich_rich_files, :low_quality_video_downloadpath, :string
  end
end
