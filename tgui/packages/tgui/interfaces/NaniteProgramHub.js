import { map } from "common/collections";
import { Fragment } from "inferno";
import { useBackend, useSharedState } from "../backend";
import {
  Box,
  Flex,
  Tabs,
  Button,
  Section,
  NoticeBox,
  LabeledList,
} from "../components";
import { Window } from "../layouts";

export const NaniteProgramHub = (props, context) => {
  const { data } = useBackend(context);
  const { programs = {} } = data;

  return (
    <Window resizable width={650} height={700}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item>
            <DiskDisplay />
          </Flex.Item>
          <Flex.Item grow>
            <Section
              mt={1}
              height="100%"
              title="Programs"
              buttons={<MenuActions />}>
              {programs !== null ? (
                <Flex direction="row">
                  <Flex.Item mr={1} width="150px">
                    <ProgramLabels />
                  </Flex.Item>
                  <Flex.Item grow basis={0} overflowY="scroll">
                    <ProgramList />
                  </Flex.Item>
                </Flex>
              ) : (
                <NoticeBox>
                  No nanite programs are currently researched.
                </NoticeBox>
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const DiskDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { disk, has_disk, has_program } = data;

  return (
    <Section
      title="Program Disk"
      overflowY="scroll"
      buttons={
        <Fragment>
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_disk}
            onClick={() => act("eject")}
          />
          <Button
            icon="minus-circle"
            content="Delete Program"
            disabled={!has_disk || disk.name === undefined || !has_program}
            onClick={() => act("clear")}
          />
        </Fragment>
      }>
      {has_disk ? (
        has_program ? (
          disk.name === undefined ? ( // This is dirty but it's not updating
            <NoticeBox>No Program Installed</NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Program Name">
                {disk.name}
              </LabeledList.Item>
              <LabeledList.Item label="Description">
                {disk.desc}
              </LabeledList.Item>
            </LabeledList>
          )
        ) : (
          <NoticeBox>No Program Installed</NoticeBox>
        )
      ) : (
        <NoticeBox>Insert Disk</NoticeBox>
      )}
    </Section>
  );
};

const MenuActions = (props, context) => {
  const { act, data } = useBackend(context);
  const { detail_view } = data;

  return (
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
  );
};

const ProgramLabels = (props, context) => {
  const { data } = useBackend(context);
  const { programs = {} } = data;
  const [selectedCategory, setSelectedCategory] = useSharedState(
    context,
    "category"
  );

  return (
    <Tabs vertical>
      {map((cat_contents, category) => {
        const progs = cat_contents || [];
        // Backend was sending stupid data that would have been
        // annoying to fix
        const tabLabel = category.substring(0, category.length - 8);
        return (
          <Button
            grow
            mb={1}
            color="grey"
            key={category}
            icon="microchip"
            content={tabLabel}
            selected={category === selectedCategory}
            onClick={() => setSelectedCategory(category)}
          />
        );
      })(programs)}
    </Tabs>
  );
};

const ProgramList = (props, context) => {
  const { act, data } = useBackend(context);
  const { detail_view, has_disk, programs = {} } = data;
  const [selectedCategory] = useSharedState(context, "category");
  const programsInCategory = (programs && programs[selectedCategory]) || [];

  return detail_view ? (
    programsInCategory.map(program => (
      <Section
        level={2}
        height="100%"
        key={program.id}
        title={program.name}
        buttons={
          <Button
            mr={1}
            height={2}
            icon="download"
            content="Download"
            disabled={!has_disk}
            onClick={() =>
              act("download", {
                program_id: program.id,
              })}
          />
        }>
        {program.desc}
      </Section>
    ))
  ) : (
    <LabeledList>
      {programsInCategory.map(program => (
        <Box key={program.id}>
          <LabeledList.Item
            label={program.name}
            buttons={
              <Button
                mt={1}
                mr={1}
                icon="download"
                content="Download"
                disabled={!has_disk}
                onClick={() =>
                  act("download", {
                    program_id: program.id,
                  })}
              />
            }
          />
          <LabeledList.Divider />
        </Box>
      ))}
    </LabeledList>
  );
};
