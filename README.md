# scripts

Personal automation scripts and GitHub Actions.

## Contents

| File | Purpose |
|------|---------|
| `delete.sh` | AWS IAM resource cleanup |
| `.github/workflows/supabase-keepalive.yml` | Cron job that pings a Supabase free-tier project every 3 days to prevent auto-pause after 7 days of inactivity |

## Supabase Keep-Alive

Free-tier Supabase projects pause after 7 days of inactivity. The workflow `supabase-keepalive.yml` runs on a 3-day cron and queries a public-readable table to reset the inactivity timer.

### Setup

1. **Add repository secrets** (Settings → Secrets and variables → Actions → New repository secret):
   - `SUPABASE_URL` — `https://<project-ref>.supabase.co`
   - `SUPABASE_ANON_KEY` — the **anon** key (NOT the service role key)

2. **Optional** — add a repository variable to override the default table name:
   - Variable: `SUPABASE_TABLE` (defaults to `comments`)
   - The table must have an anon `SELECT` RLS policy so the anon key can read it.

3. **Verify it works**: Actions tab → Supabase Keep-Alive → Run workflow.

### Why anon key, never service role

The workflow performs a read-only public query. The anon key is designed to be public (it's already shipped in client-side bundles when used with RLS-enabled tables). Never put the service role key into a GitHub Action secret — it bypasses RLS and grants full database write access.

### Schedule

Runs at `0 9 */3 * *` UTC (every 3 days at 09:00 UTC). Adjust the cron in the workflow YAML if needed; stay below 7 days between runs.

### Cost

Zero. GitHub Actions minutes are free for public repos and within the 2,000-minute free tier for private repos. Each run takes ~5 seconds.
