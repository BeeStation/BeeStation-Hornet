import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { LabeledListItem } from '../components/LabeledList';


export const FaxMachine = props => {
  const { act, data } = useBackend(props);

  return (
    <Fragment>
      <Section title="Authorization" >
        <LabeledList>
          <LabeledListItem label="Confirm Identity:">
            <Button
              icon={"eject"}
              onClick={() => act('scan')}
              content={data.scan_name} />
          </LabeledListItem>
          <LabeledListItem label="Authorize:">
            <Button
              icon={data.authenticated ? "unlock" : "lock"}
              onClick={() => act('auth')}
              content={data.authenticated ? 'Log Out' : 'Log In'} />
          </LabeledListItem>
        </LabeledList>
      </Section>

      <Section title="Fax Menu" >
        <LabeledList>
          <LabeledListItem label="Network">
            <Box color="label">
              {data.network}
            </Box>
          </LabeledListItem>
          <LabeledListItem label="Currently Sending:">
            <Button
              icon={"eject"}
              onClick={() => act('paper')}
              content={data.paper} />
            <Button
              icon={'pencil'}
              onClick={() => act('rename')}
              content={"Rename"}
              disabled={!data.paperinserted}
            />
          </LabeledListItem>
          <LabeledListItem label="Sending to:">
            <Button
              icon={'print'}
              onClick={() => act('dept')}
              content={data.destination}
              disabled={!data.authenticated} />
          </LabeledListItem>
          <LabeledListItem label="Action:">
            <Button
              icon={data.cooldown && data.respectcooldown
                ? 'clock-o'
                : "envelope-o"}
              onClick={() => act('send')}
              content={data.cooldown && data.respectcooldown
                ? "Realigning"
                : "Send"} />
          </LabeledListItem>
        </LabeledList>
      </Section>

    </Fragment>
  );
};
