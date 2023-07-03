import { useBackend } from '../backend';
import { Button, ColorBox, Section, Table } from '../components';
import { ButtonCheckbox } from '../components/Button';
import { NtosWindow } from '../layouts';

export const NtosMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    show_imprint,
    programs = [],
    has_light,
    light_on,
    comp_light_color,
    removable_media = [],
    cardholder,
    auto_imprint,
    login = [],
    proposed_login = [],
    disk,
    disk_name,
    disk_programs = [],
    stored_pai,
    stored_pai_name,
  } = data;
  return (
    <NtosWindow
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
        {!!(cardholder) && (
          <Section
            title="User Login"
            buttons={(
              <>
                <Button
                  icon="eject"
                  content="Eject ID"
                  disabled={!proposed_login.IDName}
                  onClick={() => act('PC_Eject_Disk', { name: "ID" })}
                />
                {!!(show_imprint) && (
                  <>
                    <Button
                      icon="dna"
                      content="Imprint"
                      disabled={!proposed_login.IDName || (
                        proposed_login.IDName === login.IDName
                    && proposed_login.IDJob === login.IDJob
                      )}
                      onClick={() => act('PC_Imprint_ID', { name: "ID" })}
                    />
                    <ButtonCheckbox
                      checked={auto_imprint}
                      content="Auto"
                      onClick={() => act('PC_Toggle_Auto_Imprint')} />
                  </>)}
              </>
            )}>
            <Table>
              <Table.Row>
                ID Name: {login.IDName}
                {proposed_login?.IDName ? ` (${proposed_login.IDName})` : ``}
              </Table.Row>
              <Table.Row>
                Assignment: {login.IDJob}
                {proposed_login?.IDJob ? ` (${proposed_login.IDJob})` : ``}
              </Table.Row>
            </Table>
          </Section>
        )}
        {!!removable_media.length && (
          <Section title="Media Eject">
            <Table>
              {removable_media.map(device => (
                <Table.Row key={device}>
                  <Table.Cell>
                    <Button
                      fluid
                      color="transparent"
                      icon="eject"
                      content={device}
                      onClick={() => act('PC_Eject_Disk', { name: device })}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
        {!!stored_pai && (
          <Section title={stored_pai_name ? `pAI (${stored_pai_name})` : "pAI"}>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="cat"
                    color="transparent"
                    content="Configure pAI"
                    onClick={() => act('PC_Pai_Interact', {
                      option: "interact",
                    })}
                  />
                </Table.Cell>
              </Table.Row>
              <Table.Row>
                <Table.Cell>
                  <Button
                    fluid
                    icon="eject"
                    color="transparent"
                    content="Eject pAI"
                    onClick={() => act('PC_Pai_Interact', {
                      option: "eject",
                    })}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
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
                    color={program.alert ? 'yellow' : 'transparent'}
                    icon={program.icon}
                    content={program.desc}
                    onClick={() => act('PC_runprogram', {
                      name: program.name,
                      is_disk: false,
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
        {!!disk && (
          <Section
            // pain
            title={disk_name
              ? disk_name.substring(0, disk_name.length - 5)
              : "No Job Disk Inserted"}
            buttons={(
              <Button
                icon="eject"
                content="Eject Job Disk"
                disabled={!disk_name}
                onClick={() => act('PC_Eject_Disk', { name: "job disk" })} />
            )}>
            <Table>
              {disk_programs.map(program => (
                <Table.Row key={program.name}>
                  <Table.Cell>
                    <Button
                      fluid
                      color={program.alert ? 'yellow' : 'transparent'}
                      icon={program.icon}
                      content={program.desc}
                      onClick={() => act('PC_runprogram', {
                        name: program.name,
                        is_disk: true,
                      })} />
                  </Table.Cell>
                  <Table.Cell collapsing width="18px">
                    {!!program.running && (
                      <Button
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
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
