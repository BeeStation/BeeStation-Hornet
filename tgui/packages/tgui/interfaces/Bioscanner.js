import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber, Table } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const Bioscanner = (props, context) => {
  return (
    <Window width={250} height={300}>
      <Window.Content>
        <BioscannerUIContent />
      </Window.Content>
    </Window>
  );
};

export const BioscannerUIContent = (props, context) => {
  const { act, data } = useBackend(context);

  const { open, occupant = {}, occupied, scanning } = data;

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
    <section>
      <Section label="Patient Statistics">
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          minHeight="175px"
          buttons={
            !!occupant.stat && (
              <Box inline bold color={occupant.statstate}>
                {occupant.stat}
              </Box>
            )
          }>
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
                }}
              />
              <Box mt={1} />
              <LabeledList>
                {damageTypes.map((type) => (
                  <LabeledList.Item key={type.type} label={type.label}>
                    <ProgressBar
                      value={occupant[type.type]}
                      minValue={0}
                      maxValue={occupant.maxHealth}
                      color={occupant[type.type] === 0 ? 'good' : 'bad'}
                    />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </>
          )}
        </Section>
      </Section>
      <Section label="Scan Button">
        <Button
          fluid
          bold
          content="Start Scan"
          color="blue"
          textAlign="center"
          fontSize="30px"
          lineHeight="50px"
          onClick={() => act('startscan')}
        />
      </Section>
    </section>
  );
};
