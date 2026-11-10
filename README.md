# pgsqldump
A docker image for backing up remote postgres databases. Handy for kubernetes.

## Images
- `casmith/pgsqldump`: runs `pg_dump` and writes `/pgsqldump/<DB_NAME>_<timestamp>.sql.gz`
- `casmith/pgsqlrestore`: runs `pg_restore` against `FILE`

## Environment
| Variable | Purpose |
|---|---|
| `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME` | connection (`PGSQL_ENV_*` variants also accepted) |
| `FLAGS` | extra `pg_dump`/`pg_restore` flags, e.g. `-Fc` for the custom format `pg_restore` reads |
| `FILE` | restore only: dump file to restore |
| `RETENTION_DAYS` | dump only: after a successful dump, delete this database's dumps older than N days (unset or `0` keeps everything) |
| `KEEP_MIN` | dump only: the newest N dumps are never deleted by retention (default `3`) |

## Failure handling
The dump is written to a `.partial` file and renamed into place only when `pg_dump`
and `gzip` both succeed, the archive passes `gzip -t`, and it isn't empty. Any
failure exits non-zero, so the Kubernetes job is marked failed instead of leaving
a truncated dump behind. Retention runs only after a successful dump.

## PostgreSQL version
`pg_dump` cannot dump a server newer than itself. The client major is pinned
with the `PG_MAJOR` build arg (18); raise it before upgrading servers past it.
A newer client still dumps and restores older servers.

## Releases
Versions come from conventional commits (`feat:` → minor, `fix:` → patch) and
are tagged in git by CI. Dependabot proposes Alpine and action updates.
