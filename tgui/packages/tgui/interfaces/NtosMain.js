import { useBackend } from '../backend';
import { Button, ColorBox, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

const PROGRAM_ICONS = {
  compconfig: 'cog',
  ntndownloader: 'download',
  filemanager: 'folder',
  smmonitor: 'radiation',
  alarmmonitor: 'bell',
  cardmod: 'id-card',
  arcade: 'gamepad',
  ntnrc_client: 'comment-alt',
  nttransfer: 'exchange-alt',
  powermonitor: 'plug',
  job_manage: 'address-book',
  crewmani: 'clipboard-list',
  robocontrol: 'robot',
  atmosscan: 'thermometer-half',
  shipping: 'tags',
};

export const NtosMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    programs = [],
    has_light,
    light_on,
    comp_light_color,
  } = data;
  return (
    <NtosWindow
      resizable
      width={400}
      height={500}>
      <NtosWindow.Content scrollable>
        {!!has_light && (
          <Section>
            <Button
              width="144px"
              icon="lightbulb"
              selected={light_on}
              onClick={() => act('PC_toggle_light')}>
              Flashlight: {light_on ? 'ON' : 'OFF'}
            </Button>
            <Button
              ml={1}
              onClick={() => act('PC_light_color')}>
              Color:
              <ColorBox ml={1} color={comp_light_color} />
            </Button>
          </Section>
        )}
        <Section title="Programs">
          <Table>
            {programs.map(program => (
              <Table.Row key={program.name}>
                <Table.Cell>
                  <Button
                    fluid
                    lineHeight="24px"
                    color="transparent"
                    icon={PROGRAM_ICONS[program.name]
                      || 'window-maximize-o'}
                    content={program.desc}
                    onClick={() => act('PC_runprogram', {
                      name: program.name,
                    })} />
                </Table.Cell>
                <Table.Cell collapsing width="18px">
                  {!!program.running && (
                    <Button
                      lineHeight="24px"
                      color="transparent"
                      icon="times"
                      tooltip="Close program"
                      tooltipPosition="left"
                      onClick={() => act('PC_killprogram', {
                        name: program.name,
                      })} />
                  )}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
