// Package config loads runtime configuration from environment variables.
package config

import (
	"fmt"

	"github.com/caarlos0/env/v11"
)

// Config is the API's runtime configuration.
type Config struct {
	DatabaseURL string `env:"DATABASE_URL,required,notEmpty"`
	Port        int    `env:"API_PORT" envDefault:"8080"`
}

// Load reads Config from the environment.
func Load() (Config, error) {
	cfg, err := env.ParseAs[Config]()
	if err != nil {
		return Config{}, fmt.Errorf("load config: %w", err)
	}
	return cfg, nil
}
