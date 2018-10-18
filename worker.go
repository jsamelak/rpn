package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"

	"github.com/benmanns/goworker"
)

func parseRPN(expression string) float64 {
	fmt.Printf("parseRPN: %s\n", expression)
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
					fmt.Println("Error: Division by 0!")
					c = 0
				} else {
					c = a / b
				}
			case "^":
				c = math.Pow(a, b)
			default:
				fmt.Printf("Error: Unrecognized symbol '%s'\n", el)
			}
			stack = append(stack, c)
		}
	}
	if len(stack) > 0 {
		return stack[len(stack)-1]
	}
	return 0
}

func rpn(queue string, args ...interface{}) error {
	fmt.Printf("%v\n", args)
	if len(args) > 1 {
		conn, err := goworker.GetConn()
		if err == nil {
			conn.Do("SET", args[0].(string), parseRPN(args[1].(string)))
		}
	}
	return nil
}

func init() {
	settings := goworker.WorkerSettings{
		URI:         "redis://localhost:6379/",
		Connections: 4,
		Queues:      []string{"myqueue"},
		Concurrency: 2,
		Namespace:   "resque:",
		Interval:    5.0,
	}
	goworker.SetSettings(settings)
	goworker.Register("RpnConverter", rpn)
}

func main() {
	if err := goworker.Work(); err != nil {
		fmt.Println("Error:", err)
	}
}
