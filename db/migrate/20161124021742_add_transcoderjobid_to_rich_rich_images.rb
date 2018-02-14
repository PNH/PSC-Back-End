class AddTranscoderjobidToRichRichImages < ActiveRecord::Migration
  def change
    add_column :rich_rich_files, :video_ref_id, :string
    add_column :rich_rich_files, :video_thumbnail, :string
    add_column :rich_rich_files, :video_length, :integer
    add_column :rich_rich_files, :video_downloadpath, :string
    add_column :rich_rich_files, :video_sourcepath, :string
    add_column :rich_rich_files, :file_status, :integer, default: 0
  end
end
