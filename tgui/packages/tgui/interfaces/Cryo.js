import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, ProgressBar, Section, Table } from '../components';
import { ReagentList, QueueList, ReagentListPerson } from './common/ReagentList';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: "Brute",
    type: "bruteLoss",
  },
  {
    label: "Respiratory",
    type: "oxyLoss",
  },
  {
    label: "Toxin",
    type: "toxLoss",
  },
  {
    label: "Burn",
    type: "fireLoss",
  },
];

export const Cryo = () => {
  return (
    <Window
      resizable
      width={800}
      height={460}>
      <CryoContent />
    </Window>
  );
};

const CryoContent = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window.Content scrollable>
      <Flex direction="row">
        <Box width="50%">
          <Section title="Occupant">
            <LabeledList>
              <LabeledList.Item label="Occupant">
                {data.occupant.name || 'No Occupant'}
              </LabeledList.Item>
              {!!data.hasOccupant && (
                <Fragment>
                  <LabeledList.Item
                    label="State"
                    color={data.occupant.statstate}>
                    {data.occupant.stat}
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Temperature"
                    color={data.occupant.temperaturestatus}>
                    <AnimatedNumber
                      value={data.occupant.bodyTemperature} />
                    {' K'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Health">
                    <ProgressBar
                      value={data.occupant.health / data.occupant.maxHealth}
                      color={data.occupant.health > 0 ? 'good' : 'average'}>
                      <AnimatedNumber
                        value={data.occupant.health} />
                    </ProgressBar>
                  </LabeledList.Item>
                  {(damageTypes.map(damageType => (
                    <LabeledList.Item
                      key={damageType.id}
                      label={damageType.label}>
                      <ProgressBar
                        value={data.occupant[damageType.type]/100}>
                        <AnimatedNumber
                          value={data.occupant[damageType.type]} />
                      </ProgressBar>
                    </LabeledList.Item>
                  )))}
                </Fragment>
              )}
            </LabeledList>
          </Section>
          <Section title="Cell">
            <LabeledList>
              <LabeledList.Item label="Power">
                <Button
                  icon={data.isOperating ? "power-off" : "times"}
                  disabled={data.isOpen}
                  onClick={() => act('power')}
                  color={data.isOperating && 'green'}>
                  {data.isOperating ? "On" : "Off"}
                </Button>
                <Button
                  disabled={!data.isOperating}
                  onClick={() => act('change_mode')}
                  color={data.currentMode && 'green'}>
                  Cryomode
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Temperature">
                <AnimatedNumber value={data.cellTemperature} /> K
              </LabeledList.Item>
              <LabeledList.Item label="Oxygen supply">
                <AnimatedNumber
                  value={data.oxygenSupply} />
                {' kPa'}
              </LabeledList.Item>
              <LabeledList.Item label="Cryoxadone supply">
                <AnimatedNumber
                  value={data.cryoxadoneSupply} />
                {' units'}
              </LabeledList.Item>
              <LabeledList.Item label="Door">
                <Button
                  icon={data.isOpen ? "unlock" : "lock"}
                  onClick={() => act('door')}
                  content={data.isOpen ? "Open" : "Closed"} />
              </LabeledList.Item>
              <LabeledList.Item label="Reagent boost">
                {data.currentMode === 1 && data.occupant.stat === "Unconscious" && (
                  "Active"
                ) || (
                  "Inactive"
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Box>
        <Box width="50%">
          <Section title="Reagents in blood">
            {data.occupantChemicals && (
              <ReagentListPerson
                content={data.occupantChemicals}
              />
            ) || (
              <Table>
                <Table.Row
                  color="label">
                  <Table.Cell>
                    {"No chemicals in occupant's bloodstream"}
                  </Table.Cell>
                </Table.Row>
              </Table>)}
          </Section>
          <Section title="Reagents">
            <ReagentList
              content={data.reagents} />
          </Section>
          <Section title="Queued reagents"
            buttons={(
              <Button
                content="Clear"
                onClick={() => act('remove_all')} />
            )}>
            <QueueList
              content={data.queue}
              multiplier={data.multiplier} />
            <Box mt={1}>
              {!data.injecting && (
                <Button
                  content="Inject Patient"
                  onClick={() => act("inject")} />
              ) || (
                <Button
                  content="Stop injecting"
                  color="danger"
                  onClick={() => act("stop_injecting")} />
              )}
              <Button
                content="Destroy"
                color="danger"
                onClick={() => act("destroy")} />
            </Box>
          </Section>
        </Box>
      </Flex>
    </Window.Content>
  );
};
