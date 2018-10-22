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

timings = Hash.new

post '/' do
    content_type :json
    rpn = params[:rpn]
    if rpn
        job_id = Sidekiq::Client.push "queue" => "myqueue", "class" => "RpnWorker", "args" => [rpn]
        timings[job_id] = { "rpn" => rpn, "timestamp" => Time.now }
        {:jobID => job_id}.to_json
    else
        {:jobID => ''}.to_json
    end
end

get '/' do
    content_type :json
    jobID = params[:jobID]
    v = nil
    time_taken = "0.000"
    if jobID
        time = 0
        loop do
            v = redis.get(jobID)
            redis.del(jobID)
            break if v != nil or time >= timeout
            sleep sleep_time
            time = time + sleep_time
        end
        timing = timings[jobID]
        if timing
            time_taken = "%.3f" % (Time.now - timing["timestamp"])
            logger.info("Input: '" + timing["rpn"] + "', Output: " + v + ", Time: " + time_taken + "s")
            timings.delete(jobID)
        end
    end
    if v != nil
        {:result => v, :time => time_taken}.to_json
    else
        {:result => '', :time => time_taken}.to_json
    end
end