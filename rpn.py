from sys import stdin, stdout
import requests

N = int(stdin.readline())
URL = "http://127.0.0.1:4567/?rpn="

for n in range(N):
    expression = str(stdin.readline()).rstrip()
    encoded = requests.utils.quote(expression)
    r = requests.get(URL + encoded)