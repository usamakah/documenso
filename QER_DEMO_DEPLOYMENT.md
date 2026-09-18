# QER Document Approval & e-Signature Portal — Management Demo

> Deployment trigger: QER Vercel production branch initialized.

This branch is an isolated QER management demo based on Documenso.

## Isolation

- GitHub repository: `usamakah/documenso`
- Demo branch: `qer-management-demo`
- Supabase project: `qer-documents-demo`
- Email sending domain: `documents.qer.ae`
- No Microsoft Dynamics GP integration
- Do not connect this project to CollabLinker resources
- Do not use `collablinker.me` as an email domain

## Vercel

Import `usamakah/documenso` as a separate Vercel project such as `qer-documents-demo`.

Set the production branch to:

```
qer-management-demo
```

The repository contains `Dockerfile.vercel`; the demo runs using Vercel's container runtime.

## Database

A separate Supabase project named `qer-documents-demo` has been created in `ap-south-1`.

Connect only this Supabase project to the QER Vercel project through the Supabase/Vercel integration.

The runtime automatically maps:

- `POSTGRES_PRISMA_URL` -> `NEXT_PRIVATE_DATABASE_URL`
- `POSTGRES_URL_NON_POOLING` -> `NEXT_PRIVATE_DIRECT_DATABASE_URL`

Prisma migrations run automatically when the container starts.

## Required QER demo secret

Create one sensitive Vercel environment variable:

```
QER_DEMO_MASTER_SECRET=<long random value, at least 32 characters>
```

The container derives separate values for:

- authentication
- primary encryption
- secondary encryption
- demo signing-certificate passphrase

Do not commit the master secret to GitHub.

## Signing

For this management demo, if no organisation-owned signing certificate is provided, the container generates a self-signed PKCS#12 certificate at startup.

This is suitable for demonstrating:

- document signing
- completed signed PDFs
- audit trails
- signing workflow

For production, replace it with a persistent organisation-owned certificate or supported HSM/CSC signing service.

## Transactional email

Documenso is configured to use Resend instead of a local development mail catcher.

Sender:

```
QER Documents <noreply@documents.qer.ae>
```

Recommended secret:

```
NEXT_PRIVATE_RESEND_API_KEY=<domain-scoped Resend sending key>
```

A generic Vercel Marketplace `RESEND_API_KEY` is supported as a fallback, but a domain-scoped key restricted to `documents.qer.ae` is preferred.

### DNS records for documents.qer.ae

DKIM TXT:

```
Name: resend._domainkey.documents
Value: p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJoRWo7rJba1+xQHxFSEUwfpQOLQ7Rl4xLAEnHTQ1LCyndtx5YAUSPWT05W1bA2e4q8KCuTP7sighodrQ/fNVSX2FjMRVY36zENAYcTerUS3KoCkqel7kwtYT0dsDkWV+ze1k2xudab/SPyKyaDmjtQiZBQfKZ5MLOEDsvVaGvZwIDAQAB
```

Return-path MX:

```
Name: send.documents
Value: feedback-smtp.eu-west-1.amazonses.com
Priority: 10
```

SPF TXT:

```
Name: send.documents
Value: v=spf1 include:amazonses.com ~all
```

Return-path CNAME:

```
Name: rsend.documents
Value: send.forge.rmta.net
```

These records are scoped to the `documents.qer.ae` subdomain and must not replace QER's existing Google Workspace MX records on `qer.ae`.

## Demo workflow

1. QER employee signs in.
2. Employee uploads a PDF.
3. Employee adds one or more recipients.
4. Recipient role can be Approver, Signer, Viewer, etc.
5. Document is sent.
6. Manager receives a real email notification.
7. Manager opens and approves/signs.
8. Final signed PDF is generated.
9. Document history/audit trail can be reviewed.
10. Completion email is delivered to the relevant recipients.

## Management demo test checklist

Before presenting:

- [ ] Vercel deployment is healthy.
- [ ] Database migrations complete without errors.
- [ ] QER login branding is visible.
- [ ] Real QER logo/brand treatment is visible.
- [ ] Test user can register/sign in.
- [ ] Verification/password-reset email reaches a real inbox.
- [ ] PDF upload succeeds.
- [ ] Approval email reaches the manager.
- [ ] Signing page opens from the email.
- [ ] Approval/signature completes.
- [ ] Final PDF downloads correctly.
- [ ] Audit trail displays the expected events.
- [ ] Completion email reaches the recipient.
- [ ] Ordinary users only see documents permitted by the configured team/document visibility model.

## After the first admin account is created

For a controlled management demo, disable public signup in Vercel:

```
NEXT_PUBLIC_DISABLE_SIGNUP=true
```

Then invite/create only the users needed for the presentation.
