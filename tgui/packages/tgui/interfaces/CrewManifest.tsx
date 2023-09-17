import { sortBy } from '../../common/collections';
import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Icon, Section, Table, Tooltip } from '../components';
import { Window } from '../layouts';

type DepartmentCrew = { [department: string]: ManifestEntry[] };
type JobOrdering = { [job: string]: number };

const sortSpecific = (entries: ManifestEntry[], chain: JobOrdering) =>
  sortBy<ManifestEntry>((entry) => chain[entry.hud] ?? Object.keys(chain).length + 1)(entries);

type ManifestEntry = {
  /** The name of this crew member. */
  name: string;
  /** The rank of this crew member.  */
  rank: string;
  /** The HUD icon of this crew member.  */
  hud: string;
};

type CommandInfo = {
  /** A (static) list of HUD icons used by command roles. */
  huds: string[];
  /** A (static) list of job titles considered to be command roles. */
  jobs: string[];
  /** The ordering of which heads of staff should be listed in the command section, according to chain of command. */
  order: JobOrdering;
};

type CrewManifestData = {
  /** Information pertaining to the command department  */
  command: CommandInfo;
  /** The crew staffing each department. */
  manifest: DepartmentCrew;
  /** The ordering of which jobs should be listed, based on HUD icon. */
  order: JobOrdering;
  /** Use the generic TGUI theme. */
  generic: BooleanLike;
};

export const CrewManifest = (_props, context) => {
  const {
    data: { command, order, manifest, generic },
  } = useBackend<CrewManifestData>(context);

  return (
    <Window title="Crew Manifest" width={350} height={500} theme={generic ? 'generic' : undefined}>
      <Window.Content scrollable>
        {Object.entries(manifest).map(([dept, crew]) => {
          const sorted_jobs = dept === 'Command' ? sortSpecific(crew, command.order) : sortSpecific(crew, order);
          return (
            <Section className={'CrewManifest--' + dept} key={dept} title={dept}>
              <Table>
                {Object.entries(sorted_jobs).map(([crewIndex, crewMember]) => {
                  const is_command = command.huds.includes(crewMember.hud) || command.jobs.includes(crewMember.rank);
                  return (
                    <Table.Row key={crewIndex}>
                      <Table.Cell className={'CrewManifest__Cell'} bold={is_command}>
                        {crewMember.name}
                      </Table.Cell>
                      <Table.Cell className={classes(['CrewManifest__Cell', 'CrewManifest__Icons'])} collapsing>
                        {is_command && (
                          <Tooltip content="Head of Staff" position="bottom">
                            <Icon
                              className={classes([
                                'CrewManifest__Icon',
                                'CrewManifest__Icon--Command',
                                'CrewManifest__Icon--Chevron',
                              ])}
                              name="chevron-up"
                            />
                          </Tooltip>
                        )}
                        <Box
                          inline
                          mr={0.5}
                          ml={-0.5}
                          style={{ 'transform': 'translateY(18.75%)' }}
                          className={`job-icon16x16 job-icon-hud${crewMember.hud}`}
                        />
                      </Table.Cell>
                      <Table.Cell className={classes(['CrewManifest__Cell', 'CrewManifest__Cell--Rank'])} collapsing>
                        {crewMember.rank}
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </Section>
          );
        })}
      </Window.Content>
    </Window>
  );
};
