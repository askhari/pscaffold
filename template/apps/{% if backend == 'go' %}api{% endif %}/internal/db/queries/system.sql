-- name: DatabaseNow :one
SELECT now()::timestamptz AS now;
