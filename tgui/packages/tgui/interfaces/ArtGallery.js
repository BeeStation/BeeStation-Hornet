import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Button, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const ArtGallery = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [listIndex, setListIndex] = useLocalState(context, 'listIndex', 0);
  const {
    library,
    owned,
  } = data;
  const TABS = [
    {
      name: 'All Art',
      asset_prefix: "library",
      list: library,
    },
    {
      name: 'Your Art',
      asset_prefix: "library",
      list: owned,
    },
  ];
  const tab2list = TABS[tabIndex].list;
  const is_category_empty = tab2list[listIndex] !== 0;
  return (
    <Window
      title="Art Gallery"
      width={400}
      height={406}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fitted>
              <Tabs fluid textAlign="center">
                {TABS.map((tabObj, i) => !!tabObj.list && (
                  <Tabs.Tab
                    key={i}
                    selected={i === tabIndex}
                    onClick={() => {
                      setListIndex(0);
                      setTabIndex(i);
                    }}>
                    {tabObj.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          {!!is_category_empty && (
            <Stack.Item grow={2}>
              <Section fill>
                <Stack
                  height="100%"
                  align="center"
                  justify="center"
                  direction="column">
                  <Stack.Item>
                    <img
                      src={resolveAsset(TABS[tabIndex].asset_prefix + "_" + tab2list[listIndex]["md5"])}
                      height="128px"
                      width="128px"
                      style={{
                        'vertical-align': 'middle',
                        '-ms-interpolation-mode': 'nearest-neighbor',
                      }} />
                  </Stack.Item>
                  <Stack.Item className="Section__titleText">
                    {tab2list[listIndex]["title"]}
                  </Stack.Item>
                  <Stack.Item className="Section__titleText">
                    {"Artist: " + tab2list[listIndex]["ckey"]}
                  </Stack.Item>
                  <Stack.Item className="Section__titleText">
                    {"Owner: " + tab2list[listIndex]["owner"]}
                  </Stack.Item>
                  <Stack.Item className="Section__titleText">
                    {"Price: " + tab2list[listIndex]["price"]}
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>)}
          {!is_category_empty && (
            <Stack.Item grow={2}>
              <Section fill align="center">
                No art detected in this category
              </Section>
            </Stack.Item>)}
          <Stack.Item>
            <Stack>
              <Stack.Item grow={3}>
                <Section height="100%">
                  <Stack justify="space-between">
                    <Stack.Item grow={1}>
                      <Button
                        icon="angle-double-left"
                        disabled={listIndex === 0}
                        onClick={() => setListIndex(0)}
                      />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        disabled={listIndex === 0}
                        icon="chevron-left"
                        onClick={() => setListIndex(listIndex-1)}
                      />
                    </Stack.Item>
                    <Stack.Item grow={3}>
                      <Button
                        icon="check"
                        content={"Purchase"}
                        disabled={!is_category_empty || tabIndex === 1}
                        onClick={() => act("select", {
                          tab: tabIndex+1,
                          selected: listIndex+1,
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item grow={1}>
                      <Button
                        icon="chevron-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(listIndex+1)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="angle-double-right"
                        disabled={listIndex === tab2list.length-1}
                        onClick={() => setListIndex(tab2list.length-1)}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
            <Stack.Item mt={1} mb={-1}>
              <NoticeBox info>
                A quarter of the proceeds will go to the artist,
                a quarter to the current owner, and the rest to
                Nanotrasen taxes and fees.
              </NoticeBox>
            </Stack.Item>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
