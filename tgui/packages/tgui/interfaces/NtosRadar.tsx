import { classes } from 'common/react';
import { useEffect, useRef } from 'react';

import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  NoticeBox,
  Section,
  Tooltip,
} from '../components';
import { NtosWindow } from '../layouts';

type AtomRef = string;

type NtosRadarObject = {
  ref: AtomRef;
  name: string;
};

export enum ZResult {
  Z_RESULT_SAME_Z = 0,
  Z_RESULT_TOO_FAR = 1,
}

export enum PointerZ {
  CaretUp = 'caret-up',
  CaretDown = 'caret-down',
}

type TrackInfo = {
  locx: number;
  locy: number;
  locz_string: string;
  pin_grand_z_result: ZResult;
  use_rotate: boolean;
  rotate_angle: number;
  arrowstyle: string;
  color: string;
  pointer_z: PointerZ | undefined;
  gpsx: number;
  gpsy: number;
  gpsz: number;
  dist: number;
};

type NtosRadarData = {
  full_capability: boolean;
  selected: AtomRef;
  objects: NtosRadarObject[];
  scanning: boolean;
  target: TrackInfo;
};

export const NtosRadar = () => {
  const { act, data } = useBackend<NtosRadarData>();
  const { full_capability } = data;
  return (
    <NtosWindow
      width={full_capability ? 800 : 400}
      height={full_capability ? 600 : 500}
      theme="ntos"
    >
      {full_capability ? (
        <NtosRadarContent sig_err={'Signal Lost'} />
      ) : (
        <NtosRadarContentSmall sig_err={'Signal Lost'} />
      )}
    </NtosWindow>
  );
};
const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export const NtosRadarContentSmall = (props) => {
  const { act, data } = useBackend<NtosRadarData>();
  const { selected, target } = data;
  const { sig_err } = props;
  return (
    <NtosWindow.Content scrollable>
      <NtosRadarMap displayError={selected} sig_err={sig_err} target={target} />
    </NtosWindow.Content>
  );
};

export const NtosRadarMapSmall = (props) => {
  const { selected = false, sig_err, target = [] } = props;
  return (
    <Section>
      {Object.keys(target).length === 0 ? (
        selected ? (
          <NoticeBox width={42} fontSize="30px" textAlign="center">
            {sig_err}
          </NoticeBox>
        ) : (
          <Box>No Target Selected.</Box>
        )
      ) : (
        <Box>
          Distance: {target.dist} {target.locz_string}{' '}
          {target.use_rotate &&
          target.pointer_z &&
          target.pin_grand_z_result ? (
            <Tooltip content={'WARNING: Target is too far away.'}>
              <Icon name="exclamation-triangle" color="yellow" />
            </Tooltip>
          ) : null}
          <br />
          Location: ({target.gpsx}x, {target.gpsy}y, {target.gpsz}z){' '}
          {target.use_rotate ? (
            <Icon
              name={target.dist > 0 ? 'arrow-up' : 'crosshairs'}
              style={{
                transform: `rotate(${target.rotate_angle}deg)`,
              }}
            />
          ) : null}{' '}
          {target.use_rotate && target.pointer_z ? (
            <Icon size={1.5} name={target.pointer_z} />
          ) : null}
        </Box>
      )}
    </Section>
  );
};

type NtosRadarContentProps = {
  sig_err: string;
};

export const NtosRadarContent = (props: NtosRadarContentProps) => {
  const { act, data } = useBackend<NtosRadarData>();
  const { selected, objects = [], target, scanning } = data;
  const { sig_err } = props;
  return (
    <Flex direction={'row'} hight="100%">
      <Flex.Item position="relative" width={20.5} hight="100%">
        <NtosWindow.Content scrollable>
          <Section>
            <Button
              icon="redo-alt"
              content={scanning ? 'Scanning...' : 'Scan'}
              color="blue"
              disabled={scanning}
              onClick={() => act('scan')}
            />
            {!objects.length && !scanning && (
              <div>No trackable signals found</div>
            )}
            {!scanning &&
              objects.map((object) => (
                <div
                  key={object.ref}
                  title={object.name}
                  className={classes([
                    'Button',
                    'Button--fluid',
                    'Button--color--transparent',
                    'Button--ellipsis',
                    object.ref === selected && 'Button--selected',
                  ])}
                  onClick={() => {
                    act('selecttarget', {
                      ref: object.ref,
                    });
                  }}
                >
                  {object.name}
                </div>
              ))}
          </Section>
        </NtosWindow.Content>
      </Flex.Item>
      <Flex.Item
        position="relative"
        m={1.5}
        width={45}
        height={45}
        style={{
          top: '20px',
        }}
      >
        <NtosRadarMap
          displayError={selected}
          sig_err={sig_err}
          target={target}
        />
      </Flex.Item>
    </Flex>
  );
};

export type NtosRadarMapProps = {
  rightAlign?: boolean;
  sig_err: string;
  displayError: AtomRef | boolean;
  target?: TrackInfo;
};

export function NtosRadarMap(props: NtosRadarMapProps) {
  const { sig_err, displayError, target, rightAlign } = props;

  const containerRef = useRef<HTMLDivElement>(null);
  const [state, setState] = useLocalState('state', {
    width: 0,
    height: 0,
  });

  const { width, height } = state;

  const scalingFactor = (width < height ? width : height) / 540;
  const offset = width - (width < height ? width : height);

  useEffect(() => {
    const updateDimensions = () => {
      if (!containerRef.current) {
        return;
      }
      const { width, height } = containerRef.current.getBoundingClientRect();
      setState({
        width: width,
        height: height,
      });
    };
    updateDimensions();
    window.addEventListener('resize', updateDimensions);
    return () => {
      window.removeEventListener('resize', updateDimensions);
    };
  }, []);

  return (
    <div
      style={{
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        /* Important to make sure we don't get 540px of scrollbar */
        overflow: 'hidden',
      }}
      ref={containerRef}
    >
      <div
        style={{
          /* Render at a fixed width and height and then scale it */
          width: '540px',
          height: '540px',
          transform:
            (rightAlign && 'translate(' + offset + 'px, 0px) ') +
            'scale(' +
            scalingFactor +
            ')',
          transformOrigin: 'top left',
          backgroundImage:
            'url("' + resolveAsset('ntosradarbackground.png') + '")',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat',
        }}
      >
        {!target || Object.keys(target).length === 0
          ? !!displayError && (
              <NoticeBox
                position="absolute"
                top={20.6}
                left={1.35}
                width={42}
                fontSize="30px"
                textAlign="center"
              >
                {sig_err}
              </NoticeBox>
            )
          : (!!target.use_rotate && (
              <>
                <Box
                  as="img"
                  src={resolveAsset(target.arrowstyle)}
                  position="absolute"
                  top="20px"
                  left="243px"
                  style={{
                    transform: `rotate(${target.rotate_angle}deg)`,
                  }}
                />
                {target.pointer_z ? (
                  <Icon
                    name={target.pointer_z}
                    position="absolute"
                    size={12}
                    color={target.pin_grand_z_result ? 'purple' : 'orange'}
                    top={200 + 'px'}
                    left={224 + 'px'}
                  />
                ) : null}
              </>
            )) || (
              <Icon
                name={target.pointer_z ? target.pointer_z : 'crosshairs'}
                position="absolute"
                size={target.pointer_z ? 4 : 2}
                color={
                  target.pin_grand_z_result
                    ? 'purple'
                    : target.pointer_z
                      ? 'orange'
                      : target.color
                }
                top={target.locy * 10 + 19 + 'px'}
                left={target.locx * 10 + 16 + 'px'}
              />
            )}
        {!!target && (
          <Box>
            Distance: {target.dist} {target.locz_string}
            {target.pointer_z && target.pin_grand_z_result ? (
              <Tooltip content={'WARNING: Target is too far away.'}>
                <Icon name="exclamation-triangle" color="yellow" />
              </Tooltip>
            ) : null}
            <br />
            Location: ({target.gpsx}x, {target.gpsy}y, {target.gpsz}z){' '}
          </Box>
        )}
      </div>
    </div>
  );
}
