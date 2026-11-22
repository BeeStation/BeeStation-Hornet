import {
  AnimatedNumber,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { round } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
] as const;

const stat_to_color = {
  Dead: 'bad',
  Conscious: 'bad',
  Unconscious: 'good',
} as const;

const T0C = 273.15 as const;

type Occupant = {
  name: string;
  stat: string;
  bodyTemperature: number;
  health: number;
  maxHealth: number;
  bruteLoss: number;
  oxyLoss: number;
  toxLoss: number;
  fireLoss: number;
};

type Data = {
  isOperating: BooleanLike;
  isOpen: BooleanLike;
  canTurnOn: BooleanLike;
  autoEject: BooleanLike;
  occupant: Occupant;
  cellTemperature: number;
  isBeakerLoaded: BooleanLike;
  beakerContents: ReagentData[];
};

type ReagentData = {
  name: string;
  volume: number;
};

export function Cryo() {
  const { act, data } = useBackend<Data>();
  const {
    canTurnOn,
    isBeakerLoaded,
    beakerContents,
    autoEject,
    cellTemperature,
    occupant,
    isOperating,
    isOpen,
  } = data;

  return (
    <Window width={400} height={550}>
      <Window.Content scrollable>
        <Section title="Occupant">
          <LabeledList>
            <LabeledList.Item label="Occupant">
              {occupant?.name || 'No Occupant'}
            </LabeledList.Item>
            {!!occupant && (
              <>
                <LabeledList.Item
                  label="State"
                  color={stat_to_color[occupant.stat]}
                >
                  {occupant.stat}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Temperature"
                  color={occupant.bodyTemperature < T0C ? 'good' : 'bad'} // Green if the mob can actually be healed by cryoxadone.
                >
                  <AnimatedNumber value={round(occupant.bodyTemperature, 0)} />
                  {' K'}
                </LabeledList.Item>
                <LabeledList.Item label="Health">
                  <ProgressBar
                    value={round(occupant.health / occupant.maxHealth, 2)}
                    color={occupant.health > 0 ? 'good' : 'average'}
                  >
                    <AnimatedNumber value={round(occupant.health, 0)} />
                  </ProgressBar>
                </LabeledList.Item>
                {damageTypes.map((damageType) => (
                  <LabeledList.Item
                    key={damageType.type}
                    label={damageType.label}
                  >
                    <ProgressBar
                      value={round(occupant[damageType.type] / 100, 2)}
                    >
                      <AnimatedNumber
                        value={round(occupant[damageType.type], 0)}
                      />
                    </ProgressBar>
                  </LabeledList.Item>
                ))}
              </>
            )}
          </LabeledList>
        </Section>

        <Section title="Cell">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                disabled={isOpen || !canTurnOn}
                onClick={() => act('power')}
                color={isOperating && 'green'}
              >
                {isOperating ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber value={round(cellTemperature, 0)} /> K
            </LabeledList.Item>
            <LabeledList.Item label="Door">
              <Button
                icon={isOpen ? 'unlock' : 'lock'}
                onClick={() => act('door')}
              >
                {isOpen ? 'Open' : 'Closed'}
              </Button>
              <Button
                icon={autoEject ? 'sign-out-alt' : 'sign-in-alt'}
                onClick={() => act('autoeject')}
              >
                {autoEject ? 'Auto' : 'Manual'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section
          title="Beaker"
          buttons={
            <Button
              icon="eject"
              disabled={!isBeakerLoaded}
              onClick={() => act('ejectbeaker')}
            >
              Eject
            </Button>
          }
        >
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents}
          />
        </Section>
      </Window.Content>
    </Window>
  );
}
