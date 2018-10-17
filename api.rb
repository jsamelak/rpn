require 'resque'

class RpnConverter
    @queue = :myqueue
end
  
Resque.redis = '127.0.0.1:6379'
Resque.enqueue RpnConverter, '5 1 2 + 4 * + 3 -'