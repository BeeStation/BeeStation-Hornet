import { useBackend } from '../backend';
import { Box, Flex, DmIcon, Icon } from '../components';
import { Window } from '../layouts';

type ChessBoardData = {
  contents: StoredItems[];
};

type StoredItems = {
  icon: string;
  icon_state: string;
  name: string;
  show: boolean;
};

export const ChessBoard = () => {
  const { data } = useBackend<ChessBoardData>();
  const contents = data.contents;
  return (
    <Window theme="generic" width={612} height={644}>
      <Window.Content backgroundColor="#663931">
        <Box backgroundColor="#fefff2" width="600px" height="600px" position="fixed" />
        <Flex wrap width="600px">
          {contents.map((item, index) => (
            <Cell show={item.show} index={index} key={index} icon={item.icon} icon_state={item.icon_state} name={item.name} />
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Cell = (props) => {
  const { act } = useBackend<ChessBoardData>();
  return (
    <Flex.Item width="75px" height="75px">
      <Box height="100%" width="100%" position="relative">
        <Box
          className="ChessBoard_Box"
          backgroundColor={
            Math.trunc(props.index / 8) % 2 === 1
              ? props.index % 2
                ? '#fefff2'
                : '#2f3336'
              : props.index % 2
                ? '#2f3336'
                : '#fefff2'
          }>
          {props.show && (
            <Box className="ChessBoard_Icon">
              <DmIcon
                mb={-2}
                icon={props.icon}
                icon_state={props.icon_state}
                fallback={<Icon mr={1} name="spinner" spin fontSize="18px" />}
                height="170%"
                width="170%"
                backgroundColor="red"
                style={{
                  imageRendering: 'pixelated',
                  msInterpolationMode: 'nearest-neighbor',
                }}
              />
            </Box>
          )}
          <Box className="ChessBoard_Outline" />
          <Box className="ChessBoard_Slot" onClick={() => act('ItemClick', { 'SlotKey': props.index + 1 })}>
            <Box
              className="ChessBoard_Text"
              style={{
                bottom: Math.trunc(props.index / 8) === 0 ? 'auto' : '110%',
                top: Math.trunc(props.index / 8) === 0 ? '110%' : 'auto',
              }}>
              {props.name}
            </Box>
          </Box>
        </Box>
      </Box>
    </Flex.Item>
  );
};
