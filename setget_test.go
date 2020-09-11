package main

import "testing"

func TestClusterDaemon(t *testing.T) {
	addrs := []string{
		"10.120.13.202:6379",
		"10.120.13.202:6380",
		"10.120.13.207:6379",
		"10.120.13.207:6380",
		"10.120.13.209:6379",
		"10.120.13.209:6380",
	}

	err := ClusterDaemon(addrs)
	if err != nil {
		t.FailNow()
	}
}
