import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack } from '../components';
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

// Page types for the handbook
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

export const CorporateThreatHandbook = (props) => {
  const { data, act } = useBackend<Data>();
  const {
    handbook_title,
    handbook_author,
    threat_entries = [],
    current_page = 0,
  } = data;

  // Build page list
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

  const goToPrevPage = () => {
    if (currentPage > 0) {
      changePage(currentPage - 1);
    }
  };

  const goToNextPage = () => {
    if (currentPage < totalPages - 1) {
      changePage(currentPage + 1);
    }
  };

  const goToPage = (page: number) => {
    changePage(page);
  };

  const currentPageInfo = pages[currentPage];

  return (
    <Window width={550} height={650} title={handbook_title}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill scrollable>
              <PageContent
                pageInfo={currentPageInfo}
                threatEntries={threat_entries}
                handbookTitle={handbook_title}
                handbookAuthor={handbook_author}
                goToPage={goToPage}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack justify="space-between" align="center">
              <Stack.Item>
                <Button
                  icon="chevron-left"
                  disabled={currentPage === 0}
                  onClick={goToPrevPage}
                />
              </Stack.Item>
              <Stack.Item>
                <Box color="label">
                  Page {currentPage + 1} of {totalPages}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="chevron-right"
                  disabled={currentPage === totalPages - 1}
                  onClick={goToNextPage}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
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
    <Box textAlign="center">
      <Box fontSize="24px" bold mt={4} mb={2}>
        {handbookTitle}
      </Box>
      <Box fontSize="14px" color="label" mb={4}>
        {handbookAuthor}
      </Box>
      <Box mb={4}>
        <Box italic color="average">
          FOR INTERNAL DISTRIBUTION ONLY
        </Box>
      </Box>
      <Box mt={6} mb={2} color="label">
        This handbook has been prepared by the Nanotrasen Security Division to
        brief all crew members on potential threats they may encounter during
        their shift.
      </Box>
      <Box mt={4} color="label" italic>
        Failure to familiarize yourself with this material may result in
        disciplinary action, injury, or death.
      </Box>
      <Box mt={6} fontSize="12px" color="label">
        © 2563 Nanotrasen Corporation
      </Box>
    </Box>
  );
};

type ContentsPageProps = {
  threatEntries: ThreatEntry[];
  goToPage: (page: number) => void;
};

const ContentsPage = (props: ContentsPageProps) => {
  const { threatEntries, goToPage } = props;
  // Threat entries start at page index 3 (after Cover, Contents, Designations)
  const threatStartPage = 3;

  return (
    <Box>
      <Box fontSize="18px" bold mb={2}>
        Table of Contents
      </Box>
      <Box mb={2}>
        <Button fluid onClick={() => goToPage(2)}>
          Threat Designations
        </Button>
      </Box>
      <Box bold mb={1}>
        Threat Entries:
      </Box>
      {threatEntries.map((entry, index) => (
        <Box key={entry.label} mb={1}>
          <Button fluid onClick={() => goToPage(threatStartPage + index)}>
            {entry.label} - {entry.threat_designation}
          </Button>
        </Box>
      ))}
    </Box>
  );
};

const ThreatDesignationsPage = () => {
  return (
    <Box>
      <Box fontSize="18px" bold mb={2}>
        Threat Designation Guide
      </Box>
      <Box mb={2}>
        Nanotrasen classifies threats according to the following standardized
        designation system. Understanding these classifications will help you
        respond appropriately to incidents.
      </Box>
      <Box mb={2}>
        <Box bold color="green">
          Negligible
        </Box>
        <Box ml={2}>
          Minimal risk to crew or station operations. Standard operating
          procedures are sufficient.
        </Box>
      </Box>
      <Box mb={2}>
        <Box bold color="teal">
          Minor
        </Box>
        <Box ml={2}>
          Low risk. May require security attention but poses no significant
          threat to station integrity.
        </Box>
      </Box>
      <Box mb={2}>
        <Box bold color="average">
          Moderate
        </Box>
        <Box ml={2}>
          Notable risk to crew safety. Security response recommended.
          Coordination with department heads advised.
        </Box>
      </Box>
      <Box mb={2}>
        <Box bold color="orange">
          Major
        </Box>
        <Box ml={2}>
          Significant threat to multiple crew members or critical systems. Full
          security mobilization required.
        </Box>
      </Box>
      <Box mb={2}>
        <Box bold color="bad">
          Severe
        </Box>
        <Box ml={2}>
          Extreme danger to station survival. All crew should be on high alert.
          Command-level response necessary.
        </Box>
      </Box>
      <Box mb={2}>
        <Box bold color="red">
          Critical
        </Box>
        <Box ml={2}>
          Existential threat to the station. Evacuation protocols may be
          necessary. Maximum response authorized.
        </Box>
      </Box>
    </Box>
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

  const getDesignationColor = (designation: string): string => {
    const lowerDesignation = designation.toLowerCase();
    switch (lowerDesignation) {
      case 'negligible':
        return 'green';
      case 'minor':
        return 'teal';
      case 'moderate':
        return 'average';
      case 'major':
        return 'orange';
      case 'severe':
        return 'bad';
      case 'critical':
        return 'red';
      default:
        return 'label';
    }
  };

  return (
    <Box>
      <Box fontSize="20px" bold mb={1}>
        {entry.label}
      </Box>
      <Box mb={2}>
        <Box as="span" color="label">
          Threat Designation:{' '}
        </Box>
        <Box
          as="span"
          bold
          color={getDesignationColor(entry.threat_designation)}
        >
          {entry.threat_designation}
        </Box>
      </Box>
      <Box bold mb={1}>
        Description
      </Box>
      <Box mb={2} style={{ whiteSpace: 'pre-wrap' }}>
        {entry.description}
      </Box>
      <Box bold mb={1}>
        Signs to Look For
      </Box>
      <Box mb={2}>
        {entry.signs.map((sign, index) => (
          <Box key={index} mb={1}>
            • {sign}
          </Box>
        ))}
      </Box>
      <Box bold mb={1}>
        Advised Response
      </Box>
      <Box style={{ whiteSpace: 'pre-wrap' }}>{entry.advised_response}</Box>
    </Box>
  );
};

const EndPage = () => {
  return (
    <Box textAlign="center">
      <Box fontSize="16px" bold mt={4} mb={4}>
        End of Handbook
      </Box>
      <Box color="label" mb={4}>
        This concludes the Nanotrasen Incident Awareness & Threat Recognition
        Handbook.
      </Box>
      <Box color="label" mb={4}>
        Remember: A prepared crew is a surviving crew.
      </Box>
      <Box color="label" italic mb={4}>
        For additional information or to report suspected threats, contact your
        local Security department or use emergency communication channels.
      </Box>
      <Box mt={6} color="label" fontSize="12px">
        Document Version 47.3.2
      </Box>
      <Box color="label" fontSize="12px">
        Last Updated: [REDACTED]
      </Box>
      <Box mt={4} color="average" italic fontSize="11px">
        Nanotrasen is not responsible for injury or death resulting from failure
        to follow handbook guidelines.
      </Box>
    </Box>
  );
};
