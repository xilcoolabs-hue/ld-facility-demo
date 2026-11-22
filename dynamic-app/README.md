# LDC Facility Management — enquiries and dynamic admin

This application preserves the approved LDC website design, logo, eight ordered categories and images. It replaces the compiled frontend demo with editable public HTML, a server API and a protected admin interface.

## Status

Implementation is ready for account configuration. **No production database has been provisioned or connected in this workspace.** The existing public preview has not been replaced. Missing configuration returns HTTP 503; the website never claims to have saved an enquiry unless the database confirms it.

## Features

- Enquiry collection only: name, email, phone, suburb/postcode, service, property type, message and contact consent. No booking calendar or automatic appointment confirmation.
- PostgreSQL persistence in Supabase; request IDs prevent duplicate submissions on network retry.
- Owner-approved admin accounts using Supabase Auth and server-validated admin membership.
- HttpOnly, Secure, SameSite=Strict session cookies; refresh flow; server-only database secret.
- Enquiry search, status filtering, 50-record pagination, status/notes edits, archive state and current-page CSV export.
- Add/edit/hide/reorder services and update descriptions/photos.
- Upload validated JPEG, PNG or WebP images up to 3 MB.
- Change contact numbers, Facebook/Instagram URLs, homepage headline/introduction/image and About photo.
- Customer enquiries are never readable through anonymous or ordinary authenticated database clients.
- Durable per-IP-hash rate limits and honeypot; no raw client IP is stored.

## Deploy to the owner's Vercel and Supabase accounts

1. Connect the owner's Supabase and Vercel accounts in ChatGPT to allow assisted provisioning. Do not paste passwords, database credentials or service-role keys into chat or GitHub.
2. Create/select a Supabase project in a region appropriate for the business and its customer data. This requires the owner's account; do not create a paid project without confirming its cost.
3. Execute `supabase/001_schema.sql`, then `supabase/002_seed.sql`. Seed inserts are idempotent and do not overwrite later admin edits.
4. Disable public sign-up in Supabase Auth. Create/invite the owner's admin user through Supabase Authentication. Put the owner's login email into `supabase/add-admin.sql` and execute it. No admin user is granted access automatically.
5. Import the GitHub repository into Vercel and set **Root Directory: `dynamic-app`**, Framework Preset **Other**, Build Command **`npm run build`**, Output Directory **`public`**. Use Node 22 or later. `vercel.json` configures the same-origin server API.
6. Add server-side Vercel environment variables from `.env.example`: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (Supabase's legacy server-only service-role JWT), `SITE_ORIGIN`, `RATE_LIMIT_SALT`. Generate the salt cryptographically. Set `SITE_ORIGIN` to the exact deployed HTTPS origin, without a path; preview deployments need their own origin. Never set these as `NEXT_PUBLIC_*` variables.
7. Redeploy. Check `/api/public` returns the eight seeded services and settings. Sign in at `/admin/`; verify unauthenticated `/api/admin/enquiries` returns 401.
8. Submit one clearly labelled test enquiry; confirm it appears after sign-in and survives a page reload. Update status and notes. Test a service edit/photo upload; verify it appears on the public website.
9. Connect the custom domain and update `SITE_ORIGIN` to that domain; redeploy. Enable production only after checking real database persistence and access control. Existing preview remains available until then.

## Local development

Node 22+; run `npm ci` to install the SMTP email dependency.

```sh
npm run check
npm test
npm run build
node --env-file=.env dev-server.js
```

Copy `.env.example` to `.env` and configure a development Supabase project. Use `SITE_ORIGIN=http://localhost:3000` for local development. On a host, use HTTPS so the session cookies are Secure. Tests use an isolated mock Supabase HTTP provider, not production customer records.

## Validation performed

Automated tests cover successful database-backed submission/listing, duplicate request IDs, persistence failure, input/consent checks, CSRF origin checks, rate limiting, rejected non-admin accounts, secure cookies, admin status/notes updates, service edits, missing configuration and unsafe upload/URL rejection.

Live Supabase migration, Vercel deployment, real email/password sign-in, actual image upload and browser end-to-end enquiry delivery are pending account connection. Local tests do not prove production provisioning.

## Data and maintenance

- Tables: `admin_users`, `services`, `site_settings`, `enquiries`, `rate_limits`.
- All tables have RLS enabled and direct grants revoked from anon/authenticated roles; the server authorizes each admin request before using its secret.
- Storage bucket `site-images` contains public marketing photos only. Do not upload customer enquiry documents, personal IDs or private images.
- Enquiries store contact details and notes; agree a retention period with the business owner. This implementation archives records rather than permanently deleting them.
- Configure SMTP_HOST, SMTP_PORT (465 or 587), SMTP_USER, SMTP_PASSWORD, EMAIL_FROM and ENQUIRY_TO to send notifications to the business mailbox. The sender must be allowed by the mailbox provider. Add provider-supplied SPF/DKIM DNS records.
- Enquiry persistence happens before email sending. SMTP failure never loses the enquiry; admin shows notification as Pending and provides a retry button. "Sent" means accepted by the SMTP server, not guaranteed inbox delivery.
- No automated retry scheduler is enabled; pending notifications can be retried from the protected admin panel.
- Admin photo replacement does not delete old uploaded files. Periodically review unused marketing images.
- The prior compiled Next.js demo bundles and unauthenticated demo admin are not included in this app.

## Hostinger alternative

The Node HTTP entry point is `dev-server.js`, with `npm start`. For managed plans that require a named framework, use the Express adapter `hostinger-server.js` and start it with `npm run start:hostinger`. Node 22+ is required. The same Supabase credentials and SMTP settings still apply. Hostinger's included MySQL database is **not** a drop-in replacement for this Supabase/PostgreSQL/Auth implementation; choosing a MySQL-only deployment requires a database/auth adapter and its own validation. Do not buy a static Website Builder-only plan for this backend.
