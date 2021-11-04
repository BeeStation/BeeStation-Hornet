import { range } from "common/collections";
import { BooleanLike, classes } from "common/react";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Flex, Stack, Table } from "../components";
import { Window } from "../layouts";


type AlternateAction = {
  icon: string;
  text: string;
};

const ALTERNATE_ACTIONS: Record<string, AlternateAction> = {
  enable_internals: {
    icon: "./tgfont/icons/air-tank.svg", // svg fonts need to be fixed
    text: "Enable internals",
  },

  disable_internals: {
    icon: "./tgfont/icons/air-tank-slash.svg", // svg fonts need to be fixed
    text: "Disable internals",
  },

  adjust_sensors: {
    icon: "tshirt",
    text: "Adjust suit sensors",
  },
};

enum ObscuringLevel {
  Completely = 1,
  Hidden = 2,
}

type Interactable = {
  interacting: BooleanLike;
};

/**
 * SLOTS is structured into an array of sections.
 * 
 * Each section is an arbitrarily chosen array of slots
 * that are grouped together. This is based on the behavior
 * of the old strip interface.
 * 
 * Sections that contain at least one valid slot end with a
 * spacer, similar to the space present in the old
 * interface.
 * 
 * - image is unused, and is commented out on the DM side.
 * - indented is used for slots that are enabled by other
 *   slots, for example suit storage is dependent on suit.
 */

const SLOTS: Array<
  Array<
    {
      id: string;
      displayName: string;
      image?: string;
      indented?: boolean;
    }
  >
> = [
  [
    {
      id: "left_hand",
      displayName: "Left hand",
      image: "inventory-hand_l.png",
    },
    {
      id: "right_hand",
      displayName: "Right hand",
      image: "inventory-hand_r.png",
    },
  ],
  [
    {
      id: "back",
      displayName: "Backpack",
      image: "inventory-back.png",
    },
  ],
  [
    {
      id: "head",
      displayName: "Headwear",
      image: "inventory-head.png",
    },
    {
      id: "mask",
      displayName: "Mask",
      image: "inventory-mask.png",
    },
    {
      id: "neck",
      displayName: "Neckwear",
      image: "inventory-neck.png",
    },
    {
      id: "corgi_collar",
      displayName: "Collar",
      image: "inventory-collar.png",
    },
    {
      id: "parrot_headset",
      displayName: "Headset",
      image: "inventory-ears.png",
    },
    {
      id: "eyes",
      displayName: "Eyewear",
      image: "inventory-glasses.png",
    },
    {
      id: "ears",
      displayName: "Earwear",
      image: "inventory-ears.png",
    },
  ],
  [
    {
      id: "suit",
      displayName: "Suit",
      image: "inventory-suit.png",
    },
    {
      id: "suit_storage",
      displayName: "Suit storage",
      image: "inventory-suit_storage.png",
      indented: true,
    },
    {
      id: "shoes",
      displayName: "Shoes",
      image: "inventory-shoes.png",
    },
    {
      id: "gloves",
      displayName: "Gloves",
      image: "inventory-gloves.png",
    },
    {
      id: "jumpsuit",
      displayName: "Uniform",
      image: "inventory-uniform.png",
    },
    {
      id: "belt",
      displayName: "Belt",
      image: "inventory-belt.png",
      indented: true,
    },
    {
      id: "left_pocket",
      displayName: "Left pocket",
      image: "inventory-pocket.png",
      indented: true,
    },
    {
      id: "right_pocket",
      displayName: "Right pocket",
      image: "inventory-pocket.png",
      indented: true,
    },
    {
      id: "id",
      displayName: "ID",
      image: "inventory-id.png",
      indented: true,
    },
    {
      id: "handcuffs",
      displayName: "Handcuffs",
    },
    {
      id: "legcuffs",
      displayName: "Legcuffs",
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
  | ((
      | {
          icon: string;
          name: string;
          alternate?: string;
        }
      | {
          obscured: ObscuringLevel;
        }
    ) &
      Partial<Interactable>);

type StripMenuData = {
  items: Record<keyof typeof SLOTS, StripMenuItem>;
  name: string;
};

// Internal data structure used for props
interface StripMenuRowProps {
  slotName: string;
  itemName?: string;
  slotID: string;

  alternates?: AlternateAction[];

  indented: BooleanLike;
  obscured: ObscuringLevel;
  hidden: BooleanLike;
  empty: BooleanLike;
}

const StripMenuRow = (props: StripMenuRowProps, context) => {
  const { act, data } = useBackend<StripMenuData>(context);

  return (
    <Table.Row
      className={classes([
        props.indented && "indented",
        props.obscured===ObscuringLevel.Completely && "obscured-complete",
        props.obscured===ObscuringLevel.Hidden && "obscured-hidden",
        props.hidden && "hidden",
        props.empty && "empty",
      ])}>
      <Table.Cell pl={1.5}>
        {props.slotName}:
      </Table.Cell>
      <Table.Cell pr={1.5} position="relative">
        <Flex direction="column">
          {
            !props.hidden && (
              <Flex.Item>
                <Button compact
                  content={props.obscured ? "Obscured" : (props.itemName ?? "Empty")}
                  disabled={props.obscured === ObscuringLevel.Completely}
                  color={props.empty ? "transparent" : null}
                  ellipsis
                  maxWidth="100%"
                  onClick={() => act("use", { key: props.slotID })}
                />
              </Flex.Item>
            )
          }
          {
            props.alternates?.map((alternate) => (
              <Flex.Item key={alternate.text}>
                <Button compact
                  content={alternate.text}
                  onClick={() => act("alt", { key: props.slotID })}
                />
              </Flex.Item>
            ))
          }
        </Flex>
      </Table.Cell>
    </Table.Row>
  );
};

export const StripMenu = (props, context) => {
  const { act, data } = useBackend<StripMenuData>(context);

  const items = data.items;

  const contents = SLOTS.map(section => {
    let hadLastTopLevelSlot = false;

    const rows = section
      .filter(slot => items[slot.id] !== undefined)
      .map(slot => {
        const item = items[slot.id];

        if (!slot.indented)
        { hadLastTopLevelSlot = !!item; }

        const alternate = item && ALTERNATE_ACTIONS[item.alternate];

        return (
          <StripMenuRow
            slotName={slot.displayName}
            itemName={item && item.name}
            obscured={item && ("obscured" in item) ? item.obscured : 0}
            indented={slot.indented}
            slotID={slot.id}
            hidden={slot.indented && !hadLastTopLevelSlot}
            alternates={alternate && [alternate]}
            empty={!item}
            key={slot.id}
          />
        );
      });

    //If any valid slots were found in this section, add a spacer
    if (rows.length)
    {
      rows.push(
        <Table.Row className="spacer">
          <Table.Cell /><Table.Cell />
        </Table.Row>
      );
    }

    return rows;
  });

  return (
    <Window title={`Stripping ${data.name}`}
      // Enough width to fit "atmospheric technician's jumpsuit"
      width={400}
      // Enough height to fit human with internals,
      // jumpsuit, handcuffs and legcuffs
      height={580}>
      <Window.Content scrollable fitted
        //Remove the nanotrasen logo from the window
        style={{ "background-image": "none" }}>
        <Table mt={1} className="strip-menu-table" fontSize="1.1em">
          {contents}
        </Table>
      </Window.Content>
    </Window>
  );
};
