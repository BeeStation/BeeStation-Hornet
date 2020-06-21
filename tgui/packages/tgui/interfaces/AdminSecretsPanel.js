import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Input, Section, Table, Collapsible } from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

const pick = array => array[Math.floor(Math.random() * array.length)];
const possTitles = [
  "The first rule of adminbuse is: you don't talk about the adminbuse.",
  "Oh, this is gonna be fun.",
  "ADMIN, HE'S DOING IT SIDEWAYS!",
  "What flavor of admemes are we having today?",
  "Mass Purrbation. You know you want to.",
  "What does this button do?",
  "NOO YOU CANT JUST ABUSE YOUR POWERS LIKE THAT",
  "haha admin machine go bwoink",
  "RDM RDM RDM RDM",
  "admin man grief ban he",
  "NOOO ADMEMIN IS RUINING MY IMMERSION NOOOOOOOOOOOO",
];
const Title = pick(possTitles);

export const AdminSecretsPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { Categories } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const Search = createSearch(searchText, item => {
    return item;
  });

  const filterSearch = command => {
    return Search(command[0]);
  };

  const Header = (
    <Section
      title={
        <Table>
          <Table.Row>
            <Table.Cell>
              {Title}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
              <Input
                placeholder="Search"
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                mx={1}
              />
            </Table.Cell>
          </Table.Row>
        </Table>
      } />
  );

  const makebutton = command => {
    return (
      <FlexItem
        basis="50%">
        <Button
          onClick={() => act(command[1])}
          color={(command[2] || "")}>
          {command[0]}
        </Button>
      </FlexItem>
    );
  };

  const Items = (
    <Section>
      {Categories.flatMap(Category => (
        <Collapsible
          title={Category.name}
          bold
          key>
          <Flex
            wrap="wrap"
            textAlign="center"
            justify="space-between">
            {Category.commands
              .filter(filterSearch)
              .map(makebutton)}
          </Flex>
        </Collapsible>
      ))}
    </Section>
  );

  return (
    <Window
      theme="admin"
      resizable>
      <Window.Content scrollable>
        {Header}
        {Items}
        <Flex
          textAlign="center"
          justify="space-between">
          <FlexItem
            basis="100%">
            <Button onClick={() => act("open_old_panel")}>
              No I wanna go back to the old secrets panel
            </Button>
          </FlexItem>
        </Flex>
      </Window.Content>
    </Window>
  );

};
