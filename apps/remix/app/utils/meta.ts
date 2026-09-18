import { i18n, type MessageDescriptor } from '@lingui/core';

export const appMetaTags = (title?: MessageDescriptor) => {
  const description =
    'QER Document Approval & e-Signature Portal for secure internal document routing, approvals, signatures, and audit history.';

  return [
    {
      title: title ? `${i18n._(title)} - QER Documents` : 'QER Document Approval & e-Signature Portal',
    },
    {
      name: 'description',
      content: description,
    },
    {
      name: 'keywords',
      content: 'QER, Quality Equipment Rental, document approval, electronic signature, audit trail, document workflow',
    },
    {
      name: 'author',
      content: 'Quality Equipment Rental LLC',
    },
    {
      name: 'robots',
      content: 'noindex, nofollow',
    },
    {
      property: 'og:title',
      content: 'QER Document Approval & e-Signature Portal',
    },
    {
      property: 'og:description',
      content: description,
    },
    {
      property: 'og:type',
      content: 'website',
    },
    {
      name: 'twitter:card',
      content: 'summary',
    },
    {
      name: 'twitter:description',
      content: description,
    },
  ];
};
