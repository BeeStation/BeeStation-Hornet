import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

// We fill each column top-to-bottom, so to make it easy to play tetris we define
// the display order here.
const EMPLOYER_DISPLAY_ORDER: string[] = [
  'nanotrasen',
  'auri_security',
  'stationside_services',
  'eclipse_express',
  'nakamura_engineering',
  'acrux_medical',
  'non_crew',
];

type Employer = {
  id: string;
  display_name: string;
  lore: string;
  colour: string;
  logo_icon: string | null;
  logo_icon_state: string | null;
  fa_icon: string | null;
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

  employers: Record<string, Employer>;
  employer_order: string[];

  departments: Record<string, Department>;

  jobs: Record<string, LateJob>;
};

export const LateChoices = () => {
  const { data } = useBackend<LateChoicesData>();
  const {
    employers,
    employer_order,
    departments,
    jobs,
    shuttle_status,
    prioritized_jobs_active,
    round_duration,
  } = data;

  // Bucket every job by employer, then by department, in one pass.
  const jobsByEmployerDept: Record<string, Record<string, LateJob[]>> = {};
  for (const job of Object.values(jobs)) {
    if (!job.employer) continue;
    const byDept = (jobsByEmployerDept[job.employer] ||= {});
    (byDept[job.department] ||= []).push(job);
  }

  // Merge the hand-curated display order with the backend's affiliation
  // order: take everything from EMPLOYER_DISPLAY_ORDER that the backend
  // actually sent, then append any backend employers we didn't list so
  // newcomers still appear (just at the bottom).
  const knownIds = new Set(employer_order);
  const orderedHand = EMPLOYER_DISPLAY_ORDER.filter((id) => knownIds.has(id));
  const handSet = new Set(orderedHand);
  const displayOrder = [
    ...orderedHand,
    ...employer_order.filter((id) => !handSet.has(id)),
  ];

  return (
    <Window
      title="Choose Profession"
      width={900}
      height={600}
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

          {/* A box per employer, filling the rest of the window. */}
          <Stack.Item grow basis={0} style={{ overflowY: 'auto' }}>
            <EmployerGrid
              employers={employers}
              employerOrder={displayOrder}
              departments={departments}
              jobsByEmployerDept={jobsByEmployerDept}
            />
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

// Renders one box per employer, in the supplied order. Layout is CSS
// multi-column: the browser fills column 1 top-to-bottom, then column 2,
// etc., so the order is column-major. Tweak EMPLOYER_DISPLAY_ORDER above
// to control which employers stack together in each column.
// Employers with no open positions for the player are skipped entirely.
const EmployerGrid = (props: {
  employers: Record<string, Employer>;
  employerOrder: string[];
  departments: Record<string, Department>;
  jobsByEmployerDept: Record<string, Record<string, LateJob[]>>;
}) => {
  const { employers, employerOrder, departments, jobsByEmployerDept } = props;

  return (
    <Box className="LateChoices__grid">
      {employerOrder.map((empId) => {
        const employer = employers[empId];
        if (!employer) return null;
        const byDept = jobsByEmployerDept[empId] || {};
        const visibleDepts = (employer.department_ids || []).filter(
          (deptId) => byDept[deptId]?.length,
        );
        if (visibleDepts.length === 0) return null;
        return (
          <EmployerBox
            key={empId}
            employer={employer}
            departments={departments}
            visibleDepts={visibleDepts}
            jobsByDept={byDept}
          />
        );
      })}
    </Box>
  );
};

const EmployerBox = (props: {
  employer: Employer;
  departments: Record<string, Department>;
  visibleDepts: string[];
  jobsByDept: Record<string, LateJob[]>;
}) => {
  const { employer, departments, visibleDepts, jobsByDept } = props;

  return (
    <Box
      className="LateChoices__employer section-background"
      style={{
        borderLeft: `4px solid ${employer.colour}`,
      }}
    >
      <Box
        className="LateChoices__employer-title"
        style={{ color: employer.colour }}
      >
        {!!employer.fa_icon && (
          <Icon name={employer.fa_icon} mr={1} />
        )}
        {employer.display_name}
      </Box>
      {visibleDepts.map((deptId) => {
        const dept = departments[deptId];
        if (!dept) return null;
        return (
          <DepartmentBlock
            key={deptId}
            department={dept}
            jobs={jobsByDept[deptId] || []}
          />
        );
      })}
    </Box>
  );
};

const DepartmentBlock = (props: {
  department: Department;
  jobs: LateJob[];
}) => {
  const { department, jobs } = props;

  // Command roles first, then alphabetical.
  const sortedJobs = [...jobs].sort((a, b) => {
    if (a.command !== b.command) return a.command ? -1 : 1;
    return a.title.localeCompare(b.title);
  });

  return (
    <Box className="LateChoices__department">
      <Box
        className="LateChoices__department-header"
        style={{
          color: department.colour,
          borderBottom: `1px solid ${department.colour}`,
        }}
      >
        {department.name}
      </Box>
      <Stack vertical className="LateChoices__job-list">
        {sortedJobs.map((job) => (
          <Stack.Item key={job.title}>
            <JobButton job={job} />
          </Stack.Item>
        ))}
      </Stack>
    </Box>
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
