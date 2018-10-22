from sys import stdin, stdout
import requests

N = int(stdin.readline())
URL = "http://127.0.0.1:4567/?"

jobIDs = []

for n in range(N):
    expression = str(stdin.readline()).rstrip()
    encoded = requests.utils.quote(expression)
    resp = requests.post(URL + "rpn=" + encoded).json()
    jobID = resp.get('jobID')
    if jobID:
        jobIDs.append(jobID)

for jobID in jobIDs:
    result = requests.get(URL + "jobID=" + jobID).json()
    stdout.write(str(result))
