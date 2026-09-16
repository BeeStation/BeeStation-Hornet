import { sortBy } from 'common/collections';
import { classes } from 'common/react';

import { useLocalState } from '../../backend';
import { AnimatedNumber, Button, Flex, Stack } from '../../components';
import { formatSiUnit } from '../../format';
import { MaterialIcon } from './MaterialIcon';
import { Material } from './Types';

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
export const MaterialAccessBar = (props: {
  availableMaterials: Material[];
  onEjectRequested: (material: Material, amount: number) => void;
}) => (
  <Flex wrap>
    {sortBy((material: Material) => rarity[material.name] ?? 99)(
      props.availableMaterials,
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
const MaterialCounter = (
  props: { material: Material; onEjectRequested: (amount: number) => void },
  context,
) => {
  const [hovering, setHovering] = useLocalState(
    `MaterialCounter__${props.material.name}`,
    false,
  );
  const canEject = props.material.removable && props.material.amount >= 2000;
  return (
    <div
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
      className={classes([
        'MaterialDock',
        hovering ? 'MaterialDock--active' : '',
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
              format={(value) => formatSiUnit(value, 0)}
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
                  disabled={amount * 2000 > props.material.amount}
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
