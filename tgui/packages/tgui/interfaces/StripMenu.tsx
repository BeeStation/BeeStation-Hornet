import { BooleanLike, classes } from 'common/react';

import { useBackend } from '../backend';
import { Button, Flex, Table } from '../components';
import { Window } from '../layouts';

type AlternateAction = {
  icon?: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  enable_internals: {
    text: 'Enable internals',
  },

  disable_internals: {
    text: 'Disable internals',
  },

  adjust_sensors: {
    text: 'Adjust suit sensors',
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
}

type Interactable = {
  interacting: BooleanLike;
};

type Unavailable = {
  unavailable: BooleanLike;
};

const SLOTS: Record<string, string> = {
  left_hand: 'Left hand',
  right_hand: 'Right hand',
  back: 'Backpack',
  head: 'Headwear',
  mask: 'Mask',
  neck: 'Neckwear',
  corgi_collar: 'Collar',
  parrot_headset: 'Headset',
  eyes: 'Eyewear',
  ears: 'Earwear',
  suit: 'Suit',
  suit_storage: 'Suit storage',
  shoes: 'Shoes',
  gloves: 'Gloves',
  jumpsuit: 'Uniform',
  belt: 'Belt',
  left_pocket: 'Left pocket',
  right_pocket: 'Right pocket',
  id: 'ID',
  handcuffs: 'Handcuffs',
  legcuffs: 'Legcuffs',
};

type Layout = Array<
  Array<{
    id: string;
    indented?: BooleanLike;
  }>
>;

const DEFAULT_LAYOUT: Layout = [
  [
    {
      id: 'left_hand',
    },
    {
      id: 'right_hand',
    },
  ],
  [
    {
      id: 'back',
    },
  ],
  [
    {
      id: 'head',
    },
    {
      id: 'mask',
    },
    {
      id: 'neck',
    },
    {
      id: 'corgi_collar',
    },
    {
      id: 'parrot_headset',
    },
    {
      id: 'eyes',
    },
    {
      id: 'ears',
    },
  ],
  [
    {
      id: 'suit',
    },
    {
      id: 'suit_storage',
    },
    {
      id: 'shoes',
    },
    {
      id: 'gloves',
    },
    {
      id: 'jumpsuit',
    },
    {
      id: 'belt',
    },
    {
      id: 'left_pocket',
    },
    {
      id: 'right_pocket',
    },
    {
      id: 'id',
    },
    {
      id: 'handcuffs',
    },
    {
      id: 'legcuffs',
    },
  ],
];

/**
 * Some possible options:
 *
 * null - No interactions, no item, but is an available slot
 * { interacting: 1 } - No item, but we're interacting with it
 * { icon: icon, name: name } - An item with no alternate actions
 *   that we're not interacting with.
 * { icon, name, interacting: 1 } - An item with no alternate actions
 *   that we're interacting with.
 */
type StripMenuItem =
  | null
  | Interactable
  | Unavailable
  | ((
      | {
          icon?: string;
          name: string;
          alternate?: string;
          extra_actions?: StripMenuActions;
        }
      | {
          obscured: ObscuringLevel;
        }
    ) &
      Partial<Interactable> &
      Partial<Unavailable>);

type StripMenuActions = {
  action_name: string;
  action_key: string;
  action_color: string | undefined;
  action_icon: string | undefined;
}[];

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  layout?: Layout;
  name: string;
};

// Internal data structure used for props
interface StripMenuRowProps {
  slotName: string;
  itemName?: string;
  slotID: string;

  alternates?: AlternateAction[];

  interacting: BooleanLike;
  indented: BooleanLike;
  obscured: ObscuringLevel | null;
  empty: BooleanLike;
  unavailable: BooleanLike;
  extra_actions: StripMenuActions;
}

const StripMenuRow = (props: StripMenuRowProps) => {
  const { act, data } = useBackend<StripMenuData>();

  const name = props.obscured
    ? 'Obscured'
    : props.empty
      ? 'Empty'
      : props.itemName;

  return (
    <Table.Row
      className={classes([
        props.indented && 'indented',
        props.obscured === ObscuringLevel.Completely && 'obscured-complete',
        props.obscured === ObscuringLevel.Hidden && 'obscured-hidden',
        props.unavailable && 'unavailable',
        props.empty && 'empty',
      ])}
    >
      <Table.Cell pl={1.5}>{props.slotName}:</Table.Cell>
      <Table.Cell pr={1.5} position="relative">
        <Flex direction="column">
          {!props.unavailable && (
            <Flex.Item>
              <Button
                compact
                content={name}
                disabled={props.obscured === ObscuringLevel.Completely}
                color={props.empty ? 'transparent' : null}
                ellipsis
                maxWidth="100%"
                icon={props.interacting && 'spinner'}
                iconSpin
                onClick={() => act('use', { key: props.slotID })}
              />
            </Flex.Item>
          )}
          {props.alternates?.map((alternate) => (
            <Flex.Item key={alternate.text}>
              <Button
                compact
                content={alternate.text}
                onClick={() => act('alt', { key: props.slotID })}
              />
            </Flex.Item>
          ))}
          {props.extra_actions?.map((alternate) => (
            <Flex.Item key={alternate.action_name}>
              <Button
                compact
                content={alternate.action_name}
                color={alternate.action_color || 'default'}
                icon={alternate.action_icon}
                onClick={() =>
                  act('extra_act', {
                    key: props.slotID,
                    action: alternate.action_key,
                  })
                }
              />
            </Flex.Item>
          ))}
        </Flex>
      </Table.Cell>
    </Table.Row>
  );
};

export const StripMenu = (props) => {
  const { act, data } = useBackend<StripMenuData>();

  const items = data.items;
  const layout = data.layout || DEFAULT_LAYOUT;

  const contents = layout.map((section) => {
    const rows = section
      .filter((slot) => items[slot.id] !== undefined)
      .map((slot) => {
        const item = items[slot.id];

        let alternate: AlternateAction | undefined;
        if (item && item['alternate'] !== undefined) {
          alternate = ALTERNATE_ACTIONS[item['alternate']];
        }

        let name: string | undefined;
        if (item && item['name'] !== undefined) {
          name = item['name'];
        }

        const extra_interactions =
          item && item['extra_actions'] !== undefined
            ? item['extra_actions']
            : [];

        return (
          <StripMenuRow
            slotName={SLOTS[slot.id]}
            itemName={name}
            obscured={item && 'obscured' in item ? item.obscured : null}
            indented={slot.indented}
            slotID={slot.id}
            unavailable={item && 'unavailable' in item && item.unavailable}
            alternates={alternate ? [alternate] : undefined}
            empty={!item || !('name' in item || 'obscured' in item)}
            interacting={item && 'interacting' in item && item.interacting}
            extra_actions={extra_interactions}
            /* @ts-ignore: Key is a mandatory property for .map return values */
            key={slot.id}
          />
        );
      });

    // If any valid slots were found in this section, add a spacer
    if (rows.length) {
      rows.push(
        <Table.Row className="spacer">
          <Table.Cell />
          <Table.Cell />
        </Table.Row>,
      );
    }

    return rows;
  });

  return (
    <Window
      title={`Stripping ${data.name}`}
      // Enough width to fit "atmospheric technician's jumpsuit"
      width={400}
      // Enough height to fit human with internals,
      // jumpsuit, handcuffs and legcuffs
      height={580}
    >
      <Window.Content
        scrollable
        fitted
        // Remove the nanotrasen logo from the window
        style={{ backgroundImage: 'none' }}
      >
        <Table mt={1} className="strip-menu-table" fontSize="1.1em">
          {contents}
        </Table>
      </Window.Content>
    </Window>
  );
};
