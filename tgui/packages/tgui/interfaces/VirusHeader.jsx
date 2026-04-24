// Pure‑CSS scroller (no React timers)
import '../styles/VirusReadme.scss';

import { Box } from '../components';

/**
 * @param header     – static ASCII banner (string)
 * @param preText    – small intro text (string)
 * @param text       – main body (string)
 * @param lineDelay  – seconds between each line (number) –‑ default 0.04s
 */
export const VirusHeader = ({
  header = '',
  preText = '',
  text = '',
  lineDelay = 0.04,
}) => {
  const combined = [header, preText, text].join('\n').trimEnd();
  const lines = combined.split('\n');

  return (
    <Box className="virus-readme">
      {lines.map((line, i) => (
        <Box
          // each line fades in after i×lineDelay
          key={i}
          className="readme-line"
          style={{ animationDelay: `${i * lineDelay}s` }}
        >
          {line === '' ? '\u00A0' : line}
        </Box>
      ))}
    </Box>
  );
};
