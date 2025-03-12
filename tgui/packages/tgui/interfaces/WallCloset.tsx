import { sortBy } from '../../common/collections';
import { useBackend } from '../backend';
import { Box, Flex, DmIcon, Icon } from '../components';
import { Window } from '../layouts';

type WallClosetData = {
  color: number;
  contents: StoredItems[];
}

type StoredItems = {
  icon: string;
  icon_state: string;
  name: string;
}

const Balls = [1, 2, 3, 4, 5, 6, 7, 8];

export const WallCloset = (props) => {
  const { data } = useBackend<WallClosetData>();
  const contents = data.contents;
  return (
    <Window theme="generic" width={380} height={500}>
      <Window.Content backgroundColor={data.color}>
        <Flex wrap width='360px'>
          {contents.map((item, key) => (
            <Cell key={key} id={key} icon={item.icon} icon_state={item.icon_state} name={item.name} />
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Cell = (props) => {
  const { act, data } = useBackend<WallClosetData>();
  return(
    <Flex.Item className="WallCloset_FlexItem" width='80px' height='80px'>
      <Box onClick={() => act('takeOut', { 'item': props.id })} position="relative" className="WallCloset_box">
        <Box>
          <DmIcon
            mb={-2}
            icon={props.icon}
            icon_state={props.icon_state}
            fallback={<Icon mr={1} name="spinner" spin />}
            height="100%"
            width="100%"
          />
        </Box>
        <Box className="WallCloset_ItemLabel">
          {props.name}
        </Box>
      </Box>
    </Flex.Item>
  );
};
