import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Box } from '../components';
import { Window } from '../layouts';

const traitTypes = [
  {
    label: "Green",
    type: "1",
  },
  {
    label: "Label",
    type: "2",
  },
  {
    label: "Red",
    type: "3",
  },
];

export const TraitPanel = () => {
  return (
    <Window
      resizable
      width={400}
      height={550}>
      <Window.Content scrollable>
        <TraitPanelContent />
      </Window.Content>
    </Window>
  );
};

const TraitPanelContent = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      {data.trait.map(trait => (
        <Box key={trait.name} color={trait.trait_type}>
          <Button
            content="Add"
            onClick={() => act('add')} />
        </Box>
      ))};
    </Fragment>
  );
};
