import { classes } from 'common/react';
import { sortBy } from 'es-toolkit';
import { PropsWithChildren, ReactNode } from 'react';
import { DmIcon, Dropdown } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Box, Button, Flex, Stack, Tabs, Tooltip } from '../../components';
import { sanitizeText } from '../../sanitize';
import {
  createSetPreference,
  Employer,
  Job,
  JoblessRole,
  JobPriority,
  PreferencesMenuData,
  ServerData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

// Returns an `rgba(...)` string for the given hex colour at the requested
// alpha. Accepts #RGB, #RGBA, #RRGGBB, or #RRGGBBAA. Returns the input
// unchanged if it can't be parsed, so a bad colour never breaks rendering.
const withAlpha = (hex: string, alpha: number): string => {
  const match = hex.trim().match(/^#([0-9a-f]{3,8})$/i);
  if (!match) return hex;

  // Expand shorthand (#RGB -> #RRGGBB, #RGBA -> #RRGGBBAA) by doubling each char.
  let digits = match[1];
  if (digits.length === 3 || digits.length === 4) {
    digits = digits
      .split('')
      .map((c) => c + c)
      .join('');
  }
  if (digits.length !== 6 && digits.length !== 8) return hex;

  const r = parseInt(digits.slice(0, 2), 16);
  const g = parseInt(digits.slice(2, 4), 16);
  const b = parseInt(digits.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

const sortJobs = (entries: [string, Job][], head?: string) =>
  sortBy(entries, [([key, _]) => (key === head ? -1 : 1), ([key, _]) => key]);

const PriorityButton = (props: {
  name: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
}) => {
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

const createCreateSetPriorityFromName = (
  jobName: string,
): CreateSetPriority => {
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
      const { act } = useBackend<PreferencesMenuData>();

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

const PriorityButtons = (props: {
  createSetPriority: CreateSetPriority;
  priority: JobPriority;
}) => {
  const { createSetPriority, priority } = props;

  return (
    <Flex
      style={{
        alignItems: 'center',
        justifyContent: 'flex-end',
        height: '100%',
        border: '1px solid rgba(0, 0, 0, 0.4)',
      }}
    >
      <>
        <PriorityButton
          name="Off"
          modifier="off"
          enabled={!priority}
          onClick={createSetPriority(null)}
        />

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
    </Flex>
  );
};

const JobRow = (props: {
  className?: string;
  job: Job;
  name: string;
  style?: Partial<CSSStyleDeclaration>;
}) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { className, job, name, style } = props;

  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded =
    data.job_required_experience && data.job_required_experience[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;
  const lockReason = job.lock_reason;

  let rightSide: ReactNode;

  if (lockReason) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item grow textAlign="right">
          {lockReason}
        </Stack.Item>
      </Stack>
    );
  } else if (experienceNeeded) {
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
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        priority={priority}
      />
    );
  }

  return (
    <Stack.Item className={className} height="100%" mt={0} style={style}>
      <Stack fill align="center">
        <Tooltip content={job.description} position="bottom-start">
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
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

const Department = (props: { department: string } & PropsWithChildren) => {
  const { children, department: name } = props;
  const { data: prefs } = useBackend<PreferencesMenuData>();
  const selectedEmployer =
    (prefs.character_preferences.non_contextual.selected_employer as
      | string
      | undefined) || '';
  const className = `PreferencesMenu__Jobs__departments--row`;

  return (
    <ServerPreferencesFetcher
      render={(data: ServerData) => {
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
          Object.entries(jobs).filter(
            ([_, job]) =>
              job.department === name && job.employer === selectedEmployer,
          ),
          department.head,
        );

        // No jobs from this department belong to the selected employer. Sad :(
        if (!jobsForDepartment.length) {
          return null;
        }

        const deptColour = department.colour || '#888888';
        const deptName = department.name || name;

        const headBg = deptColour;
        const bodyBg = withAlpha(deptColour, 0.45);
        const borderColor = 'rgba(0, 0, 0, 0.3)';

        return (
          <Box
            style={{
              borderTop: `2px solid ${deptColour}`,
              marginBottom: '0.2em',
            }}
          >
            <Box
              bold
              style={{
                color: deptColour,
                padding: '0.2em 0.3em 0.1em',
                fontSize: '0.9em',
                textTransform: 'uppercase',
                letterSpacing: '0.05em',
              }}
            >
              {deptName}
            </Box>
            <Stack vertical fill>
              {jobsForDepartment.map(([jobName, job], index) => {
                const isHead = jobName === department.head;
                const border = `2px solid ${borderColor}`;
                const rowStyle: Partial<CSSStyleDeclaration> = {
                  background: isHead ? headBg : bodyBg,
                  border,
                  // Avoid double borders between adjacent rows: only the
                  // first row draws a top border; the rest inherit the
                  // previous row's bottom border.
                  borderTop: index === 0 ? border : 'none',
                  color: 'black',
                };
                return (
                  <JobRow
                    className={classes([className, isHead && 'head'])}
                    key={jobName}
                    job={job}
                    name={jobName}
                    style={rowStyle}
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

const JoblessRoleDropdown = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
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

  const selection = options?.find(
    (option) => option.value === selected,
  )!.displayText;

  return (
    <Dropdown
      width="100%"
      selected={selection}
      onSelected={createSetPreference(act, 'joblessrole')}
      options={options}
    />
  );
};

const ClearJobsButton = (_) => {
  const { act } = useBackend<PreferencesMenuData>();
  return (
    <Button
      fluid
      content="Clear All"
      confirm
      onClick={() => act('clear_job_preferences')}
    />
  );
};

const EmployerTabs = (props: {
  employers: Record<string, Employer>;
  order: string[];
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { employers, order } = props;
  const selectedId =
    (data.character_preferences.non_contextual.selected_employer as
      | string
      | undefined) || order[0];

  return (
    <Tabs fluid>
      {order.map((id) => {
        const opt = employers[id];
        if (!opt) return null;
        const selected = id === selectedId;
        return (
          <Tabs.Tab
            key={id}
            selected={selected}
            onClick={() =>
              !selected && createSetPreference(act, 'selected_employer')(id)
            }
            style={{
              borderTop: `3px solid ${opt.colour}`,
              fontWeight: selected ? 'bold' : undefined,
            }}
          >
            {opt.display_name}
          </Tabs.Tab>
        );
      })}
    </Tabs>
  );
};

// Top-of-page chooser: prominent employer tabs with a lore strip + the
// jobless / clear controls underneath.
const EmployerInfoBox = () => {
  return (
    <ServerPreferencesFetcher
      render={(data: ServerData) => {
        if (!data) {
          return null;
        }
        const { employers, employer_order: order } = data.jobs;
        if (!order || !order.length) {
          return null;
        }

        return <EmployerInfoBoxInner employers={employers} order={order} />;
      }}
    />
  );
};

const EmployerInfoBoxInner = (props: {
  employers: Record<string, Employer>;
  order: string[];
}) => {
  const { data } = useBackend<PreferencesMenuData>();
  const { employers, order } = props;

  const selectedId =
    (data.character_preferences.non_contextual.selected_employer as
      | string
      | undefined) || order[0];
  const employer = employers[selectedId] || employers[order[0]];

  return (
    <Box mb={1}>
      <EmployerTabs employers={employers} order={order} />

      <Box
        className="section-background"
        p={1}
        style={{
          borderLeft: `4px solid ${employer.colour}`,
        }}
      >
        <Stack fill align="center">
          <Stack.Item>
            <Box
              width="136px"
              height="136px"
              style={{
                border: `1px solid ${employer.colour}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'rgba(0, 0, 0, 0.2)',
              }}
              title={employer.display_name}
            >
              {employer.logo_icon && employer.logo_icon_state ? (
                <DmIcon
                  icon={employer.logo_icon}
                  icon_state={employer.logo_icon_state}
                  width="128px"
                  height="128px"
                  // See LateChoices.tsx: DmIcon's underlying <Image> defaults
                  // to fixBlur=true, which forces image-rendering: pixelated
                  // and overrides our style. Turn it off for smooth scaling.
                  {...({ fixBlur: false } as any)}
                  style={{ imageRendering: 'auto' }}
                />
              ) : (
                <Box
                  style={{
                    fontSize: '1.5em',
                    fontWeight: 'bold',
                    color: 'rgba(255, 255, 255, 0.85)',
                    textTransform: 'uppercase',
                  }}
                >
                  {employer.display_name.charAt(0)}
                </Box>
              )}
            </Box>
          </Stack.Item>

          <Stack.Item grow basis={0} ml={1} mr={1}>
            <Box bold mb={0.25}>
              {employer.display_name}
            </Box>
            <Box
              style={{
                fontSize: '0.95em',
                opacity: 0.9,
                whiteSpace: 'pre-wrap',
              }}
              dangerouslySetInnerHTML={{
                __html: sanitizeText(employer.lore || '\u00A0'),
              }}
            />
          </Stack.Item>

          <Stack.Item width="240px">
            <Stack vertical fill>
              <Stack.Item>
                <JoblessRoleDropdown />
              </Stack.Item>
              <Stack.Item>
                <ClearJobsButton />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Box>
    </Box>
  );
};

// Renders one Department block per department that has at least one job
// belonging to the currently selected employer. The Department component
// itself filters by employer; we just have to enumerate every department
// the jobs payload knows about so events / edge cases keep working.
const EmployerJobLayout = () => {
  return (
    <ServerPreferencesFetcher
      render={(data: ServerData) => {
        if (!data) {
          return null;
        }

        const { jobs } = data.jobs;

        // Prefer the canonical order shipped from DM, then append any
        // department only seen in the jobs payload (defensive — keeps
        // the UI from dropping departments if the order lags behind).
        // `new Set` preserves insertion order and dedupes for free.
        const departmentOrder = Array.from(
          new Set<string>([
            ...(data.jobs.department_order || []),
            ...Object.values(jobs).map((job) => job.department),
          ]),
        );

        return (
          <Stack vertical fill className="section-background" p={1}>
            <Stack.Item>
              <Stack fill className="PreferencesMenu__Jobs">
                <Stack.Item grow basis={0}>
                  {departmentOrder.map((dept) => (
                    <Department key={dept} department={dept}>
                      <Gap amount={6} />
                    </Department>
                  ))}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
};

export const JobsPage = () => {
  return (
    <>
      <EmployerInfoBox />
      <EmployerJobLayout />
    </>
  );
};
