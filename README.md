# rpn
System for evaluating Reverse Polish Notation expressions.
Logs containing input, timings and results are saved into 'rblog.log' file.
Results and timings are printed on stdout. 

Usage:
go run .\worker.go
ruby .\api.rb
py .\rpn.py


Make sure to install required dependencies:
1. Go: go get github.com/Scalingo/go-workers
2. Ruby: gem install redis, sinatra, logger, sidekiq
3. Python: pip install requests


Architecture:
1. User interface endpoint (Python):
    - collects input data
    - splits input into a number of RPN expressions
    - requests parsing RPN via REST API
    - gets the results via REST API
    - displays results
2. API (Ruby):
    - defines REST API
    - accepts single RPN expression and triggers worker
    - logs input, results and timings into a file
    - uses Sidekiq for queueing requests
3. Worker (Go):
    - receives RPN expression
    - parses RPN expression and evaluates result
    - saves result in Redis database
    - uses GoWorker + Redis server