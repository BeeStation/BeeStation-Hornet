import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon } from '../components';
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
    <Window width={600} height={750} title={handbook_title} theme="document">
      <Window.Content scrollable>
        <Box className="Document__wrapper">
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

          <Box className="Document__page">
            <Box className="Document__content">
              <PageContent
                pageInfo={currentPageInfo}
                threatEntries={threat_entries}
                handbookTitle={handbook_title}
                handbookAuthor={handbook_author}
                goToPage={changePage}
              />
            </Box>
          </Box>

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

          <Button
            className={
              'Document__nav-side Document__nav-side--left' +
              (currentPage === 0 ? ' Document__nav-side--disabled' : '')
            }
            icon="chevron-left"
            disabled={currentPage === 0}
            onClick={() => changePage(currentPage - 1)}
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
            onClick={() => changePage(currentPage + 1)}
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
    <Box className="Document__cover">
      <Box className="Document__cover-seal">
        <Box className="Document__cover-seal-logo">
          <Icon name="tg-nanotrasen-logo" size={6} />
        </Box>
        <Box className="Document__cover-seal-text">NANOTRASEN CORPORATION</Box>
      </Box>

      <Box className="Document__cover-title-block">
        <Box className="Document__cover-title">{handbookTitle}</Box>
        <Box className="Document__cover-author">{handbookAuthor}</Box>
      </Box>

      <Box className="Document__cover-stamps">
        <Box className="Document__cover-stamp Document__cover-stamp--red">
          INTERNAL USE ONLY
        </Box>
        <Box className="Document__cover-stamp Document__cover-stamp--blue">
          APPROVED
        </Box>
      </Box>

      <Box className="Document__cover-info">
        <Box className="Document__cover-info-item">
          <Box className="Document__cover-info-label">Document Class</Box>
          <Box className="Document__cover-info-value">NT-SEC-47C</Box>
        </Box>
        <Box className="Document__cover-info-item">
          <Box className="Document__cover-info-label">Clearance Level</Box>
          <Box className="Document__cover-info-value">General</Box>
        </Box>
        <Box className="Document__cover-info-item">
          <Box className="Document__cover-info-label">Revision</Box>
          <Box className="Document__cover-info-value">2563.7</Box>
        </Box>
      </Box>

      <Box className="Document__cover-notice">
        Failure to familiarize yourself with this material may result in
        disciplinary action, injury, or death.
      </Box>

      <Box className="Document__cover-footer">
        © 2563 Nanotrasen Corporation — All Rights Reserved
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
  const threatStartPage = 3;

  return (
    <Box className="Document__contents">
      <Box className="Document__contents-header">
        <Box className="Document__section-title">Table of Contents</Box>
        <Box className="Document__contents-subtitle">
          Quick Reference Guide to Identified Threats
        </Box>
      </Box>

      <Box className="Document__contents-grid">
        <Box className="Document__contents-column">
          <Box className="Document__contents-section-header">
            <Icon name="book" /> Reference Materials
          </Box>
          <Box className="Document__contents-item" onClick={() => goToPage(2)}>
            <Box className="Document__contents-item-number">I.</Box>
            <Box className="Document__contents-item-text">
              Threat Designation Guide
              <Box className="Document__contents-item-desc">
                Understanding threat classifications
              </Box>
            </Box>
            <Box className="Document__contents-item-page">3</Box>
          </Box>
        </Box>

        <Box className="Document__contents-column">
          <Box className="Document__contents-section-header">
            <Icon name="list" /> Threat Count by Level
          </Box>
          <Box className="Document__contents-stats">
            {THREAT_LEVELS.map((level) => ({
              level,
              count: threatEntries.filter(
                (e) =>
                  e.threat_designation.toLowerCase() === level.toLowerCase(),
              ).length,
            }))
              .filter((item) => item.count > 0)
              .map((item) => (
                <Box key={item.level} className="Document__contents-stat">
                  <Box
                    className={`Document__designation Document__designation--${item.level.toLowerCase()}`}
                  >
                    {item.level}
                  </Box>
                  <Box className="Document__contents-stat-count">
                    {item.count}
                  </Box>
                </Box>
              ))}
          </Box>
        </Box>
      </Box>

      <Box className="Document__contents-threats">
        <Box className="Document__contents-section-header">
          <Icon name="shield" /> Documented Threats
        </Box>
        <Box className="Document__contents-threat-grid">
          {threatEntries.map((entry, index) => (
            <Box
              key={entry.label}
              className="Document__contents-threat-item"
              onClick={() => goToPage(threatStartPage + index)}
            >
              <Box className="Document__contents-threat-icon">
                <Box className="Document__threat-symbol">
                  {getThreatSymbol(entry.threat_designation)}
                </Box>
              </Box>
              <Box className="Document__contents-threat-info">
                <Box className="Document__contents-threat-name">
                  {entry.label}
                </Box>
                <Box
                  className={`Document__designation Document__designation--${entry.threat_designation.toLowerCase()}`}
                >
                  {entry.threat_designation}
                </Box>
              </Box>
              <Box className="Document__contents-threat-page">
                {threatStartPage + index + 1}
              </Box>
            </Box>
          ))}
        </Box>
      </Box>
    </Box>
  );
};

const ThreatDesignationsPage = () => {
  return (
    <Box className="Document__designations">
      <Box className="Document__section-title">Threat Designation Guide</Box>
      <Box className="Document__designations-intro">
        Nanotrasen classifies threats according to the following standardized
        designation system. Understanding these classifications will help you
        respond appropriately to incidents.
      </Box>

      <Box className="Document__designations-grid">
        {DESIGNATIONS.map((d) => (
          <Box
            key={d.level}
            className={`Document__designation-card Document__designation-card--${d.level.toLowerCase()}`}
          >
            <Box className="Document__designation-card-header">
              <Box className="Document__threat-symbol Document__designation-card-symbol">
                {d.symbol}
              </Box>
              <Box
                className={`Document__designation Document__designation--${d.level.toLowerCase()}`}
              >
                {d.level}
              </Box>
            </Box>
            <Box className="Document__designation-card-desc">{d.desc}</Box>
          </Box>
        ))}
      </Box>

      <Box className="Document__designations-note">
        <Icon name="info-circle" /> Threat levels may be upgraded or downgraded
        based on situational assessment by Security personnel.
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

  const designationClass = `Document__designation Document__designation--${entry.threat_designation.toLowerCase()}`;

  return (
    <Box className="Document__threat-entry">
      <Box
        className={`Document__threat-header Document__threat-header--${entry.threat_designation.toLowerCase()}`}
      >
        <Box className="Document__threat-header-icon">
          <Box className="Document__threat-symbol Document__threat-symbol--large">
            {getThreatSymbol(entry.threat_designation)}
          </Box>
        </Box>
        <Box className="Document__threat-header-info">
          <Box className="Document__threat-header-title">{entry.label}</Box>
          <Box className={designationClass}>{entry.threat_designation}</Box>
        </Box>
      </Box>

      <Box className="Document__threat-body">
        <Box className="Document__threat-main">
          <Box className="Document__threat-section">
            <Box className="Document__threat-section-title">
              <Icon name="file-alt" /> Description
            </Box>
            <Box className="Document__threat-section-content">
              {entry.description}
            </Box>
          </Box>

          <Box className="Document__threat-section">
            <Box className="Document__threat-section-title">
              <Icon name="shield-alt" /> Advised Response
            </Box>
            <Box className="Document__threat-section-content">
              {entry.advised_response}
            </Box>
          </Box>
        </Box>

        <Box className="Document__threat-sidebar">
          <Box className="Document__threat-sidebar-section">
            <Box className="Document__threat-sidebar-title">
              <Icon name="search" /> Signs to Look For
            </Box>
            <Box className="Document__threat-signs">
              {entry.signs.map((sign, index) => (
                <Box key={index} className="Document__threat-sign">
                  <Icon
                    name="chevron-right"
                    className="Document__threat-sign-icon"
                  />
                  {sign}
                </Box>
              ))}
            </Box>
          </Box>

          <Box className="Document__threat-sidebar-section">
            <Box className="Document__threat-sidebar-title">
              <Icon name="clipboard-check" /> Quick Reference
            </Box>
            <Box className="Document__threat-quickref">
              <Box className="Document__threat-quickref-item">
                <Box className="Document__threat-quickref-label">Threat</Box>
                <Box className="Document__threat-quickref-value">
                  {entry.label}
                </Box>
              </Box>
              <Box className="Document__threat-quickref-item">
                <Box className="Document__threat-quickref-label">Level</Box>
                <Box className={designationClass}>
                  {entry.threat_designation}
                </Box>
              </Box>
              <Box className="Document__threat-quickref-item">
                <Box className="Document__threat-quickref-label">Signs</Box>
                <Box className="Document__threat-quickref-value">
                  {entry.signs.length} identified
                </Box>
              </Box>
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

const EndPage = () => {
  return (
    <Box className="Document__endpage">
      <Box className="Document__endpage-seal">
        <Icon name="check-circle" size={3} />
      </Box>

      <Box className="Document__endpage-title">End of Handbook</Box>

      <Box className="Document__endpage-divider">
        <Box className="Document__endpage-divider-line" />
        <Icon name="star" />
        <Box className="Document__endpage-divider-line" />
      </Box>

      <Box className="Document__endpage-message">
        This concludes the Nanotrasen Incident Awareness & Threat Recognition
        Handbook.
      </Box>

      <Box className="Document__endpage-quote">
        <Icon name="quote-left" className="Document__endpage-quote-icon" />
        <Box className="Document__endpage-quote-text">
          A prepared crew is a surviving crew.
        </Box>
      </Box>

      <Box className="Document__endpage-contact">
        <Box className="Document__endpage-contact-title">
          <Icon name="headset" /> Need Assistance?
        </Box>
        <Box className="Document__endpage-contact-text">
          For additional information or to report suspected threats, contact
          your local Security department or use emergency communication
          channels.
        </Box>
      </Box>

      <Box className="Document__endpage-footer">
        <Box className="Document__endpage-version">
          Document Version 47.3.2 — Last Updated: [REDACTED]
        </Box>
        <Box className="Document__endpage-disclaimer">
          Nanotrasen is not responsible for injury or death resulting from
          failure to follow handbook guidelines.
        </Box>
      </Box>
    </Box>
  );
};
