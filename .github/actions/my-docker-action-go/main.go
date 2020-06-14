package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Printf("::set-output name=time::%s", time.Now())
}
