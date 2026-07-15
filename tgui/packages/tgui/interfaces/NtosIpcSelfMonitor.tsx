import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  ProgressBar,
  Section,
} from '../components';
import { NtosWindow } from '../layouts';

type Upgrade = {
  name: string
  active: boolean
  power_req: number
  active_power_req: number
  passive: boolean
}

type Data = {
  name: string
  charge: number
  max_charge: number
  upgrade_core: Upgrade
  upgrade_external: Upgrade
  upgrade_utility: Upgrade
  control_circuit: boolean
}

export const NtosIpcSelfMonitor = (_) => {
  const { data } = useBackend();
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <NtosIpcSelfMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosIpcSelfMonitorContent = (_) => {
  const { act, data } = useBackend<Data>();
  return (
  <Flex direction={'row'} height="100%">
    <Flex.Item width="50%" height="100%" mr={1}>
      <Flex direction={'column'} height="100%">
        <Flex.Item>
          <Section title="CORE.STAT" width="100%">
            <Box my={1}>
              Internal ID :: {data.name}
            </Box>
            <ProgressBar
            value={data.max_charge ? data.charge / data.max_charge * 100 : 0}
            minValue={0}
            maxValue={100}
            ranges={{
              bad: [-Infinity, 25],
              average: [25, 75],
              good: [75, Infinity],
            }}
            />
            <Box mt={1}>
              {Math.round(data.charge)} KW / {Math.round(data.max_charge)} KW
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item mt={1} grow>
          <Section title="CORE.CONTROL" fill>
            <Flex direction={'column'} height="100%">
              <Flex.Item>
                <Button
                  mb={1}
                  icon={'eject'}
                  content="Eject"
                  disabled={data.control_circuit !== null}
                  onClick={() => act('eject_control')}
                />
              </Flex.Item>
              <Flex.Item grow>
                <DrawControlPort />
              </Flex.Item>
            </Flex>
          </Section>
        </Flex.Item>
      </Flex>
    </Flex.Item>
    <Flex.Item grow>
      <Flex direction={'column'} height="100%">
        <Flex.Item grow mb={1}>
          <Section title="UPGRADE.CORE" fill>
              <UpgradeStats upgrade={data.upgrade_core} />
          </Section>
        </Flex.Item>
        <Flex.Item grow mb={1}>
          <Section title="UPGRADE.EXTERNAL" fill>
              <UpgradeStats upgrade={data.upgrade_external} />
          </Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section title="UPGRADE.UTILITY" fill>
              <UpgradeStats upgrade={data.upgrade_utility} />
          </Section>
        </Flex.Item>
      </Flex>
    </Flex.Item>
  </Flex>);
};

type UpgradeProps = {
  upgrade: Upgrade
}

export const UpgradeStats = (props: UpgradeProps) => {
  const { act, data } = useBackend<Data>();
  if(props.upgrade === null) { return (
  <Flex
  justify="center"
  align="center"
  height="100%"
>
  <Box fontSize="30px" color="red">No Upgrade Detected</Box>
  </Flex>
  ); }
  return (
    <Flex direction={'column'} height="100%" justify="space-evenly">
      <Flex.Item textJustify="center">{props.upgrade.name}</Flex.Item>
      <Flex.Item textJustify="center" color={props.upgrade.passive ? "green" : props.upgrade.active ? "green" : "red"}>{props.upgrade.passive ? "Passive" : props.upgrade.active ? "Active" : "Inactive"}</Flex.Item>
      <Flex.Item textJustify="center">Draw: {props.upgrade.power_req} KW</Flex.Item>
      <Flex.Item textJustify="center">{props.upgrade.active_power_req >= 0 ? `Passive Draw: ${props.upgrade.active_power_req} KW` : `Passive Generation: ${-props.upgrade.active_power_req} KW`}</Flex.Item>
    </Flex>
  );
};

export const DrawControlPort = (_) => {
  const { act, data } = useBackend<Data>();
  return (
    <svg width="100%" height="100%">
      <rect
        x="0"
        y="0"
        width="100%"
        height="100%"
        fill="black"
        stroke="grey"
      />
    </svg>
  );
};
