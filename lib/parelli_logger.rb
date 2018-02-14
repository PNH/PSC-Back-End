class ParelliLogger < Logger
  def initialize(filename)
    logfile = File.open("#{Rails.root}/log/#{filename}.log", 'a')
    logfile.sync = true
    super logfile
  end

  def format_message(severity, timestamp, _progname, msg)
    "#{timestamp} #{severity} : #{msg}\n"
  end
end
