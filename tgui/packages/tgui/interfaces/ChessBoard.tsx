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
    <Window theme="generic" width={492} height={524}>
      <Window.Content backgroundColor="#663931">
        <Box width="480px" height="480px" position="fixed">
          <Flex direction="column" height="100%" width="100%">
            <Box className="ChessBoard_Background" height="100%" width="100%" backgroundColor="#fefff2" />
          </Flex>
        </Box>
        <Flex wrap width="480px">
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
    <Flex.Item className="ChessBoard_FlexItem" width="60px" height="60px">
      <Box className="ChessBoard_Box" position="relative">
        <Box className="ChessBoard_Box">
          <Box className="ChessBoard_outline" />
          {props.show && (
            <Box className="ChessBoard_Icon">
              <DmIcon
                mb={-2}
                icon={props.icon}
                icon_state={props.icon_state}
                fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
                height="100%"
                width="100%"
                backgroundColor="red"
                style={{
                  imageRendering: 'pixelated',
                  msInterpolationMode: 'nearest-neighbor',
                }}
              />
            </Box>
          )}
          <Box className="ChessBoard_Slot" onClick={() => act('ItemClick', { 'SlotKey': props.index + 1 })}>
            {props.name}
          </Box>
        </Box>
      </Box>
    </Flex.Item>
  );
};
