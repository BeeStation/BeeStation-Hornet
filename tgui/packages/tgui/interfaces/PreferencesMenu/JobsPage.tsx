import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import type { Inferno, InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Dropdown, Stack, Flex, Tooltip } from '../../components';
import { createSetPreference, Job, JoblessRole, JobPriority, PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const sortJobs = (entries: [string, Job][], head?: string) =>
  sortBy<[string, Job]>(
    ([key, _]) => (key === head ? -1 : 1),
    ([key, _]) => key
  )(entries);

const PriorityButton = (props: { name: string; modifier?: string; enabled: boolean; onClick: () => void }) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Flex.Item grow height="100%">
      <Button
        height="100%"
        verticalAlignContent="middle"
        className={classes([
          className,
          !props.enabled && `${className}--disabled`,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        fluid
        content={props.name}
        onClick={props.onClick}
        textAlign="center"
      />
    </Flex.Item>
  );
};

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName = (context, jobName: string): CreateSetPriority => {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  const createSetPriority = (priority: JobPriority | null) => {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    const setPriority = () => {
      const { act } = useBackend<PreferencesMenuData>(context);

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    };

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  };

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
};

const PriorityButtons = (props: { createSetPriority: CreateSetPriority; isOverflow: boolean; priority: JobPriority }) => {
  const { createSetPriority, isOverflow, priority } = props;

  return (
    <Flex
      style={{
        'align-items': 'center',
        'justify-content': 'flex-end',
        'height': '100%',
        'border': '1px solid rgba(0, 0, 0, 0.4)',
      }}>
      {isOverflow ? (
        <>
          <PriorityButton name="Off" modifier="off" enabled={!priority} onClick={createSetPriority(null)} />

          <PriorityButton name="On" modifier="high" enabled={!!priority} onClick={createSetPriority(JobPriority.High)} />
        </>
      ) : (
        <>
          <PriorityButton name="Off" modifier="off" enabled={!priority} onClick={createSetPriority(null)} />

          <PriorityButton
            name="Low"
            modifier="low"
            enabled={priority === JobPriority.Low}
            onClick={createSetPriority(JobPriority.Low)}
          />

          <PriorityButton
            name="Med"
            modifier="medium"
            enabled={priority === JobPriority.Medium}
            onClick={createSetPriority(JobPriority.Medium)}
          />

          <PriorityButton
            name="High"
            modifier="high"
            enabled={priority === JobPriority.High}
            onClick={createSetPriority(JobPriority.High)}
          />
        </>
      )}
    </Flex>
  );
};

const JobRow = (
  props: {
    className?: string;
    job: Job;
    name: string;
  },
  context
) => {
  const { data } = useBackend<PreferencesMenuData>(context);
  const { className, job, name } = props;

  const isOverflow = data.overflow_role === name;
  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(context, name);

  const experienceNeeded = data.job_required_experience && data.job_required_experience[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;

  let rightSide: InfernoNode;

  if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{hoursNeeded}h</b> as {experience_type}
        </Stack.Item>
      </Stack>
    );
  } else if (daysLeft > 0) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
        </Stack.Item>
      </Stack>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          <b>Banned</b>
        </Stack.Item>
      </Stack>
    );
  } else {
    rightSide = <PriorityButtons createSetPriority={createSetPriority} isOverflow={isOverflow} priority={priority} />;
  }

  return (
    <Stack.Item
      className={className}
      height="100%"
      style={{
        'margin-top': 0,
      }}>
      <Stack fill align="center">
        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              'padding-left': '0.3em',
            }}>
            {name}
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options">
          {rightSide}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const Department: Inferno.SFC<{ department: string }> = (props) => {
  const { children, department: name } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return null;
        }

        const { departments, jobs } = data.jobs;
        const department = departments[name];

        // This isn't necessarily a bug, it's like this
        // so that you can remove entire departments without
        // having to edit the UI.
        // This is used in events, for instance.
        if (!department) {
          return null;
        }

        const jobsForDepartment = sortJobs(
          Object.entries(jobs).filter(([_, job]) => job.department === name),
          department.head
        );

        return (
          <Box>
            <Stack vertical fill>
              {jobsForDepartment.map(([name, job]) => {
                return (
                  <JobRow
                    className={classes([className, name === department.head && 'head'])}
                    key={name}
                    job={job}
                    name={name}
                  />
                );
              })}
            </Stack>

            {children}
          </Box>
        );
      }}
    />
  );
};

// *Please* find a better way to do this, this is RIDICULOUS.
// All I want is for a gap to pretend to be an empty space.
// But in order for everything to align, I also need to add the 0.2em padding.
// But also, we can't be aligned with names that break into multiple lines!
const Gap = (props: { amount: number }) => {
  // 0.2em comes from the padding-bottom in the department listing
  return <Box height={`calc(${props.amount}px + 0.2em)`} />;
};

const JoblessRoleDropdown = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role} if unavailable`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: `Join as a random job if unavailable`,
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: `Return to lobby if unavailable`,
      value: JoblessRole.ReturnToLobby,
    },
  ];

  return (
    <Box width="30%" style={{ 'margin': '5px auto' }}>
      <Dropdown
        width="100%"
        selected={selected}
        onSelected={createSetPreference(act, 'joblessrole')}
        options={options}
        displayText={<Box pr={1}>{options.find((option) => option.value === selected)!.displayText}</Box>}
      />
    </Box>
  );
};

const ClearJobsButton = (_, context) => {
  const { act } = useBackend<PreferencesMenuData>(context);
  return <Button content="Clear All" confirm onClick={() => act('clear_job_preferences')} />;
};

export const JobsPage = () => {
  return (
    <>
      <Box textAlign="center" className="section-background" p={0.5} pb={1} mb={1}>
        <JoblessRoleDropdown />
        <ClearJobsButton />
      </Box>

      <Stack vertical fill className="section-background" p={1}>
        <Stack.Item>
          <Stack fill className="PreferencesMenu__Jobs">
            <Stack.Item mr={1}>
              <Department department="Assistant">
                <Gap amount={6} />
              </Department>

              <Department department="Engineering">
                <Gap amount={6} />
              </Department>

              <Department department="Medical" />
            </Stack.Item>

            <Stack.Item mr={1}>
              <Department department="Captain">
                <Gap amount={6} />
              </Department>

              <Department department="Civilian">
                <Gap amount={6} />
              </Department>

              <Department department="Service">
                <Gap amount={6} />
              </Department>

              <Department department="Cargo" />
            </Stack.Item>

            <Stack.Item>
              <Department department="Science">
                <Gap amount={6} />
              </Department>

              <Department department="Security">
                <Gap amount={6} />
              </Department>

              <Department department="Silicon" />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
};
