import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, NoticeBox, Section, Tooltip } from '../components';
import { NtosWindow } from '../layouts';

export const NtosRadar = (props, context) => {
  const { act, data } = useBackend(context);
  const { full_capability } = data;
  return (
    <NtosWindow width={full_capability ? 800 : 400} height={full_capability ? 600 : 500} theme="ntos">
      {full_capability ? <NtosRadarContent sig_err={'Signal Lost'} /> : <NtosRadarContentSmall sig_err={'Signal Lost'} />}
    </NtosWindow>
  );
};
const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export const NtosRadarContentSmall = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected, object = [], target = [], scanning, full_capability } = data;
  const { sig_err } = props;
  return (
    <NtosWindow.Content scrollable>
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
            {target.use_rotate && target.pointer_z && target.pin_grand_z_result ? (
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
                  'transform': `rotate(${target.rotate_angle}deg)`,
                }}
              />
            ) : null}{' '}
            {target.use_rotate && target.pointer_z ? <Icon size={1.5} name={target.pointer_z} /> : null}
          </Box>
        )}
      </Section>

      <Section>
        <Button
          icon="redo-alt"
          content={scanning ? 'Scanning...' : 'Scan'}
          color="blue"
          disabled={scanning}
          onClick={() => act('scan')}
        />
        {!object.length && !scanning && <div>No trackable signals found</div>}
        {!scanning &&
          object.map((object) => (
            <div
              key={object.dev}
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
              }}>
              {object.name}
            </div>
          ))}
      </Section>
    </NtosWindow.Content>
  );
};

export const NtosRadarContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected, object = [], target = [], scanning, full_capability } = data;
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
            {!object.length && !scanning && <div>No trackable signals found</div>}
            {!scanning &&
              object.map((object) => (
                <div
                  key={object.dev}
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
                  }}>
                  {object.name}
                </div>
              ))}
          </Section>
        </NtosWindow.Content>
      </Flex.Item>
      <Flex.Item
        style={{
          'background-image': 'url("' + resolveAsset('ntosradarbackground.png') + '")',
          'background-position': 'center',
          'background-repeat': 'no-repeat',
          'top': '20px',
        }}
        position="relative"
        m={1.5}
        width={45}
        height={45}>
        {Object.keys(target).length === 0
          ? !!selected && (
            <NoticeBox position="absolute" top={20.6} left={1.35} width={42} fontSize="30px" textAlign="center">
              {sig_err}
            </NoticeBox>
          )
          : (!!target.use_rotate && (
            <Fragment>
              <Box
                as="img"
                src={resolveAsset(target.arrowstyle)}
                position="absolute"
                top="20px"
                left="243px"
                style={{
                  'transform': `rotate(${target.rotate_angle}deg)`,
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
            </Fragment>
          )) || (
            <Icon
              name={target.pointer_z ? target.pointer_z : 'crosshairs'}
              position="absolute"
              size={target.pointer_z ? 4 : 2}
              color={target.pin_grand_z_result ? 'purple' : target.pointer_z ? 'orange' : target.color}
              top={target.locy * 10 + 19 + 'px'}
              left={target.locx * 10 + 16 + 'px'}
            />
          )}
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
      </Flex.Item>
    </Flex>
  );
};
