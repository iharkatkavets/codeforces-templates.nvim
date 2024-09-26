package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	// Using bufio for fast input
	reader := bufio.NewReader(os.Stdin)
	writer := bufio.NewWriter(os.Stdout)
	defer writer.Flush()

	// Example: Reading multiple integers in a single line
	line, _ := reader.ReadString('\n')
	line = strings.TrimSpace(line)
	nums := strings.Split(line, " ")

	// Converting string input to integers
	var arr []int
	for _, num := range nums {
		val, _ := strconv.Atoi(num)
		arr = append(arr, val)
	}

	// Example: Solving something with the input array
	// This is where your main logic goes.
	result := solve(arr)

	// Output the result
	fmt.Fprintln(writer, result)
}

// Example solve function to handle the logic
func solve(arr []int) int {
	// Your solution logic here
	// For example, returning the sum of the array
	sum := 0
	for _, val := range arr {
		sum += val
	}
	return sum
}
