import { useBackend, useLocalState } from '../backend';
import { Section, Box, Dropdown, Button, Input, TextArea, Divider, NumberInput, Tooltip, Knob } from '../components';
import { Window } from '../layouts';

export const AdminFax = (props, context) => {
  return (
    <Window title="Send Fax Message" width={500} height={800} theme="admin">
      <Window.Content scrollable>
        <FaxMainPanel />
      </Window.Content>
    </Window>
  );
};

export const FaxMainPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const [fax, setFax] = useLocalState(context, 'fax', '');
  const [saved, setSaved] = useLocalState(context, 'saved', false);
  const [paperName, setPaperName] = useLocalState(context, 'paperName', '');
  const [fromWho, setFromWho] = useLocalState(context, 'fromWho', '');
  const [rawText, setRawText] = useLocalState(context, 'rawText', '');
  const [stamp, setStamp] = useLocalState(context, 'stampType', '');
  const [stampCoordX, setStampCoordX] = useLocalState(context, 'stampCoordX', 0);
  const [stampCoordY, setStampCoordY] = useLocalState(context, 'stampCoordY', 0);
  const [stampAngle, setStampAngle] = useLocalState(context, 'stampAngle', 0);
  if (stamp && data.stamps[0] !== 'None') {
    data.stamps.unshift('None');
  }
  return (
    <>
      <Section
        title="Fax Message"
        buttons={
          <Box>
            <Button
              icon="arrow-up"
              disabled={!fax}
              onClick={() =>
                act('follow', {
                  faxName: fax,
                })
              }>
              Follow
            </Button>
          </Box>
        }>
        <Box fontSize="13px">
          <Dropdown
            textAlign="center"
            selected="Choose fax machine..."
            width="100%"
            nochevron
            nowrap
            options={data.faxes}
            onSelected={(value) => setFax(value)}
          />
        </Box>
      </Section>
      <Section
        title="Paper"
        buttons={
          <Button
            icon="eye"
            disabled={!saved}
            onClick={() =>
              act('preview', {
                faxName: fax,
              })
            }>
            Preview
          </Button>
        }>
        <Box fontSize="14px">
          <Input mb="5px" placeholder="Paper name..." value={paperName} width="100%" onChange={(_, v) => setPaperName(v)} />
          <Button color="blue" fluid textAlign="center" onClick={() => setPaperName('Central Command Report')}>
            Central Command Report
          </Button>
          <Button color="red" fluid textAlign="center" onClick={() => setPaperName('Syndicate Report')}>
            Syndicate Report
          </Button>
        </Box>
        <Divider />
        <Box fontSize="14px" mt="5px">
          <Tooltip content="This is shown in the fax log.">
            <Input mb="5px" placeholder="From who..." value={fromWho} width="100%" onChange={(_, v) => setFromWho(v)} />
          </Tooltip>
          <Button color="blue" fluid textAlign="center" onClick={() => setFromWho('Central Command')}>
            Central Command
          </Button>
          <Button color="red" fluid textAlign="center" onClick={() => setFromWho('Syndicate')}>
            Syndicate
          </Button>
        </Box>
        <Divider />
        <Box mt="5px">
          <TextArea
            placeholder="Your message here..."
            height="200px"
            value={rawText}
            onInput={(e, value) => {
              setRawText(value);
            }}
          />
        </Box>
        <Divider />
        <Box mt="5px">
          <Dropdown
            width="100%"
            options={data.stamps}
            selected="Choose Stamp (optional)"
            onSelected={(v) => {
              if (v === 'None') {
                setStamp('');
                data.stamps.shift();
              } else {
                setStamp(v);
              }
            }}
          />
          {stamp && (
            <Box textAlign="center">
              <h4>
                X Coordinate:{' '}
                <NumberInput
                  width="45px"
                  minValue={0}
                  maxValue={300}
                  value={stampCoordX}
                  onChange={(_, v) => setStampCoordX(v)}
                />
              </h4>

              <h4>
                Y Coordinate:{' '}
                <NumberInput width="45px" minValue={0} value={stampCoordY} onChange={(_, v) => setStampCoordY(v)} />
              </h4>

              <Box textAlign="center">
                <h4>Rotation Angle</h4>
                <Knob
                  size={1.5}
                  value={stampAngle}
                  minValue={0}
                  maxValue={360}
                  animated={false}
                  onChange={(_, v) => setStampAngle(v)}
                />
              </Box>
            </Box>
          )}
        </Box>
      </Section>
      <Section title="Actions">
        <Box>
          <Button
            disabled={!saved || !fax}
            icon="paper-plane"
            mr="9px"
            onClick={() =>
              act('send', {
                faxName: fax,
              })
            }>
            Send Fax
          </Button>
          <Button
            icon="save"
            mr="9px"
            color="green"
            onClick={() => {
              setSaved(true);
              act('save', {
                faxName: fax,
                paperName: paperName,
                rawText: rawText,
                stamp: stamp,
                stampX: stampCoordX,
                stampY: stampCoordY,
                stampAngle: stampAngle,
                fromWho: fromWho,
              });
            }}>
            Save Changes
          </Button>
          <Button
            disabled={!saved}
            icon="plus-circle"
            onClick={() =>
              act('createPaper', {
                faxName: fax,
              })
            }>
            Create Paper
          </Button>
        </Box>
      </Section>
    </>
  );
};
