import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, Image, Input, NoticeBox, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPortraitPrinter = (props) => {
  const { act, data } = useBackend();
  const [listIndex, setListIndex] = useLocalState('listIndex', 0);
  const { paintings, search_string, search_mode } = data;
  const got_paintings = !!paintings.length;
  const current_portrait_title = got_paintings && paintings[listIndex]['title'];
  const current_portrait_author = got_paintings && 'By ' + paintings[listIndex]['creator'];
  const current_portrait_asset_name = got_paintings && 'paintings' + '_' + paintings[listIndex]['md5'];
  return (
    <NtosWindow title="Art Galaxy" width={400} height={446}>
      <NtosWindow.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Search">
              <Input
                fluid
                placeholder="Search Paintings..."
                value={search_string}
                onChange={(e, value) => {
                  act('search', {
                    to_search: value,
                  });
                  setListIndex(0);
                }}
              />
              <Button
                content={search_mode}
                onClick={() => {
                  act('change_search_mode');
                  if (search_string) {
                    setListIndex(0);
                  }
                }}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow={2}>
            <Section fill>
              <Stack height="100%" align="center" justify="center" direction="column">
                {got_paintings ? (
                  <>
                    <Stack.Item>
                      <img
                        src={resolveAsset(current_portrait_asset_name)}
                        height="128px"
                        width="128px"
                        style={{
                          'vertical-align': 'middle',
                          '-ms-interpolation-mode': 'nearest-neighbor',
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item className="Section__titleText">{current_portrait_title}</Stack.Item>
                    <Stack.Item>{current_portrait_author}</Stack.Item>
                  </>
                ) : (
                  <Stack.Item className="Section__titleText">No paintings found.</Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item grow={3}>
                <Section height="100%">
                  <Stack justify="space-between">
                    <Stack.Item grow={1}>
                      <Button icon="angle-double-left" disabled={listIndex === 0} onClick={() => setListIndex(0)} />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button disabled={listIndex === 0} icon="chevron-left" onClick={() => setListIndex(listIndex - 1)} />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        icon="check"
                        content="Print Portrait"
                        onClick={() =>
                          act('select', {
                            selected: paintings[listIndex]['ref'],
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(listIndex + 1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex >= paintings.length - 1}
                        onClick={() => setListIndex(paintings.length - 1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1} mb={-1}>
              <NoticeBox info>Printing a canvas costs 10 paper from the printer installed in your machine.</NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
