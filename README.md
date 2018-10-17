# rpn

Architecture:

1. User interface endpoint (Python):
    - collects input data
    - splits input into a number of RPN expressions
    - requests parsing RPN via REST API
    - displays results
2. API (Ruby):
    - defines API
    - accepts single RPN expression and triggers worker
    - logs input and timing into a file
    - uses Resque for queueing requests
3. Worker (Go):
    - receives RPN expression
    - parses RPN expression and evaluates result
    - uses GoWorker + Redis server