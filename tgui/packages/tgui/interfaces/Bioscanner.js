import { useBackend } from '../backend';
import { Box, Button, Collapsible, Grid, LabeledList, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const Bioscanner = (props, context) => {
  return (
    <Window>
      <Window.Content scrollable>
        <BioscannerUIContent />
      </Window.Content>
    </Window>
  );
};

export const BioscannerUIContent = (props, context) => {
  const { act, data } = useBackend(context);

  const { open, occupant = {}, occupied } = data;

  return (
    <section>
      <Section label="Patient Statistics">
        <Box>Patient Stats</Box>
      </Section>
      <Section label="Scan Button">
        <Button
          fluid
          bold
          icon="syringe"
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
