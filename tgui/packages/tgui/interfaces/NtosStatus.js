import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Input, Section, Button, Flex } from '../components';

export const NtosStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper, lower } = data;

  return (
    <NtosWindow width={310} height={320}>
      <NtosWindow.Content>
        <Section>
          <Flex direction="column">
            <Flex.Item>
              <Button icon="times" content="Clear Alert" color="bad" onClick={() => act('stat_pic', { picture: 'blank' })} />
            </Flex.Item>
            <Flex.Item mt={1}>
              <Button icon="check-square-o" content="Default" onClick={() => act('stat_pic', { picture: 'default' })} />

              <Button icon="bell-o" content="Red Alert" onClick={() => act('stat_pic', { picture: 'redalert' })} />

              <Button icon="exclamation-triangle" content="Lockdown" onClick={() => act('stat_pic', { picture: 'lockdown' })} />

              <Button icon="exclamation-circle" content="Biohazard" onClick={() => act('stat_pic', { picture: 'biohazard' })} />

              <Button icon="space-shuttle" content="Shuttle ETA" onClick={() => act('stat_pic', { picture: 'shuttle' })} />
            </Flex.Item>
          </Flex>
        </Section>
        <Section>
          <Input
            fluid
            value={upper}
            onChange={(e, value) =>
              act('stat_update', {
                position: 'upper',
                text: value,
              })
            }
          />
          <br />
          <Input
            fluid
            value={lower}
            onChange={(e, value) =>
              act('stat_update', {
                position: 'lower',
                text: value,
              })
            }
          />
          <br />
          <Button fluid onClick={() => act('stat_send')} content="Update Status Displays" />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
