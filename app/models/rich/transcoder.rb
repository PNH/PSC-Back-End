require 'aws-sdk'
module Rich
class Transcoder < RichFile

  # HLS_0400K_PRESET     = '1351620000001-200050'
  # HLS_0600K_PRESET    = '1351620000001-200040'
  # HLS_1000K_PRESET     = '1351620000001-200030'
  # HLS_1500K_PRESET     = '1351620000001-200020'
  # HLS_2000K_PRESET     = '1351620000001-200010'
  # HLS_3000K_PRESET     = '1480438202224-x9eqzm'
  # HLS_5000K_PRESET     = '1481701924725-po6lel'
  HLS_AUDIO_128K_PRESET     = '1351620000001-200060'

  # HLS424X240_PRESET =  '1487186890328-gm9cat'
  # HLS640X480_PRESET =  '1351620000001-000030'
  # HLS848X480_PRESET =  '1487187525198-lz5xc1'
  # HLS960X720_PRESET =  '1487187718183-djymso'
  # HLS1280X720_PRESET =  '1487187852128-9e8x4l'
  # HLS1280X720D_PRESET =  '1487345937252-he86oy'
  # HLS1920X1080_PRESET =  '1487346097891-wwf9id'

  USP_PRESET =  '1487186890328-gm9cat'
  ASP_PRESET =  '1487187525198-lz5xc1'

  HLS424X240_PRESET =  '1488969455737-gvl884'
  HLS640X480_PRESET =  '1488969507479-314k86'
  HLS848X480_PRESET =  '1488969547769-k00ssn'
  HLS960X720_PRESET =  '1488969578350-i34f95'
  HLS1280X720_PRESET =  '1488969611019-p9ztxb'
  HLS1280X720D_PRESET =  '1488969642278-uiavam'
  HLS1920X1080_PRESET =  '1488969672051-6mfz8x'

  def initialize(avfile)

    @pipeline_id = Rails.application.config.transcoder[:pipeline_id]
    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]
    @segment_duration = Rails.application.config.transcoder[:segment_duration]
    @cloudfront_path = Rails.application.config.transcoder[:cloudfront_path]
    @s3_source_path = Rails.application.config.transcoder[:s3_source_path]
    @s3_thumbnail_path = Rails.application.config.transcoder[:s3_thumbnail_path]
    @s3_source_name = Rails.application.config.transcoder[:s3_source_name]

    Aws.config.update({
      region: @aws_reagion,
      credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
    })

    @avfile = avfile
    @timepan = Time.now.to_i
    @vfile_path = @avfile.video_downloadpath.nil? ? @avfile.rich_file.url('original','no-security') : @avfile.video_downloadpath
  end

  def self.read_transcode_notifications

    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_sqs_url = Rails.application.config.transcoder[:aws_sqs_url]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]

    @max_messages = 10 
    @visibility_timeout = 15
    @wait_time_seconds = 5

    Aws.config.update({
          region: @aws_reagion,
          credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
        })
    sqs_client = Aws::SQS::Client.new
 
    sqs_messages = sqs_client.receive_message(
    queue_url: @aws_sqs_url,
    max_number_of_messages: @max_messages,
    wait_time_seconds: @wait_time_seconds).data[:messages]
      
    unless sqs_messages.empty?
 
           
    sqs_messages.each do |sqs_message|

      notification = JSON.parse(JSON.parse(sqs_message[:body])['Message'])
      avfiles = Rich::RichFile.where('video_ref_id = ?', notification['jobId'])
     
      if avfiles.any? 
        avfile = avfiles.first
        if notification['state'] == 'COMPLETED'        
          avfile.file_status = 1
          avfile.rich_file_file_size = 5000
          avfile.video_length = (notification['outputs'][0]['duration']).to_i
          avfile.save
        elsif notification['state'] == 'ERROR'        
          avfile.file_status = -1
          avfile.save
        end       
      end 
      sqs_client.delete_message(queue_url: @aws_sqs_url, receipt_handle: sqs_message[:receipt_handle])  
      end   
      

    end    
  end

  def self.s3_bulkfeed(prefix = '')

    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_sqs_url = Rails.application.config.transcoder[:aws_sqs_url]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]
    @s3_external_source_name= Rails.application.config.transcoder[:s3_external_source_name]
    @s3_external_source_path = Rails.application.config.transcoder[:s3_external_source_path]

    accepted_formats = [".mp4", ".mov", ".m4v"]
    file_array ||= []

    Aws.config.update({
          region: @aws_reagion,
          credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
        })

    s3 = Aws::S3::Client.new
    s3_resouces = s3.list_objects(bucket:@s3_external_source_name, prefix:prefix , delimiter:'/')
    s3_file_list = s3_resouces.contents.map(&:key)
    s3_directory_list = s3_resouces.common_prefixes

    s3_file_list.each do |key|
      # file_array << key.to_s     

      if accepted_formats.include? File.extname(key.to_s)

        avfile = Rich::RichFile.where('rich_file_file_name = ?',self.clean_file_name(key.to_s)).first
        unless avfile.present?
          avfile = Rich::RichFile.new
        end      

        avfile.rich_file_file_name = key.to_s
        avfile.rich_file_content_type = "application/mp4"
        avfile.simplified_type = "video"
        avfile.file_status = -2
        avfile.rich_file_file_size = 1000000
        avfile.video_downloadpath = @s3_external_source_path+key.to_s
        avfile.save
      end
    end

    s3_directory_list.each do |key|
      return_file_array = self.s3_bulkfeed key.prefix.to_s
      file_array = file_array + return_file_array
    end

    file_array
  end

  def self.fix_filename(source_file)
   begin
    source_file_path = source_file.video_downloadpath
    transcoded_file_path = source_file.video_sourcepath
    elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')
    input_file_path = source_file_path.split("/")[4..-1].join("/").split("?")[0]
    output_file_path = input_file_path.gsub(/\s/,'-')

    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]
    @s3_external_source_name= Rails.application.config.transcoder[:s3_external_source_name]

    Aws.config.update({
          region: @aws_reagion,
          credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
        })

    s3 = Aws::S3::Client.new
    s3.copy_object(bucket: @s3_external_source_name,
                   copy_source: "#{@s3_external_source_name}/#{input_file_path}",
                   key: output_file_path)

    source_file.video_downloadpath = "#{source_file_path.split("/")[0..3].join("/")}/#{output_file_path}"
    source_file.rich_file_file_size = -2
    source_file.save!
    rescue => error
      false
    end
  end

  def self.fix_download_path(prefix = '')

    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_sqs_url = Rails.application.config.transcoder[:aws_sqs_url]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]
    @s3_source_name= Rails.application.config.transcoder[:s3_source_name]
    @s3_source_path = Rails.application.config.transcoder[:s3_source_path]

    accepted_formats = [".mp4", ".mov", ".m4v"]
    file_array ||= []

    Aws.config.update({
          region: @aws_reagion,
          credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
        })

    s3 = Aws::S3::Client.new
    s3_resouces = s3.list_objects(bucket:@s3_source_name, prefix:prefix , delimiter:'/')
    s3_file_list = s3_resouces.contents.map(&:key)
    s3_directory_list = s3_resouces.common_prefixes

    s3_file_list.each do |key|
      # file_array << key.to_s     

      if accepted_formats.include? File.extname(key.to_s)
        avfile = Rich::RichFile.where('rich_file_file_name = ?',File.basename(key.to_s)).first

        if avfile.present?
          avfile.video_downloadpath = @s3_source_path+key.to_s
          avfile.save
        end
      end
    end

    s3_directory_list.each do |key|
      return_file_array = self.fix_download_path key.prefix.to_s
      file_array = file_array + return_file_array
    end

    file_array
  end

  def self.s3_bulkfeed_audio(prefix = '')

    @aws_reagion = Rails.application.config.transcoder[:aws_reagion]
    @aws_sqs_url = Rails.application.config.transcoder[:aws_sqs_url]
    @aws_access_key_id = Rails.application.config.transcoder[:aws_access_key]
    @aws_secret_access_key = Rails.application.config.transcoder[:aws_secret_access_key]
    @s3_external_source_name= Rails.application.config.transcoder[:s3_external_source_name]
    @s3_external_source_path = Rails.application.config.transcoder[:s3_external_source_path]

    accepted_formats = [".mp3", ".wma", ".aac"]
    file_array ||= []

    Aws.config.update({
          region: @aws_reagion,
          credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key)
        })

    s3 = Aws::S3::Client.new
    s3_resouces = s3.list_objects(bucket:@s3_external_source_name, prefix:prefix , delimiter:'/')
    s3_file_list = s3_resouces.contents.map(&:key)
    s3_directory_list = s3_resouces.common_prefixes

    s3_file_list.each do |key|
      # file_array << key.to_s
      if accepted_formats.include? File.extname(key.to_s)

        avfile = Rich::RichFile.where('rich_file_file_name = ?',self.clean_file_name(key.to_s)).first
        unless avfile.present?
          avfile = Rich::RichFile.new
        end     

        avfile.rich_file_file_name = key.to_s
        avfile.rich_file_content_type = "application/mp3"
        avfile.simplified_type = "audio"
        avfile.file_status = -2
        avfile.rich_file_file_size = 1000000
        avfile.video_downloadpath = @s3_external_source_path+key.to_s
        avfile.save


      end
    end

    s3_directory_list.each do |key|
      return_file_array = self.s3_bulkfeed_audio key.prefix.to_s
      file_array = file_array + return_file_array
    end

    file_array
  end

  def create

      elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')
      # hls_600k = {
      #   key: "hls0600k/#{vfile_base}",
      #   preset_id: HLS_0600K_PRESET,
      #   segment_duration: @segment_duration,
      # }

      # hls_1000k = {
      #   key: "hls1000k/#{vfile_base}",
      #   preset_id: HLS_1000K_PRESET,
      #   segment_duration: @segment_duration,
      # }

      # hls_3000k = {
      #   key: "hls3000k/#{vfile_base}",
      #   preset_id: HLS_3000K_PRESET,
      #   segment_duration: @segment_duration,
      # }

      # hls_5000k = {
      #   key: "hls5000k/#{vfile_base}",
      #   preset_id: HLS_5000K_PRESET,
      #   segment_duration: @segment_duration,
      #   thumbnail_pattern: "#{vfile_base}-{count}"
      # }

      hls_1 = {
        key: "hls424x240/#{vfile_base}",
        preset_id: HLS424X240_PRESET,
        segment_duration: @segment_duration
      }

      hls_2 = {
        key: "hls640x480_PRESET/#{vfile_base}",
        preset_id: HLS640X480_PRESET,
        segment_duration: @segment_duration
      }

      hls_3 = {
        key: "hls848x480/#{vfile_base}",
        preset_id: HLS848X480_PRESET,
        segment_duration: @segment_duration
      }

      hls_4 = {
        key: "hls960x720/#{vfile_base}",
        preset_id: HLS960X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_5 = {
        key: "hls1280x720/#{vfile_base}",
        preset_id: HLS1280X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_6 = {
        key: "hls1280x720d/#{vfile_base}",
        preset_id: HLS1280X720D_PRESET,
        segment_duration: @segment_duration
      }
      hls_7 = {
        key: "hls1920x1080/#{vfile_base}",
        preset_id: HLS1920X1080_PRESET,
        segment_duration: @segment_duration,
        thumbnail_pattern: "#{vfile_base}-{count}"
      }

      mp4_1 = {
        key: "usp/#{vfile_base}.mp4",
        preset_id: USP_PRESET
      }

      mp4_2 = {
        key: "asp/#{vfile_base}.mp4",
        preset_id: ASP_PRESET
      }


      play_outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7]
      outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7,mp4_1, mp4_2]
      playlist = {
        name: vfile_base,
        format: 'HLSv3',
        output_keys: play_outputs.map { |output| output[:key] }
      }
      job_options = {}
      job_options[:pipeline_id] = @pipeline_id
      job_options[:input] = {
        key: vfile_dir+file_name
      }
      job_options[:outputs] = outputs
      job_options[:playlists] =  [playlist]

      job = elastictranscoder.create_job(job_options)

      unless job.nil?

        cache_path = {}
        cache_path["original"] = "#{@cloudfront_path}#{vfile_base}.m3u8"
        cache_path["thumb"] = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        @avfile.video_ref_id = job.data[:job][:id]
        @avfile.video_thumbnail = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        @avfile.video_downloadpath = @vfile_path
        @avfile.low_quality_video_downloadpath = "#{@cloudfront_path}asp/#{vfile_base}.mp4" 
        @avfile.video_sourcepath = "#{@cloudfront_path}#{vfile_base}.m3u8"
        @avfile.uri_cache = cache_path.to_json
        @avfile.rich_file_content_type = "application/mp4"
        @avfile.file_status = 2
        @avfile.simplified_type = "video"
        @avfile.save!

      end

end

 def manual_create_external(source_file, pipeline)
      source_file_path = source_file.video_downloadpath
      transcoded_file_path = source_file.video_sourcepath
      elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')
      input_file_name = File.basename(source_file_path)
      output_file_name = File.basename(transcoded_file_path, File.extname(transcoded_file_path))  

      hls_1 = {
        key: "hls424x240/#{output_file_name}",
        preset_id: HLS424X240_PRESET,
        segment_duration: @segment_duration
      }

      hls_2 = {
        key: "hls640x480/#{output_file_name}",
        preset_id: HLS640X480_PRESET,
        segment_duration: @segment_duration
      }

      hls_3 = {
        key: "hls848x480/#{output_file_name}",
        preset_id: HLS848X480_PRESET,
        segment_duration: @segment_duration
      }

      hls_4 = {
        key: "hls960x720/#{output_file_name}",
        preset_id: HLS960X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_5 = {
        key: "hls1280x720/#{output_file_name}",
        preset_id: HLS1280X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_6 = {
        key: "hls1280x720d/#{output_file_name}",
        preset_id: HLS1280X720D_PRESET,
        segment_duration: @segment_duration
      }
      hls_7 = {
        key: "hls1920x1080/#{output_file_name}",
        preset_id: HLS1920X1080_PRESET,
        segment_duration: @segment_duration,
        thumbnail_pattern: "#{output_file_name}-{count}"
      }

      mp4_1 = {
        key: "usp/#{output_file_name}.mp4",
        preset_id: USP_PRESET
      }

      mp4_2 = {
        key: "asp/#{output_file_name}.mp4",
        preset_id: ASP_PRESET
      }


      play_outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7]
      outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7,mp4_1, mp4_2]
      playlist = {
        name: output_file_name,
        format: 'HLSv3',
        output_keys: play_outputs.map { |output| output[:key] }
      }
      job_options = {}
      job_options[:pipeline_id] = pipeline
      job_options[:input] = {
        key: source_file_path.split("/")[4..-1].join("/").split("?")[0]
      }
      job_options[:outputs] = outputs
      job_options[:playlists] =  [playlist]

      job = elastictranscoder.create_job(job_options)

      unless job.nil?

         source_file.video_ref_id = job.data[:job][:id]     
         source_file.save!

        # cache_path = {}
        # cache_path["original"] = "#{@cloudfront_path}#{vfile_base}.m3u8"
        # cache_path["thumb"] = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        #@avfile.video_ref_id = job.data[:job][:id]
        # @avfile.video_thumbnail = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        # # @avfile.video_downloadpath = @vfile_path
        # @avfile.video_sourcepath = "#{@cloudfront_path}#{vfile_base}.m3u8"
        # @avfile.uri_cache = cache_path.to_json
        # @avfile.rich_file_content_type = "application/mp4"
        # @avfile.file_status = 2
        # @avfile.simplified_type = "video"
        #@avfile.save!

      end
end

 def create_external(pipeline)
      elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')

      hls_1 = {
        key: "hls424x240/#{vfile_base}",
        preset_id: HLS424X240_PRESET,
        segment_duration: @segment_duration,
      }

      hls_2 = {
        key: "hls640x480/#{vfile_base}",
        preset_id: HLS640X480_PRESET,
        segment_duration: @segment_duration,
      }

      hls_3 = {
        key: "hls848x480/#{vfile_base}",
        preset_id: HLS848X480_PRESET,
        segment_duration: @segment_duration,
      }

      hls_4 = {
        key: "hls960x720/#{vfile_base}",
        preset_id: HLS960X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_5 = {
        key: "hls1280x720/#{vfile_base}",
        preset_id: HLS1280X720_PRESET,
        segment_duration: @segment_duration
      }
      hls_6 = {
        key: "hls1280x720d/#{vfile_base}",
        preset_id: HLS1280X720D_PRESET,
        segment_duration: @segment_duration
      }
      hls_7 = {
        key: "hls1920x1080/#{vfile_base}",
        preset_id: HLS1920X1080_PRESET,
        segment_duration: @segment_duration,
        thumbnail_pattern: "#{vfile_base}-{count}"
      }
      mp4_1 = {
        key: "usp/#{vfile_base}.mp4",
        preset_id: USP_PRESET
      }

      mp4_2 = {
        key: "asp/#{vfile_base}.mp4",
        preset_id: ASP_PRESET
      }


      play_outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7]
      outputs = [hls_1, hls_2, hls_3, hls_4, hls_5, hls_6, hls_7,mp4_1, mp4_2]
      playlist = {
        name: vfile_base,
        format: 'HLSv3',
        output_keys: play_outputs.map { |output| output[:key] }
      }

      

      job_options = {}
      job_options[:pipeline_id] = pipeline
      job_options[:input] = {
        key: vfile_dir+file_name
      }
      job_options[:outputs] = outputs
      job_options[:playlists] =  [playlist]

      job = elastictranscoder.create_job(job_options)

      unless job.nil?

        cache_path = {}
        cache_path["original"] = "#{@cloudfront_path}#{vfile_base}.m3u8"
        cache_path["thumb"] = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        @avfile.video_ref_id = job.data[:job][:id]
        @avfile.video_thumbnail = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
#        @avfile.video_downloadpath = @vfile_path
        @avfile.low_quality_video_downloadpath = "#{@cloudfront_path}asp/#{vfile_base}.mp4" 
        @avfile.video_sourcepath = "#{@cloudfront_path}#{vfile_base}.m3u8"
        @avfile.uri_cache = cache_path.to_json
        @avfile.rich_file_content_type = "application/mp4"
        @avfile.file_status = 2
        @avfile.simplified_type = "video"
        @avfile.save!

      end

end




 def create_external_low_quality(source_file, pipeline)
      source_file_path = source_file.video_downloadpath
      transcoded_file_path = source_file.video_sourcepath
     unless transcoded_file_path.nil?
      elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')
      input_file_name = File.basename(source_file_path)
      output_file_name = File.basename(transcoded_file_path, File.extname(transcoded_file_path))      

      mp4_1 = {
        key: "usp/#{output_file_name}.mp4",
        preset_id: USP_PRESET
      }

      mp4_2 = {
        key: "asp/#{output_file_name}.mp4",
        preset_id: ASP_PRESET
      }

      outputs = [mp4_1, mp4_2]
      job_options = {}
      job_options[:pipeline_id] = pipeline
      job_options[:input] = {
        key: source_file_path.split("/")[4..-1].join("/").split("?")[0]
      }
      job_options[:outputs] = outputs
      job = elastictranscoder.create_job(job_options)
      unless job.nil?       
        source_file.video_ref_id = job.data[:job][:id]
        source_file.low_quality_video_downloadpath = "#{@cloudfront_path}asp/#{output_file_name}.mp4"        
        source_file.save!
      end
    end
end




def create_audio

      elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')
      hls_audio128k = {
        key: "hlsaudio128k/#{vfile_base}",
        preset_id: HLS_AUDIO_128K_PRESET,
        segment_duration: @segment_duration,
      }

      
      outputs = [hls_audio128k]
      playlist = {
        name: vfile_base,
        format: 'HLSv3',
        output_keys: outputs.map { |output| output[:key] }
      }
      job_options = {}
      job_options[:pipeline_id] = @pipeline_id
      job_options[:input] = {
        key: vfile_dir+file_name
      }
      job_options[:outputs] = outputs
      job_options[:playlists] =  [playlist]

      job = elastictranscoder.create_job(job_options)

      unless job.nil?

        cache_path = {}
        cache_path["original"] = "#{@cloudfront_path}#{vfile_base}.m3u8"
        cache_path["thumb"] = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        @avfile.video_ref_id = job.data[:job][:id]
        @avfile.video_thumbnail = "#{@s3_thumbnail_path}#{vfile_base}-00001.png"
        # @avfile.video_downloadpath = @vfile_path
        @avfile.video_sourcepath = "#{@cloudfront_path}#{vfile_base}.m3u8"
        @avfile.uri_cache = cache_path.to_json
        @avfile.rich_file_content_type = "application/mp3"
        @avfile.file_status = 2
        @avfile.simplified_type = "audio"
        @avfile.save!

      end

end

private 

  def self.clean_file_name(file_name)
        extension = File.extname(file_name).gsub(/^\.+/, '')
        filename = file_name.gsub(/\.#{extension}$/, '')
        filename = CGI.unescape(filename)
        extension = extension.downcase
        filename = filename.downcase.gsub(/[^a-z0-9]+/i, '-')
        "#{filename}.#{extension}"
  end

  def file_base
    fbase = File.basename(@vfile_path, File.extname(@vfile_path))
  end

  def file_name    
    fext = File.extname(@vfile_path).split('?')[0]
    "#{file_base}#{fext}"
  end

  def vfile_name    
    fext = File.extname(@vfile_path).split('?')[0]
    "#{file_base}-#{@timepan}#{fext}"
  end

  def vfile_dir    
    fdir = @vfile_path.split("/")[4..-2].join("/")
    "#{fdir}/"
  end

  def vfile_base
    "#{file_base}-#{@timepan}"
  end

  def vfile_extention
    File.extname(@vfile_path).split('?')[0]
  end
end
end


