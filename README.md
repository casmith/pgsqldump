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

## PostgreSQL version
`pg_dump` cannot dump a server newer than itself. The client major is pinned
with the `PG_MAJOR` build arg (17); raise it before upgrading servers past it.

## Releases
Versions come from conventional commits (`feat:` → minor, `fix:` → patch) and
are tagged in git by CI. Dependabot proposes Alpine and action updates.
