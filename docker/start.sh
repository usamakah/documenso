#!/bin/sh

set -eu

printf "🚀 Starting QER Document Portal...\n\n"

# ---------------------------------------------------------------------------
# QER management demo bootstrap
# ---------------------------------------------------------------------------
# Map Supabase/Vercel integration variables to Documenso's expected variables.
# POSTGRES_PRISMA_URL is the pooled Prisma runtime URL.
# POSTGRES_URL_NON_POOLING is supplied by the Supabase Vercel integration as
# the session-mode pooler URL, making it suitable for Prisma migrations on
# Vercel's IPv4 network.
if [ -z "${NEXT_PRIVATE_DATABASE_URL:-}" ]; then
    export NEXT_PRIVATE_DATABASE_URL="${POSTGRES_PRISMA_URL:-${POSTGRES_URL:-}}"
fi

if [ -z "${NEXT_PRIVATE_DIRECT_DATABASE_URL:-}" ]; then
    export NEXT_PRIVATE_DIRECT_DATABASE_URL="${POSTGRES_URL_NON_POOLING:-${POSTGRES_URL:-${POSTGRES_PRISMA_URL:-}}}"
fi


# Keep secrets out of the public fork. Prefer an explicit QER_DEMO_MASTER_SECRET.
# For this isolated management demo only, fall back to the private database URL
# injected by the dedicated Supabase/Vercel integration. This gives us a stable,
# non-public secret source without reusing any other application's credentials.
QER_SECRET_SOURCE="${QER_DEMO_MASTER_SECRET:-${NEXT_PRIVATE_DATABASE_URL:-}}"

if [ -n "${QER_SECRET_SOURCE:-}" ]; then
    derive_secret() {
        printf '%s' "${QER_SECRET_SOURCE}:$1" | sha256sum | awk '{print $1}'
    }

    export NEXTAUTH_SECRET="${NEXTAUTH_SECRET:-$(derive_secret auth)}"
    export NEXT_PRIVATE_ENCRYPTION_KEY="${NEXT_PRIVATE_ENCRYPTION_KEY:-$(derive_secret encryption-primary)}"
    export NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY="${NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY:-$(derive_secret encryption-secondary)}"
fi

# Resolve the deployed web URL automatically where possible.
if [ -z "${NEXT_PUBLIC_WEBAPP_URL:-}" ]; then
    if [ -n "${VERCEL_PROJECT_PRODUCTION_URL:-}" ]; then
        export NEXT_PUBLIC_WEBAPP_URL="https://${VERCEL_PROJECT_PRODUCTION_URL}"
    elif [ -n "${VERCEL_URL:-}" ]; then
        export NEXT_PUBLIC_WEBAPP_URL="https://${VERCEL_URL}"
    fi
fi

export NEXT_PRIVATE_INTERNAL_WEBAPP_URL="${NEXT_PRIVATE_INTERNAL_WEBAPP_URL:-${NEXT_PUBLIC_WEBAPP_URL:-http://localhost:3000}}"

# Real transactional email. Prefer a dedicated domain-scoped key in
# NEXT_PRIVATE_RESEND_API_KEY. RESEND_API_KEY is accepted as a Vercel
# Marketplace fallback.
if [ -z "${NEXT_PRIVATE_RESEND_API_KEY:-}" ] && [ -n "${RESEND_API_KEY:-}" ]; then
    export NEXT_PRIVATE_RESEND_API_KEY="${RESEND_API_KEY}"
fi

if [ -n "${NEXT_PRIVATE_RESEND_API_KEY:-}" ]; then
    export NEXT_PRIVATE_SMTP_TRANSPORT="${NEXT_PRIVATE_SMTP_TRANSPORT:-resend}"
fi

export NEXT_PRIVATE_SMTP_FROM_NAME="${NEXT_PRIVATE_SMTP_FROM_NAME:-QER Documents}"
export NEXT_PRIVATE_SMTP_FROM_ADDRESS="${NEXT_PRIVATE_SMTP_FROM_ADDRESS:-noreply@documents.qer.ae}"

# Demo-safe defaults.
export NEXT_PUBLIC_UPLOAD_TRANSPORT="${NEXT_PUBLIC_UPLOAD_TRANSPORT:-database}"
export NEXT_PUBLIC_FEATURE_BILLING_ENABLED="${NEXT_PUBLIC_FEATURE_BILLING_ENABLED:-false}"
export NEXT_PRIVATE_JOBS_PROVIDER="${NEXT_PRIVATE_JOBS_PROVIDER:-local}"
export DOCUMENSO_DISABLE_TELEMETRY="${DOCUMENSO_DISABLE_TELEMETRY:-true}"
export NEXT_PRIVATE_SIGNING_REASON="${NEXT_PRIVATE_SIGNING_REASON:-Approved and signed through QER Document Portal}"
export NEXT_PUBLIC_SIGNING_CONTACT_INFO="${NEXT_PUBLIC_SIGNING_CONTACT_INFO:-${NEXT_PUBLIC_WEBAPP_URL:-QER Document Portal}}"

# Generate an ephemeral self-signed signing certificate for the management
# demo when a real certificate has not been supplied. Each signed PDF embeds
# the certificate used at signing time. Production should replace this with a
# persistent organisation-owned certificate/HSM.
if [ -z "${NEXT_PRIVATE_SIGNING_LOCAL_FILE_CONTENTS:-}" ] && [ -z "${NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH:-}" ] && [ -n "${QER_SECRET_SOURCE:-}" ]; then
    CERT_DIR="/tmp/qer-documenso-cert"
    mkdir -p "$CERT_DIR"

    SIGNING_PASSPHRASE="$(derive_secret signing-certificate)"
    KEY_FILE="$CERT_DIR/key.pem"
    CRT_FILE="$CERT_DIR/cert.pem"
    P12_FILE="$CERT_DIR/qer-demo-signing.p12"

    openssl req -x509 -newkey rsa:2048 -sha256 -nodes \
        -keyout "$KEY_FILE" \
        -out "$CRT_FILE" \
        -days 365 \
        -subj "/C=AE/O=Quality Equipment Rental LLC/OU=IT/CN=QER Document Demo" >/dev/null 2>&1

    openssl pkcs12 -export \
        -out "$P12_FILE" \
        -inkey "$KEY_FILE" \
        -in "$CRT_FILE" \
        -passout "pass:$SIGNING_PASSPHRASE" >/dev/null 2>&1

    export NEXT_PRIVATE_SIGNING_TRANSPORT="local"
    export NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH="$P12_FILE"
    export NEXT_PRIVATE_SIGNING_PASSPHRASE="$SIGNING_PASSPHRASE"
fi

# Validate required runtime configuration before touching the database.
if [ -z "${NEXT_PRIVATE_DATABASE_URL:-}" ] || [ -z "${NEXT_PRIVATE_DIRECT_DATABASE_URL:-}" ]; then
    printf "❌ Database connection is not configured. Connect the dedicated QER Supabase project to this Vercel project.\n"
    exit 1
fi

if [ -z "${NEXTAUTH_SECRET:-}" ] || [ -z "${NEXT_PRIVATE_ENCRYPTION_KEY:-}" ] || [ -z "${NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY:-}" ]; then
    printf "❌ QER demo secrets are not configured. Connect the dedicated Supabase project or add QER_DEMO_MASTER_SECRET.\n"
    exit 1
fi

# 🔐 Check certificate configuration
printf "🔐 Checking certificate configuration...\n"

CERT_PATH="${NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH:-/opt/documenso/cert.p12}"

if [ -f "$CERT_PATH" ] && [ -r "$CERT_PATH" ]; then
    printf "✅ Signing certificate is ready.\n"
elif [ -n "${NEXT_PRIVATE_SIGNING_LOCAL_FILE_CONTENTS:-}" ]; then
    printf "✅ Base64 signing certificate is configured.\n"
else
    printf "⚠️ Signing certificate is unavailable; document signing will not work.\n"
fi

printf "🗄️  Running database migrations...\n"
npx prisma migrate deploy --schema ../../packages/prisma/schema.prisma

printf "🌟 Starting QER Document Portal server...\n"
HOSTNAME=0.0.0.0 node build/server/main.js
