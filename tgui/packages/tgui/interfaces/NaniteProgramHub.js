import { map } from "common/collections";
import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../backend";
import {
  Box,
  Flex,
  Icon,
  Tabs,
  Button,
  Section,
  NoticeBox,
  LabeledList,
} from "../components";
import { Window } from "../layouts";

export const NaniteProgramHub = (props, context) => {
  const { act, data } = useBackend(context);
  const { detail_view, disk, has_disk, has_program, programs = {} } = data;
  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    "category"
  );
  const programsInCategory = (programs && programs[selectedCategory]) || [];
  return (
    <Window resizable width={650} height={700}>
      <Window.Content>
        <Section
          title="Program Disk"
          height="20%"
          overflowY="scroll"
          buttons={
            <Fragment>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act("eject")}
              />
              <Button
                icon="minus-circle"
                content="Delete Program"
                onClick={() => act("clear")}
              />
            </Fragment>
          }>
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
            <NoticeBox>Insert Disk</NoticeBox>
          )}
        </Section>
        <Section
          title="Programs"
          buttons={
            <Fragment>
              <Button
                icon={detail_view ? "info" : "list"}
                content={detail_view ? "Detailed" : "Compact"}
                onClick={() => act("toggle_details")}
              />
              <Button
                icon="sync"
                content="Sync Research"
                onClick={() => act("refresh")}
              />
            </Fragment>
          }>
          {programs !== null ? (
            <Flex height={39}>
              <Flex.Item minWidth="150px">
                <Tabs vertical>
                  {map((cat_contents, category) => {
                    const progs = cat_contents || [];
                    // Backend was sending stupid data that would have been
                    // annoying to fix
                    const tabLabel = category.substring(0, category.length - 8);
                    return (
                      <Button
                        key={category}
                        color="grey"
                        selected={category === selectedCategory}
                        onClick={() => setSelectedCategory(category)}
                        mb={2}
                        width="80%"
                        height={2}>
                        <Flex direction="row" justify="space-between">
                          <Icon
                            mt={1}
                            color={
                              category === selectedCategory ? "lime" : "white"
                            }
                            name="microchip"
                          />
                          {tabLabel}
                        </Flex>
                      </Button>
                    );
                  })(programs)}
                </Tabs>
              </Flex.Item>
              <Flex.Item grow width="100%" overflowY="scroll">
                {detail_view ? (
                  programsInCategory.map(program => (
                    <Section
                      key={program.id}
                      title={program.name}
                      level={2}
                      width="100%"
                      buttons={
                        <Button
                          height={2}
                          disabled={!has_disk}
                          onClick={() =>
                            act("download", {
                              program_id: program.id,
                            })}>
                          <Icon ml={1} mr={2} name="download" />
                          Download
                        </Button>
                      }>
                      {program.desc}
                    </Section>
                  ))
                ) : (
                  <LabeledList>
                    {programsInCategory.map(program => (
                      <LabeledList.Item
                        key={program.id}
                        label={program.name}
                        buttons={
                          <Button
                            mt={1}
                            mr={2}
                            height={2}
                            disabled={!has_disk}
                            onClick={() =>
                              act("download", {
                                program_id: program.id,
                              })}>
                            <Icon mr={2} name="download" />
                            Download
                          </Button>
                        }
                      />
                    ))}
                  </LabeledList>
                )}
              </Flex.Item>
            </Flex>
          ) : (
            <NoticeBox>No nanite programs are currently researched.</NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
