import { useBackend, useLocalState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Flex,
  Icon,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type ThreatEntry = {
  label: string;
  threat_designation: string;
  description: string;
  signs: string[];
  advised_response: string;
};

type Data = {
  handbook_title: string;
  handbook_author: string;
  threat_entries: ThreatEntry[];
  current_page: number;
};

enum PageType {
  Cover,
  Contents,
  ThreatDesignations,
  ThreatEntry,
  EndPage,
}

type PageInfo = {
  type: PageType;
  threatIndex?: number;
};

/** Threat levels ordered from least to most severe */
const THREAT_LEVELS = [
  'Negligible',
  'Minor',
  'Moderate',
  'Major',
  'Severe',
  'Critical',
] as const;

const THREAT_SYMBOLS: Record<string, string> = {
  negligible: 'α',
  minor: 'β',
  moderate: 'γ',
  major: 'Δ',
  severe: 'ε',
  critical: 'Ω',
};

const DESIGNATIONS = [
  {
    level: 'Negligible',
    symbol: 'α',
    desc: 'Minimal risk to crew or station operations. Standard operating procedures are sufficient.',
  },
  {
    level: 'Minor',
    symbol: 'β',
    desc: 'Low risk. May require security attention but poses no significant threat to station integrity.',
  },
  {
    level: 'Moderate',
    symbol: 'γ',
    desc: 'Notable risk to crew safety. Security response recommended. Coordination with department heads advised.',
  },
  {
    level: 'Major',
    symbol: 'Δ',
    desc: 'Significant threat to multiple crew members or critical systems. Full security mobilization required.',
  },
  {
    level: 'Severe',
    symbol: 'ε',
    desc: 'Extreme danger to station survival. All crew should be on high alert. Command-level response necessary.',
  },
  {
    level: 'Critical',
    symbol: 'Ω',
    desc: 'Existential threat to the station. Evacuation protocols may be necessary. Maximum response authorized.',
  },
];

const getThreatSymbol = (designation: string): string => {
  return THREAT_SYMBOLS[designation.toLowerCase()] || '?';
};

export const CorporateThreatHandbook = () => {
  const { data, act } = useBackend<Data>();
  const {
    handbook_title,
    handbook_author,
    threat_entries = [],
    current_page = 0,
  } = data;

  const pages: PageInfo[] = [
    { type: PageType.Cover },
    { type: PageType.Contents },
    { type: PageType.ThreatDesignations },
    ...threat_entries.map((_, index) => ({
      type: PageType.ThreatEntry,
      threatIndex: index,
    })),
    { type: PageType.EndPage },
  ];

  const [currentPage, setCurrentPage] = useLocalState(
    'currentPage',
    current_page,
  );
  const totalPages = pages.length;

  const changePage = (newPage: number) => {
    if (newPage >= 0 && newPage < totalPages && newPage !== currentPage) {
      setCurrentPage(newPage);
      act('turn_page', { page: newPage });
    }
  };

  const currentPageInfo = pages[currentPage];

  return (
    <Window width={600} height={750} title={handbook_title} theme="document">
      <Window.Content className="Handbook">
        <Box className="Handbook__pageNumber">
          Page {currentPage + 1}/{totalPages}
        </Box>

        <Box className="Handbook__page">
          <PageContent
            pageInfo={currentPageInfo}
            threatEntries={threat_entries}
            handbookTitle={handbook_title}
            handbookAuthor={handbook_author}
            goToPage={changePage}
          />
        </Box>

        <Flex className="Handbook__nav">
          <Flex.Item>
            <Button
              icon="chevron-left"
              disabled={currentPage === 0}
              onClick={() => changePage(currentPage - 1)}
            >
              Previous
            </Button>
          </Flex.Item>
          <Flex.Item grow />
          <Flex.Item>
            <Button
              icon="chevron-right"
              iconPosition="right"
              disabled={currentPage === totalPages - 1}
              onClick={() => changePage(currentPage + 1)}
            >
              Next
            </Button>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

type PageContentProps = {
  pageInfo: PageInfo;
  threatEntries: ThreatEntry[];
  handbookTitle: string;
  handbookAuthor: string;
  goToPage: (page: number) => void;
};

const PageContent = (props: PageContentProps) => {
  const { pageInfo, threatEntries, handbookTitle, handbookAuthor, goToPage } =
    props;

  switch (pageInfo.type) {
    case PageType.Cover:
      return (
        <CoverPage
          handbookTitle={handbookTitle}
          handbookAuthor={handbookAuthor}
        />
      );
    case PageType.Contents:
      return <ContentsPage threatEntries={threatEntries} goToPage={goToPage} />;
    case PageType.ThreatDesignations:
      return <ThreatDesignationsPage />;
    case PageType.ThreatEntry:
      return (
        <ThreatEntryPage
          entry={threatEntries[pageInfo.threatIndex as number]}
        />
      );
    case PageType.EndPage:
      return <EndPage />;
    default:
      return <Box>Unknown page type</Box>;
  }
};

type CoverPageProps = {
  handbookTitle: string;
  handbookAuthor: string;
};

const CoverPage = (props: CoverPageProps) => {
  const { handbookTitle, handbookAuthor } = props;
  return (
    <Stack vertical align="center" className="Handbook__cover">
      <Stack.Item>
        <Stack vertical align="center">
          <Stack.Item className="Handbook__coverLogo">
            <Icon name="tg-nanotrasen-logo" size={6} />
          </Stack.Item>
          <Stack.Item className="Handbook__coverCorp">
            NANOTRASEN CORPORATION
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item className="Handbook__coverTitleBlock">
        <Box className="Handbook__coverTitle">{handbookTitle}</Box>
        <Box className="Handbook__coverAuthor">{handbookAuthor}</Box>
      </Stack.Item>

      <Stack.Item>
        <Flex className="Handbook__stamps">
          <Flex.Item className="Handbook__stamp Handbook__stamp--red">
            INTERNAL USE ONLY
          </Flex.Item>
          <Flex.Item className="Handbook__stamp Handbook__stamp--blue">
            APPROVED
          </Flex.Item>
        </Flex>
      </Stack.Item>

      <Stack.Item>
        <Flex className="Handbook__coverInfo">
          <Flex.Item className="Handbook__coverInfoItem">
            <Box className="Handbook__coverInfoLabel">Document Class</Box>
            <Box className="Handbook__coverInfoValue">NT-SEC-47C</Box>
          </Flex.Item>
          <Flex.Item className="Handbook__coverInfoItem">
            <Box className="Handbook__coverInfoLabel">Clearance Level</Box>
            <Box className="Handbook__coverInfoValue">General</Box>
          </Flex.Item>
          <Flex.Item className="Handbook__coverInfoItem">
            <Box className="Handbook__coverInfoLabel">Revision</Box>
            <Box className="Handbook__coverInfoValue">2563.7</Box>
          </Flex.Item>
        </Flex>
      </Stack.Item>

      <Stack.Item className="Handbook__notice">
        Failure to familiarize yourself with this material may result in
        disciplinary action, injury, or death.
      </Stack.Item>

      <Stack.Item className="Handbook__coverFooter">
        © 2563 Nanotrasen Corporation — All Rights Reserved
      </Stack.Item>
    </Stack>
  );
};

type ContentsPageProps = {
  threatEntries: ThreatEntry[];
  goToPage: (page: number) => void;
};

const ContentsPage = (props: ContentsPageProps) => {
  const { threatEntries, goToPage } = props;
  const threatStartPage = 3;

  const threatCounts = THREAT_LEVELS.map((level) => ({
    level,
    count: threatEntries.filter(
      (e) => e.threat_designation.toLowerCase() === level.toLowerCase(),
    ).length,
  })).filter((item) => item.count > 0);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Table of Contents">
          <Box className="Handbook__subtitle">
            Quick Reference Guide to Identified Threats
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Flex>
          <Flex.Item grow basis={0}>
            <Section
              title={
                <>
                  <Icon name="book" /> Reference Materials
                </>
              }
            >
              <Box className="Handbook__tocItem" onClick={() => goToPage(2)}>
                <span className="Handbook__tocNumber">I.</span>
                <span className="Handbook__tocText">
                  Threat Designation Guide
                  <Box className="Handbook__tocDesc">
                    Understanding threat classifications
                  </Box>
                </span>
                <span className="Handbook__tocPage">3</span>
              </Box>
            </Section>
          </Flex.Item>

          <Flex.Item grow basis={0}>
            <Section
              title={
                <>
                  <Icon name="list" /> Threat Count by Level
                </>
              }
            >
              {threatCounts.map((item) => (
                <Flex key={item.level} className="Handbook__statRow">
                  <Flex.Item grow>
                    <span
                      className={`Handbook__designation Handbook__designation--${item.level.toLowerCase()}`}
                    >
                      {item.level}
                    </span>
                  </Flex.Item>
                  <Flex.Item className="Handbook__statCount">
                    {item.count}
                  </Flex.Item>
                </Flex>
              ))}
            </Section>
          </Flex.Item>
        </Flex>
      </Stack.Item>

      <Stack.Item grow>
        <Section
          title={
            <>
              <Icon name="shield" /> Documented Threats
            </>
          }
        >
          <Box className="Handbook__threatGrid">
            {threatEntries.map((entry, index) => (
              <Box
                key={entry.label}
                className="Handbook__threatItem"
                onClick={() => goToPage(threatStartPage + index)}
              >
                <span className="Handbook__threatSymbol">
                  {getThreatSymbol(entry.threat_designation)}
                </span>
                <span className="Handbook__threatInfo">
                  <Box bold>{entry.label}</Box>
                  <span
                    className={`Handbook__designation Handbook__designation--${entry.threat_designation.toLowerCase()}`}
                  >
                    {entry.threat_designation}
                  </span>
                </span>
                <span className="Handbook__threatPage">
                  {threatStartPage + index + 1}
                </span>
              </Box>
            ))}
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ThreatDesignationsPage = () => {
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Threat Designation Guide">
          <Box className="Handbook__intro">
            Nanotrasen classifies threats according to the following
            standardized designation system. Understanding these classifications
            will help you respond appropriately to incidents.
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Box className="Handbook__designationGrid">
          {DESIGNATIONS.map((d) => (
            <Box
              key={d.level}
              className={`Handbook__designationCard Handbook__designationCard--${d.level.toLowerCase()}`}
            >
              <Flex align="center" mb={0.5}>
                <Flex.Item className="Handbook__designationSymbol">
                  {d.symbol}
                </Flex.Item>
                <Flex.Item
                  className={`Handbook__designation Handbook__designation--${d.level.toLowerCase()}`}
                >
                  {d.level}
                </Flex.Item>
              </Flex>
              <Box className="Handbook__designationDesc">{d.desc}</Box>
            </Box>
          ))}
        </Box>
      </Stack.Item>

      <Stack.Item className="Handbook__note">
        <Icon name="info-circle" /> Threat levels may be upgraded or downgraded
        based on situational assessment by Security personnel.
      </Stack.Item>
    </Stack>
  );
};

type ThreatEntryPageProps = {
  entry: ThreatEntry;
};

const ThreatEntryPage = (props: ThreatEntryPageProps) => {
  const { entry } = props;

  if (!entry) {
    return <Box>Error: Threat entry not found</Box>;
  }

  const level = entry.threat_designation.toLowerCase();

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Flex
          align="center"
          className={`Handbook__entryHeader Handbook__entryHeader--${level}`}
        >
          <Flex.Item className="Handbook__entrySymbol">
            {getThreatSymbol(entry.threat_designation)}
          </Flex.Item>
          <Flex.Item grow>
            <Box bold className="Handbook__entryTitle">
              {entry.label}
            </Box>
            <span
              className={`Handbook__designation Handbook__designation--${level}`}
            >
              {entry.threat_designation}
            </span>
          </Flex.Item>
        </Flex>
      </Stack.Item>

      <Stack.Item grow>
        <Flex>
          <Flex.Item grow basis={0}>
            <Stack vertical>
              <Stack.Item>
                <Section
                  title={
                    <>
                      <Icon name="file-alt" /> Description
                    </>
                  }
                >
                  <Box preserveWhitespace>{entry.description}</Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title={
                    <>
                      <Icon name="shield-alt" /> Advised Response
                    </>
                  }
                >
                  <Box preserveWhitespace>{entry.advised_response}</Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Flex.Item>

          <Flex.Item className="Handbook__sidebar">
            <Stack vertical>
              <Stack.Item>
                <Section
                  title={
                    <>
                      <Icon name="search" /> Identification
                    </>
                  }
                >
                  {entry.signs.map((sign, index) => (
                    <Box key={index} className="Handbook__sign">
                      <Icon name="chevron-right" /> {sign}
                    </Box>
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title={
                    <>
                      <Icon name="clipboard-check" /> Quick Reference
                    </>
                  }
                >
                  <Box className="Handbook__quickrefItem">
                    <Box className="Handbook__quickrefLabel">Threat</Box>
                    <Box bold>{entry.label}</Box>
                  </Box>
                  <Box className="Handbook__quickrefItem">
                    <Box className="Handbook__quickrefLabel">Level</Box>
                    <span
                      className={`Handbook__designation Handbook__designation--${level}`}
                    >
                      {entry.threat_designation}
                    </span>
                  </Box>
                  <Box className="Handbook__quickrefItem">
                    <Box className="Handbook__quickrefLabel">Signs</Box>
                    <Box bold>{entry.signs.length} identified</Box>
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Flex.Item>
        </Flex>
      </Stack.Item>
    </Stack>
  );
};

const EndPage = () => {
  return (
    <Stack vertical align="center" fill className="Handbook__endPage">
      <Stack.Item className="Handbook__endSeal">
        <Icon name="check-circle" size={3} />
      </Stack.Item>

      <Stack.Item className="Handbook__endTitle">End of Handbook</Stack.Item>

      <Stack.Item>
        <Flex align="center" className="Handbook__endDivider">
          <Flex.Item grow className="Handbook__endDividerLine" />
          <Flex.Item>
            <Icon name="star" />
          </Flex.Item>
          <Flex.Item grow className="Handbook__endDividerLine" />
        </Flex>
      </Stack.Item>

      <Stack.Item className="Handbook__endMessage">
        This concludes the Nanotrasen Incident Awareness & Threat Recognition
        Handbook.
      </Stack.Item>

      <Stack.Item>
        <BlockQuote>A prepared crew is a surviving crew.</BlockQuote>
      </Stack.Item>

      <Stack.Item>
        <Section
          title={
            <>
              <Icon name="headset" /> Need Assistance?
            </>
          }
        >
          <Box className="Handbook__contactText">
            For additional information or to report suspected threats, contact
            your local Security department or use emergency communication
            channels.
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item grow />

      <Stack.Item className="Handbook__endFooter">
        <Box className="Handbook__endVersion">
          Document Version 47.3.2 — Last Updated: [REDACTED]
        </Box>
        <Box className="Handbook__endDisclaimer">
          Nanotrasen is not responsible for injury or death resulting from
          failure to follow handbook guidelines.
        </Box>
      </Stack.Item>
    </Stack>
  );
};
