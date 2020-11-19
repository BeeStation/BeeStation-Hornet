
import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { ByondUi, Section, Box, Divider, ProgressBar, NoticeBox, Table } from '../components';
import { Window } from '../layouts';

export const WeaponConsole = (props, context) => {
  const { act, data, config } = useBackend(context);
  const {
    mapRef,
  } = data;
  return (
    <Window
      width={870}
      height={708}
      resizable>
      <div className="WeaponConsole__left">
        <Window.Content scrollable>
          <ShipSearchContent />
        </Window.Content>
      </div>
      <div className="WeaponConsole__right">
        <div className="WeaponConsole__weaponpane">
          <WeaponSelection />
        </div>
        <ByondUi
          className="WeaponConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }} />
      </div>
    </Window>
  );
};

export const WeaponSelection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    weapons,
  } = data;
  return (
    <Section>
      <Table>
        <Table.Row>
          {weapons.map(weapon => (
            <Table.Cell
              key={weapon.id}
              className={classes([
                'Button',
                'Button--fluid',
                'Button--color--transparent',
                'Button--ellipsis',
                'Button--selected',
              ])}
              onClick={() => {
                act('set_weapon_target', {
                  id: weapon.id,
                });
              }}>
              <Box
                textAlign="center">
                <b>
                  {weapon.name}
                </b>
              </Box>
              <ProgressBar
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }}
                value={1-weapon.cooldownLeft / weapon.cooldown}>
                {weapon.cooldownLeft > 0
                  ? "Recharging: " + (weapon.cooldownLeft/10)
                  + " seconds"
                  : "Ready to fire."}
              </ProgressBar>
              <Divider />
              <Table>
                <Table.Row>
                  Cooldown - {weapon.cooldown/10} seconds
                </Table.Row>
                <Table.Row>
                  Inaccuracy - {weapon.inaccuracy} meters
                </Table.Row>
              </Table>
            </Table.Cell>
          ))}
        </Table.Row>
      </Table>
    </Section>
  );
};

export const ShipSearchContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ships,
    selectedShip,
  } = data;
  return (
    <Section>
      {ships.map(ship => (
        <Box
          key={ship.id}
          className={classes([
            'Button',
            'Button--fluid',
            'Button--color--transparent',
            'Button--ellipsis',
            selectedShip
              && selectedShip === ship.id
              && 'Button--selected',
          ])}
          onClick={() => {
            act('target_ship', {
              id: ship.id,
            });
          }}>
          <b>
            {ship.name}{" - "}
          </b>
          {ship.faction}
          <Divider />
          {(ship.critical
            ? (
              <NoticeBox
                textAlign="center">
                !! Reactor Critical !!
              </NoticeBox>
            )
            : (
              <Fragment>
                <ProgressBar
                  ranges={{
                    good: [0.75, Infinity],
                    average: [0.25, 0.75],
                    bad: [-Infinity, 0.25],
                  }}
                  value={ship.health/ship.maxHealth}>
                  Integrity: {ship.health}
                </ProgressBar>
                <Divider />
                {ship.id === selectedShip
                  ? (
                    <NoticeBox
                      textAlign="center"
                      color="red">
                      Target Locked
                    </NoticeBox>
                  )
                  : (
                    <NoticeBox
                      textAlign="center"
                      color="grey">
                      Lock Target
                    </NoticeBox>
                  )}
              </Fragment>
            )
          )}
        </Box>
      ))}
    </Section>
  );
};
