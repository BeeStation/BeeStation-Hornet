import { Box, Section, Stack } from '../../components';
import { resolveAsset } from '../../assets';

type Props = {
  name: string;
  asset?: string;
  color?: string;
};

export const AntagInfoHeader = (props: Props, _context) => {
  const { name, asset, color } = props;
  return (
    <Section>
      <Stack className="AntagInfo__header_outer">
        {!!asset && (
          <Stack.Item className="AntagInfo__header_img">
            <Box
              inline
              as="img"
              src={resolveAsset(asset)}
              width="64px"
              style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
            />
          </Stack.Item>
        )}
        <Stack.Item grow className="AntagInfo__header_text">
          <h1>
            You are the{' '}
            <Box inline textColor={color || 'red'}>
              {name}
            </Box>
            !
          </h1>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
