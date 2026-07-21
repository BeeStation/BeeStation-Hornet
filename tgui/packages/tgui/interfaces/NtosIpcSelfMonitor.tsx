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
  return (
    <NtosWindow width={800} height={500}>
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
        <Flex.Item mb={1}>
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
        <Flex.Item grow>
          <Section title="CORE.CONTROL" fill>
            <Flex direction={'column'} height="100%">
              <Flex.Item>
                <Button
                  mb={1}
                  icon={'eject'}
                  content="Eject"
                  disabled={!data.control_circuit}
                  onClick={() => act('eject_control')}
                />
              </Flex.Item>
              <Flex.Item grow>
                <Box style={{ border: `2px solid #323442` }} height="100%" backgroundColor="#0c0e16">
                <Flex direction={'column'} height="100%" justify="space-evenly" align="center" fontSize="30px" fontFamily="Miriam Mono CLM">
                  <Flex.Item mb={1}>
                    IO_PORT_AUX {data.control_circuit ? "OCCUPIED" : "EMPTY"}
                  </Flex.Item>
                  <Flex.Item mb={1} fontSize="20px" color={data.control_circuit ? "green" : "red"}>
                    {data.control_circuit ? "Control Module installed" : "Control Module missing"}
                  </Flex.Item>
                </Flex>
                </Box>
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
  let passive = (props.upgrade.power_req + props.upgrade.active_power_req) === 0;
  return (
    <Flex direction={'column'} height="100%" justify="space-evenly">
      <Flex.Item textJustify="center">{props.upgrade.name}</Flex.Item>
      <Flex.Item textJustify="center" color={passive ? "green" : props.upgrade.active ? "green" : "red"}>{passive ? "Passive" : props.upgrade.active ? "Active" : "Inactive"}</Flex.Item>
      <Flex.Item textJustify="center">Draw: {props.upgrade.power_req} KW</Flex.Item>
      <Flex.Item textJustify="center">{props.upgrade.active_power_req >= 0 ? `Passive Draw: ${props.upgrade.active_power_req} KW` : `Passive Generation: ${-props.upgrade.active_power_req} KW`}</Flex.Item>
    </Flex>
  );
};
