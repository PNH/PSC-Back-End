require 'aws-sdk' # Using the aws-sdk

hls_64k_audio_preset_id = '1351620000001-200071';
hls_0400k_preset_id     = '1351620000001-200050';
hls_0600k_preset_id     = '1351620000001-200040';
hls_1000k_preset_id     = '1351620000001-200030';
hls_1500k_preset_id     = '1351620000001-200020';
hls_2000k_preset_id     = '1351620000001-200010';



# HLS Segment duration that will be targeted.
segment_duration = '2'

# The AWS_ACCESS_KEY_ID and the AWS_SECRET_ACCESS_KEY have to be set as specified here https://github.com/aws/aws-sdk-ruby

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new('AKIAI4DKWQ6OEAHZVHSQ', 'AZc+LADwaYSoU+ETK0w9zhjyLFjbV4GBngKXALPb')
})

PRESET_ID = '1351620000001-200035' # ID for the sytem web preset

filename = 'DVD 1 PATTERNS-FIGURE 8.mp4'

##### Upload the input video file to a s3 bucket:

# Get an instance of the S3 interface
s3 = Aws::S3::Resource.new(region:'us-east-1')

# Upload the file into a pre-existing s3 bucket. 
obj = s3.bucket('transcoder-source-input').object(filename) #s3.bucket('bucket-name').object('key')
# obj.upload_file('/') #/path/to/source/file

# Create a transcoder client
elastictranscoder = Aws::ElasticTranscoder::Client.new(region: 'us-east-1')

# Create a pipeline with the following code below or using the AWS console GUI(http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/creating-pipelines.html)
# pipeline_options = {}
# pipeline_options[:name] = 'parelli-videos'
# pipeline_options[:input_bucket] = 'parelli-videos'
# pipeline_options[:output_bucket] = 'parelli-videos-converted'
# pipeline_options[:role] = 'arn:aws:iam::725775057539:role/Elastic_Transcoder_Default_Role' # Eg: 'arn:aws:iam::444888444994:role/Elastic_Transcoder_Default_Role'

# pipeline = elastictranscoder.create_pipeline(pipeline_options)

# PIPELINE_ID =  pipeline[:pipeline][:id]
PIPELINE_ID = '1479699552146-k2grer'

hls_audio = {
  key: 'hlsAudio/' + filename,
  preset_id: hls_64k_audio_preset_id,
  segment_duration: segment_duration
}

hls_400k = {
  key: 'hls0400k/' + filename,
  preset_id: hls_0400k_preset_id,
  segment_duration: segment_duration
}

hls_600k = {
  key: 'hls0600k/' + filename,
  preset_id: hls_0600k_preset_id,
  segment_duration: segment_duration
}

hls_1000k = {
  key: 'hls1000k/' + filename,
  preset_id: hls_1000k_preset_id,
  segment_duration: segment_duration
}

hls_1500k = {
  key: 'hls1500k/' + filename,
  preset_id: hls_1500k_preset_id,
  segment_duration: segment_duration
}

hls_2000k = {
  key: 'hls2000k/' + filename,
  preset_id: hls_2000k_preset_id,
  segment_duration: segment_duration
}

outputs = [ hls_400k, hls_600k, hls_1000k, hls_1500k, hls_2000k ]
playlist = {
  name: 'hls_' + filename,
  format: 'HLSv3',
  output_keys: outputs.map { |output| output[:key] }
}

# Create a job
job_options = {}
job_options[:pipeline_id] = PIPELINE_ID
job_options[:input] = {
  key: filename
}
# job_options[:output] = {
#   key: 'transcoded' + filename,
#   preset_id: PRESET_ID,
#   thumbnail_pattern: "{count}-#{filename}"
# }
job_options[:outputs] = outputs
job_options[:playlists] =  [playlist]

job = elastictranscoder.create_job(job_options)
