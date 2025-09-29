import { binaryInsertWith, sortBy } from 'common/collections';

import { useLocalState } from '../../backend';
import {
  Button,
  FitText,
  Icon,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
  TrackOutsideClicks,
} from '../../components';
import { Name } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

type NameWithKey = {
  key: string;
  name: Name;
};

const binaryInsertName = (collection: NameWithKey[], value: NameWithKey) =>
  binaryInsertWith(collection, value, ({ key }) => key);

const sortNameWithKeyEntries = (array: [string, NameWithKey[]][]) =>
  sortBy(array, ([key]) => key);

export const MultiNameInput = (props: {
  handleClose: () => void;
  handleRandomizeName: (nameType: string) => void;
  handleUpdateName: (nameType: string, value: string) => void;
  names: Record<string, string>;
}) => {
  const [currentlyEditingName, setCurrentlyEditingName] = useLocalState<
    string | null
  >('currentlyEditingName', null);

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const namesIntoGroups: Record<string, NameWithKey[]> = {};

        for (const [key, name] of Object.entries(data.names.types)) {
          namesIntoGroups[name.group] = binaryInsertName(
            namesIntoGroups[name.group] || [],
            {
              key,
              name,
            },
          );
        }

        return (
          <Modal
            style={{
              margin: '0 auto',
              width: '40%',
            }}
          >
            <TrackOutsideClicks
              onOutsideClick={props.handleClose}
              removeOnOutsideClick
            >
              <Section
                buttons={
                  <Button color="red" onClick={props.handleClose}>
                    Close
                  </Button>
                }
                title="All Names"
              >
                <LabeledList>
                  {sortNameWithKeyEntries(Object.entries(namesIntoGroups)).map(
                    ([_, names], index, collection) => (
                      <>
                        {names.map(({ key, name }) => {
                          let content;

                          if (currentlyEditingName === key) {
                            const updateName = (event, value) => {
                              props.handleUpdateName(key, value);

                              setCurrentlyEditingName(null);
                            };

                            content = (
                              <Input
                                autoSelect
                                onEnter={updateName}
                                onChange={updateName}
                                onEscape={() => {
                                  setCurrentlyEditingName(null);
                                }}
                                value={props.names[key]}
                              />
                            );
                          } else {
                            content = (
                              <Button
                                width="100%"
                                onClick={(event) => {
                                  setCurrentlyEditingName(key);
                                  event.cancelBubble = true;
                                  event.stopPropagation();
                                }}
                              >
                                <FitText maxFontSize={12} maxWidth={130}>
                                  {props.names[key]}
                                </FitText>
                              </Button>
                            );
                          }

                          return (
                            <LabeledList.Item
                              key={key}
                              label={name.explanation}
                            >
                              <Stack fill>
                                <Stack.Item grow>{content}</Stack.Item>

                                {!!name.can_randomize && (
                                  <Stack.Item>
                                    <Button
                                      icon="dice"
                                      tooltip="Randomize"
                                      tooltipPosition="right"
                                      onClick={() => {
                                        props.handleRandomizeName(key);
                                      }}
                                    />
                                  </Stack.Item>
                                )}
                              </Stack>
                            </LabeledList.Item>
                          );
                        })}

                        {index !== collection.length - 1 && (
                          <LabeledList.Divider />
                        )}
                      </>
                    ),
                  )}
                </LabeledList>
              </Section>
            </TrackOutsideClicks>
          </Modal>
        );
      }}
    />
  );
};

export const NameInput = (props: {
  handleUpdateName: (name: string) => void;
  name: string;
  openMultiNameInput: () => void;
}) => {
  const [lastNameBeforeEdit, setLastNameBeforeEdit] = useLocalState<
    string | null
  >('lastNameBeforeEdit', null);
  const editing = lastNameBeforeEdit === props.name;

  const updateName = (e, value) => {
    setLastNameBeforeEdit(null);
    props.handleUpdateName(value);
  };

  return (
    <Button
      captureKeys={!editing}
      onClick={() => {
        setLastNameBeforeEdit(props.name);
      }}
      width="100%"
      height="28px"
    >
      <Stack fill style={{ alignItems: 'center' }} align="center">
        <Stack.Item width="20px">
          <Icon
            style={{
              color: 'rgba(255, 255, 255, 0.5)',
              fontSize: '17px',
              marginTop: '5px',
              display: 'inline-block',
            }}
            name="edit"
          />
        </Stack.Item>

        <Stack.Item
          width="160px"
          position="relative"
          textAlign="center"
          style={{
            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
          }}
        >
          {(editing && (
            <Input
              autoSelect
              onEnter={updateName}
              onChange={updateName}
              fluid
              onEscape={() => {
                setLastNameBeforeEdit(null);
              }}
              value={props.name}
            />
          )) || (
            <FitText maxFontSize={16} maxWidth={130}>
              {props.name}
            </FitText>
          )}
        </Stack.Item>

        {/* We only know other names when the server tells us */}
        <ServerPreferencesFetcher
          render={(data) =>
            data ? (
              <Stack.Item>
                <Button
                  as="span"
                  tooltip="Alternate Names"
                  tooltipPosition="bottom"
                  style={{
                    background: 'rgba(0, 0, 0, 0.7)',
                    position: 'absolute',
                    right: '5px',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    width: '20px',
                  }}
                  onClick={(event) => {
                    props.openMultiNameInput();

                    // We're a button inside a button.
                    // Did you know that's against the W3C standard? :)
                    event.cancelBubble = true;
                    event.stopPropagation();
                  }}
                >
                  <Icon
                    name="bars"
                    style={{
                      position: 'relative',
                      left: '2px',
                      minWidth: '0px',
                    }}
                  />
                </Button>
              </Stack.Item>
            ) : null
          }
        />
      </Stack>
    </Button>
  );
};
