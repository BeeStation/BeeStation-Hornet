import { classes } from 'common/react';

import { sortBy } from '../../common/collections';
import { useBackend } from '../backend';
import {
  Box,
  CollapsibleSection,
  Flex,
  Icon,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type DepartmentCrew = { [department: string]: ManifestEntry[] };
type JobOrdering = { [job: string]: number };

const sortSpecific = (entries: ManifestEntry[], chain: JobOrdering) =>
  sortBy(entries, (entry) => chain[entry.hud] ?? Object.keys(chain).length + 1);

type ManifestEntry = {
  /** The name of this crew member. */
  name: string;
  /** The rank of this crew member.  */
  rank: string;
  /** The HUD icon of this crew member.  */
  hud: string;
};

type CommandInfo = {
  /** The name of the 'superior' department. Honestly, this is always going to be "Command", but well, apparently this shouldn't be hardcoded, so yolo! */
  dept: string;
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
  /** The TGUI theme to use. */
  user_theme?: string;
};

export const CrewManifest = (_props) => {
  const {
    data: { command, order, manifest, user_theme },
  } = useBackend<CrewManifestData>();

  return (
    <Window title="Crew Manifest" width={450} height={500} theme={user_theme}>
      <Window.Content scrollable>
        {Object.entries(manifest).map(([dept, crew]) => {
          const sorted_jobs =
            dept === command.dept
              ? sortSpecific(crew, command.order)
              : sortSpecific(crew, order);
          return (
            <CollapsibleSection
              className={classes(['CrewManifest', `CrewManifest--${dept}`])}
              key={dept}
              sectionKey={dept}
              title={dept}
            >
              <Table>
                {Object.entries(sorted_jobs).map(([crewIndex, crewMember]) => {
                  const is_command =
                    command.huds.includes(crewMember.hud) ||
                    command.jobs.includes(crewMember.rank);
                  return (
                    <Table.Row
                      key={crewIndex}
                      className="candystripe"
                      height="16px"
                    >
                      <Table.Cell
                        className={'CrewManifest__Cell'}
                        bold={is_command}
                        pl={0.5}
                      >
                        <Flex direction="row" style={{ alignItems: 'center' }}>
                          <Flex.Item>
                            <Box
                              inline
                              mr={0.5}
                              ml={-0.5}
                              style={{ verticalAlign: 'middle' }}
                              className={`job-icon16x16 job-icon-hud${crewMember.hud}`}
                            />
                          </Flex.Item>
                          <Flex.Item grow>{crewMember.name}</Flex.Item>
                        </Flex>
                      </Table.Cell>
                      <Table.Cell
                        className={classes([
                          'CrewManifest__Cell',
                          'CrewManifest__Cell--Rank',
                        ])}
                        collapsing
                        pr={1}
                      >
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
                        {crewMember.rank}
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </CollapsibleSection>
          );
        })}
      </Window.Content>
    </Window>
  );
};
