import { useBackend } from '../backend';
import { Window } from '../layouts';
import { GenericUplink } from './Uplink';

export const MalfunctionModulePicker = (props) => {
  const { act, data } = useBackend();
  const { processingTime, categories } = data;

  const categoriesList = [];
  const items = [];
  for (let i = 0; i < categories.length; i++) {
    const category = categories[i];
    categoriesList.push(category.name);
    for (let itemIndex = 0; itemIndex < category.items.length; itemIndex++) {
      const item = category.items[itemIndex];
      items.push({
        id: item.name,
        name: item.name,
        category: category.name,
        cost: `${item.cost} PT`,
        desc: item.desc,
        disabled: processingTime < item.cost,
      });
    }
  }

  return (
    <Window width={620} height={525} theme="malfunction">
      <Window.Content scrollable>
        <GenericUplink
          categories={categoriesList}
          items={items}
          currencyAmount={`${processingTime} PT`}
          handleBuy={(item) => act('buy', { name: item.name })}
        />
      </Window.Content>
    </Window>
  );
};
