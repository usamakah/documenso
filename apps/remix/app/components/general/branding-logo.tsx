import type { SVGAttributes } from 'react';

export type LogoProps = SVGAttributes<SVGSVGElement>;

export const BrandingLogo = ({ ...props }: LogoProps) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 700 120"
      role="img"
      aria-label="QER Document Portal"
      {...props}
    >
      <rect x="0" y="8" width="142" height="104" rx="16" fill="#708238" />
      <text
        x="71"
        y="79"
        textAnchor="middle"
        fill="#ffffff"
        fontFamily="Inter, Arial, sans-serif"
        fontSize="58"
        fontWeight="800"
        letterSpacing="-3"
      >
        QER
      </text>
      <text
        x="166"
        y="51"
        fill="currentColor"
        fontFamily="Inter, Arial, sans-serif"
        fontSize="30"
        fontWeight="750"
      >
        QER Documents
      </text>
      <text
        x="166"
        y="82"
        fill="#708238"
        fontFamily="Inter, Arial, sans-serif"
        fontSize="19"
        fontWeight="600"
      >
        Approval &amp; e-Signature Portal
      </text>
    </svg>
  );
};
