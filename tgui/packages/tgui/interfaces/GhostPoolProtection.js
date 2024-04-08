import { useBackend } from '../backend';
import { Button, Flex, Section, NoticeBox } from '../components';
import { Window } from '../layouts';

export const GhostPoolProtection = (props, context) => {
  const { act, data } = useBackend(context);
  const { events_or_midrounds, spawners, station_sentience, silicons, minigames } = data;
  return (
    <Window theme="admin" title="Ghost Pool Protection" width={400} height={285}>
      <Window.Content>
        <Flex grow={1} height="100%">
          <Section
            title="Options"
            buttons={
              <>
                <Button color="good" icon="plus-circle" content="Enable Everything" onClick={() => act('all_roles')} />
                <Button color="bad" icon="minus-circle" content="Disable Everything" onClick={() => act('no_roles')} />
              </>
            }>
            <NoticeBox danger>
              For people creating a sneaky event: If you toggle Station Created Sentience, people may catch on that admins have
              disabled roles for your event...
            </NoticeBox>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={events_or_midrounds ? 'good' : 'bad'}
                icon="meteor"
                content="Events and Midround Rulesets"
                onClick={() => act('toggle_events_or_midrounds')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={spawners ? 'good' : 'bad'}
                icon="pastafarianism"
                content="Ghost Role Spawners"
                onClick={() => act('toggle_spawners')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={station_sentience ? 'good' : 'bad'}
                icon="user-astronaut"
                content="Station Created Sentience"
                onClick={() => act('toggle_station_sentience')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={silicons ? 'good' : 'bad'}
                icon="robot"
                content="Silicons"
                onClick={() => act('toggle_silicons')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={minigames ? 'good' : 'bad'}
                icon="gamepad"
                content="Minigames"
                onClick={() => act('toggle_minigames')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={1.4}
                textAlign="center"
                color="orange"
                icon="check"
                content="Apply Changes"
                onClick={() => act('apply_settings')}
              />
            </Flex.Item>
          </Section>
        </Flex>
      </Window.Content>
    </Window>
  );
};
