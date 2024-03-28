import { binaryInsertWith, sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import { Button, FitText, Icon, Input, LabeledList, Stack, Tooltip } from '../../components';
import { Name } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

type NameWithKey = {
  key: string;
  name: Name;
};

const binaryInsertName = binaryInsertWith<NameWithKey>(({ key }) => key);

const sortNameWithKeyEntries = sortBy<[string, NameWithKey[]]>(([key]) => key);

export const MultiNameInput = (
  props: {
    handleRandomizeName: (nameType: string) => void;
    handleUpdateName: (nameType: string, value: string) => void;
    names: Record<string, string>;
  },
  context
) => {
  const [currentlyEditingName, setCurrentlyEditingName] = useLocalState<string | null>(context, 'currentlyEditingName', null);

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const namesIntoGroups: Record<string, NameWithKey[]> = {};

        for (const [key, name] of Object.entries(data.names.types)) {
          namesIntoGroups[name.group] = binaryInsertName(namesIntoGroups[name.group] || [], {
            key,
            name,
          });
        }

        return (
          <LabeledList>
            {sortNameWithKeyEntries(Object.entries(namesIntoGroups)).map(([group, names], index, collection) => (
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
                        onClick={(event) => {
                          setCurrentlyEditingName(key);
                          event.cancelBubble = true;
                          event.stopPropagation();
                        }}>
                        <FitText maxFontSize={12} maxWidth={130}>
                          {props.names[key]}
                        </FitText>
                      </Button>
                    );
                  }

                  return (
                    <LabeledList.Item key={key} label={name.name_type} tooltip={name.tooltip}>
                      <Stack fill>
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
                        <Stack.Item grow>
                          {content}
                          {name.policy_tooltip && (
                            <Tooltip
                              content={
                                <span>
                                  {name.policy_tooltip}
                                  {name.policy_link ? <br /> : ''}
                                  {name.policy_link ? 'Click this alert icon to view the policy.' : ''}
                                </span>
                              }>
                              {name.policy_link ? (
                                <a href={name.policy_link} target="_blank" rel="noreferrer">
                                  <Icon size={1.3} pb={-1} ml={1} name="exclamation-triangle" color="yellow" />
                                </a>
                              ) : (
                                <Icon size={1.3} ml={1} name="exclamation-triangle" color="yellow" />
                              )}
                            </Tooltip>
                          )}
                        </Stack.Item>
                      </Stack>
                    </LabeledList.Item>
                  );
                })}
                {
                  group !== '1' && index !== collection.length - 1 && <LabeledList.Divider />
                  // showing a bar under alt human name looks ugly, but this hardcoding is easier to handle...
                  // Note: It's number type in DM side, but it becomes string because of assoc sorting
                }
              </>
            ))}
          </LabeledList>
        );
      }}
    />
  );
};
