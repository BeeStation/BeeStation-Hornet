// Adapted From NSV13

import { clamp, toFixed } from 'common/math';

import { useBackend, useSharedState } from '../backend';
import { Button, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const GenPop = (props) => {
  const { act, data } = useBackend();

  const { desired_name = '', desired_details = '', crime_list = {} } = data;

  // Local state for the time of the prisoner.
  const [time, setTime] = useSharedState('time', 0);

  // Local state to determine which modifiers we have active
  const [resistedMod, setResistedMod] = useSharedState('resisted', false);
  const [attemptedMod, setAttemptedMod] = useSharedState('attempted', false);
  const [elevatedMod, setElevatedMod] = useSharedState(
    'repeat_offender',
    false,
  );

  // Local state for the name of the crime being issued
  const [crimeName, setCrimeName] = useSharedState('crimeName', 'No crime');

  // Local state for the name of the crime details
  const [crimeDetails, setCrimeDetails] = useSharedState(
    'crimeDetails',
    'No details provided',
  );

  // Local state for the current category that we are browsing
  const [crimeCategory, setCrimeCategory] = useSharedState(
    'crimeCategory',
    crime_list && crime_list.length > 0 ? Object.keys(crime_list)[0] : null,
  );

  const resetLocalState = () => {
    // Set back to the default crime name
    setCrimeName('No crime');
    setTime(3000);
    setCrimeDetails('No details provided');
    setResistedMod(false);
    setAttemptedMod(false);
    setElevatedMod(false);
  };

  const getProcessedTime = () => {
    return (
      (time +
        // Back to major crime (9000)
        (attemptedMod ? (time >= 36000 ? -27000 : -3000) : 0) +
        // Set to 36000 if a crime over 900 deciseconds was repeated.
        (elevatedMod ? (time >= 9000 ? 360000 - time : 3000) : 0)) *
      // Resisting arrest applies to everything at the end
      (resistedMod ? 1.2 : 1)
    );
  };

  return (
    <Window resizable width={625} height={400}>
      <Window.Content scrollable>
        <Section
          title="Prisoner ID Printer:"
          buttons={
            <>
              <Button
                icon="id-card-alt"
                content={
                  data.desired_name ? data.desired_name : 'Enter Prisoner Name'
                }
                onClick={() => act('prisoner_name')}
              />
              <Button
                icon="print"
                content="Finalize ID"
                tooltip={
                  attemptedMod && time <= 3000
                    ? 'Attempted minor crimes must be met with fines!'
                    : crimeName === 'No crime'
                      ? 'You have not selected a crime.'
                      : !data.desired_name
                        ? 'The prisoner requires an identifier for their card.'
                        : null
                }
                color="good"
                disabled={
                  !data.canPrint ||
                  (attemptedMod && time <= 3000) ||
                  crimeName === 'No crime' ||
                  !data.desired_name
                }
                onClick={() => {
                  act('print', {
                    desired_sentence: getProcessedTime(),
                    desired_crime:
                      (attemptedMod ? 'Attempted ' : '') +
                      crimeName +
                      (elevatedMod ? ' (Repeat offender)' : ''),
                  });
                  // Reset to the default state
                  resetLocalState();
                }}
              />
            </>
          }
        >
          <Button
            icon="fast-backward"
            onClick={() => setTime(clamp(time - 1200, 0, 36000))}
          />
          <Button
            icon="backward"
            onClick={() => setTime(clamp(time - 600, 0, 36000))}
          />
          {String(getProcessedTime() / 600)} min:{' '}
          <Button
            icon="forward"
            onClick={() => setTime(clamp(time + 600, 0, 36000))}
          />
          <Button
            icon="fast-forward"
            onClick={() => setTime(clamp(time + 1200, 0, 36000))}
          />
          <br />
          {Object.keys(crime_list)
            // Remove any categories with no crimes so we don't bluescreen in the event that a category has no crimes.
            .filter((crime) => crime_list[crime].length > 0)
            .map((category) => (
              <Button
                key={category}
                icon={
                  category === 'Capital'
                    ? 'exclamation-triangle'
                    : 'hourglass-start'
                }
                content={category}
                color={crime_list[category][0].colour}
                onClick={() => {
                  // Set the crime category
                  setCrimeCategory(category);
                  // Set the default crime length
                  setTime(crime_list[category][0].sentence);
                }}
              />
            ))}
          <br />
        </Section>
        <Section title="Infractions">
          {Object.keys(crime_list[crimeCategory] || {}).map((key) => {
            let value = crime_list[crimeCategory][key];
            return (
              <Button
                key={key}
                content={value.name}
                color={value.colour}
                icon={value.icon}
                tooltip={value.tooltip}
                selected={crimeName === value.name}
                onClick={() => {
                  if (crimeName === value.name) {
                    setCrimeName('No crime');
                    setTime(3000);
                    return;
                  }
                  setTime(value.sentence);
                  setCrimeName(value.name);
                }}
              />
            );
          })}
        </Section>
        <Section title="Modifiers">
          <Button
            icon="hand-paper"
            content="Attempted crime"
            color="orange"
            selected={attemptedMod}
            onClick={() => {
              setAttemptedMod(!attemptedMod);
            }}
          />
          <Button
            icon="thumbs-down"
            content="Resisted Arrest"
            color="orange"
            selected={resistedMod}
            onClick={() => {
              setResistedMod(!resistedMod);
            }}
          />
          <Button
            icon="redo"
            content="Elevated Sentencing"
            color="bad"
            selected={elevatedMod}
            onClick={() => {
              setElevatedMod(!elevatedMod);
            }}
          />
        </Section>
        <Section title="Preview">
          Identity: {String(data.desired_name || 'No name entered')} <br />
          Crime: {String(crimeName)} <br />
          Sentence: {String(getProcessedTime() / 600)} min <br />
          <Section
            title="Crime details"
            buttons={
              <Button
                content="Edit"
                icon="pen"
                onClick={() => act('edit_details')}
              />
            }
          >
            {desired_details}
          </Section>
        </Section>
        <Section title="Prison Management:">
          {Object.keys(data.allPrisoners).map((key) => {
            let value = data.allPrisoners[key];
            return (
              <Section
                key={value}
                title={value.name}
                buttons={
                  <>
                    <Button
                      icon="backward"
                      onClick={() =>
                        act('adjust_time', { adjust: -60, id: value.id })
                      }
                    />
                    <Button
                      icon="forward"
                      onClick={() =>
                        act('adjust_time', { adjust: 60, id: value.id })
                      }
                    />
                    <Button
                      icon="check"
                      content="Release"
                      color="good"
                      onClick={() => act('release', { id: value.id })}
                    />
                    <Button
                      icon="running"
                      content="Escaped"
                      color="bad"
                      onClick={() => act('escaped', { id: value.id })}
                    />
                  </>
                }
              >
                Incarcerated for: {value.crime} <br />
                <ProgressBar
                  value={(value.served_time / value.sentence) * 100 * 0.01}
                  ranges={{
                    good: [0.99, Infinity],
                    average: [0.4, 0.99],
                    bad: [-Infinity, 0.4],
                  }}
                >
                  {toFixed(value.served_time / 60)} min /{' '}
                  {toFixed(value.sentence / 60)} min
                </ProgressBar>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
