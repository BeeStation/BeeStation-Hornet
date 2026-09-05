/**
 * @file
 * @author Original by ArcaneMusic (https://github.com/ArcaneMusic)
 * @author Changes Shadowh4nD/jlsnow301
 * @author Ported by itsmeow
 * @license MIT
 */

import { decodeHtmlEntities } from 'common/string';
import { marked } from 'marked';

import { useBackend, useLocalState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Icon,
  Input,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../components';
import { sanitizeText } from '../sanitize';
import { BountyBoardContent } from './BountyBoard';

const CENSOR_MESSAGE =
  'This channel has been deemed as threatening to \
  the welfare of the station, and marked with a Nanotrasen D-Notice.';
const SYSTEM_CHANNEL_IDS = [1000, 2000];
const WANTED_DANGER_META = {
  'Wanted - Low Threat': {
    icon: 'info-circle',
    marker: '',
    backgroundColor: '#5A4818',
    color: '#FFE7A3',
    borderColor: '#D9B85A',
    buttonColor: 'yellow',
  },
  'Wanted - Caution': {
    icon: 'exclamation-circle',
    marker: '!',
    backgroundColor: '#5A3416',
    color: '#FFD0A6',
    borderColor: '#E39A66',
    buttonColor: 'orange',
  },
  'Armed and Dangerous': {
    icon: 'exclamation-triangle',
    marker: '!!',
    backgroundColor: '#5A2418',
    color: '#FFC1B5',
    borderColor: '#E08472',
    buttonColor: 'red',
  },
  'Lethal Threat': {
    icon: 'skull-crossbones',
    marker: '!!!',
    backgroundColor: '#4A151A',
    color: '#FFB6C0',
    borderColor: '#D86C7D',
    buttonColor: 'red',
  },
  'Explosives Risk': {
    icon: 'bomb',
    marker: '',
    backgroundColor: '#4F4512',
    color: '#FFE88A',
    borderColor: '#FFCC33',
    buttonColor: 'yellow',
  },
};

const getWantedDangerMeta = (level) =>
  WANTED_DANGER_META[level] || WANTED_DANGER_META['Armed and Dangerous'];

const parseWantedCharges = (details = '') => {
  if (!details) {
    return [];
  }
  const knownChargesPrefix = 'Known charges:';
  if (details.startsWith(knownChargesPrefix)) {
    return details
      .slice(knownChargesPrefix.length)
      .split(',')
      .map((charge) => charge.trim())
      .filter(Boolean);
  }
  return details
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
};

export const Newscaster = (props) => {
  const { override_bg } = props;
  const { data } = useBackend();
  const { user } = data;
  const NEWSCASTER_SCREEN = 1;
  const BOUNTYBOARD_SCREEN = 2;
  const [screenmode, setScreenmode] = useLocalState(
    'tab_main',
    NEWSCASTER_SCREEN,
  );
  return (
    <>
      <NewscasterChannelCreation override_bg={override_bg} />
      <NewscasterChannelEditing override_bg={override_bg} />
      <NewscasterCommentCreation override_bg={override_bg} />
      <Stack fill vertical>
        {!user?.admin && !user?.pai && (
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                color="Green"
                selected={screenmode === NEWSCASTER_SCREEN}
                onClick={() => setScreenmode(NEWSCASTER_SCREEN)}
              >
                Newscaster
              </Tabs.Tab>
              <Tabs.Tab
                Color="Blue"
                selected={screenmode === BOUNTYBOARD_SCREEN}
                onClick={() => setScreenmode(BOUNTYBOARD_SCREEN)}
              >
                Bounty Board
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
        )}
        <Stack.Item grow>
          {screenmode === NEWSCASTER_SCREEN && <NewscasterContent />}
          {screenmode === BOUNTYBOARD_SCREEN && <BountyBoardContent />}
        </Stack.Item>
      </Stack>
    </>
  );
};

const NewscasterChannelModal = ({ header, submit_content, override_bg }) => {
  const {
    act,
    data: {
      editor: { channelName, channelDesc, channelLocked },
    },
  } = useBackend();
  const modalStyle = { border: '1px solid #2c4461' };
  return (
    <Modal
      textAlign="center"
      mr={1.5}
      pt={0}
      style={modalStyle}
      backgroundColor={override_bg}
      width="350px"
    >
      <h2>{header}</h2>
      <Stack vertical fill>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box as="label" color="label" htmlFor="create_channel_name">
                Channel Name:{' '}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                id="create_channel_name"
                width="100%"
                maxLength={42}
                onChange={(e, name) =>
                  act('setChannelName', {
                    channeltext: name,
                  })
                }
                value={channelName}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Box as="label" color="label" htmlFor="create_channel_name">
                Channel Privacy:{' '}
              </Box>
            </Stack.Item>
            <Stack.Item grow textAlign="left">
              <Button
                selected={!channelLocked}
                content="Public"
                onClick={() =>
                  act('setChannelLocked', { channellocked: false })
                }
              />
              <Button
                selected={!!channelLocked}
                content="Private"
                onClick={() => act('setChannelLocked', { channellocked: true })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Box as="label" color="label" htmlFor="create_channel_desc">
                Channel Description
              </Box>
            </Stack.Item>
            <Stack.Item grow basis="content">
              <TextArea
                id="create_channel_desc"
                height="150px"
                width="100%"
                maxLength={512}
                onChange={(e, desc) =>
                  act('setChannelDesc', {
                    channeldesc: desc,
                  })
                }
                value={channelDesc}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content={submit_content}
              onClick={() => act('createChannel')}
            />
            <Button
              content="Cancel"
              color="red"
              onClick={() => act('cancelCreation')}
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const NewscasterChannelCreation = (props) => {
  const { override_bg } = props;
  const {
    data: { creating_channel },
  } = useBackend();
  if (!creating_channel) {
    return null;
  }
  return (
    <NewscasterChannelModal
      override_bg={override_bg}
      header="Create Channel"
      submit_content="Submit Channel"
      default_locked
    />
  );
};

const NewscasterChannelEditing = (props) => {
  const { override_bg } = props;
  const {
    data: { creating_channel, editing_channel },
  } = useBackend();
  if (creating_channel || !editing_channel) {
    return null;
  }
  return (
    <NewscasterChannelModal
      override_bg={override_bg}
      header="Edit Channel"
      submit_content="Save Changes"
    />
  );
};

/** The modal menu that contains the prompts to making new comments. */
const NewscasterCommentCreation = (props) => {
  const { override_bg } = props;
  const { act, data } = useBackend();
  const { creating_comment, viewing_message } = data;
  if (!creating_comment) {
    return null;
  }
  return (
    <Modal textAlign="center" backgroundColor={override_bg} mr={1.5}>
      <Stack vertical>
        <Stack.Item>
          <Box pb={1}>
            Enter comment:
            <Button
              content="X"
              color="red"
              position="relative"
              top="20%"
              left="25%"
              onClick={() => act('cancelCreation')}
            />
          </Box>
          <TextArea
            fluid
            height="120px"
            width="240px"
            backgroundColor="black"
            textColor="white"
            maxLength={512}
            onChange={(e, comment) =>
              act('setCommentBody', {
                commenttext: comment,
              })
            }
          >
            Channel Name
          </TextArea>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              content={'Submit Comment'}
              onClick={() =>
                act('createComment', {
                  messageID: viewing_message,
                })
              }
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const NewscasterWantedScreen = () => {
  const { act, data } = useBackend();
  const {
    viewing_wanted,
    editing_wanted,
    photo_data,
    wanted_create_mode,
    wanted = [],
    criminal_name,
    crime_description,
    wanted_danger_level,
    selected_wanted_id,
  } = data;
  const wantedEntries = wanted.filter((entry) => entry.criminal);
  const activeWantedEntry = wantedEntries.find((entry) => entry.active) || wantedEntries[0];
  const selectedWantedEntry =
    wantedEntries.find((entry) => entry.id === selected_wanted_id) || activeWantedEntry;
  const currentWantedDangerLabel = selectedWantedEntry?.danger_level || 'Armed and Dangerous';
  const currentWantedDangerMeta = getWantedDangerMeta(currentWantedDangerLabel);
  const selectedDangerLabel = wanted_danger_level || 'Armed and Dangerous';
  const selectedDangerMeta = getWantedDangerMeta(selectedDangerLabel);
  const selectedEntryCharges = parseWantedCharges(selectedWantedEntry?.crime);
  const editCharges = parseWantedCharges(crime_description);
  if ((!viewing_wanted && !editing_wanted) || (!editing_wanted && !wantedEntries.length)) {
    return null;
  }
  return (
    <Section title="Wanted Board" fill style={{ minHeight: '460px' }}>
      {!editing_wanted ? (
        <Stack fill>
          <Stack.Item basis="32%">
            <Section title="Open Warrants" fill>
              <Box style={{ maxHeight: '360px', overflowY: 'auto' }}>
                {wantedEntries.map((entry) => (
                  <Button
                    key={entry.id}
                    fluid
                    textAlign="left"
                    mb={0.6}
                    selected={selectedWantedEntry?.id === entry.id}
                    onClick={() => act('setWantedTarget', { wantedID: entry.id })}
                  >
                    <Box bold>{entry.criminal}</Box>
                    <Box fontSize={0.9} opacity={0.8}>{entry.danger_level || 'Armed and Dangerous'}</Box>
                  </Button>
                ))}
                {!wantedEntries.length && (
                  <NoticeBox>No wanted cases currently listed.</NoticeBox>
                )}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title={selectedWantedEntry?.criminal || 'Selected Case'}
              fill
              buttons={
                <>
                  {!!wanted_create_mode && (
                    <>
                      <Button
                        content="New Case"
                        icon="plus-square"
                        color="green"
                        onClick={() => act('createWantedCase')}
                      />
                      <Button
                        content="Edit Case"
                        icon="pen"
                        color="orange"
                        disabled={!selectedWantedEntry}
                        onClick={() => act('editWanted')}
                      />
                      <Button
                        content="Clear"
                        icon="times"
                        color="red"
                        disabled={!selectedWantedEntry}
                        onClick={() => act('clearWantedIssue')}
                      />
                    </>
                  )}
                  <Button
                    content="Return"
                    color="red"
                    onClick={() => act('cancelCreation')}
                  />
                </>
              }
            >
              {!!selectedWantedEntry && (
                <>
                  <Box mb={0.5} bold color="red">
                    {selectedWantedEntry.active ? 'Active Wanted Issue' : 'Dismissed Wanted Issue'}
                  </Box>
                  <Box
                    mb={1.3}
                    px={0.5}
                    py={0.25}
                    backgroundColor={currentWantedDangerMeta.backgroundColor}
                    color={currentWantedDangerMeta.color}
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      border: `1px solid ${currentWantedDangerMeta.borderColor}`,
                      borderRadius: '3px',
                    }}
                  >
                    <Icon name={currentWantedDangerMeta.icon} mr={0.35} />
                    {currentWantedDangerMeta.marker
                      ? `${currentWantedDangerLabel} ${currentWantedDangerMeta.marker}`
                      : currentWantedDangerLabel}
                  </Box>
                  <Stack>
                    {!!selectedWantedEntry.image && (
                      <Stack.Item basis="35%">
                        <Box as="img" src={selectedWantedEntry.image} style={{ maxWidth: '100%', maxHeight: '180px' }} />
                      </Stack.Item>
                    )}
                    <Stack.Item grow>
                      <Box>
                        <Box mb={0.4} bold>
                          Charges / Details
                        </Box>
                        <Box
                          p={1}
                          style={{
                            border: '1px solid rgba(255, 255, 255, 0.12)',
                            borderRadius: '4px',
                            background: 'rgba(255, 255, 255, 0.03)',
                          }}
                        >
                          {selectedEntryCharges.length ? (
                            selectedEntryCharges.map((charge, index) => (
                              <Box key={`${selectedWantedEntry?.id || 'wanted'}-charge-${index}`}>
                                - {charge}
                              </Box>
                            ))
                          ) : (
                            <Box italic style={{ whiteSpace: 'normal', wordBreak: 'break-word' }}>
                              {selectedWantedEntry.crime}
                            </Box>
                          )}
                        </Box>
                      </Box>
                    </Stack.Item>
                  </Stack>
                  <Box mt={0.6} italic>
                    Posted by {selectedWantedEntry.author ? selectedWantedEntry.author : 'N/A'}
                  </Box>
                </>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      ) : null}
      {!wanted_create_mode && editing_wanted ? (
        <NoticeBox>
          Security record access is required to create or edit wanted cases.
        </NoticeBox>
      ) : null}
      {wanted_create_mode && editing_wanted ? (
        <Section title="Edit Wanted Case" fill>
          <LabeledList>
            <LabeledList.Item label="Criminal Name">
              <Button
                content={criminal_name ? criminal_name : ' N/A'}
                disabled={!wanted_create_mode}
                icon="pen"
                onClick={() => act('setCriminalName')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Charge Entries">
              <Button
                content={
                  editCharges.length
                    ? `${editCharges.length} charge${editCharges.length === 1 ? '' : 's'} configured`
                    : 'Add charge entries'
                }
                nowrap={false}
                disabled={!wanted_create_mode}
                icon="pen"
                onClick={() => act('setCrimeData')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Danger Level">
              <Button
                content={
                  selectedDangerMeta.marker
                    ? `${selectedDangerLabel} ${selectedDangerMeta.marker}`
                    : selectedDangerLabel
                }
                disabled={!wanted_create_mode}
                icon={selectedDangerMeta.icon}
                color={selectedDangerMeta.buttonColor}
                onClick={() => act('setDangerLevel')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Box mt={1} mb={1}>
            <Button
              icon="camera"
              selected={photo_data}
              disabled={!wanted_create_mode}
              content={photo_data ? 'Remove Photo' : 'Scan Photo'}
              onClick={() => act('togglePhoto')}
            />
            <Button
              icon="id-badge"
              disabled={!wanted_create_mode}
              color={photo_data ? 'green' : undefined}
              content={photo_data ? 'Import From Security Records (Photo Loaded)' : 'Import From Security Records'}
              onClick={() => act('importWantedRecord')}
            />
          </Box>
          <Box>
            <Button
              content="Submit"
              disabled={!wanted_create_mode}
              color="green"
              icon="volume-up"
              onClick={() => act('submitWantedIssue')}
            />
            <Button
              content="Cancel"
              disabled={!wanted_create_mode}
              icon="times"
              color="red"
              onClick={() => act('cancelCreation')}
            />
          </Box>
        </Section>
      ) : null}
    </Section>
  );
};

export const UserDetails = ({ sourceRole = null }) => {
  const { data } = useBackend();
  const { user } = data;

  if (!user.authenticated) {
    return (
      <NoticeBox>No ID detected! Contact the Head of Personnel.</NoticeBox>
    );
  }
  return (
    <Box
      color="label"
      fontSize={0.95}
      opacity={0.85}
      textAlign="right"
      style={{ maxWidth: '290px' }}
    >
      <Box style={{ whiteSpace: 'normal', wordBreak: 'break-word', overflowWrap: 'anywhere' }}>
        <Icon name="id-card" mr={0.5} />
        {user.name}
      </Box>
      <Box fontSize={0.9} opacity={0.85} style={{ whiteSpace: 'normal', wordBreak: 'break-word', overflowWrap: 'anywhere' }}>
        {user.job}
        {!!sourceRole && ` - ${sourceRole}`}
      </Box>
    </Box>
  );
};

const NewscasterContent = (_) => {
  const { act, data } = useBackend();
  const {
    channels = [],
    channelName,
    channelDesc,
    channelCensored,
    messages = [],
    viewing_channel,
    viewing_wanted,
    wanted = [],
    pinnedArticle,
    user,
    wanted_create_mode,
  } = data;
  const [feedSearch, setFeedSearch] = useLocalState('feed_search', '');
  const [selectedMessageId, setSelectedMessageId] = useLocalState(
    'selected_message',
    null,
  );

  const wantedCount = wanted.filter((entry) => entry.criminal).length;
  const activeWantedCount = wanted.filter((entry) => entry.active && entry.criminal).length;
  const showWantedTab = wantedCount > 0;
  const pinnedMessage =
    pinnedArticle?.ID
      ? messages.find((message) => message.ID === pinnedArticle.ID)
      : null;
  const visibleMessages = messages.filter((message) => {
    const query = feedSearch.trim().toLowerCase();
    if (!query) {
      return true;
    }
    return (
      (message.headline || '').toLowerCase().includes(query) ||
      (message.auth || '').toLowerCase().includes(query) ||
      (message.body || '').toLowerCase().includes(query)
    );
  });
  const feedListMessages = pinnedMessage
    ? [
      pinnedMessage,
      ...visibleMessages.filter((message) => message.ID !== pinnedMessage.ID),
    ]
    : visibleMessages;
  const selectedMessage =
    feedListMessages.find((message) => message.ID === selectedMessageId) ||
    feedListMessages[feedListMessages.length - 1];
  const hasSelectedChannel = !!viewing_channel;
  const isSystemChannelView = SYSTEM_CHANNEL_IDS.includes(viewing_channel);

  return (
    <>
      <Section
        title="News Sources"
        buttons={(
          <>
            <Button
              icon="plus-square"
              content="Create Channel"
              color="green"
              onClick={() => act('startCreateChannel')}
            />
            <Button
              icon="list"
              content="Choose Source"
              disabled={!viewing_wanted && !hasSelectedChannel}
              onClick={() => act('returnToSourceSelect')}
            />
            <Button
              icon="skull-crossbones"
              color={activeWantedCount ? 'red' : (wanted_create_mode ? 'orange' : undefined)}
              content={activeWantedCount ? `Wanted (${activeWantedCount})` : (wantedCount ? 'Wanted' : 'Create Wanted')}
              disabled={!wanted_create_mode && !wantedCount}
              tooltip={!wanted_create_mode && !wantedCount ? 'Security records access required to create a wanted case.' : null}
              onClick={() => act(wantedCount ? 'showWanted' : 'createWantedCase')}
            />
          </>
        )}
      >
        <Tabs fluid>
          {channels.map((channel) => (
            <Tabs.Tab
              key={channel.ID}
              selected={!viewing_wanted && viewing_channel === channel.ID}
              icon={channel.censored ? 'ban' : undefined}
              color={channel.censored ? 'red' : undefined}
              onClick={() => act('setChannel', { channel: channel.ID })}
            >
              {channel.name}
            </Tabs.Tab>
          ))}
          {showWantedTab && (
            <Tabs.Tab
              selected={!!viewing_wanted}
              icon="skull-crossbones"
              color={activeWantedCount ? 'red' : undefined}
              onClick={() => act('showWanted')}
            >
              {activeWantedCount ? `Wanted (${activeWantedCount})` : 'Wanted'}
            </Tabs.Tab>
          )}
        </Tabs>
      </Section>

      {!!viewing_wanted && <NewscasterWantedScreen />}

      {!viewing_wanted && !hasSelectedChannel ? (
        <NewscasterChannelPicker
          channels={channels}
          showWanted={showWantedTab}
          activeWantedCount={activeWantedCount}
        />
      ) : !viewing_wanted && isSystemChannelView ? (
        <>
          <Section title="Channel Description">
            <Box color="#d5dee8" fontSize={0.95} opacity={0.92}>
              {decodeHtmlEntities(channelDesc || 'Station-wide automated broadcast feed.')}
            </Box>
          </Section>
          <NewscasterSystemChannelView
            channelCensored={channelCensored}
            messages={messages}
          />
        </>
      ) : !viewing_wanted ? (
        <>
          <Stack>
            <Stack.Item basis="30%" grow>
              <Section title="Article List" fill>
                <Input
                  fluid
                  placeholder="Filter headlines/articles..."
                  value={feedSearch}
                  onInput={(e, value) => setFeedSearch(value)}
                  mb={1}
                />
                <Box style={{ overflowY: 'auto', maxHeight: '160px' }}>
                {channelCensored ? (
                  <NoticeBox danger>
                    <b>ATTENTION:</b> {CENSOR_MESSAGE}
                  </NoticeBox>
                ) : !feedListMessages.length ? (
                  <NoticeBox>No Listed Articles.</NoticeBox>
                ) : (
                  feedListMessages.map((message) => {
                    const isPinned = pinnedMessage?.ID === message.ID;
                    return (
                      <Button
                        key={message.ID}
                        fluid
                        textAlign="left"
                        nowrap={false}
                        mb={0.5}
                        color={isPinned ? 'yellow' : undefined}
                        style={isPinned ? { borderLeft: '3px solid #f1c40f' } : undefined}
                        selected={selectedMessage?.ID === message.ID}
                        onClick={() => setSelectedMessageId(message.ID)}
                      >
                        <Box
                          bold
                          style={{
                            whiteSpace: 'normal',
                            wordBreak: 'break-word',
                            lineHeight: 1.25,
                          }}
                        >
                          {isPinned && (
                            <>
                              <Icon name="thumbtack" color="yellow" mr={0.5} />
                              <Box as="span" color="yellow">PINNED: </Box>
                            </>
                          )}
                          {message.headline || 'Untitled Article'}
                        </Box>
                        <Box fontSize={0.95} opacity={0.85}>
                          {message.censored_author ? '[REDACTED]' : message.auth} at {message.time}
                        </Box>
                      </Button>
                    );
                  })
                )}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item basis="70%" grow>
              <Stack fill vertical>
                <Stack.Item grow basis="content">
                  <NewscasterChannelBox />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>

          <NewscasterArticleView selectedMessage={selectedMessage} />
        </>
      ) : null}
    </>
  );
};

const NewscasterChannelPicker = ({ channels = [], showWanted = false, activeWantedCount = 0 }) => {
  const { act } = useBackend();
  return (
    <Box p={3}>
      <Box width="100%" style={{ maxWidth: '520px' }}>
        <Box style={{ maxHeight: '430px', overflowY: 'auto', paddingRight: '4px' }}>
          {showWanted && (
            <Button
              fluid
              mb={1}
              px={2}
              py={1}
              nowrap={false}
              textAlign="left"
              fontSize={1.15}
              color={activeWantedCount ? 'red' : undefined}
              style={{ height: 'auto' }}
              onClick={() => act('showWanted')}
            >
              <Box style={{ width: '100%' }}>
                <Box bold>
                  {activeWantedCount ? `Wanted (${activeWantedCount})` : 'Wanted'}
                </Box>
                <Box
                  fontSize={0.85}
                  opacity={0.75}
                  mt={0.2}
                  style={{
                    whiteSpace: 'normal',
                    wordBreak: 'break-word',
                    overflowWrap: 'anywhere',
                    lineHeight: 1.25,
                  }}
                >
                  View active criminal alerts and case details.
                </Box>
              </Box>
            </Button>
          )}
          {channels.map((channel) => (
            <Button
              key={channel.ID}
              fluid
              mb={1}
              px={2}
              py={1}
              nowrap={false}
              textAlign="left"
              fontSize={1.15}
              color={channel.censored ? 'red' : undefined}
              style={{ height: 'auto' }}
              onClick={() => act('setChannel', { channel: channel.ID })}
            >
              <Box style={{ width: '100%' }}>
                <Box bold style={{ whiteSpace: 'normal', wordBreak: 'break-word' }}>
                  {channel.name}
                </Box>
                  {!!channel.desc && (
                  <Box
                    fontSize={0.85}
                    opacity={0.75}
                    mt={0.2}
                    style={{
                      whiteSpace: 'normal',
                      wordBreak: 'break-word',
                      overflowWrap: 'anywhere',
                      lineHeight: 1.25,
                    }}
                  >
                      {channel.desc}
                  </Box>
                )}
              </Box>
            </Button>
          ))}
          {!channels.length && (
            <Box textAlign="center" color="#a8c3dd" mt={2}>
              No news sources available. Create one to get started.
            </Box>
          )}
        </Box>
      </Box>
    </Box>
  );
};

const NewscasterSystemChannelView = ({ channelCensored, messages = [] }) => {
  const streamMessages = [...messages].reverse();
  return (
    <Section fill title="Broadcast Stream" style={{ minHeight: '360px' }}>
      {channelCensored ? (
        <NoticeBox danger>
          <b>ATTENTION:</b> {CENSOR_MESSAGE}
        </NoticeBox>
      ) : !streamMessages.length ? (
        <NoticeBox>
          No current broadcasts are available on this network.
        </NoticeBox>
      ) : (
        streamMessages.map((message) => {
          const messagePhotos =
            message?.photos?.length
              ? message.photos
              : (message?.photo ? [message.photo] : []);
          const announcementHeader =
            message.censored_author
              ? `[REDACTED] at ${message.time}`
              : `${message.auth} at ${message.time}`;
          return (
            <Box
              key={message.ID}
              mb={1}
              p={1}
              style={{
                border: '1px solid rgba(255, 255, 255, 0.14)',
                borderRadius: '4px',
                background: 'rgba(255, 255, 255, 0.03)',
              }}
            >
              <Box mb={0.6} bold fontSize={1.1}>
                {announcementHeader}
              </Box>
              {message.censored_message ? (
                <NoticeBox danger>
                  This message was deemed dangerous to the general welfare of the
                  station and marked with a <b>D-Notice</b>.
                </NoticeBox>
              ) : (
                <>
                  {!!messagePhotos.length && (
                    <Box mb={0.5}>
                      {messagePhotos.map((photoSrc, index) => (
                        <Box
                          key={`${message.ID}-photo-${index}`}
                          as="img"
                          src={photoSrc}
                          mr={0.5}
                          mb={0.5}
                          style={{ maxWidth: '200px', maxHeight: '140px' }}
                        />
                      ))}
                    </Box>
                  )}
                  <Box dangerouslySetInnerHTML={processedText(message.body)} />
                </>
              )}
            </Box>
          );
        })
      )}
    </Section>
  );
};

/** The Channel Box is the basic channel information where buttons live.*/
const NewscasterChannelBox = (_) => {
  const { act, data } = useBackend();
  const {
    channelName,
    channelDesc,
    channelLocked,
    channelAuthor,
    channelAllowedPosters = [],
    channelCensored,
    viewing_channel,
    security_mode,
    command_mode,
    photo_count = 0,
    paper,
    user,
  } = data;
  const [showManagePanel, setShowManagePanel] = useLocalState(
    'channel_management_expanded',
    false,
  );
  const [showFullDesc, setShowFullDesc] = useLocalState(
    'channel_desc_expanded',
    false,
  );
  const isOwner = !user.silicon && user.name === channelAuthor;
  const canPost =
    !channelCensored &&
    (!channelLocked || isOwner || channelAllowedPosters.includes(user.name));
  const showingManage = isOwner && showManagePanel;
  const channelDescText = decodeHtmlEntities(channelDesc || 'No channel description set.');
  const canExpandDesc = channelDescText.length > 180;
  const isSystemChannel = channelName === 'Station Announcements' || channelName === 'AuriNet WeatherCast';
  const sourceRole = isOwner ? 'Owner' : (channelAllowedPosters.includes(user.name) ? 'Author' : null);
  return (
    <Section fill title="Channel Details">
      <Stack fill vertical>
        <Stack.Item>
          <Stack justify="space-between" align="center">
            <Stack.Item grow>
              <Stack>
                <Stack.Item>
                  <Box
                    as="span"
                    px={0.5}
                    py={0.25}
                    mr={0.5}
                    backgroundColor={channelLocked ? '#4a1e1e' : '#173f2a'}
                    color={channelLocked ? '#ffb8b8' : '#9ef2c2'}
                    style={{ border: '1px solid rgba(255,255,255,0.12)', borderRadius: '3px' }}
                  >
                    <Icon name={channelLocked ? 'lock' : 'globe'} mr={0.25} />
                    {channelLocked ? 'Private' : 'Public'}
                  </Box>
                  {!isSystemChannel && (
                    <Box
                      as="span"
                      px={0.5}
                      py={0.25}
                      mr={0.5}
                      backgroundColor="#1d2b44"
                      color="#b8d5ff"
                      style={{
                        display: 'inline-block',
                        maxWidth: '360px',
                        whiteSpace: 'normal',
                        wordBreak: 'break-word',
                        overflowWrap: 'anywhere',
                        border: '1px solid rgba(255,255,255,0.12)',
                        borderRadius: '3px',
                      }}
                    >
                      Owner: {channelAuthor}
                    </Box>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <UserDetails sourceRole={sourceRole} />
                </Stack.Item>
                {!!isOwner && (
                  <Stack.Item>
                    <Button
                      icon={showingManage ? 'chevron-up' : 'wrench'}
                      content={showingManage ? 'Close Manage' : 'Manage Channel'}
                      selected={showingManage}
                      onClick={() => setShowManagePanel(!showManagePanel)}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow basis="content" mt={0.5}>
          {channelCensored ? (
            <Section>
              <BlockQuote color="red">
                <b>ATTENTION:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>
          ) : (
            <Box
              p={1}
              backgroundColor="rgba(255,255,255,0.03)"
              style={{ border: '1px solid rgba(255,255,255,0.08)', borderRadius: '4px' }}
            >
              <Box color="#d5dee8" fontSize={0.9} opacity={0.88} mb={0.45}>
                Channel Description
              </Box>
              <Box
                color="#dbe4ee"
                opacity={0.95}
                style={
                  showFullDesc || !canExpandDesc
                    ? { whiteSpace: 'normal', wordBreak: 'break-word', lineHeight: 1.3 }
                    : {
                      whiteSpace: 'normal',
                      wordBreak: 'break-word',
                      lineHeight: 1.3,
                      display: '-webkit-box',
                      WebkitLineClamp: 3,
                      WebkitBoxOrient: 'vertical',
                      overflow: 'hidden',
                    }
                }
              >
                {channelDescText}
              </Box>
              {canExpandDesc && (
                <Button
                  mt={0.5}
                  icon={showFullDesc ? 'angle-up' : 'angle-down'}
                  content={showFullDesc ? 'Show less' : 'Show more'}
                  onClick={() => setShowFullDesc(!showFullDesc)}
                />
              )}
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              content="Submit Story"
              disabled={!canPost}
              tooltip={
                channelLocked && !isOwner && !channelAllowedPosters.includes(user.name)
                  ? 'This channel is private. Ask owner to add you as poster.'
                  : channelCensored
                    ? 'Channel is censored.'
                    : null
              }
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1}
            />
            <Button
              icon="camera"
              color={photo_count > 0 ? 'green' : undefined}
              content={
                photo_count > 0
                  ? `Photo (${photo_count}/3)`
                  : 'Add Photo'
              }
              disabled={!canPost}
              onClick={() => act('togglePhoto')}
            />
            {photo_count > 0 && (
              <Button
                icon="times"
                color="red"
                content="Clear Photos"
                onClick={() => act('clearPhotos')}
              />
            )}
            <Button
              icon="newspaper"
              content="Print Newspaper"
              disabled={user.silicon || paper <= 0}
              tooltip={paper <= 0 ? 'Please insert paper.' : null}
              onClick={() => act('printNewspaper')}
            />
            {!!command_mode && (
              <Button
                icon="ban"
                content={channelCensored ? 'Remove D-Notice' : 'D-Notice'}
                color="red"
                tooltip="Censor the whole channel and mark its \
                  contents as dangerous to the station."
                disabled={!command_mode || !viewing_channel}
                onClick={() =>
                  act('channelDNotice', {
                    secure: command_mode,
                    channel: viewing_channel,
                  })
                }
              />
            )}
          </Box>
        </Stack.Item>
        {!!showingManage && (
          <Stack.Item>
            <Section title="Owner Management">
              <Box mb={1} color="label">
                Privacy: <b>{channelLocked ? 'Private' : 'Public'}</b>
                {channelLocked
                  ? ' (owner and allowed crew can post)'
                  : ' (anyone can post)'}
              </Box>
              <Box>
                <Button
                  icon="pen"
                  content="Rename Channel"
                  onClick={() => act('manageSetChannelName')}
                />
                <Button
                  icon="align-left"
                  content="Edit Description"
                  onClick={() => act('manageSetChannelDesc')}
                />
                <Button
                  icon={channelLocked ? 'unlock' : 'lock'}
                  content={channelLocked ? 'Set Public' : 'Set Private'}
                  onClick={() => act('manageToggleChannelPrivacy')}
                />
                <Button
                  icon="thumbtack"
                  content="Set Pinned Article"
                  onClick={() => act('manageSetPinnedArticle')}
                />
              </Box>
              <Divider />
              <Box mb={1} color="label">Allowed Private Posters</Box>
              <Box mb={1}>
                <Button
                  icon="user-plus"
                  content="Add From Manifest"
                  onClick={() => act('manageAddAllowedPoster')}
                />
                <Button
                  icon="user-minus"
                  content="Remove Selected"
                  disabled={!channelAllowedPosters.length}
                  onClick={() => act('manageRemoveAllowedPoster')}
                />
              </Box>
              {channelAllowedPosters.length ? (
                <Box>
                  {channelAllowedPosters.map((name) => (
                    <BlockQuote key={name}>{name}</BlockQuote>
                  ))}
                </Box>
              ) : (
                <NoticeBox>No additional posters configured.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const processedText = (value) => {
  const textHtml = {
    __html: sanitizeText(
      marked(value, {
        breaks: true,
        smartypants: true,
        smartLists: true,
        baseUrl: 'thisshouldbreakhttp',
      }),
    ),
  };
  return textHtml;
};

const NewscasterArticleView = ({ selectedMessage }) => {
  const { act, data } = useBackend();
  const {
    security_mode,
    channelCensored,
    channelLocked,
    channelAuthor,
    user,
  } = data;
  const messagePhotos =
    selectedMessage?.photos?.length
      ? selectedMessage.photos
      : (selectedMessage?.photo ? [selectedMessage.photo] : []);

  if (channelCensored) {
    return (
      <Section color="red" fill>
        <b>ATTENTION:</b> Comments cannot be read at this time.
        <br />
        Thank you for your understanding, and have a secure day.
      </Section>
    );
  }
  if (!selectedMessage) {
    return <NoticeBox>Select an article from the feed list.</NoticeBox>;
  }

  return (
    <Section
      fill
      title="Selected Article"
      style={{ minHeight: '360px' }}
      buttons={
        <>
          {!!security_mode && (
            <Button
              icon="comment-slash"
              tooltip="Censor Story"
              onClick={() =>
                act('storyCensor', {
                  messageID: selectedMessage.ID,
                })
              }
            />
          )}
          {!!security_mode && (
            <Button
              icon="user-slash"
              tooltip="Censor Author"
              onClick={() =>
                act('authorCensor', {
                  messageID: selectedMessage.ID,
                })
              }
            />
          )}
          <Button
            icon="comment"
            tooltip="Leave a Comment"
            disabled={
              selectedMessage.censored_author ||
              selectedMessage.censored_message ||
              !user?.authenticated ||
              (!!channelLocked && channelAuthor !== user?.name && !user?.admin)
            }
            onClick={() =>
              act('startComment', {
                messageID: selectedMessage.ID,
              })
            }
          />
        </>
      }
    >
      <Box
        mb={1}
        bold
        fontSize={1.2}
        textAlign="center"
        style={{ whiteSpace: 'normal', wordBreak: 'break-word', lineHeight: 1.25 }}
      >
        {selectedMessage.headline || 'Untitled Article'}
      </Box>
      <Divider />
      <Box my={1} italic textAlign="center">
        {selectedMessage.censored_author
          ? 'By: [REDACTED] (D-Notice)'
          : `By: ${selectedMessage.auth} at ${selectedMessage.time}`}
      </Box>
      {selectedMessage.censored_message ? (
        <NoticeBox danger>
          This message was deemed dangerous to the general welfare of the
          station and therefore marked with a <b>D-Notice</b>.
        </NoticeBox>
      ) : (
        <>
          {messagePhotos.length ? (
            <Stack align="flex-start">
              <Stack.Item basis="38%">
                {messagePhotos.map((photoSrc, index) => (
                  <Box
                    key={`photo-frame-${index}`}
                    mb={0.75}
                    p={0.35}
                    backgroundColor="rgba(255,255,255,0.04)"
                    style={{ border: '1px solid rgba(255,255,255,0.14)', borderRadius: '4px' }}
                  >
                    <Box
                      as="img"
                      src={photoSrc}
                      style={{ maxWidth: '100%', maxHeight: '260px', display: 'block' }}
                    />
                  </Box>
                ))}
              </Stack.Item>
              <Stack.Item grow>
                <Section>
                  <Box dangerouslySetInnerHTML={processedText(selectedMessage.body)} />
                </Section>
              </Stack.Item>
            </Stack>
          ) : (
            <Section>
              <Box dangerouslySetInnerHTML={processedText(selectedMessage.body)} />
            </Section>
          )}
          {selectedMessage.photo_caption && (
            <Section
              dangerouslySetInnerHTML={processedText(
                selectedMessage.photo_caption,
              )}
            />
          )}
        </>
      )}
      {!!selectedMessage.comments?.length && (
        <Section title="Comments">
          {selectedMessage.comments.map((comment) => (
            <BlockQuote key={`${comment.time}-${comment.auth}`}>
              <Box italic textColor="white">
                By: {comment.auth} at {comment.time}
              </Box>
              <Section>
                <Box dangerouslySetInnerHTML={processedText(comment.body)} />
              </Section>
            </BlockQuote>
          ))}
        </Section>
      )}
      <Divider />
    </Section>
  );
};
