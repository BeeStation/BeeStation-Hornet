import { useBackend, useLocalState } from '../backend';
import { Button, Dimmer, LabeledList, NoticeBox, Icon, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

const ProbingConsoleConfirmation = (_props, context) => {
  const { act } = useBackend(context);
  const [customObjective, setCustomObjective] = useLocalState(context, 'customObjective', '');
  const [experimentPopup, setExperimentPopup] = useLocalState(context, 'experimentPopup', 0);
  return (
    <Dimmer>
      <Stack align="baseline" textAlign="center" fontSize="14px" vertical>
        <Stack.Item>
          <Icon color="yellow" name="brain" size={5} />
        </Stack.Item>
        <Stack.Item>
          Are you sure you want to imprint the <br />
          following goal onto the subject?
        </Stack.Item>
        <Stack.Item>
          <b>{customObjective}</b>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Button
                color="good"
                content="Yes!"
                onClick={() => {
                  act('experiment', {
                    experiment_type: experimentPopup,
                    objective: customObjective,
                  });
                  setExperimentPopup(0);
                  setCustomObjective('');
                }}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                color="bad"
                content="No"
                onClick={() => {
                  setExperimentPopup(0);
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

export const ProbingConsole = (_props, context) => {
  const { act, data } = useBackend(context);
  const { open, feedback, occupant, occupant_name, occupant_status } = data;
  const [customObjective, setCustomObjective] = useLocalState(context, 'customObjective', '');
  const [experimentPopup, setExperimentPopup] = useLocalState(context, 'experimentPopup', 0);
  const trimmedCustomObjective = customObjective.trim();
  return (
    <Window width={400} height={240} theme="abductor">
      {experimentPopup > 0 && <ProbingConsoleConfirmation />}
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Machine Report">{feedback}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Scanner"
          buttons={
            <Button
              icon={open ? 'sign-out-alt' : 'sign-in-alt'}
              content={open ? 'Close' : 'Open'}
              onClick={() => act('door')}
            />
          }>
          {(occupant && (
            <LabeledList>
              <LabeledList.Item label="Name">{occupant_name}</LabeledList.Item>
              <LabeledList.Item
                label="Status"
                color={occupant_status === 3 ? 'bad' : occupant_status === 2 ? 'average' : 'good'}>
                {occupant_status === 3 ? 'Deceased' : occupant_status === 2 ? 'Unconscious' : 'Conscious'}
              </LabeledList.Item>
              <LabeledList.Item label="Psyche Imprinter">
                <Input
                  value={customObjective}
                  onInput={(_e, value) => setCustomObjective(value)}
                  placeholder="Optional Objective"
                  fluid
                />
              </LabeledList.Item>
              <LabeledList.Item label="Experiments">
                <Button
                  icon="thermometer"
                  content="Probe"
                  onClick={() => {
                    if (trimmedCustomObjective.length > 0) {
                      setExperimentPopup(1);
                    } else {
                      act('experiment', {
                        experiment_type: 1,
                      });
                    }
                  }}
                />
                <Button
                  icon="brain"
                  content="Dissect"
                  onClick={() => {
                    if (trimmedCustomObjective.length > 0) {
                      setExperimentPopup(2);
                    } else {
                      act('experiment', {
                        experiment_type: 2,
                      });
                    }
                  }}
                />
                <Button
                  icon="search"
                  content="Analyze"
                  onClick={() => {
                    if (trimmedCustomObjective.length > 0) {
                      setExperimentPopup(3);
                    } else {
                      act('experiment', {
                        experiment_type: 2,
                      });
                    }
                  }}
                />
              </LabeledList.Item>
            </LabeledList>
          )) || <NoticeBox>No Subject</NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
