require 'resque'
require 'resque-result'
require 'redis'
require 'sinatra'
require 'logger'

file = File.open('rblog.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(file)
logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime}: #{msg}\n"
end
Resque.redis = '127.0.0.1:6379'
redis = Redis.new

get '/' do
    rpn = params[:rpn]
    logger.info(rpn)
    if rpn
        job = RpnConverter.enqueue rpn
        jobID = job.meta_id
        v = nil
        loop do
            v = redis.get(jobID)
            sleep 0.1
            break if v != nil
        end
        logger.info(v)
    end
end

class RpnConverter
    extend Resque::Plugins::Result
    @queue = :myqueue
end
