/* eslint-disable react/prefer-stateless-function */
import { useBackend } from '../backend';
import { Button, Input, TextArea, LabeledList, Section, Box, Dropdown, Stack, Collapsible, Flex } from '../components';
import { Window } from '../layouts';

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    key_enabled,
    key,
    ip_enabled,
    ip,
    cid_enabled,
    cid,
    applies_to_admins,
    can_supress,
    suppressed,
    duration_type,
    ban_duration,
    time_units,
    ban_type,
    force_cryo_after, // Rest in piss, forever miss
    use_last_connection,
    roles,
    selected_roles,
    selected_groups,
  } = data;

  return (
    <Window theme="admin" title="Banning Panel" width={850} height={800} resizable>
      <Window.Content>
        <Section title="Player Information">
          <Stack wrap="wrap">
            <Stack.Item>
              <Button.Checkbox content="Key" checked={key_enabled} onClick={() => act('toggle_key')} />
              <Input value={key} style={key_enabled ? { display: 'inline-block' } : { display: 'none' }} />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="IP" checked={ip_enabled} onClick={() => act('toggle_ip')} />
              <Input value={ip} style={ip_enabled ? { display: 'inline-block' } : { display: 'none' }} />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="CID" checked={cid_enabled} onClick={() => act('toggle_cid')} />
              <Input value={cid} style={cid_enabled ? { display: 'inline-block' } : { display: 'none' }} />
            </Stack.Item>
            <Stack.Item style={can_supress ? { display: 'flex' } : { display: 'none' }}>
              <Button.Checkbox
                content="Enable supression"
                color="bad"
                checked={suppressed}
                onClick={() => act('toggle_suppressed')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <Button.Checkbox
                content="Use IP and CID from last connection of key"
                checked={use_last_connection}
                onClick={() => act('toggle_use_last_connection')}
              />
              <Button.Checkbox
                content="Applies to admins"
                checked={applies_to_admins}
                onClick={() => act('toggle_applies_to_admins')}
              />
              <LabeledList>
                <LabeledList.Item label="Duration Type" verticalAlign="middle">
                  <Stack>
                    <Dropdown
                      selected={duration_type}
                      options={['Permanent', 'Temporary']}
                      onSelected={(selected) => act('set_duration_type', { type: selected })}
                    />
                    <Box style={duration_type === 'Temporary' ? { display: 'flex' } : { display: 'none' }}>
                      <Input value={ban_duration} />
                      <Dropdown
                        selected={time_units}
                        options={['Seconds', 'Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']}
                        onSelected={(selected) => act('set_time_units', { units: selected })}
                      />{' '}
                    </Box>
                  </Stack>
                </LabeledList.Item>
                <LabeledList.Item label="Ban Type" verticalAlign="middle">
                  <Dropdown
                    selected={ban_type}
                    options={['Server', 'Role']}
                    onSelected={(selected) => act('set_ban_type', { type: selected })}
                  />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Ban Reason" verticalAlign="top">
                  <TextArea height="100px" />
                </LabeledList.Item>
                <LabeledList.Item>
                  <Button.Confirm content="Submit" onClick={() => act('submit_ban')} />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Roles" style={ban_type === 'Role' ? { display: 'block' } : { display: 'none' }}>
          <Roles selected_roles={selected_roles} roles={roles} selected_groups={selected_groups} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Roles = (roles, selected_roles, selected_groups) => {
  return (
    <Stack direction="column">
      <CheckboxCollapsible title="Command Roles" color="blue" checked={selected_groups.includes('command')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['command']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Security Roles" color="red">
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['security']}
          checked={selected_roles.includes('security')}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Engineering Roles" color="orange" checked={selected_groups.includes('engineering')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['engineering']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Medical Roles" color="teal" checked={selected_groups.includes('medical')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['medical']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Science Roles" color="purple" checked={selected_groups.includes('science')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['science']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Supply Roles" color="brown" checked={selected_groups.includes('supply')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['supply']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Silicon Roles" color="green" checked={selected_groups.includes('silicon')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['silicon']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Antagonist Positions"
        color="black"
        checked={selected_groups.includes('antagonist_positions')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['antagonist_positions']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Forced Antagonist Positions"
        color="bad"
        checked={selected_groups('forced_antagonist_positions')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['forced_antagonist_positions']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Ghost Roles" color="grey" checked={selected_groups.includes('ghost_roles')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['ghost_roles']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Civilian" color="light-grey" checked={selected_groups.includes('civilian')}>
        <RolesInCategory
          selected_roles={selected_roles}
          roles={<RolesInCategory selected_roles={selected_roles} roles={roles['civilian']} />}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Gimmick" color="pink" checked={selected_groups.includes('gimmick')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['gimmick']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Other" checked={selected_groups.includes('other')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['other']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Abstract" checked={selected_groups.includes('abstract')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['abstract']} />
      </CheckboxCollapsible>
    </Stack>
  );
};

const CheckboxCollapsible = ({ color, title, onClick, checked, children }) => {
  return (
    <Flex>
      <Button.Checkbox
        onClick={onClick}
        color={color}
        checked={checked}
        tooltip="Select all for this category"
        maxHeight="20px"
        verticalAlignContent="middle"
      />
      <Collapsible title={title} color={color} inline>
        {children}
      </Collapsible>
    </Flex>
  );
};

const RolesInCategory = ({ roles, selected_roles }) => {
  return (
    <Stack wrap>
      {roles.map((role) => {
        return <Button.Checkbox content={role} key={role} checked={selected_roles.includes(role)} />;
      })}
    </Stack>
  );
};
