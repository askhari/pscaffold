-- +goose Up
-- Case-insensitive text for emails and handles.
CREATE EXTENSION IF NOT EXISTS citext;

-- +goose Down
DROP EXTENSION IF EXISTS citext;
