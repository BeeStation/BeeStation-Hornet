/* eslint-disable react/prefer-stateless-function */
import { Dropdown } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../components';
import { Window } from '../layouts';

const KEY_REGEX =
  /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

export const BanningPanel = (props) => {
  const { act, data } = useBackend();
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

  // The anti-moderator death grinder
  const hasValidKey = key_enabled && key && key.trim() !== '';
  const hasValidIp = ip_enabled && ip && ip.trim() !== '';
  const hasValidCid = cid_enabled && cid && cid.trim() !== '';
  const canSubmit = hasValidKey || hasValidIp || hasValidCid;

  return (
    <Window
      theme="admin"
      title="Banning Panel"
      width={750}
      height={800}
      resizable
    >
      <Window.Content>
        <Section title="Player Information">
          <Stack>
            <Flex direction="column">
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="Key"
                      checked={key_enabled}
                      onClick={() => act('toggle_key')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="CKEY"
                      value={key}
                      onChange={(e) =>
                        act('update_key', { key: e.target.value })
                      }
                      style={
                        key_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="IP"
                      checked={ip_enabled}
                      onClick={() => act('toggle_ip')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="IP"
                      value={ip}
                      onChange={(e) => act('update_ip', { ip: e.target.value })}
                      style={
                        ip_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="CID"
                      checked={cid_enabled}
                      onClick={() => act('toggle_cid')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="CID"
                      value={cid}
                      onChange={(e) =>
                        act('update_cid', { cid: e.target.value })
                      }
                      style={
                        cid_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Button.Checkbox
                content="Use IP and CID from last connection of key"
                checked={use_last_connection}
                onClick={() => act('toggle_use_last_connection')}
              />
            </Flex>
            <Stack direction="column" mx="10px">
              <Flex mb={1}>
                <Button.Checkbox
                  content="Force Cryo After"
                  checked={force_cryo_after}
                  onClick={() => act('toggle_cryo')}
                />
                <Button.Checkbox
                  content="Applies to admins"
                  checked={applies_to_admins}
                  onClick={() => act('toggle_applies_to_admins')}
                />

                <Box
                  style={
                    can_supress ? { display: 'flex' } : { display: 'none' }
                  }
                >
                  <Button.Checkbox
                    content="Enable suppression"
                    color="bad"
                    checked={suppressed}
                    onClick={() => act('toggle_suppressed')}
                  />
                </Box>
              </Flex>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item
                    label="Duration Type"
                    verticalAlign="middle"
                  >
                    <Flex>
                      <Dropdown
                        selected={duration_type}
                        options={['Permanent', 'Temporary']}
                        onSelected={(selected) =>
                          act('set_duration_type', { type: selected })
                        }
                      />
                      <Box
                        style={
                          duration_type === 'Temporary'
                            ? { display: 'flex' }
                            : { display: 'none' }
                        }
                      >
                        <NumberInput
                          value={ban_duration}
                          animated
                          minValue={1}
                          maxValue={+Infinity}
                          step={1}
                          onChange={(value) =>
                            act('update_duration', { duration: value })
                          }
                        />
                        <Dropdown
                          selected={time_units}
                          options={Object.keys(timeUnitsMapping)}
                          onSelected={(selected) =>
                            act('set_time_units', {
                              units: timeUnitsMapping[selected],
                            })
                          }
                        />{' '}
                      </Box>
                    </Flex>
                  </LabeledList.Item>
                  <LabeledList.Item label="Ban Type" verticalAlign="middle">
                    <Dropdown
                      selected={ban_type}
                      options={['Server', 'Role']}
                      onSelected={(selected) =>
                        act('set_ban_type', { type: selected })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
        <Section title="Ban Reason">
          <TextArea
            height="100px"
            onChange={(e) => act('update_reason', { reason: e.target.value })}
          />
        </Section>

        <Section
          title="Roles"
          style={
            ban_type === 'Role' ? { display: 'block' } : { display: 'none' }
          }
        >
          <Roles
            selected_roles={selected_roles}
            roles={roles}
            selected_groups={selected_groups}
            act={act}
          />
        </Section>
        <Button.Confirm
          content="Submit"
          onClick={() => act('submit_ban')}
          // Disabled if no key OR no IP OR no CID. Look at the checkbox too so some wiseguy doesn't fuck it up by inputting then unchecking either
          disabled={!canSubmit}
          tooltip={!canSubmit ? 'CKEY/IP/CID is required' : null}
          m={0.5}
          width={7}
          height={2}
          color="green"
          textAlign="center"
        />
      </Window.Content>
    </Window>
  );
};

const Roles = ({ roles, selected_roles, selected_groups, act }) => {
  return (
    <Stack direction="column">
      <CheckboxCollapsible
        title="Abstract"
        onClick={() => act('toggle_group', { group: 'abstract' })}
        checked={selected_groups.includes('abstract')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['abstract']}
          act={act}
        />
      </CheckboxCollapsible>

      <CheckboxCollapsible
        title="Command Roles"
        onClick={() => act('toggle_group', { group: 'command' })}
        color="blue"
        checked={selected_groups.includes('command')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['command']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Security Roles"
        onClick={() => act('toggle_group', { group: 'security' })}
        color="red"
        checked={selected_groups.includes('security')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['security']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Engineering Roles"
        onClick={() => act('toggle_group', { group: 'engineering' })}
        color="orange"
        checked={selected_groups.includes('engineering')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['engineering']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Medical Roles"
        onClick={() => act('toggle_group', { group: 'medical' })}
        color="teal"
        checked={selected_groups.includes('medical')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['medical']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Science Roles"
        color="purple"
        onClick={() => act('toggle_group', { group: 'science' })}
        checked={selected_groups.includes('science')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['science']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Supply Roles"
        color="brown"
        onClick={() => act('toggle_group', { group: 'supply' })}
        checked={selected_groups.includes('supply')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['supply']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Silicon Roles"
        color="yellow"
        onClick={() => act('toggle_group', { group: 'silicon' })}
        checked={selected_groups.includes('silicon')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['silicon']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Antagonist Positions"
        onClick={() => act('toggle_role', { selected_role: 'All Antagonists' })}
        color="black"
        checked={selected_roles.includes('All Antagonists')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['antagonist_positions']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Forced Antagonist Positions"
        onClick={() =>
          act('toggle_role', { selected_role: 'Forced Antagonists' })
        }
        color="bad"
        checked={selected_roles.includes('Forced Antagonists')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['forced_antagonist_positions']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Ghost Roles"
        onClick={() =>
          act('toggle_role', { selected_role: 'Non-Antagonist Ghost Roles' })
        }
        color="grey"
        checked={selected_roles.includes('Non-Antagonist Ghost Roles')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['ghost_roles']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Civilian"
        onClick={() => act('toggle_group', { group: 'civilian' })}
        color="grey"
        checked={selected_groups.includes('civilian')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['civilian']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Gimmick"
        onClick={() => act('toggle_group', { group: 'gimmick' })}
        color="pink"
        checked={selected_groups.includes('gimmick')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['gimmick']}
          act={act}
        />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Other"
        onClick={() => act('toggle_group', { group: 'other' })}
        checked={selected_groups.includes('other')}
      >
        <RolesInCategory
          selected_roles={selected_roles}
          roles={roles['other']}
          act={act}
        />
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
      <Collapsible title={title} color={color} inline iconPosition="right">
        {children}
      </Collapsible>
    </Flex>
  );
};
const RolesInCategory = ({ roles, selected_roles, act }) => {
  return (
    <Stack wrap width="600px">
      {roles.map((role) => {
        return (
          <Button.Checkbox
            content={role}
            key={role}
            onClick={() => act('toggle_role', { selected_role: role })}
            checked={selected_roles.includes(role)}
          />
        );
      })}
    </Stack>
  );
};

const timeUnitsMapping = {
  Seconds: 'SECOND',
  Minutes: 'MINUTE',
  Hours: 'HOUR',
  Days: 'DAY',
  Weeks: 'WEEK',
  Months: 'MONTH',
  Years: 'YEAR',
};
