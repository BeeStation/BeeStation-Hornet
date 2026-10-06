import { classes } from 'common/react';

import { Icon } from '../../components';

const MATERIAL_ICONS: Record<string, [number, string][]> = {
  iron: [
    [0, 'sheet-metal'],
    [17, 'sheet-metal_2'],
    [34, 'sheet-metal_3'],
  ],
  glass: [
    [0, 'sheet-glass'],
    [17, 'sheet-glass_2'],
    [34, 'sheet-glass_3'],
  ],
  copper: [
    [0, 'sheet-copper'],
    [17, 'sheet-copper_2'],
    [34, 'sheet-copper_3'],
  ],
  silver: [
    [0, 'sheet-silver'],
    [17, 'sheet-silver_2'],
    [34, 'sheet-silver_3'],
  ],
  gold: [
    [0, 'sheet-gold'],
    [17, 'sheet-gold_2'],
    [34, 'sheet-gold_3'],
  ],
  diamond: [[0, 'sheet-diamond']],
  plasma: [
    [0, 'sheet-plasma'],
    [17, 'sheet-plasma_2'],
    [34, 'sheet-plasma_3'],
  ],
  uranium: [[0, 'sheet-uranium']],
  bananium: [[0, 'sheet-bananium']],
  titanium: [
    [0, 'sheet-titanium'],
    [17, 'sheet-titanium_2'],
    [34, 'sheet-titanium_3'],
  ],
  'bluespace crystal': [[0, 'polycrystal']],
  plastic: [
    [0, 'sheet-plastic'],
    [17, 'sheet-plastic_2'],
    [34, 'sheet-plastic_3'],
  ],
  wood: [
    [0, 'sheet-wood'],
    [17, 'sheet-wood_2'],
    [34, 'sheet-wood_3'],
  ],
  // Wood and adamantine are not worth anything on their own and cant be normally used for building anything, however toolboxes are an exception to that
  adamantine: [
    [0, 'sheet-adamantine'],
    [17, 'sheet-adamantine_2'],
    [34, 'sheet-adamantine_3'],
  ],
};

export const MaterialIcon = (props: {
  materialName: string;
  amount?: number;
}) => {
  const icons = MATERIAL_ICONS[props.materialName];
  if (!icons) return <Icon name="question-circle" />;
  let active = 0;
  while (
    icons[active + 1] &&
    icons[active + 1][0] <= (props.amount ?? 200000) / 2000
  ) {
    active++;
  }
  return (
    <div className="FabricatorMaterialIcon">
      {icons.map(([_, state], index) => (
        <div
          key={state}
          className={classes([
            'FabricatorMaterialIcon__Icon',
            index === active && 'FabricatorMaterialIcon__Icon--active',
            'sheetmaterials32x32',
            state,
          ])}
        />
      ))}
    </div>
  );
};
