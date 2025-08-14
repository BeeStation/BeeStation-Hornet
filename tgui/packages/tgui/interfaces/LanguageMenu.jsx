import { classes } from 'common/react';

import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

export const LanguageMenu = (props) => {
  const { act, data } = useBackend();
  const {
    admin_mode,
    is_living,
    omnitongue,
    language_static_data = [],
    known_languages = [],
    unknown_languages = [],
  } = data;
  return (
    <Window theme="generic" width={700} height={600}>
      <Window.Content scrollable>
        <Section title="Known Languages">
          <LabeledList>
            {known_languages.map((each_language, index) => {
              const languageData = language_static_data[each_language.name];
              return (
                <>
                  <LabeledList.Item
                    key={languageData.name}
                    label={
                      <Stack vertical mb={-3.5} ml={1}>
                        <Stack.Item>
                          <Stack mb={-1}>
                            <Stack.Item mr={0.2}>
                              <Box
                                className={classes([
                                  'chat16x16',
                                  'language-' + languageData.icon_state,
                                ])}
                                style={{ verticalAlign: 'bottom' }}
                              />
                            </Stack.Item>
                            <Stack.Item>{languageData.name}</Stack.Item>
                          </Stack>
                        </Stack.Item>
                        <Stack.Item>
                          <Box pl={4}>Chat key: ,{languageData.key}</Box>
                        </Stack.Item>
                      </Stack>
                    }
                    buttons={
                      <>
                        {!!is_living && (
                          <Button
                            content={
                              each_language.is_default
                                ? 'Default Language'
                                : 'Select as Default'
                            }
                            disabled={!each_language.can_speak}
                            selected={each_language.is_default}
                            onClick={() =>
                              act('select_default', {
                                language_name: languageData.name,
                              })
                            }
                          />
                        )}
                        {!!admin_mode && (
                          <>
                            <Button
                              content="Grant"
                              onClick={() =>
                                act('grant_language', {
                                  language_name: languageData.name,
                                })
                              }
                            />
                            <Button
                              content="Remove"
                              onClick={() =>
                                act('remove_language', {
                                  language_name: languageData.name,
                                })
                              }
                            />
                          </>
                        )}
                      </>
                    }
                  >
                    <Box>{languageData.desc}</Box>
                    <Box>
                      {each_language.can_understand
                        ? 'Can understand.'
                        : 'Cannot understand.'}{' '}
                      {each_language.can_speak ? 'Can speak.' : 'Cannot speak.'}
                    </Box>
                  </LabeledList.Item>
                  {index !== known_languages.length - 1 && (
                    <LabeledList.Divider />
                  )}
                </>
              );
            })}
          </LabeledList>
        </Section>
        {!!admin_mode && (
          <Section
            title="Unknown Languages"
            buttons={
              <Button
                content={'Omnitongue ' + (omnitongue ? 'Enabled' : 'Disabled')}
                selected={omnitongue}
                onClick={() => act('toggle_omnitongue')}
              />
            }
          >
            <LabeledList>
              {unknown_languages.map((each_language, index) => {
                const languageData = language_static_data[each_language.name];
                return (
                  <>
                    <LabeledList.Item
                      key={languageData.name}
                      label={
                        <Stack vertical mb={-3.5} ml={1}>
                          <Stack.Item>
                            <Stack mb={-1}>
                              <Stack.Item mr={0.2}>
                                <Box
                                  className={classes([
                                    'chat16x16',
                                    'language-' + languageData.icon_state,
                                  ])}
                                />
                              </Stack.Item>
                              <Stack.Item>{languageData.name}</Stack.Item>
                            </Stack>
                          </Stack.Item>
                          <Stack.Item>
                            <Box pl={4}>Chat key: ,{languageData.key}</Box>
                          </Stack.Item>
                        </Stack>
                      }
                      buttons={
                        <Button
                          content="Grant"
                          onClick={() =>
                            act('grant_language', {
                              language_name: languageData.name,
                            })
                          }
                        />
                      }
                    >
                      <Box>{languageData.desc}</Box>
                      <Box>
                        {each_language.can_understand
                          ? 'Can understand.'
                          : 'Cannot understand.'}{' '}
                        {each_language.can_speak
                          ? 'Can speak.'
                          : 'Cannot speak.'}
                      </Box>
                    </LabeledList.Item>
                    {index !== unknown_languages.length - 1 && (
                      <LabeledList.Divider />
                    )}
                  </>
                );
              })}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
