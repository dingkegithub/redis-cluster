package main

import (
	"log"

	"github.com/go-redis/redis"
)

func ClusterDaemon(addrs []string) error {

	redisCli := redis.NewClusterClient(&redis.ClusterOptions{
		Addrs: addrs,
	})

	err := redisCli.Set("name", "golang client", 0).Err()
	if err != nil {
		return err
	}

	res, err := redisCli.Get("name").Result()
	if err != nil {
		return err
	}

	log.Println("result: ", res)
	return nil
}
