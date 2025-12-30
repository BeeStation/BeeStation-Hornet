import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
  uplink_note: string | undefined;
  stash_location: boolean;
  valid_converts?: string[];
};
export const AntagInfoBrother = (_props) => {
  const { data } = useBackend<Info>();
  const {
    objectives,
    antag_name,
    brothers,
    uplink_note,
    stash_location,
    valid_converts,
  } = data;
  return (
    <Window
      width={620}
      height={
        250 +
        (uplink_note ? 100 : 0) +
        (stash_location ? 100 : 0) +
        (valid_converts && valid_converts.length > 0 ? 100 : 0)
      }
      theme="syndicate"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader
              name={
                brothers
                  ? `${antag_name || 'Blood Brother'} of ${brothers}`
                  : antag_name || 'Blood Brother'
              }
              asset="traitor.png"
            />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
          {!!uplink_note && (
            <Stack.Item>
              <Section title="Uplink Code">{uplink_note}</Section>
            </Stack.Item>
          )}
          {stash_location &&
            (!valid_converts || valid_converts.length === 0) && (
              <Stack.Item>
                <Section title="Recruitment">
                  You have a hidden stash at {stash_location} which might
                  contain items important to your objectives. It may also
                  contain a conversion implant, but this will not work as there
                  are no valid targets for conversion.
                </Section>
              </Stack.Item>
            )}
          {stash_location && !!valid_converts && valid_converts.length > 0 && (
            <Stack.Item>
              <Section title="Recruitment">
                You are able to recruit a team-member. Visit your hidden stash
                at {stash_location} to find an implant which will grant your
                recruitee with everything they need to make themselves useful.
                <br />
                The conversion implant will not work on anyone, the victim must
                have a susceptible mind. The identified targets are as follows:
                <ul>
                  {valid_converts.map((target) => (
                    <li key={target}>{target}</li>
                  ))}
                </ul>
              </Section>
            </Stack.Item>
          )}
          {!stash_location && !!valid_converts && valid_converts.length > 0 && (
            <Stack.Item>
              <Section title="Recruitment">
                <br />
                The conversion implant will not work on anyone, the victim must
                have a susceptible mind. The identified targets are as follows:
                <ul>
                  {valid_converts.map((target) => (
                    <li key={target}>{target}</li>
                  ))}
                </ul>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
