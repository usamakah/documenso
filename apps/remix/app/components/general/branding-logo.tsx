import type { SVGAttributes } from 'react';

export type LogoProps = SVGAttributes<SVGSVGElement>;

export const BrandingLogo = ({ ...props }: LogoProps) => {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 640 292"
      role="img"
      aria-label="QER - Equipment to Build Better"
      {...props}
    >
      <image href="/qer-logo.svg" width="640" height="292" preserveAspectRatio="xMidYMid meet" />
    </svg>
  );
};
