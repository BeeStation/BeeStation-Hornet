import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  src?: string;
};

export const NtosDatabank = (props) => {
  const { data } = useBackend<Data>();
  const { src } = data;

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>
        <Stack fill vertical justify="space-between">
          <Section fill>
            <iframe src={src} height="100%" width="100%" frameBorder="0" />
          </Section>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
