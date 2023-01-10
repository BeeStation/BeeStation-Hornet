import { useBackend, useLocalState } from '../backend';
import { Section, Box, Button, Table, Tabs, Tab } from '../components';
import { NtosWindow } from '../layouts';

export const NtosViroSymptoms = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    symptoms,
  } = data;

  const [selectedSymptoms, setSelectedSymptoms] = useLocalState(context, 'selectedSymptoms', {});
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  
  const renderSymptomList = () => (
    Object.keys(symptoms).map(symptomName => (
      <Section key={symptomName}>
        <Box><h1>{symptomName}</h1></Box>
        <Box>{symptoms[symptomName]["desc"]}</Box>
        <Box><b>Stealth:</b> {symptoms[symptomName]["stealth"]}</Box>
        <Box><b>Resistance:</b> {symptoms[symptomName]["resistance"]}</Box>
        <Box><b>Stage Speed:</b> {symptoms[symptomName]["stage_speed"]}</Box>
        <Box><b>Transmission:</b> {symptoms[symptomName]["transmission"]}</Box>
        <Box><b>Level:</b> {symptoms[symptomName]["level"]}</Box>
        <Box><b>Threshold Description:</b>
          <>
            {symptoms[symptomName]["threshold_desc"]
              .split('<br>')
              .map((line, i) => (
                <>
                  {line.replace(/<b>/g, ' ')
                    .replace(/<\/b>/g, '')}
                  <br />
                </>
              ))}
          </>
        </Box>
        <Box><b>Severity:</b> {symptoms[symptomName]["severity"]}</Box>
        <Box>
          {selectedSymptoms[symptomName]
            ? (
              <Button
                onClick={() => {
                  const newSelectedSymptoms = { ...selectedSymptoms };
                  delete newSelectedSymptoms[symptomName];
                  setSelectedSymptoms(newSelectedSymptoms);
                }}>
                Deselect
              </Button>
            )
            : (
              <Button
                disabled={Object.keys(selectedSymptoms).length === 6}
                onClick={() => {
                  const newSelectedSymptoms = { ...selectedSymptoms };
                  newSelectedSymptoms[symptomName] = symptoms[symptomName];
                  setSelectedSymptoms(newSelectedSymptoms);
                }}>
                Select
              </Button>
            ) }
        </Box>
      </Section>
    ))
  );

  function calculateTotal(selectedSymptoms) {
    let total = {
      stealth: 0,
      resistance: 0,
      stage_speed: 0,
      transmission: 0,
      severity: 0,
    };

    Object.values(selectedSymptoms).forEach(symptom => {
      total.stealth += symptom.stealth;
      total.resistance += symptom.resistance;
      total.stage_speed += symptom.stage_speed;
      total.transmission += symptom.transmission;
      total.severity += symptom.severity;
    });

    return total;
  };

  const total = calculateTotal(selectedSymptoms);

  return (
    <NtosWindow
      width={600}
      height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          Virology Symptom Information
        </Section>
        <Tabs>
          <Tabs.Tab
            key="symptoms"
            icon="list"
            title="All Symptoms"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            {renderSymptomList()}
          </Tabs.Tab>
          <Tabs.Tab
            key="selected"
            icon="list"
            title="Selected Symptoms"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            <Table>
              <Table.Row key="total">
                <Table.Cell>Symptom</Table.Cell>
                <Table.Cell>Stealth</Table.Cell>
                <Table.Cell>Resistance</Table.Cell>
                <Table.Cell>Stage Speed</Table.Cell>
                <Table.Cell>Transmission</Table.Cell>
                <Table.Cell>Severity</Table.Cell>
                <Table.Cell>Level</Table.Cell>
              </Table.Row>
              {Object.keys(selectedSymptoms).map(symptomName => (
                <Table.Row key={symptomName}>
                  <Table.Cell>{symptomName}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["stealth"]}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["resistance"]}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["stage_speed"]}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["transmission"]}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["severity"]}</Table.Cell>
                  <Table.Cell>{selectedSymptoms[symptomName]["level"]}</Table.Cell>
                  <Table.Cell>
                    <Button
                      icon="trash-can"
                      onClick={() => {
                        const newSelectedSymptoms = { ...selectedSymptoms };
                        delete newSelectedSymptoms[symptomName];
                        setSelectedSymptoms(newSelectedSymptoms);
                      }} />
                  </Table.Cell>
                </Table.Row>
              ))}
              <Table.Row>
                <Table.Cell>Total</Table.Cell>
                <Table.Cell>{total.stealth}</Table.Cell>
                <Table.Cell>{total.resistance}</Table.Cell>
                <Table.Cell>{total.stage_speed}</Table.Cell>
                <Table.Cell>{total.transmission}</Table.Cell>
                <Table.Cell>{total.severity}</Table.Cell>
                <Table.Cell />
                <Table.Cell />
              </Table.Row>
            </Table>
          </Tabs.Tab>
        </Tabs>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
