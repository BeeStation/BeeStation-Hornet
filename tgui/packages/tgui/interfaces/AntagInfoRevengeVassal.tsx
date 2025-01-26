import { resolveAsset } from '../assets';
import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Dropdown, Section, Stack } from '../components';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
  complete: BooleanLike;
  was_uncompleted: BooleanLike;
  reward: number;
};

type VampireInformation = {
  power: PowerInfo[];
};

type PowerInfo = {
  power_name: string;
  power_explanation: string;
  power_icon: string;
};

type Info = {
  objectives: Objective[];
};

const ObjectivePrintout = (props: any) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoRevengeVassal = (props: any) => {
  return (
    <Window width={620} height={300}>
      <Window.Content>
        <VassalInfo />
      </Window.Content>
    </Window>
  );
};

const VassalInfo = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="20rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a Vassal tasked with taking revenge for the death of your Master!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill>
          <Stack vertical>
            <Stack.Item>
              <span>
                You have gained your Master&#39;s old Powers, and a brand new power. You will have to survive and maintain your
                old Master&#39;s integrity. Bring their old Vassals back into the fold using your new Ability.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <PowerSection />
      </Stack.Item>
    </Stack>
  );
};

const PowerSection = (props: any) => {
  const { act, data } = useBackend<VampireInformation>();
  const { power } = data;
  if (!power) {
    return <Section minHeight="220px" />;
  }

  const [selectedPower, setSelectedPower] = useLocalState('power', power[0]);

  return (
    <Section
      fill
      scrollable={!!power}
      title="Powers"
      buttons={<Button icon="info" tooltipPosition="left" tooltip={'Select a Power to explain.'} />}>
      <Stack>
        <Stack.Item grow>
          <Dropdown
            displayText={selectedPower.power_name}
            selected={selectedPower.power_name}
            width="100%"
            options={power.map((powers) => powers.power_name)}
            onSelected={(powerName: string) => setSelectedPower(power.find((p) => p.power_name === powerName) || power[0])}
          />
          {selectedPower && (
            <Box position="absolute" height="12rem" as="img" src={resolveAsset(`vampire.${selectedPower.power_icon}.png`)} />
          )}
          <Divider Vertical />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item scrollable grow={1} fontSize="16px">
          {selectedPower && selectedPower.power_explanation}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
