import { resolveAsset } from '../../assets';
import { Box, Section, Stack } from '../../components';

type Props = {
  name: string;
  asset?: string;
  color?: string;
};

export const AntagInfoHeader = (props: Props) => {
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
              style={{
                msInterpolationMode: 'nearest-neighbor',
                imageRendering: 'pixelated',
              }}
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
