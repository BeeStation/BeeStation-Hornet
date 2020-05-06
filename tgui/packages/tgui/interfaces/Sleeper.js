import { useBackend } from '../backend';
import { Box, Section, LabeledList, Button, ProgressBar, AnimatedNumber } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';
import { toFixed } from 'common/math';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    open,
    occupant = {},
    occupied,
  } = data;

  const preSortChems = data.chems || [];
  const chems = preSortChems.sort((a, b) => {
    const descA = a.name.toLowerCase();
    const descB = b.name.toLowerCase();
    if (descA < descB) {
      return -1;
    }
    if (descA > descB) {
      return 1;
    }
    return 0;
  });

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
    <Window resizable>
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
            <Fragment>
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
            </Fragment>
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
          {chems.map(chem => (
            <Button
              key={chem.name}
              icon="flask"
              content={chem.name}
              disabled={!(occupied && chem.allowed)}
              width="140px"
              onClick={() => act('inject', {
                chem: chem.id,
              })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
