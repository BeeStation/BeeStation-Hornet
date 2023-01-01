import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Section, Input } from '../components';
import { NtosWindow } from '../layouts';

export const NtosViroSymptoms = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    symptoms,
  } = data;
  const [searchTerm, setSearchTerm] = useLocalState(context, 'searchTerm', '');

  const filteredSymptoms = Object.keys(symptoms).filter(symptomName => {
    return symptomName.toLowerCase().includes(searchTerm.toLowerCase());
  });

  return (
    <NtosWindow
      width={600}
      height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          Virology Symptom Information
        </Section>
        <Input
          placeholder="Search by name..."
          value={searchTerm}
          onChange={(e, value) => setSearchTerm(value)}
        />
        {filteredSymptoms.map(symptomName => (
          <Section>
            <Box fontWeight="bold">{symptomName}</Box>
            <Box>{symptoms[symptomName]["desc"]}</Box>
            <Box>Stealth: {symptoms[symptomName]["stealth"]}</Box>
            <Box>Resistance: {symptoms[symptomName]["resistance"]}</Box>
            <Box>Stage Speed: {symptoms[symptomName]["stage_speed"]}</Box>
            <Box>Transmission: {symptoms[symptomName]["transmission"]}</Box>
            <Box>Level: {symptoms[symptomName]["level"]}</Box>
            <Box>
              Threshold Description:
              <div
                dangerouslySetInnerHTML={{
                  __html: symptoms[symptomName]["threshold_desc"],
                }}
              />
            </Box>
            <Box>Severity: {symptoms[symptomName]["severity"]}</Box>
          </Section>
        ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
