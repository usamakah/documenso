# QER Document Portal - Vercel Demo

This branch contains the QER-branded Documenso management demo.

## Hosting model

- Vercel container deployment via `Dockerfile.vercel`
- External PostgreSQL database
- Database-backed document storage for the demo
- Local Documenso signing transport with a Base64 PKCS#12 certificate
- Email/password authentication
- Billing disabled
- Anonymous telemetry disabled

## Required runtime environment variables

```
NEXTAUTH_SECRET=
NEXT_PRIVATE_ENCRYPTION_KEY=
NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY=

NEXT_PUBLIC_WEBAPP_URL=
NEXT_PRIVATE_INTERNAL_WEBAPP_URL=

NEXT_PRIVATE_DATABASE_URL=
NEXT_PRIVATE_DIRECT_DATABASE_URL=

NEXT_PUBLIC_UPLOAD_TRANSPORT=database

NEXT_PRIVATE_SIGNING_TRANSPORT=local
NEXT_PRIVATE_SIGNING_LOCAL_FILE_CONTENTS=
NEXT_PRIVATE_SIGNING_PASSPHRASE=
NEXT_PRIVATE_SIGNING_REASON=Approved and signed through QER Document Portal
NEXT_PUBLIC_SIGNING_CONTACT_INFO=

NEXT_PRIVATE_SMTP_TRANSPORT=resend
NEXT_PRIVATE_RESEND_API_KEY=
NEXT_PRIVATE_SMTP_FROM_NAME=QER Documents
NEXT_PRIVATE_SMTP_FROM_ADDRESS=

NEXT_PUBLIC_FEATURE_BILLING_ENABLED=false
NEXT_PUBLIC_DISABLE_SIGNUP=false
DOCUMENSO_DISABLE_TELEMETRY=true
NEXT_PRIVATE_JOBS_PROVIDER=local
```

## Database connection recommendation

For Supabase:
- application runtime: pooled connection string
- Prisma migrations: session/direct connection string appropriate to the hosting network

Do not reuse an existing production application's database.

## Demo workflow

Employee -> Upload document -> Add approver/signer -> Send -> Manager approval -> Signature -> Completed PDF -> Audit trail.

## Safety

This demo is intentionally isolated from Microsoft Dynamics GP and QER production systems.
