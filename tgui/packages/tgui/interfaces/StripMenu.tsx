import { range } from "common/collections";
import { BooleanLike, classes } from "common/react";
import { resolveAsset } from "../assets";
import { useBackend } from "../backend";
import { Box, Button, Icon, Stack, Table } from "../components";
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
      displayName: "left hand",
      image: "inventory-hand_l.png",
    },
    {
      id: "right_hand",
      displayName: "right hand",
      image: "inventory-hand_r.png",
    },
  ],
  [
    {
      id: "back",
      displayName: "backpack",
      image: "inventory-back.png",
    },
  ],
  [
    {
      id: "head",
      displayName: "headwear",
      image: "inventory-head.png",
    },
    {
      id: "mask",
      displayName: "mask",
      image: "inventory-mask.png",
    },
    {
      id: "neck",
      displayName: "neckwear",
      image: "inventory-neck.png",
    },
    {
      id: "corgi_collar",
      displayName: "collar",
      image: "inventory-collar.png",
    },
    {
      id: "parrot_headset",
      displayName: "headset",
      image: "inventory-ears.png",
    },
    {
      id: "eyes",
      displayName: "eyewear",
      image: "inventory-glasses.png",
    },
    {
      id: "ears",
      displayName: "earwear",
      image: "inventory-ears.png",
    },
  ],
  [
    {
      id: "suit",
      displayName: "suit",
      image: "inventory-suit.png",
    },
    {
      id: "suit_storage",
      displayName: "suit storage",
      image: "inventory-suit_storage.png",
      indented: true,
    },
    {
      id: "shoes",
      displayName: "shoes",
      image: "inventory-shoes.png",
    },
    {
      id: "gloves",
      displayName: "gloves",
      image: "inventory-gloves.png",
    },
    {
      id: "jumpsuit",
      displayName: "uniform",
      image: "inventory-uniform.png",
    },
    {
      id: "belt",
      displayName: "belt",
      image: "inventory-belt.png",
      indented: true,
    },
    {
      id: "left_pocket",
      displayName: "left pocket",
      image: "inventory-pocket.png",
      indented: true,
    },
    {
      id: "right_pocket",
      displayName: "right pocket",
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
      displayName: "handcuffs",
    },
    {
      id: "legcuffs",
      displayName: "legcuffs",
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
  icon?: Element;
  obscured?: ObscuringLevel;
  alternates?: AlternateAction[];
  hidden: BooleanLike;
  indented: BooleanLike;
  spaced: BooleanLike;
  slotID: string;
}

// Sizes here are in em

const rowHeightRaw = 1.8
const imageSizeRaw = 1.6
const imageSizeItemRaw = imageSizeRaw*2
const imageColumnWidthRaw = rowHeightRaw*0.7

const imageSize = `${imageSizeRaw}em`
const imageSizeItem = `${imageSizeItemRaw}em`
const imageColumnWidth = `${imageColumnWidthRaw}em`
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

      if(item && "alternate" in item && ALTERNATE_ACTIONS[item.alternate])
        row.alternates = [ALTERNATE_ACTIONS[item.alternate]]

      if(!row.obscured)
      {
        row.icon = <Box
          as="img"
          src={item ? `data:image/png;base64,${item.icon}` : resolveAsset(slot.image)}
          width={item ? imageSizeItem : imageSize}
          //style={{
          //  "vertical-align": "middle",
          //}}
        />
      }
      //*
      else if(row.obscured)
      {
        row.icon = 
            <Icon
              name={
                item.obscured === ObscuringLevel.Completely
                  ? "ban"
                  : "eye-slash"
              }
              fontSize={imageSize}/>
      }
      //*/

      /*
      if(row.icon)
      {
        row.icon = <Box className="strip-menu-icon"
          //position="absolute"
          //height={imageSize}
          //width={imageSize}
          //top={imageOffset}
          //left={imageOffset}
          >
          {row.icon}
        </Box>
      }
      //*/

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
          //"candystripe",
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
        {/*}
        <Table.Cell height={rowHeight} width={imageColumnWidth}>
          <Box as="div" height={rowHeight} width="100%" position="relative" className="strip-menu-icon-container">
            <Box as="div">
              {row.icon}
            </Box>
          </Box>
        </Table.Cell>
        {*/}
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
