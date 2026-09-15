# feeds
A simple Caddy container that serves GTFS Schedule and GTFS-realtime files,
published behind Traefik at https://feeds.simovi.org.

## Layout
Feeds are stored as `<agency>/<feed-type>/<file>` under `GTFS_DATA_PATH`
(default `./gtfs-data`) and served at the matching URL, e.g.
`https://feeds.simovi.org/incofer/schedule/gtfs.zip`. Files are overwritten in
place, so every URL is stable; `Cache-Control: no-cache` forces clients to
revalidate against the ETag rather than serve a stale feed.

## Index page
`/` serves `index.html`, a Go template rendered by Caddy's `templates`
directive. It lists every feed currently on disk with its size and last-modified
date, so no regeneration step is needed after an upload.

The file is mounted at `/etc/caddy/site/index.html` rather than into the site
root, because `/srv` is a read-only mount and Docker cannot create a mountpoint
inside it. `templates { root /srv }` points the template's file functions back
at the feed volume. Templates are deliberately scoped to the index handler only:
template evaluation can read files and the environment, so it must never be
applied to the feed payloads.

Directory listing remains disabled — only `/` and exact file paths are served.

## Uploading
```
./upload.sh <agency> <feed-type> <local-file>
./upload.sh incofer schedule ./build/incofer-feed.zip
```

## Running
```
cp .env.example .env   # then adjust as needed
docker compose up -d
```
