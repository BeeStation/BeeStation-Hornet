import { useBackend } from '../backend';
import { classes } from 'common/react';
import { Button, Box, LabeledList, Section, Flex } from '../components';
import { Window } from '../layouts';

export const LanguageMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { admin_mode, is_living, omnitongue, language_static_data = [], known_languages = [], unknown_languages = [] } = data;
  return (
    <Window theme="generic" width={700} height={600}>
      <Window.Content scrollable>
        <Section title="Known Languages">
          <LabeledList>
            {known_languages.map((each_language) => {
              const languageData = language_static_data[each_language.name];
              return (
                <LabeledList.Item
                  key={languageData.name}
                  label={
                    <Flex>
                      <Flex.Item m={-0.5}>
                        <Box className={classes(['chat16x16', 'language-' + languageData.icon_state])} />
                      </Flex.Item>
                      <Flex.Item pl={1} align="center">
                        {languageData.name}
                      </Flex.Item>
                    </Flex>
                  }
                  buttons={
                    <>
                      {!!is_living && (
                        <Button
                          content={each_language.is_default ? 'Default Language' : 'Select as Default'}
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
                  }>
                  <Box>{languageData.desc}</Box>
                  <Box pl={2}>Chat key: ,{languageData.key}</Box>
                  <Box pl={2}>
                    {each_language.can_understand ? 'Can understand.' : 'Cannot understand.'}{' '}
                    {each_language.can_speak ? 'Can speak.' : 'Cannot speak.'}
                  </Box>
                </LabeledList.Item>
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
            }>
            <LabeledList>
              {unknown_languages.map((each_language) => {
                const languageData = language_static_data[each_language.name];
                return (
                  <LabeledList.Item
                    key={languageData.name}
                    label={
                      <Flex>
                        <Flex.Item m={-0.5}>
                          <Box className={classes(['chat16x16', 'language-' + languageData.icon_state])} />
                        </Flex.Item>
                        <Flex.Item pl={1} align="center">
                          {languageData.name}
                        </Flex.Item>
                      </Flex>
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
                    }>
                    <Box>{languageData.desc}</Box>
                    <Box pl={2}>
                      Chat key: ,{languageData.key} {!!each_language.shadow && '(gained from mob)'}
                    </Box>
                    <Box pl={2}>
                      {each_language.can_understand ? 'Can understand.' : 'Cannot understand.'}{' '}
                      {each_language.can_speak ? 'Can speak.' : 'Cannot speak.'}
                    </Box>
                  </LabeledList.Item>
                );
              })}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
