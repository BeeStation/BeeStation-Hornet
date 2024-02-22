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
              <Input value={key} onChange={(e) => act('update_key', { key: e.target.value })} style={key_enabled ? { display: 'inline-block' } : { display: 'none' }} />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="IP" checked={ip_enabled} onClick={() => act('toggle_ip')} />
              <Input value={ip} onChange={(e) => act('update_ip', { ip: e.target.value })} style={ip_enabled ? { display: 'inline-block' } : { display: 'none' }} />
            </Stack.Item>
            <Stack.Item>
              <Button.Checkbox content="CID" checked={cid_enabled} onClick={() => act('toggle_cid')} />
              <Input value={cid} onChange={(e) => act('update_cid', { cid: e.target.value })} style={cid_enabled ? { display: 'inline-block' } : { display: 'none' }} />
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
                      <Input value={ban_duration} onChange={(e) => act('update_duration', { duration: e.target.value })} />
                      <Dropdown
                        selected={time_units}
                        options={Object.keys(timeUnitsMapping)}
                        onSelected={(selected) => act('set_time_units', { units: timeUnitsMapping[selected] })}
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
                  <TextArea height="100px" onChange={(e) => act('update_reason', { reason: e.target.value })} />
                </LabeledList.Item>
                <LabeledList.Item>
                  <Button.Confirm content="Submit" onClick={() => act('submit_ban')} />
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Roles" style={ban_type === 'Role' ? { display: 'block' } : { display: 'none' }}>
          <Roles selected_roles={selected_roles} roles={roles} selected_groups={selected_groups} act={act} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Roles = ({ roles, selected_roles, selected_groups, act }) => {
  return (
    <Stack direction="column">
      <CheckboxCollapsible title="Command Roles" onClick={() => act('toggle_group', { group: "command" })} color="blue" checked={selected_groups.includes('command')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['command']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Security Roles" onClick={() => act('toggle_group', { group: "security" })} color="blue" checked={selected_groups.includes('security')}>
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['security']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Engineering Roles" onClick={() => act('toggle_group', { group: "engineering" })} color="orange" checked={selected_groups.includes('engineering')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['engineering']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Medical Roles" onClick={() => act('toggle_group', { group: "medical" })} color="teal" checked={selected_groups.includes('medical')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['medical']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Science Roles" color="purple" onClick={() => act('toggle_group', { group: "science" })} checked={selected_groups.includes('science')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['science']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Supply Roles" color="brown" onClick={() => act('toggle_group', { group: "supply" })} checked={selected_groups.includes('supply')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['supply']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Silicon Roles" color="green" onClick={() => act('toggle_group', { group: "silicon" })} checked={selected_groups.includes('silicon')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['silicon']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Antagonist Positions"
        onClick={() => act('toggle_group', { group: "antagonist_positions" })}
        color="black"
        checked={selected_groups.includes('antagonist_positions')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['antagonist_positions']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Forced Antagonist Positions"
        onClick={() => act('toggle_group', { group: "forced_antagonist_positions" })}
        color="bad"
        checked={selected_groups.includes('forced_antagonist_positions')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['forced_antagonist_positions']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Ghost Roles" onClick={() => act('toggle_group', { group: "ghost_roles" })} color="grey" checked={selected_groups.includes('ghost_roles')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['ghost_roles']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Civilian" onClick={() => act('toggle_group', { group: "civilian" })} color="grey" checked={selected_groups.includes('civilian')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['civilian']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Gimmick" onClick={() => act('toggle_group', { group: "gimmick" })} color="pink" checked={selected_groups.includes('gimmick')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['gimmick']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Other" onClick={() => act('toggle_group', { group: "other" })} checked={selected_groups.includes('other')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['other']} act={act} />
      </CheckboxCollapsible>
      <CheckboxCollapsible title="Abstract" checked={selected_groups.includes('abstract')}>
        <RolesInCategory selected_roles={selected_roles} roles={roles['abstract']} act={act} />
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
const RolesInCategory = ({ roles, selected_roles, act }) => {
  return (
    <Stack wrap width="800px">
    {roles.map((role) => {
        return <Button.Checkbox content={role} key={role} onClick={() => act('toggle_role', { selected_role: role })} checked={selected_roles.includes(role)} />;
      })}
    </Stack>
  );
};

const timeUnitsMapping = {
  'Seconds': 'SECOND',
  'Minutes': 'MINUTE',
  'Hours': 'HOUR',
  'Days': 'DAY',
  'Weeks': 'WEEK',
  'Months': 'MONTH',
  'Years': 'YEAR',
};
