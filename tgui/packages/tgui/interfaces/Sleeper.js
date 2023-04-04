import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber, Table } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    open,
    occupant = {},
    occupied,
    chems = {},
  } = data;

  const damageTypes = [
    {
      label: 'Brute',
      type: 'bruteLoss',
    },
    {
      label: 'Burn',
      type: 'fireLoss',
    },
    {
      label: 'Toxin',
      type: 'toxLoss',
    },
    {
      label: 'Oxygen',
      type: 'oxyLoss',
    },
  ];

  return (
    <Window
      width={310}
      height={520}>
      <Window.Content>
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          minHeight="250px"
          buttons={!!occupant.stat && (
            <Box
              inline
              bold
              color={occupant.statstate}>
              {occupant.stat}
            </Box>
          )}>
          {!!occupied && (
            <>
              <ProgressBar
                value={occupant.health}
                minValue={occupant.minHealth}
                maxValue={occupant.maxHealth}
                ranges={{
                  good: [50, Infinity],
                  average: [0, 50],
                  bad: [-Infinity, 0],
                }} />
              <Box mt={1} />
              <LabeledList>
                {damageTypes.map(type => (
                  <LabeledList.Item
                    key={type.type}
                    label={type.label}>
                    <ProgressBar
                      value={occupant[type.type]}
                      minValue={0}
                      maxValue={occupant.maxHealth}
                      color="bad" />
                  </LabeledList.Item>
                ))}
                <LabeledList.Item
                  label="Cells"
                  color={occupant.cloneLoss ? 'bad' : 'good'}>
                  {occupant.cloneLoss ? 'Damaged' : 'Healthy'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Brain"
                  color={occupant.brainLoss ? 'bad' : 'good'}>
                  {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
                </LabeledList.Item>
                <LabeledList.Item label="Reagents">
                  <Box color="label">
                    {occupant.reagents.length === 0 && '—'}
                    {occupant.reagents.map(chemical => (
                      <Box key={chemical.name}>
                        <AnimatedNumber
                          value={chemical.volume}
                          format={value => toFixed(value, 1)} />
                        {` units of ${chemical.name}`}
                      </Box>
                    ))}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </>
          )}
        </Section>
        <Section
          title="Medicines"
          minHeight="205px"
          buttons={(
            <Button
              icon={open ? 'door-open' : 'door-closed'}
              content={open ? 'Open' : 'Closed'}
              onClick={() => act('door')} />
          )}>
          <Table>
            {chems.map(chem => (
              <Table.Row
                key={chem.id} >
                <Table.Cell>
                  <Button
                    key={chem.id}
                    icon="flask"
                    width="100%"
                    content={chem.name + ' (' + chem.amount + 'u)'}
                    disabled={!(occupied && chem.allowed)}
                    onClick={() => act('inject', {
                      chem: chem.id,
                    })}
                  />
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    key={chem.id}
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject', {
                      chem: chem.id,
                    })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
