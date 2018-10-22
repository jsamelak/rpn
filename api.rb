require 'redis'
require 'sinatra'
require 'logger'
require 'json'
require 'sidekiq'

file = File.open('rblog.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(file)
logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime}: #{msg}\n"
end

redis = Redis.new(:timeout => 5)

timeout = 10
sleep_time = 0.1

Sidekiq::configure_client do |config|
    config.redis = {url: "redis://127.0.0.1:6379", namespace: "goworkers"}
end

post '/' do
    content_type :json
    rpn = params[:rpn]
    logger.info(rpn)
    if rpn
        job_id = Sidekiq::Client.push "queue" => "myqueue", "class" => "RpnWorker", "args" => [rpn]
        logger.info(job_id)
        {:jobID => job_id}.to_json
    else
        {:jobID => ''}.to_json
    end
end

get '/' do
    content_type :json
    jobID = params[:jobID]
    logger.info(jobID)
    v = nil
    if jobID
        time = 0
        loop do
            v = redis.get(jobID)
            logger.info(v)
            sleep sleep_time
            time = time + sleep_time
            break if v != nil or time >= timeout
        end
        logger.info(v)
    end
    if v != nil
        {:result => v}.to_json
    else
        {:result => ''}.to_json
    end
end