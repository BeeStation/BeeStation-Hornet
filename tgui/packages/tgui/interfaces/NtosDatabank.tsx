import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Stack, Section } from '../components';

type Data = {
  src?: string;
};

export const NtosDatabank = (props, context) => {
  const { data } = useBackend<Data>(context);
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
