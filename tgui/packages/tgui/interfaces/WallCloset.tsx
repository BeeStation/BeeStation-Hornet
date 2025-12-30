import { CSSProperties } from 'react';
import { DmIcon } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Box, Flex, Icon } from '../components';
import { Window } from '../layouts';

type WallClosetData = {
  color: number;
  contents: StoredItems[];
};

type StoredItems = {
  icon: string;
  icon_state: string;
  image: string;
  name: string;
  show: boolean;
};

export const WallCloset = () => {
  const { data } = useBackend<WallClosetData>();
  const contents = data.contents;
  return (
    <Window theme="generic" width={372} height={504}>
      <Window.Content backgroundColor={data.color}>
        <Box width="360px" height="460px" position="fixed">
          <Flex direction="column" height="100%" width="100%">
            <Flex.Item grow>
              <Box className="WallCloset_Background" />
              <Box className="WallCloset_BackgroundShelf" />
            </Flex.Item>
            <Flex.Item grow>
              <Box className="WallCloset_Background" />
              <Box className="WallCloset_BackgroundShelf" />
            </Flex.Item>
            <Flex.Item grow>
              <Box className="WallCloset_Background" />
              <Box className="WallCloset_BackgroundShelf" />
            </Flex.Item>
            <Flex.Item grow>
              <Box className="WallCloset_Background" />
              <Box className="WallCloset_BackgroundShelf" />
            </Flex.Item>
            <Flex.Item grow>
              <Box className="WallCloset_Background" />
              <Box className="WallCloset_BackgroundShelf" />
            </Flex.Item>
          </Flex>
        </Box>
        <Flex wrap width="360px">
          {contents.map((item, index) => (
            <Cell
              show={item.show}
              index={index}
              key={index}
              icon={item.icon}
              icon_state={item.icon_state}
              name={item.name}
              image={item.image}
            />
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Cell = (props) => {
  const { act } = useBackend<WallClosetData>();
  return (
    <Flex.Item className="WallCloset_FlexItem" width="80px" height="80px">
      <Box className="WallCloset_Box" position="relative">
        <Box className="WallCloset_Box">
          {props.show && (
            <Box className="WallCloset_Box">
              {!props.image ? (
                <DmIcon
                  mb={-2}
                  icon={props.icon}
                  icon_state={props.icon_state}
                  fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
                  height="100%"
                  width="100%"
                  backgroundColor="red"
                  style={
                    {
                      imageRendering: 'pixelated',
                    } as CSSProperties
                  }
                />
              ) : (
                <Box
                  as="img"
                  src={props.image}
                  width="100%"
                  height="100%"
                  style={{
                    textAlign: 'center',
                    verticalAlign: 'middle',
                    imageRendering: 'pixelated',
                    msInterpolationMode: 'nearest-neighbor',
                  }}
                />
              )}
            </Box>
          )}
          <Box
            className="WallCloset_Slot"
            onClick={() => act('ItemClick', { SlotKey: props.index + 1 })}
          >
            {props.name}
          </Box>
        </Box>
      </Box>
    </Flex.Item>
  );
};
