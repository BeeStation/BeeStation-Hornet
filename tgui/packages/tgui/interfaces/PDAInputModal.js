import { Window } from '../layouts';
import { Flex, Box, Button, TextArea, Input } from '../components';
import { useBackend } from '../backend';

export const PDAInputModal = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, job, text, image, target = 'Select PDA', everyone, theme } = data;
  return (
    <Window title="Send PDA Message" theme={theme} width={600} height={290}>
      <Window.Content>
        <Box>
          <Box inline color="label">
            To:{' '}
          </Box>
          <Button
            ml={1}
            icon={target !== 'Select PDA' || everyone ? 'envelope' : null}
            content={everyone ? 'Everyone' : target}
            onClick={() => act('select')}
          />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Name:
          </Box>
          <Input value={name} maxLength={32} fluid onInput={(_, value) => act('set_name', { value })} />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Job:
          </Box>
          <Input value={job} maxLength={16} fluid onInput={(_, value) => act('set_job', { value })} />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Attachment:{' '}
          </Box>
          <Button ml={1} icon="camera" content={'Scan Photo'} color={image ? 'good' : null} onClick={() => act('photo')} />
        </Box>
        <Box mt={0.5}>
          <Box inline color="label">
            Message:
          </Box>
          <TextArea
            mt={0.25}
            value={text}
            maxLength={1024}
            fluid
            height="60px"
            onInput={(_, value) => act('set_message', { value })}
          />
        </Box>
        <Flex
          width="100%"
          height="45px"
          fontSize={1.75}
          style={{
            'justify-content': 'center',
            'align-content': 'center',
            'align-items': 'center',
          }}>
          <Flex.Item mr={1} grow={1} basis={0} height="80%">
            <Button align="center" height="100%" fluid content="Send" color="good" onClick={() => act('submit')} />
          </Flex.Item>
          <Flex.Item ml={1} grow={1} basis={0} height="80%">
            <Button align="center" height="100%" fluid content="Cancel" color="bad" onClick={() => act('cancel')} />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
