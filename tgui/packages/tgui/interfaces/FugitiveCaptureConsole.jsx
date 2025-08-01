import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const FugitiveCaptureConsole = (_) => {
  const { act, data } = useBackend();
  const {
    linked = false,
    locked = false,
    open = false,
    prisoner_valid = false,
    prisoner_ref = null,
    targets = [],
  } = data;
  return (
    <Window width={380} height={300} theme="neutral">
      <Window.Content scrollable>
        <Section
          title="Containment Console"
          buttons={
            <>
              <Button
                content={open ? 'Open' : 'Closed'}
                disabled={locked}
                selected={open}
                onClick={() => act('toggle_open')}
              />
              <Button
                icon={locked ? 'lock' : 'unlock'}
                content={locked ? 'Locked' : 'Unlocked'}
                selected={locked}
                disabled={open}
                onClick={() => act('toggle_lock')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Fugitive Containment Chamber"
              color={linked ? 'good' : 'bad'}
              buttons={
                !linked && (
                  <Button content="Reconnect" onClick={() => act('scan')} />
                )
              }
            >
              {linked ? 'Connected' : 'Not Connected'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {targets.map((fugitive) => (
          <Section
            title={`Wanted Fugitive: ${fugitive.name}`}
            key={fugitive.ref}
          >
            <LabeledList>
              <LabeledList.Item
                label="Status"
                color={fugitive.captured || !fugitive.living ? 'good' : 'bad'}
              >
                {fugitive.captured
                  ? fugitive.captured_living
                    ? 'Captured (Alive)'
                    : 'Captured (Dead)'
                  : fugitive.living
                    ? 'At Large'
                    : 'Dead'}
              </LabeledList.Item>
              {fugitive.location ? (
                <LabeledList.Item label="Last known location">
                  {fugitive.location}
                </LabeledList.Item>
              ) : null}
            </LabeledList>
            {prisoner_valid &&
            prisoner_ref === fugitive.ref &&
            prisoner_ref !== null ? (
              <Button
                fluid
                mt={1}
                content="Permanently Capture Fugitive"
                disabled={!linked || !locked || open || !prisoner_valid}
                textAlign="center"
                color="bad"
                onClick={() => act('capture')}
              />
            ) : null}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
