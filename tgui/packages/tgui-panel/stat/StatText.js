import { useSelector } from 'tgui/backend';
import { Button, Flex, Box } from 'tgui/components';
import { selectStatPanel } from './selectors';
import { Divider } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_BLANK } from './constants';
import { capitalize } from 'common/string';

export const StatText = (props) => {
  const stat = useSelector(selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData) {
    return <Box color="red">Passed stat panel data was null contant coderman (or coderwoman).</Box>;
  }
  let verbs = {};
  if (stat.verbData !== null) {
    verbs = stat.verbData[stat.selectedTab] || {};
  }
  return (
    <div className="StatBorder">
      <Flex direction="row" wrap>
        {statPanelData
          ? Object.keys(statPanelData)
            .filter((x) => x !== null)
            .sort((a, b) => {
              return StatTagToPriority(statPanelData[b].tag) - StatTagToPriority(statPanelData[a].tag);
            })
            .map(
              (key) =>
                !!statPanelData[key] &&
                ((statPanelData[key].type === STAT_TEXT && <StatTextText title={key} text={statPanelData[key].text} />) ||
                  (statPanelData[key].type === STAT_BUTTON && (
                    <StatTextButton
                      title={key}
                      text={statPanelData[key].text}
                      action_id={statPanelData[key].action}
                      params={statPanelData[key].params}
                      multirow={statPanelData[key].multirow}
                      buttons={statPanelData[key].buttons}
                    />
                  )) ||
                  (statPanelData[key].type === STAT_ATOM && (
                    <StatTextAtom
                      atom_ref={key}
                      atom_name={statPanelData[key].text}
                      atom_tag={statPanelData[key].tag}
                      atom_icon={statPanelData[key].image}
                    />
                  )) ||
                  (statPanelData[key].type === STAT_DIVIDER && <StatTextDivider />) ||
                  (statPanelData[key].type === STAT_BLANK && (
                    <Flex.Item width="100%">
                      <br />
                    </Flex.Item>
                  )))
            )
          : 'No data'}
        {Object.keys(verbs).map((verb) => (
          <StatTextVerb key={verb} title={verb} action_id={verbs[verb].action} params={verbs[verb].params} />
        ))}
      </Flex>
    </div>
  );
};

const StatTagToPriority = (text) => {
  switch (text) {
    case 'You':
      return 11;
    case 'Human':
      return 10;
    case 'Mob':
      return 9;
    case 'Structure':
      return 8;
    case 'Machinery':
      return 7;
    case 'Item':
      return 6;
    case 'Turf':
      return 4;
  }
  return 5;
};

const StatTagToClassName = (text) => {
  switch (text) {
    case 'You':
      return 'StatAtomTag Self';
    case 'Turf':
      return 'StatAtomTag Turf';
    case 'Human':
      return 'StatAtomTag Human';
    case 'Mob':
      return 'StatAtomTag Mob';
    case 'Structure':
      return 'StatAtomTag Structure';
    case 'Machinery':
      return 'StatAtomTag Machinery';
    case 'Item':
      return 'StatAtomTag Item';
  }
  return 'StatAtomTag Other';
};

/*
 * FLEX COMPATIBLE
 */

export const StatTextText = (props) => {
  const { title, text } = props;
  return (
    <Flex.Item mt={1} width="100%">
      <b>{title}: </b>
      {text}
    </Flex.Item>
  );
};

export const StatTextButton = (props) => {
  const { title, text, action_id, params = [], multirow = false, buttons = [] } = props;
  return (
    <Flex.Item mt={1} width="100%">
      <Button
        width="100%"
        overflowX="hidden"
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent">
        {!multirow ? (
          <Flex direction="row">
            <Flex.Item bold>{title}</Flex.Item>
            {buttons.map((buttonInfo) => (
              <Flex.Item shrink={1} key={buttonInfo}>
                <Button
                  color={buttonInfo['color']}
                  onClick={(e) => {
                    e.stopPropagation();
                    Byond.sendMessage('stat/pressed', {
                      action_id: buttonInfo['action_id'],
                      params: buttonInfo['params'],
                    });
                  }}>
                  {buttonInfo['title']}
                </Button>
              </Flex.Item>
            ))}
            <Flex.Item
              grow={1}
              ml={1.5}
              style={{
                whiteSpace: 'normal',
              }}>
              {text}
            </Flex.Item>
          </Flex>
        ) : (
          <>
            <Flex bold direction="row">
              <Flex.Item grow={1}>{title}</Flex.Item>
              {buttons.map((buttonInfo) => (
                <Flex.Item shrink={1} key={buttonInfo}>
                  <Button
                    color={buttonInfo['color']}
                    onClick={(e) => {
                      e.stopPropagation();
                      Byond.sendMessage('stat/pressed', {
                        action_id: buttonInfo['action_id'],
                        params: buttonInfo['params'],
                      });
                    }}>
                    {buttonInfo['title']}
                  </Button>
                </Flex.Item>
              ))}
            </Flex>
            <Box
              style={{
                whiteSpace: 'normal',
              }}>
              {text}
            </Box>
          </>
        )}
      </Button>
    </Flex.Item>
  );
};

let janky_storage = null; // Because IE sucks
const storeAtomRef = (value) => {
  janky_storage = value;
};
const retrieveAtomRef = () => janky_storage;

export const StatTextAtom = (props) => {
  const { atom_name, atom_ref, atom_tag, atom_icon } = props;

  storeAtomRef(null);

  return (
    <Flex.Item mt={0.5} width={'33%'}>
      <Button
        height="100%"
        pl={0}
        width="100%"
        overflowX="hidden"
        draggable
        onDragStart={(e) => {
          // e.dataTransfer.setData("text", atom_ref);
          /*
          Apparently can't use "text/plain" because IE, this took me way too
          long to figure out.

          Apparently, even if you do "text", IE will also put the stored data
          into your clipboard, overriding whatever was there. Fuck this.
          Leaving it here for reference, in case somebody smarter than me
          knows a way to fix it
          */
          storeAtomRef(atom_ref);
        }}
        onDragOver={(e) => {
          e.preventDefault();
        }}
        onDrop={(e) => {
          // let other_atom_ref = e.dataTransfer.getData("text");
          let other_atom_ref = retrieveAtomRef();
          if (other_atom_ref) {
            e.preventDefault();
            storeAtomRef(null);
            Byond.sendMessage('stat/pressed', {
              action_id: 'atomDrop',
              params: {
                ref: atom_ref,
                ref_other: other_atom_ref,
              },
            });
          }
        }}
        onDragEnd={(e) => {
          storeAtomRef(null);
        }}
        onClick={(e) =>
          Byond.sendMessage('stat/pressed', {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          })
        }
        color="transparent">
        <div className="StatAtomElement">
          <Flex direction="row" wrap="wrap">
            {
              <Flex.Item mr={1}>
                <img width="32px" height="32px" src={atom_icon} />
              </Flex.Item>
            }
            <Flex.Item grow={1} className="StatWordWrap">
              {capitalize(atom_name)}
            </Flex.Item>
          </Flex>
        </div>
      </Button>
    </Flex.Item>
  );
};

export const StatTextDivider = (props) => {
  return (
    <Flex.Item width="100%">
      <Divider />
    </Flex.Item>
  );
};

export const StatTextVerb = (props) => {
  const { title, action_id, params = [] } = props;
  return (
    <Box shrink={1} inline width="200px">
      <Button
        content={title}
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent"
        fluid
      />
    </Box>
  );
};
