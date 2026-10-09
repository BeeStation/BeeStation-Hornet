import { sortBy } from 'common/collections';
import { classes } from 'common/react';

import { useLocalState } from '../../backend';
import { AnimatedNumber, Button, Flex, Stack } from '../../components';
import { MaterialIcon } from './MaterialIcon';
import { Design, formatSheets, Material } from './Types';

const LABEL_FORMAT = (value: number) => formatSheets(value);

const rarity: Record<string, number> = {
  glass: 0,
  iron: 1,
  copper: 2,
  plastic: 3,
  titanium: 4,
  plasma: 5,
  silver: 6,
  gold: 7,
  uranium: 8,
  diamond: 9,
  'bluespace crystal': 10,
  bananium: 11,
};

/** Every material name that any of these designs is built from. */
const materialsUsedBy = (designs: Design[]) => {
  const used = new Set<string>();
  for (const design of designs) {
    for (const material of Object.keys(design.cost)) {
      used.add(material);
    }
  }
  return used;
};

export const MaterialAccessBar = (props: {
  availableMaterials: Material[];
  designs?: Design[];
  onEjectRequested: (material: Material, amount: number) => void;
}) => {
  const spendable = materialsUsedBy(props.designs || []);

  return (
    <Flex wrap>
      {sortBy((material: Material) => rarity[material.name] ?? 99)(
        props.availableMaterials.filter(
          (material) => material.amount > 0 || spendable.has(material.name),
        ),
      ).map((material) => (
        <Flex.Item key={material.name} grow={1}>
          <MaterialCounter
            material={material}
            onEjectRequested={(amount) =>
              props.onEjectRequested(material, amount)
            }
          />
        </Flex.Item>
      ))}
    </Flex>
  );
};

const MaterialCounter = (
  props: { material: Material; onEjectRequested: (amount: number) => void },
  context,
) => {
  const [hovering, setHovering] = useLocalState(
    `MaterialCounter__${props.material.name}`,
    false,
  );
  // Coerce to a real boolean, otherwise it would add a literal white 0
  const canEject = !!props.material.removable && props.material.amount >= 2000;
  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={classes([
        'MaterialDock',
        hovering && canEject ? 'MaterialDock--active' : '',
        !canEject ? 'MaterialDock--disabled' : '',
      ])}
    >
      <Stack direction="column-reverse">
        <Flex
          direction="column"
          textAlign="center"
          onClick={() => canEject && props.onEjectRequested(1)}
          className="MaterialDock__Label"
        >
          <Flex.Item>
            <MaterialIcon
              materialName={props.material.name}
              amount={props.material.amount}
            />
          </Flex.Item>
          <Flex.Item>
            <AnimatedNumber
              value={props.material.amount}
              format={LABEL_FORMAT}
            />
          </Flex.Item>
        </Flex>
        {hovering && canEject && (
          <div className="MaterialDock__Dock">
            <Flex direction="column-reverse">
              {[5, 10, 25, 50].map((amount) => (
                <Button
                  key={amount}
                  fluid
                  color="transparent"
                  className={classes([
                    'Fabricator__PrintAmount',
                    amount * 2000 > props.material.amount &&
                      'Fabricator__PrintAmount--disabled',
                  ])}
                  onClick={() => props.onEjectRequested(amount)}
                >
                  &times;{amount}
                </Button>
              ))}
            </Flex>
          </div>
        )}
      </Stack>
    </div>
  );
};
