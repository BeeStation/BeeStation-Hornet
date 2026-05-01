import { DmIcon } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Employer = {
  id: string;
  display_name: string;
  lore: string;
  colour: string;
  logo_icon: string | null;
  logo_icon_state: string | null;
  department_ids: string[];
};

type Department = {
  id: string;
  name: string;
  colour: string;
};

type LateJob = {
  title: string;
  department: string;
  employer: string | null;
  positions: number;
  available: boolean;
  unavailable_reason: string | null;
  prioritized: boolean;
  command: boolean;
};

type LateChoicesData = {
  round_duration: string;
  shuttle_status: 'evacuated' | 'evacuating' | null;
  prioritized_jobs_active: boolean;
  selected_employer: string | null;

  employers: Record<string, Employer>;
  employer_order: string[];

  departments: Record<string, Department>;
  department_order: string[];

  jobs: Record<string, LateJob>;
};

export const LateChoices = (_props) => {
  const { data } = useBackend<LateChoicesData>();
  const {
    employers,
    employer_order,
    selected_employer,
    departments,
    department_order,
    jobs,
    shuttle_status,
    prioritized_jobs_active,
    round_duration,
  } = data;

  const employer =
    (selected_employer && employers[selected_employer]) ||
    employers[employer_order[0]];

  // Bucket jobs by department for the currently selected employer.
  const jobsForDepartment: Record<string, LateJob[]> = {};
  for (const job of Object.values(jobs)) {
    if (!employer || job.employer !== employer.id) continue;
    (jobsForDepartment[job.department] ||= []).push(job);
  }

  // Visible departments: those that contributed at least one job to this employer.
  const visibleDepartments = department_order.filter(
    (id) => jobsForDepartment[id]?.length,
  );

  return (
    <Window
      title="Choose Profession"
      width={760}
      height={640}
      theme="generic-yellow"
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <TopBanner
              roundDuration={round_duration}
              shuttleStatus={shuttle_status}
              prioritizedActive={prioritized_jobs_active}
            />
          </Stack.Item>

          {employer && (
            <Stack.Item>
              <EmployerInfoBox
                employer={employer}
                employers={employers}
                order={employer_order}
              />
            </Stack.Item>
          )}

          {/*
            Job list lives in its own scrollable thingy otherwise we are sad
          */}
          <Stack.Item grow basis={0}>
            <Box position="relative" height="100%">
              <Box
                position="absolute"
                top={0}
                bottom={0}
                left={0}
                right={0}
                style={{ overflowY: 'auto' }}
              >
                {visibleDepartments.length > 0 ? (
                  <DepartmentColumns
                    departmentIds={visibleDepartments}
                    departments={departments}
                    jobsForDepartment={jobsForDepartment}
                  />
                ) : (
                  <Section>
                    <Box textAlign="center" italic color="label">
                      {employer
                        ? `${employer.display_name} has no positions open right now.`
                        : 'No positions open.'}
                    </Box>
                  </Section>
                )}
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TopBanner = (props: {
  roundDuration: string;
  shuttleStatus: 'evacuated' | 'evacuating' | null;
  prioritizedActive: boolean;
}) => {
  const { act } = useBackend<LateChoicesData>();
  const { roundDuration, shuttleStatus, prioritizedActive } = props;

  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow basis={0}>
          <Box>
            <Box bold inline>
              Round Duration:
            </Box>{' '}
            {roundDuration}
          </Box>
          {!!prioritizedActive && (
            <Box mt={0.5} color="good">
              Highlighted jobs have been prioritized by the Head of Personnel,
              please consider joining as one.
            </Box>
          )}
          {shuttleStatus === 'evacuated' && (
            <Box mt={0.5} color="bad" bold>
              The station has been evacuated.
            </Box>
          )}
          {shuttleStatus === 'evacuating' && (
            <Box mt={0.5} color="bad" bold>
              The station is currently undergoing evacuation procedures.
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="users"
            content="View Manifest"
            onClick={() => act('view_manifest')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EmployerInfoBox = (props: {
  employer: Employer;
  employers: Record<string, Employer>;
  order: string[];
}) => {
  const { act } = useBackend<LateChoicesData>();
  const { employer, employers, order } = props;

  return (
    <Box
      className="section-background"
      p={1}
      style={{
        borderLeft: `4px solid ${employer.colour}`,
      }}
    >
      <Stack fill align="stretch">
        {/* Logo placeholder; matches the prefs menu's fallback so both UIs read the same. */}
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
                // The underlying <Image> defaults to fixBlur=true, which forces
                // image-rendering: pixelated (nearest-neighbor) and overrides
                // any style we pass. Disable it so the 32x source gets smoothly
                // scaled up to 128px instead of looking crunchy. fixBlur is a
                // valid runtime prop on Image but is not declared on DmIcon's
                // public type, so we spread it via a cast.
                {...({ fixBlur: false } as any)}
                style={{ imageRendering: 'auto' }}
              />
            ) : (
              <Box
                style={{
                  fontSize: '1.6em',
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
          <Stack vertical fill>
            <Stack.Item>
              <Box bold>{employer.display_name}</Box>
            </Stack.Item>
            <Stack.Item grow basis={0} style={{ position: 'relative' }}>
              {/* Absolutely-positioned inner so the scroll box fills the
                  flex parent's height instead of being measured by content. Append: Is this shitcode?*/}
              <Box
                style={{
                  position: 'absolute',
                  inset: 0,
                  overflowY: 'auto',
                  fontSize: '0.95em',
                  opacity: 0.9,
                  whiteSpace: 'pre-wrap',
                }}
                dangerouslySetInnerHTML={{
                  __html: sanitizeText(employer.lore || '\u00A0'),
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item width="180px">
          <Stack vertical fill>
            {order.map((id) => {
              const opt = employers[id];
              if (!opt) return null;
              const selected = opt.id === employer.id;
              return (
                <Stack.Item key={id}>
                  <Button
                    fluid
                    selected={selected}
                    content={opt.display_name}
                    onClick={() =>
                      !selected && act('select_employer', { employer: id })
                    }
                  />
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// Stacks visible departments vertically, matches the prefs JobsPage layout
// for visual consistency between the two job-selection UIs.
const DepartmentColumns = (props: {
  departmentIds: string[];
  departments: Record<string, Department>;
  jobsForDepartment: Record<string, LateJob[]>;
}) => {
  const { departmentIds, departments, jobsForDepartment } = props;

  return (
    <Stack vertical>
      {departmentIds.map((deptId) => {
        const dept = departments[deptId];
        if (!dept) return null;
        return (
          <Stack.Item key={deptId}>
            <DepartmentBlock
              department={dept}
              jobs={jobsForDepartment[deptId] || []}
            />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const DepartmentBlock = (props: {
  department: Department;
  jobs: LateJob[];
}) => {
  const { department, jobs } = props;

  // Sort: command roles first, then alphabetical. Stable enough for this view.
  const sortedJobs = [...jobs].sort((a, b) => {
    if (a.command !== b.command) return a.command ? -1 : 1;
    return a.title.localeCompare(b.title);
  });

  return (
    <Section
      title={
        <Box inline style={{ color: department.colour }}>
          {department.name}
        </Box>
      }
      style={{
        borderTop: `2px solid ${department.colour}`,
      }}
    >
      <Stack vertical>
        {sortedJobs.length === 0 ? (
          <Stack.Item>
            <Box italic color="label">
              No positions open.
            </Box>
          </Stack.Item>
        ) : (
          sortedJobs.map((job) => (
            <Stack.Item key={job.title}>
              <JobButton job={job} />
            </Stack.Item>
          ))
        )}
      </Stack>
    </Section>
  );
};

const JobButton = (props: { job: LateJob }) => {
  const { act } = useBackend<LateChoicesData>();
  const { job } = props;

  const button = (
    <Button
      fluid
      disabled={!job.available}
      bold={job.command}
      color={job.prioritized ? 'good' : undefined}
      onClick={() => job.available && act('select_job', { job: job.title })}
      content={`${job.title} (${job.positions})`}
    />
  );

  if (!job.available && job.unavailable_reason) {
    return <Tooltip content={job.unavailable_reason}>{button}</Tooltip>;
  }
  return button;
};
