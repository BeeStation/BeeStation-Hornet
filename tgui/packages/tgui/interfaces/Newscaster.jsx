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
      <NewscasterWantedScreen override_bg={override_bg} />
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

const NewscasterWantedScreen = (props) => {
  const { override_bg } = props;
  const { act, data } = useBackend();
  const {
    viewing_wanted,
    editing_wanted,
    photo_data,
    security_mode,
    wanted = [],
    criminal_name,
    crime_description,
  } = data;
  if (!viewing_wanted && !editing_wanted) {
    return null;
  }
  return (
    <Modal textAlign="center" backgroundColor={override_bg} mr={1.5} width={25}>
      {!editing_wanted
        ? wanted
            .filter((wanted) => wanted.criminal)
            .map((activeWanted) => (
              <>
                <Stack vertical>
                  <Stack.Item>
                    <Box bold color="red" mb={1}>
                      {activeWanted.active
                        ? 'Active Wanted Issue'
                        : 'Dismissed Wanted Issue'}
                    </Box>
                    <Section>
                      {activeWanted.has_image ? (
                        <Box as="img" src={activeWanted.image} />
                      ) : null}
                      <Box bold>{activeWanted.criminal}</Box>
                      <Box italic>{activeWanted.crime}</Box>
                    </Section>
                    <Box italic>
                      Posted by{' '}
                      {activeWanted.author ? activeWanted.author : 'N/A'}
                    </Box>
                  </Stack.Item>
                </Stack>
                <Divider />
                <Button
                  content="Close"
                  color="red"
                  onClick={() => act('cancelCreation')}
                />
              </>
            ))
        : null}
      {security_mode && editing_wanted ? (
        <>
          <LabeledList>
            <LabeledList.Item label="Criminal Name">
              <Button
                content={criminal_name ? criminal_name : ' N/A'}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCriminalName')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Criminal Activity">
              <Button
                content={crime_description ? crime_description : ' N/A'}
                nowrap={false}
                disabled={!security_mode}
                icon="pen"
                onClick={() => act('setCrimeData')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Button
            mt={1}
            mb={1}
            icon="camera"
            selected={photo_data}
            disabled={!security_mode}
            content={photo_data ? 'Remove Photo' : 'Scan Photo'}
            onClick={() => act('togglePhoto')}
          />
          <Section>
            <Button
              content="Submit"
              disabled={!security_mode}
              color="green"
              icon="volume-up"
              onClick={() => act('submitWantedIssue')}
            />
            <Button
              content="Cancel"
              disabled={!security_mode}
              icon="times"
              color="red"
              onClick={() => act('cancelCreation')}
            />
          </Section>
        </>
      ) : null}
    </Modal>
  );
};

export const UserDetails = (_) => {
  const { data } = useBackend();
  const { user } = data;

  if (!user.authenticated) {
    return (
      <NoticeBox>No ID detected! Contact the Head of Personnel.</NoticeBox>
    );
  } else {
    return (
      <Section>
        <Stack>
          <Stack.Item>
            <Icon name="id-card" size={3} mr={1} />
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="User">{user.name}</LabeledList.Item>
              <LabeledList.Item label="Occupation">{user.job}</LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
};

const NewscasterContent = (_) => {
  const { data } = useBackend();
  const { current_channel = {} } = data;
  return (
    <>
      <Stack>
        <Stack.Item grow basis="content">
          <NewscasterChannelSelector />
        </Stack.Item>
        <Stack.Item grow basis="content" style={{ width: '100%' }}>
          <Stack fill vertical>
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
            <Stack.Item grow basis="content">
              <NewscasterChannelBox
                channelName={current_channel.name}
                channelOwner={current_channel.owner}
                channelDesc={current_channel.desc}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
      <NewscasterChannelMessages />
    </>
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
    channelCensored,
    viewing_channel,
    security_mode,
    photo_data,
    paper,
    user,
  } = data;
  return (
    <Section
      fill
      title={channelName}
      buttons={
        user.name === channelAuthor || user.admin ? (
          <Button
            icon="pen"
            content="Edit Channel"
            onClick={() =>
              act('startEditChannel', { current: viewing_channel })
            }
          />
        ) : null
      }
    >
      <Stack fill vertical>
        <Stack.Item grow basis="content">
          {channelCensored ? (
            <Section>
              <BlockQuote color="red">
                <b>ATTENTION:</b> {CENSOR_MESSAGE}
              </BlockQuote>
            </Section>
          ) : (
            <Box width="100%" height="100%" style={{ overflowY: 'auto' }}>
              <BlockQuote italic fontSize={1.2}>
                {decodeHtmlEntities(channelDesc)}
              </BlockQuote>
            </Box>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box>
            <Button
              icon="print"
              content="Submit Story"
              disabled={
                (channelLocked && channelAuthor !== user.name && !user.admin) ||
                channelCensored
              }
              onClick={() => act('createStory', { current: viewing_channel })}
              mt={1}
            />
            <Button
              icon="camera"
              selected={photo_data}
              content="Scan Photo"
              disabled={
                (channelLocked && channelAuthor !== user.name && !user.admin) ||
                channelCensored
              }
              onClick={() => act('togglePhoto')}
            />
            {!!security_mode && (
              <Button
                icon="ban"
                content={channelCensored ? 'Remove D-Notice' : 'D-Notice'}
                color={channelCensored ? 'red' : null}
                tooltip="Censor the whole channel and its \
                  contents as dangerous to the station."
                disabled={!security_mode || !viewing_channel}
                onClick={() =>
                  act('channelDNotice', {
                    secure: security_mode,
                    channel: viewing_channel,
                  })
                }
              />
            )}
          </Box>
          <Box>
            <Button
              icon="newspaper"
              content="Print Newspaper"
              disabled={user.silicon || paper <= 0}
              tooltip={paper <= 0 ? 'Please insert paper.' : null}
              onClick={() => act('printNewspaper')}
            />
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Channel select is the left-hand menu where all the channels are listed. */
const NewscasterChannelSelector = (_) => {
  const { act, data } = useBackend();
  const {
    channels = [],
    viewing_channel,
    wanted = [],
    user,
    security_mode,
  } = data;
  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item grow basis="content">
          <Tabs vertical>
            {wanted
              .filter((wanted) => wanted.criminal)
              .map((activeWanted) => (
                <Tabs.Tab
                  pt={0.75}
                  pb={0.75}
                  mr={1}
                  key={activeWanted.index}
                  icon={activeWanted.active ? 'skull-crossbones' : null}
                  textColor={activeWanted.active ? 'red' : 'grey'}
                  onClick={() => act('showWanted')}
                >
                  Wanted Issue
                </Tabs.Tab>
              ))}
            {channels.map((channel) => (
              <Tabs.Tab
                key={channel.index}
                pt={0.75}
                pb={0.75}
                mr={1}
                selected={viewing_channel === channel.ID}
                icon={channel.censored ? 'ban' : null}
                textColor={channel.censored ? 'red' : 'white'}
                onClick={() =>
                  act('setChannel', {
                    channel: channel.ID,
                  })
                }
              >
                {channel.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Item>
          <Button
            fill
            width="100%"
            color="green"
            onClick={() => act('startCreateChannel')}
            content="Create Channel"
            icon="plus-square"
            disabled={!user.authenticated}
          />
        </Stack.Item>
        {!!security_mode && (
          <>
            <Stack.Item>
              <Button
                fill
                width="100%"
                color="red"
                onClick={() => act('editWanted')}
                content="Edit Wanted Issue"
                icon="pen"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fill
                width="100%"
                color="red"
                content="Clear Wanted Issue"
                icon="times"
                onClick={() => act('clearWantedIssue')}
              />
            </Stack.Item>
          </>
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

/** This is where the channels comments get spangled out (tm) */
const NewscasterChannelMessages = (_) => {
  const { act, data } = useBackend();
  const {
    messages = [],
    viewing_channel,
    security_mode,
    channelCensored,
    channelLocked,
    channelAuthor,
    user,
  } = data;
  if (channelCensored) {
    return (
      <Section style={{ marginTop: '0.5em' }} color="red">
        <b>ATTENTION:</b> Comments cannot be read at this time.
        <br />
        Thank you for your understanding, and have a secure day.
      </Section>
    );
  }
  const visibleMessages = messages.filter(
    (message) => message.ID !== viewing_channel,
  );

  return (
    <Box style={{ marginTop: '0.5em' }}>
      {visibleMessages.map((message) => {
        return (
          <Section
            key={message.index}
            textColor="white"
            style={{ marginTop: '0.5em' }}
            title={
              <i>
                {message.censored_author ? (
                  <Box as="span" color="red" style={{ display: 'inline' }}>
                    By: [REDACTED] (D-Notice)
                  </Box>
                ) : (
                  <>
                    By: {message.auth} at {message.time}
                  </>
                )}
              </i>
            }
            buttons={
              <>
                {!!security_mode && (
                  <Button
                    icon="comment-slash"
                    tooltip="Censor Story"
                    disabled={!security_mode}
                    onClick={() =>
                      act('storyCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                {!!security_mode && (
                  <Button
                    icon="user-slash"
                    tooltip="Censor Author"
                    disabled={!security_mode}
                    onClick={() =>
                      act('authorCensor', {
                        messageID: message.ID,
                      })
                    }
                  />
                )}
                <Button
                  icon="comment"
                  tooltip="Leave a Comment."
                  disabled={
                    message.censored_author ||
                    message.censored_message ||
                    !user?.authenticated ||
                    (!!channelLocked &&
                      channelAuthor !== user?.name &&
                      !user?.admin)
                  }
                  onClick={() =>
                    act('startComment', {
                      messageID: message.ID,
                    })
                  }
                />
              </>
            }
          >
            <BlockQuote>
              {message.censored_message ? (
                <Section textColor="red">
                  This message was deemed dangerous to the general welfare of
                  the station and therefore marked with a <b>D-Notice</b>.
                </Section>
              ) : (
                <Section pl={1}>
                  <Box dangerouslySetInnerHTML={processedText(message.body)} />
                </Section>
              )}
              {message.photo !== null && !message.censored_message && (
                <>
                  <Box as="img" src={message.photo} />
                  {message.photo_caption && (
                    <Section
                      dangerouslySetInnerHTML={processedText(
                        message.photo_caption,
                      )}
                      pl={1}
                    />
                  )}
                </>
              )}
              {!!message.comments && (
                <Box>
                  {message.comments.map((comment) => (
                    <BlockQuote key={comment.index}>
                      <Box italic textColor="white">
                        By: {comment.auth} at {comment.time}
                      </Box>
                      <Section ml={2.5}>
                        <Box
                          dangerouslySetInnerHTML={processedText(comment.body)}
                        />
                      </Section>
                    </BlockQuote>
                  ))}
                </Box>
              )}
            </BlockQuote>
            <Divider />
          </Section>
        );
      })}
    </Box>
  );
};
