require 'resque'
require 'sinatra'
require 'logger'

file = File.open('rblog.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(file)
logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime}: #{msg}\n"
end
Resque.redis = '127.0.0.1:6379'

get '/' do
    rpn = params[:rpn]
    logger.info(rpn)
    if rpn
        Resque.enqueue RpnConverter, rpn
    end
end

class RpnConverter
    @queue = :myqueue
end
