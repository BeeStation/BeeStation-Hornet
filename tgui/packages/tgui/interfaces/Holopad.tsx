import {
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  calling: BooleanLike;
  on_network: BooleanLike;
  on_cooldown: BooleanLike;
  allowed: BooleanLike;
  disk: BooleanLike;
  disk_record: BooleanLike;
  replay_mode: BooleanLike;
  loop_mode: BooleanLike;
  record_mode: BooleanLike;
  holo_calls: HoloCall[];
};

type HoloCall = {
  caller: string;
  connected: BooleanLike;
  ref: string;
};

export const Holopad = (props) => {
  const { act, data } = useBackend<Data>();
  const { calling } = data;

  return (
    <Window width={440} height={245}>
      {!!calling && (
        <Modal fontSize="36px" fontFamily="monospace">
          <Flex align="center">
            <Flex.Item mr={2} mt={2}>
              <Icon name="phone-alt" rotation={25} />
            </Flex.Item>
            <Flex.Item mr={2}>{'Dialing...'}</Flex.Item>
          </Flex>
          <Box mt={2} textAlign="center" fontSize="24px">
            <Button
              lineHeight="40px"
              icon="times"
              color="bad"
              onClick={() => act('hang_up')}
            >
              Hang Up
            </Button>
          </Box>
        </Modal>
      )}
      <Window.Content scrollable>
        <HolopadContent />
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on_network,
    on_cooldown,
    allowed,
    disk,
    disk_record,
    replay_mode,
    loop_mode,
    record_mode,
    holo_calls = [],
  } = data;

  return (
    <>
      <Section
        title="Holopad"
        buttons={
          <Button
            icon="bell"
            disabled={!on_network || on_cooldown}
            onClick={() => act('AIrequest')}
          >
            {on_cooldown ? "AI's Presence Requested" : "Request AI's Presence"}
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Communicator">
            <Button
              icon="phone-alt"
              disabled={!on_network}
              onClick={() => act('holocall', { headcall: allowed })}
            >
              {allowed ? 'Connect To Holopad' : 'Call Holopad'}
            </Button>
          </LabeledList.Item>
          {holo_calls.map((call) => {
            return (
              <LabeledList.Item
                label={call.connected ? 'Current Call' : 'Incoming Call'}
                key={call.ref}
              >
                <Button
                  icon={call.connected ? 'phone-slash' : 'phone-alt'}
                  color={call.connected ? 'bad' : 'good'}
                  disabled={!on_network}
                  onClick={() =>
                    act(call.connected ? 'disconnectcall' : 'connectcall', {
                      holopad: call.ref,
                    })
                  }
                >
                  {call.connected
                    ? `Disconnect call from ${call.caller}`
                    : `Answer call from ${call.caller}`}
                </Button>
              </LabeledList.Item>
            );
          })}
          {holo_calls.filter((call) => !call.connected).length > 0 && (
            <LabeledList.Item key="reject">
              <Button
                icon="phone-slash"
                color="bad"
                onClick={() => act('rejectall')}
              >
                Reject incoming call(s)
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section
        title="Holodisk"
        buttons={
          <Button
            icon="eject"
            disabled={!disk || replay_mode || record_mode}
            onClick={() => act('disk_eject')}
          >
            Eject
          </Button>
        }
      >
        {(!disk && <NoticeBox>No holodisk</NoticeBox>) || (
          <LabeledList>
            <LabeledList.Item label="Disk Player">
              <Button
                icon={replay_mode ? 'pause' : 'play'}
                selected={replay_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('replay_mode')}
              >
                {replay_mode ? 'Stop' : 'Replay'}
              </Button>
              <Button
                icon={'sync'}
                selected={loop_mode}
                disabled={record_mode || !disk_record}
                onClick={() => act('loop_mode')}
              >
                {loop_mode ? 'Looping' : 'Loop'}
              </Button>
              <Button
                icon="exchange-alt"
                disabled={!replay_mode}
                onClick={() => act('offset')}
              >
                Change Offset
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Recorder">
              <Button
                icon={record_mode ? 'pause' : 'video'}
                selected={record_mode}
                disabled={(disk_record && !record_mode) || replay_mode}
                onClick={() => act('record_mode')}
              >
                {record_mode ? 'End Recording' : 'Record'}
              </Button>
              <Button
                icon="trash"
                color="bad"
                disabled={!disk_record || replay_mode || record_mode}
                onClick={() => act('record_clear')}
              >
                Clear Recording
              </Button>
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </>
  );
};
