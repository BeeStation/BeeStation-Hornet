import { useState } from 'react';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { NaniteProgram } from './common/NaniteTypes';

type Data = {
  detail_view: BooleanLike;
  disk: NaniteProgram;
  has_disk: BooleanLike;
  has_program: BooleanLike;
  programs: NaniteProgram[];
};

export function NaniteProgramHub(props) {
  const { act, data } = useBackend<Data>();
  const { detail_view, disk, has_disk, has_program, programs = [] } = data;

  const [selectedCategory, setSelectedCategory] = useState('Utility Nanites');
  const programsInCategory = (programs && programs[selectedCategory]) || [];

  return (
    <Window width={500} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Section
            title="Program Disk"
            buttons={
              <>
                <Button icon="eject" onClick={() => act('eject')}>
                  Eject
                </Button>
                <Button icon="minus-circle" onClick={() => act('clear')}>
                  Delete Program
                </Button>
              </>
            }
          >
            {has_disk ? (
              has_program ? (
                <LabeledList>
                  <LabeledList.Item label="Program Name">
                    {disk.name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Description">
                    {disk.desc}
                  </LabeledList.Item>
                </LabeledList>
              ) : (
                <NoticeBox>No Program Installed</NoticeBox>
              )
            ) : (
              <NoticeBox>No Disk Inserted</NoticeBox>
            )}
          </Section>
          <Stack.Item grow>
            <Section
              title="Programs"
              fill
              buttons={
                <>
                  <Button
                    icon={detail_view ? 'info' : 'list'}
                    onClick={() => act('toggle_details')}
                  >
                    {detail_view ? 'Detailed' : 'Compact'}
                  </Button>
                  <Button icon="sync" onClick={() => act('refresh')}>
                    Sync Research
                  </Button>
                </>
              }
            >
              {programs.length === 0 ? (
                <NoticeBox>
                  No nanite programs are currently researched.
                </NoticeBox>
              ) : (
                <Stack fill>
                  <Stack.Item>
                    <Tabs vertical>
                      {Object.entries(programs).map(
                        ([category, cat_contents]) => {
                          // Backend was sending stupid data that would have been
                          // annoying to fix
                          const tabLabel = category.substring(
                            0,
                            category.length - 8,
                          );
                          return (
                            <Tabs.Tab
                              key={category}
                              selected={category === selectedCategory}
                              onClick={() => setSelectedCategory(category)}
                            >
                              {tabLabel}
                            </Tabs.Tab>
                          );
                        },
                      )}
                    </Tabs>
                  </Stack.Item>
                  <Stack.Item p={2} grow>
                    <Section scrollable fill>
                      {detail_view ? (
                        programsInCategory.map((program) => (
                          <Section
                            key={program.id}
                            title={program.name}
                            buttons={
                              <Button
                                icon="download"
                                disabled={!has_disk}
                                onClick={() =>
                                  act('download', {
                                    program_id: program.id,
                                  })
                                }
                              >
                                Download
                              </Button>
                            }
                          >
                            {program.desc}
                          </Section>
                        ))
                      ) : (
                        <LabeledList>
                          {programsInCategory.map((program) => (
                            <LabeledList.Item
                              key={program.id}
                              label={program.name}
                              buttons={
                                <Button
                                  icon="download"
                                  disabled={!has_disk}
                                  onClick={() =>
                                    act('download', {
                                      program_id: program.id,
                                    })
                                  }
                                >
                                  Download
                                </Button>
                              }
                            />
                          ))}
                        </LabeledList>
                      )}
                    </Section>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
