package main

import (
	"math"
	"strconv"
	"strings"

	"github.com/Scalingo/go-workers"
)

func parseRPN(expression string) string {
	var stack []float64
	for _, el := range strings.Split(expression, " ") {
		num, err := strconv.ParseFloat(el, 64)
		if err == nil {
			stack = append(stack, num)
		} else if len(stack) > 1 {
			var a, b, c float64
			b, stack = stack[len(stack)-1], stack[:len(stack)-1]
			a, stack = stack[len(stack)-1], stack[:len(stack)-1]
			c = 0
			switch el {
			case "+":
				c = a + b
			case "-":
				c = a - b
			case "*":
				c = a * b
			case "/":
				if b == 0 {
					return "Error: Division by 0"
				} else {
					c = a / b
				}
			case "^":
				c = math.Pow(a, b)
			default:
				return "Error: Unrecognized symbol " + el
			}
			stack = append(stack, c)
		} else {
			return "Error: Invalid RPN expression"
		}
	}
	if len(stack) > 0 {
		return strconv.FormatFloat(stack[len(stack)-1], 'f', 3, 64)
	}
	return "Error: Unknown error"
}

func RpnWorker(msg *workers.Msg) {
	args, _ := msg.Get("args").StringArray()
	jid, _ := msg.Get("jid").String()

	if len(args) > 0 {
		conn := workers.Config.Pool.Get()
		result := parseRPN(args[0])
		conn.Do("SET", jid, result)
		conn.Flush()
	}
}

func main() {
	workers.Configure(map[string]string{
		"process": "worker1", "server": "127.0.0.1:6379", "namespace": "goworkers",
	})
	workers.Process("myqueue", RpnWorker, 10)
	workers.Run()
}
