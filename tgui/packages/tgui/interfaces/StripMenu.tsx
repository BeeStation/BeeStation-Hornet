import { range } from "common/collections";
import { BooleanLike, classes } from "common/react";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Stack, Table } from "../components";
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

const SLOTS: Array<
  Array<
    {
      id: string;
      displayName: string;
      image?: string;
      indented?: Boolean;
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

type StripMenuRowData = {
  slotName: string;
  itemName?: string;
  obscured?: ObscuringLevel;
  alternates?: AlternateAction[];
  hidden: BooleanLike;
  indented: BooleanLike;
  spaced: BooleanLike;
  slotID: string;
}

// Sizes here are in em

const rowHeightRaw = 1.8

const rowHeight = `${rowHeightRaw}em`

export const StripMenu = (props, context) => {
  const { act, data } = useBackend<StripMenuData>(context);

  const items = data.items;

  const rows: StripMenuRowData[] = [];

  for (const category of SLOTS)
  {
    let slotFound = false;
    let hadLastTopLevelSlot = false;
    for (const slot of category)
    {
      const item = items[slot.id];

      if (item === undefined) continue;

      slotFound = true;

      const row: StripMenuRowData = {
        slotName: slot.displayName,
        itemName: item && item.name,
        obscured: item && ("obscured" in item) ? item.obscured : 0,
        indented: slot.indented,
        slotID: slot.id,
        hidden: slot.indented && !hadLastTopLevelSlot
      };

      rows.push(row);

      if(!slot.indented)
        hadLastTopLevelSlot = !!item
    }

    if(slotFound)
      rows[rows.length-1].spaced = true;
  }

  const contents = rows.map((row, index) => {

    return (
      <>
      <Table.Row
        height={rowHeight}
        className={classes([
          row.indented && "indented",
          row.obscured===ObscuringLevel.Completely && "obscured-complete",
          row.obscured===ObscuringLevel.Hidden && "obscured-hidden",
          row.hidden && "hidden",
          row.spaced && "spaced",
        ])}>
        <Table.Cell pl={1.5} pr={1}
            collapsing
            >
          {row.slotName}:
        </Table.Cell>
        <Table.Cell pl={2} pr={1.5}>
          {
            !row.hidden && (
              <Button compact
                content={row.obscured ? "Obscured" : (row.itemName || "Empty")}
                disabled={row.obscured === ObscuringLevel.Completely}
                onClick={() => act("use", { key: row.slotID })}
              />
            )
          }
          {
            row.alternates?.map((alternate) => (
              <Button compact
                content={alternate.text}
                onClick={() => act("alt", { key: row.slotID })}
              />
            ))
          }
        </Table.Cell>
      </Table.Row>
      {(!!row.spaced) && <Table.Row height={0.5} className="candystripe"/>}
      </>
    );
  })

  return (
    <Window title={`Stripping ${data.name}`}
      width={400}
      height={500}>
      <Window.Content scrollable fitted
      style={{"background-image": "none"}}>
        <Table mt={1} className="strip-menu-table" fontSize="1.1em">
          {contents}
        </Table>
      </Window.Content>
    </Window>
  );
};
