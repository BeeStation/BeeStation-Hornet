/* eslint-disable max-len */
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Tabs, ProgressBar, Section, Divider, LabeledControls, NumberInput } from '../components';
import { Window } from '../layouts';

export const AiDashboard = (props, context) => {
  const { act, data } = useBackend(context);


  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const [selectedCategory, setCategory] = useLocalState(context, 'selectedCategory', data.categories[0]);

  return (
    <Window
      width={650}
      height={600}
      resizable
      title="Dashboard">
      <Window.Content scrollable>
        <Section title={"Status"}>
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [50, 100],
                  average: [25, 50],
                  bad: [0, 25],
                }}
                value={(data.integrity + 100) * 0.5}
                maxValue={100}>{(data.integrity + 100) * 0.5}%
              </ProgressBar>
              System Integrity
            </LabeledControls.Item>
            <LabeledControls.Item >
              <Box bold color="average">
                {data.location_name}
                <Box>
                  ({data.location_coords})
                </Box>
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity],
                }}
                value={data.temperature}
                maxValue={750}>{data.temperature}K
              </ProgressBar>
              Core Temperature
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.current_cpu * 0.7, Infinity],
                  average: [data.current_cpu * 0.3, data.current_cpu * 0.7],
                  bad: [0, data.current_cpu * 0.3],
                }}
                value={data.used_cpu}
                maxValue={data.current_cpu}>
                {data.used_cpu ? data.used_cpu : 0}/{data.current_cpu} THz
              </ProgressBar>
              Utilized CPU Power
            </LabeledControls.Item>
            <LabeledControls.Item>
              <ProgressBar
                ranges={{
                  good: [data.current_ram * 0.7, Infinity],
                  average: [data.current_ram * 0.3, data.current_ram * 0.7],
                  bad: [0, data.current_ram * 0.3],
                }}
                value={data.used_ram}
                maxValue={data.current_ram}>
                {data.used_ram ? data.used_ram : 0}/{data.current_ram} TB
              </ProgressBar>
              Utilized RAM Capacity
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Divider />
        <Tabs>
          <Tabs.Tab
            selected={tab === 1}
            onClick={(() => setTab(1))}>
            Available Projects
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            onClick={(() => setTab(2))}>
            Completed Projects
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Section title="Available Projects">
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={selectedCategory === category}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.available_projects.filter(project => {
              return project.category === selectedCategory;
            }).map((project, index) => (
              <Section key={index} title={(<Box inline color={project.available ? "lightgreen" : "bad"}>{project.name} | {project.available ? "Available" : "Unavailable"}</Box>)} buttons={(
                <Fragment>
                  <Box inline bold>Assigned CPU:&nbsp;</Box>
                  <NumberInput value={project.assigned_cpu} minValue={0} maxValue={data.current_cpu} onChange={(e, value) => act('allocate_cpu', {
                    project_name: project.name,
                    amount: value,
                  })} />
                  <Box inline bold>&nbsp;THz</Box>
                </Fragment>
              )}>
                <Box bold>Research Cost: {project.research_cost} THz</Box>
                <Box bold>RAM Requirement: {project.ram_required} TB</Box>
                <Box bold>Research Requirements: &nbsp;{project.research_requirements}</Box>
                <Box mb={1}>
                  {project.description}
                </Box>
                <ProgressBar value={project.research_progress / project.research_cost} />
              </Section>
            ))}
          </Section>
        )}
        {tab === 2 && (
          <Section title="Completed Projects">
            <Tabs>
              {data.categories.map((category, index) => (
                <Tabs.Tab key={index}
                  selected={selectedCategory === category}
                  onClick={(() => setCategory(category))}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
            {data.completed_projects.filter(project => {
              return project.category === selectedCategory;
            }).map((project, index) => (
              <Section key={index} title={(<Box inline color={project.running ? "lightgreen" : "bad"}>{project.name} | {project.running ? "Running" : "Not Running"}</Box>)} buttons={(
                <Button icon={project.running ? "stop" : "play"} color={project.running ? "bad" : "good"} onClick={(e, value) => act(project.running ? "stop_project" : "run_project", {
                  project_name: project.name,
                })}>{project.running ? "Stop" : "Run"}
                </Button>
              )}>
                <Box bold>RAM Requirement: {project.ram_required} TB</Box>
                <Box mb={1}>
                  {project.description}
                </Box>
              </Section>
            ))}
          </Section>
        )}


      </Window.Content>
    </Window>
  );
};
