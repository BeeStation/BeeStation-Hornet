import { Dropdown } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosConfiguration = (props) => {
  const { act, data } = useBackend();

  const {
    power_usage,
    battery_exists,
    battery = {},
    disk_size,
    disk_used,
    hardware = [],
    PC_device_theme,
    themes = {},
    PC_theme_locked,
  } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        {!PC_theme_locked ? (
          <Section title="Appearance">
            <Dropdown
              overflow-y="scroll"
              width="240px"
              options={Object.keys(themes)}
              selected={
                Object.keys(themes).find(
                  (key) => themes[key] === PC_device_theme,
                ) || 'NtOS Default'
              }
              onSelected={(value) =>
                act('PC_select_theme', {
                  theme: value,
                })
              }
            />
            {PC_device_theme === 'thinktronic-classic' ? (
              <Button
                icon="palette"
                content="Set Color"
                onClick={() => act('PC_set_classic_color')}
              />
            ) : null}
          </Section>
        ) : null}
        <Section
          title="Power Supply"
          buttons={
            <Box inline bold mr={1}>
              Power Draw: {power_usage}W
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Battery Status"
              color={!battery_exists && 'average'}
            >
              {battery_exists ? (
                <ProgressBar
                  value={battery.charge}
                  minValue={0}
                  maxValue={battery.max}
                  ranges={{
                    good: [battery.max / 2, Infinity],
                    average: [battery.max / 4, battery.max / 2],
                    bad: [-Infinity, battery.max / 4],
                  }}
                >
                  {battery.charge} / {battery.max}
                </ProgressBar>
              ) : (
                'Not Available'
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="File System">
          <ProgressBar
            value={disk_used}
            minValue={0}
            maxValue={disk_size}
            color="good"
          >
            {disk_used} GQ / {disk_size} GQ
          </ProgressBar>
        </Section>
        <Section title="Hardware Components">
          {hardware.map((component) => (
            <Section
              key={component.name}
              title={component.name}
              level={2}
              buttons={
                <>
                  {!component.critical && (
                    <Button.Checkbox
                      content="Enabled"
                      checked={component.enabled}
                      mr={1}
                      onClick={() =>
                        act('PC_toggle_component', {
                          name: component.name,
                        })
                      }
                    />
                  )}
                  <Box inline bold mr={1}>
                    Power Usage: {component.powerusage}W
                  </Box>
                </>
              }
            >
              {component.desc}
            </Section>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
