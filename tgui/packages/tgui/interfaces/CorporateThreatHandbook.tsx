import { useBackend, useLocalState } from '../backend';
import { Box, Button } from '../components';
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

  // Get the title for the current page
  const getPageTitle = (pageInfo: PageInfo): string => {
    switch (pageInfo.type) {
      case PageType.Cover:
        return 'Cover';
      case PageType.Contents:
        return 'Table of Contents';
      case PageType.ThreatDesignations:
        return 'Threat Designations';
      case PageType.ThreatEntry:
        return threat_entries[pageInfo.threatIndex as number]?.label || 'Entry';
      case PageType.EndPage:
        return 'End of Handbook';
      default:
        return '';
    }
  };

  return (
    <Window width={550} height={700} title={handbook_title} theme="document">
      <Window.Content scrollable>
        <Box className="Document__wrapper">
          {/* Fixed Document Header */}
          <Box className="Document__header">
            <Box className="Document__header-left">
              Nanotrasen Publications Division
            </Box>
            <Box className="Document__header-center">
              Security Clearance: General
            </Box>
            <Box className="Document__header-right">
              {getPageTitle(currentPageInfo)} — Page {currentPage + 1}/
              {totalPages}
            </Box>
          </Box>

          {/* Main Content Area */}
          <Box className="Document__page">
            <Box className="Document__content">
              <PageContent
                pageInfo={currentPageInfo}
                threatEntries={threat_entries}
                handbookTitle={handbook_title}
                handbookAuthor={handbook_author}
                goToPage={goToPage}
              />
            </Box>
          </Box>

          {/* Fixed Document Footer */}
          <Box className="Document__doc-footer">
            <Box className="Document__doc-footer-left">
              NT Form 47-C Rev. 2563
            </Box>
            <Box className="Document__doc-footer-center">
              INTERNAL USE ONLY — DO NOT DISTRIBUTE
            </Box>
            <Box className="Document__doc-footer-right">
              Printed: [REDACTED]
            </Box>
          </Box>

          {/* OOC Navigation - Floating side buttons */}
          <Button
            className={
              'Document__nav-side Document__nav-side--left' +
              (currentPage === 0 ? ' Document__nav-side--disabled' : '')
            }
            icon="chevron-left"
            disabled={currentPage === 0}
            onClick={goToPrevPage}
          />
          <Button
            className={
              'Document__nav-side Document__nav-side--right' +
              (currentPage === totalPages - 1
                ? ' Document__nav-side--disabled'
                : '')
            }
            icon="chevron-right"
            disabled={currentPage === totalPages - 1}
            onClick={goToNextPage}
          />
        </Box>
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
      <Box className="Document__title" mt={4}>
        {handbookTitle}
      </Box>
      <Box className="Document__subtitle">{handbookAuthor}</Box>
      <hr className="Document__divider" />
      <Box className="Document__stamp" mt={2} mb={2}>
        FOR INTERNAL DISTRIBUTION ONLY
      </Box>
      <hr className="Document__divider" />
      <Box mt={4} className="Document__notice">
        This handbook has been prepared by the Nanotrasen Security Division to
        brief all crew members on potential threats they may encounter during
        their shift.
      </Box>
      <Box mt={3} className="Document__notice" italic>
        Failure to familiarize yourself with this material may result in
        disciplinary action, injury, or death.
      </Box>
      <Box className="Document__footer" mt={6}>
        © 2563 Nanotrasen Corporation
        <br />
        All Rights Reserved
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
      <Box className="Document__section-title">Table of Contents</Box>
      <Box className="Document__index-section">Reference Materials</Box>
      <Box
        className="Document__index-link"
        onClick={() => goToPage(2)}
        style={{ cursor: 'pointer' }}
      >
        I. Threat Designation Guide
      </Box>
      <Box className="Document__index-section" mt={2}>
        Threat Entries
      </Box>
      {threatEntries.map((entry, index) => (
        <Box
          key={entry.label}
          className="Document__index-link"
          onClick={() => goToPage(threatStartPage + index)}
          style={{ cursor: 'pointer' }}
        >
          {index + 1}. {entry.label}{' '}
          <Box
            as="span"
            className={
              'Document__designation Document__designation--' +
              entry.threat_designation.toLowerCase()
            }
          >
            [{entry.threat_designation}]
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const ThreatDesignationsPage = () => {
  return (
    <Box>
      <Box className="Document__section-title">Threat Designation Guide</Box>
      <Box mb={2}>
        Nanotrasen classifies threats according to the following standardized
        designation system. Understanding these classifications will help you
        respond appropriately to incidents.
      </Box>
      <hr className="Document__divider" />
      <Box mb={2}>
        <Box className="Document__designation Document__designation--negligible">
          Negligible
        </Box>
        <Box ml={2} mt={1}>
          Minimal risk to crew or station operations. Standard operating
          procedures are sufficient.
        </Box>
      </Box>
      <Box mb={2}>
        <Box className="Document__designation Document__designation--minor">
          Minor
        </Box>
        <Box ml={2} mt={1}>
          Low risk. May require security attention but poses no significant
          threat to station integrity.
        </Box>
      </Box>
      <Box mb={2}>
        <Box className="Document__designation Document__designation--moderate">
          Moderate
        </Box>
        <Box ml={2} mt={1}>
          Notable risk to crew safety. Security response recommended.
          Coordination with department heads advised.
        </Box>
      </Box>
      <Box mb={2}>
        <Box className="Document__designation Document__designation--major">
          Major
        </Box>
        <Box ml={2} mt={1}>
          Significant threat to multiple crew members or critical systems. Full
          security mobilization required.
        </Box>
      </Box>
      <Box mb={2}>
        <Box className="Document__designation Document__designation--severe">
          Severe
        </Box>
        <Box ml={2} mt={1}>
          Extreme danger to station survival. All crew should be on high alert.
          Command-level response necessary.
        </Box>
      </Box>
      <Box mb={2}>
        <Box className="Document__designation Document__designation--critical">
          Critical
        </Box>
        <Box ml={2} mt={1}>
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

  const designationClass =
    'Document__designation Document__designation--' +
    entry.threat_designation.toLowerCase();

  return (
    <Box>
      <Box className="Document__title" style={{ fontSize: '20px' }}>
        {entry.label}
      </Box>
      <Box textAlign="center" mb={2}>
        <Box as="span" color="label">
          Threat Designation:{' '}
        </Box>
        <Box as="span" className={designationClass}>
          {entry.threat_designation}
        </Box>
      </Box>
      <hr className="Document__divider" />
      <Box className="Document__section-title" style={{ fontSize: '14px' }}>
        Description
      </Box>
      <Box mb={2} style={{ whiteSpace: 'pre-wrap' }}>
        {entry.description}
      </Box>
      <Box className="Document__section-title" style={{ fontSize: '14px' }}>
        Signs to Look For
      </Box>
      <Box mb={2} ml={2}>
        {entry.signs.map((sign, index) => (
          <Box key={index} className="Document__bullet">
            {sign}
          </Box>
        ))}
      </Box>
      <Box className="Document__section-title" style={{ fontSize: '14px' }}>
        Advised Response
      </Box>
      <Box style={{ whiteSpace: 'pre-wrap' }}>{entry.advised_response}</Box>
    </Box>
  );
};

const EndPage = () => {
  return (
    <Box textAlign="center">
      <Box className="Document__title" mt={4}>
        End of Handbook
      </Box>
      <hr className="Document__divider" />
      <Box className="Document__notice" mb={3}>
        This concludes the Nanotrasen Incident Awareness & Threat Recognition
        Handbook.
      </Box>
      <Box bold mb={3}>
        Remember: A prepared crew is a surviving crew.
      </Box>
      <Box className="Document__notice" mb={3}>
        For additional information or to report suspected threats, contact your
        local Security department or use emergency communication channels.
      </Box>
      <hr className="Document__divider" />
      <Box className="Document__footer">
        Document Version 47.3.2
        <br />
        Last Updated: [REDACTED]
      </Box>
      <Box mt={3} className="Document__stamp" style={{ fontSize: '10px' }}>
        Nanotrasen is not responsible for injury or death resulting from failure
        to follow handbook guidelines.
      </Box>
    </Box>
  );
};
