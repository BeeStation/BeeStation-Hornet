import { sortBy } from 'common/collections';
import { capitalize } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  Blink,
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  TextArea,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { StatusDisplayControls } from './common/StatusDisplayControls';

const STATE_BUYING_SHUTTLE = 'buying_shuttle';
const STATE_CHANGING_STATUS = 'changing_status';
const STATE_MESSAGES = 'messages';

// Used for whether or not you need to swipe to confirm an alert level change
const SWIPE_NEEDED = 'SWIPE_NEEDED';

const ILLEGAL_SHUTTLE_NOTICE =
  'Warning: Safety features disabled. This shuttle is uncertified. Order at your own peril.';

const sortShuttles = (shuttles) =>
  sortBy(
    shuttles,
    (shuttle) => !shuttle.illegal,
    (shuttle) => shuttle.creditCost,
  );

const AlertButton = (props) => {
  const { act, data } = useBackend();
  const { alertLevelTick, canSetAlertLevel } = data;
  const { alertLevel, setShowAlertLevelConfirm } = props;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && 'good'}
      content={capitalize(alertLevel)}
      onClick={() => {
        if (thisIsCurrent) {
          return;
        }

        if (canSetAlertLevel === SWIPE_NEEDED) {
          setShowAlertLevelConfirm([alertLevel, alertLevelTick]);
        } else {
          act('changeSecurityLevel', {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    />
  );
};

const MessageModal = (props) => {
  const { data } = useBackend();
  const { maxMessageLength } = data;

  const [input, setInput] = useLocalState(props.label, '');

  const longEnough =
    props.minLength === undefined || input.length >= props.minLength;

  return (
    <Modal>
      <Stack vertical position="relative">
        <Stack.Item fontSize="16px" maxWidth="90vw">
          {props.label}:
        </Stack.Item>

        <Stack.Item>
          <TextArea
            fluid
            height="20vh"
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setInput(value.substring(0, maxMessageLength));
            }}
            value={input}
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            icon={props.icon}
            content={props.buttonText}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? 'You need a longer reason.' : ''}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput('');
                props.onSubmit(input);
              }
            }}
          />

          <Button
            icon="times"
            content="Cancel"
            color="bad"
            onClick={props.onBack}
          />
        </Stack.Item>

        {!!props.notice && (
          <Stack.Item maxWidth="90vw">{props.notice}</Stack.Item>
        )}
      </Stack>
    </Modal>
  );
};

const NoConnectionModal = () => {
  return (
    <Dimmer>
      <Flex direction="column" textAlign="center" width="300px">
        <Flex.Item>
          <Icon color="red" name="wifi" size={10} />

          <Blink>
            <div
              style={{
                background: '#db2828',
                bottom: '60%',
                left: '25%',
                height: '10px',
                position: 'relative',
                transform: 'rotate(45deg)',
                width: '150px',
              }}
            />
          </Blink>
        </Flex.Item>

        <Flex.Item fontSize="16px">
          A connection to the station cannot be established.
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
};

const PageBuyingShuttle = (props) => {
  const { act, data } = useBackend();
  const { canBuyShuttles } = data;

  return (
    <>
      {canBuyShuttles !== 1 && (
        <Stack.Item>
          <NoticeBox danger>{canBuyShuttles}</NoticeBox>
        </Stack.Item>
      )}

      <Stack vertical fill>
        <Stack.Item>
          <Section>
            Budget: <b>{data.budget.toLocaleString()}</b> credits
          </Section>
        </Stack.Item>

        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {sortShuttles(data.shuttles).map((shuttle) => (
                <Stack.Item key={shuttle.ref}>
                  <Section
                    title={
                      <span
                        style={{
                          display: 'inline-block',
                          width: '70%',
                        }}
                      >
                        {shuttle.name}
                      </span>
                    }
                    buttons={
                      <>
                        {shuttle.danger === 1 ? (
                          <Tooltip content="According to our analysis, this shuttle will not properly fulfill the duties of a typical escape shuttle.">
                            <Icon
                              mr={1}
                              name="exclamation-triangle"
                              color="yellow"
                            />
                          </Tooltip>
                        ) : shuttle.danger === 2 ? (
                          <Tooltip content="According to our analysis, this shuttle has a high risk potential, and may result in the death of large amounts of crew.">
                            <Icon mr={1.25} name="exclamation" color="red" />
                          </Tooltip>
                        ) : null}
                        <Button
                          content={`${shuttle.creditCost.toLocaleString()} credits`}
                          color={shuttle.illegal ? 'red' : 'default'}
                          disabled={
                            !canBuyShuttles || data.budget < shuttle.creditCost
                          }
                          onClick={() =>
                            act('purchaseShuttle', {
                              shuttle: shuttle.ref,
                            })
                          }
                          tooltip={
                            data.budget < shuttle.creditCost
                              ? `You need ${shuttle.creditCost - data.budget} more credits.`
                              : shuttle.illegal
                                ? ILLEGAL_SHUTTLE_NOTICE
                                : undefined
                          }
                          tooltipPosition="left"
                        />
                      </>
                    }
                  >
                    <Box textAlign="justify">{shuttle.description}</Box>
                    {shuttle.prerequisites ? (
                      <b>Prerequisites: {shuttle.prerequisites}</b>
                    ) : null}
                  </Section>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const PageChangingStatus = (props) => {
  const { act } = useBackend();

  return (
    <Box>
      <StatusDisplayControls />
    </Box>
  );
};

const PageMain = (props) => {
  const { act, data } = useBackend();
  const {
    alertLevel,
    alertLevelTick,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRecallShuttles,
    canRequestNuke,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emagged,
    emergencyAccess,
    importantActionReady,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
    page,
  } = data;

  const [callingShuttle, setCallingShuttle] = useLocalState(
    'calling_shuttle',
    false,
  );
  const [messagingAssociates, setMessagingAssociates] = useLocalState(
    'messaging_associates',
    false,
  );
  const [messagingSector, setMessagingSector] = useLocalState(
    'messaing_sector',
    null,
  );
  const [requestingNukeCodes, setRequestingNukeCodes] = useLocalState(
    'requesting_nuke_codes',
    false,
  );

  const [
    [showAlertLevelConfirm, confirmingAlertLevelTick],
    setShowAlertLevelConfirm,
  ] = useLocalState('showConfirmPrompt', [null, null]);

  return (
    <Box>
      <Section title="Emergency Shuttle">
        {shuttleCalled ? (
          <Button.Confirm
            icon="space-shuttle"
            content="Recall Emergency Shuttle"
            color="bad"
            disabled={!canRecallShuttles || !shuttleRecallable}
            tooltip={
              canRecallShuttles
                ? !shuttleRecallable &&
                  "It's too late for the emergency shuttle to be recalled."
                : 'You do not have permission to recall the emergency shuttle.'
            }
            tooltipPosition="bottom-end"
            onClick={() => act('recallShuttle')}
          />
        ) : (
          <Button
            icon="space-shuttle"
            content="Call Emergency Shuttle"
            disabled={shuttleCanEvacOrFailReason !== 1}
            tooltip={
              shuttleCanEvacOrFailReason !== 1
                ? shuttleCanEvacOrFailReason
                : undefined
            }
            tooltipPosition="bottom-end"
            onClick={() => setCallingShuttle(true)}
          />
        )}

        {!!shuttleCalledPreviously &&
          ((shuttleLastCalled && (
            <Box>
              Most recent shuttle call/recall traced to:{' '}
              <b>{shuttleLastCalled}</b>
            </Box>
          )) || <Box>Unable to trace most recent shuttle/recall signal.</Box>)}
      </Section>

      {!!canSetAlertLevel && (
        <Section title="Alert Level">
          <Flex justify="space-between">
            <Flex.Item>
              <Box>
                Currently on <b>{capitalize(alertLevel)}</b> Alert
              </Box>
            </Flex.Item>

            <Flex.Item>
              <AlertButton
                alertLevel="green"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />

              <AlertButton
                alertLevel="blue"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />
              <AlertButton
                alertLevel="yellow (Engineering)"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />
              <AlertButton
                alertLevel="yellow (Medical)"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />
            </Flex.Item>
          </Flex>
        </Section>
      )}

      <Section title="Functions">
        <Flex direction="column">
          {!!canMakeAnnouncement && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="bullhorn"
                content="Make Priority Announcement"
                onClick={() => act('makePriorityAnnouncement')}
              />
            </Flex.Item>
          )}

          {!!canToggleEmergencyAccess && (
            <Flex.Item mt={0.3}>
              <Button.Confirm
                fluid
                icon="id-card-o"
                content={`${emergencyAccess ? 'Disable' : 'Enable'} Emergency Maintenance Access`}
                color={emergencyAccess ? 'bad' : undefined}
                onClick={() => act('toggleEmergencyAccess')}
              />
            </Flex.Item>
          )}

          {!!canMessageAssociates && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="comment-o"
                content={`Send message to ${emagged ? '[UNKNOWN]' : 'CentCom'}`}
                disabled={!importantActionReady}
                onClick={() => setMessagingAssociates(true)}
              />
            </Flex.Item>
          )}

          {!!canRequestNuke && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="radiation"
                content="Request Nuclear Authentication Codes"
                disabled={!importantActionReady}
                onClick={() => setRequestingNukeCodes(true)}
              />
            </Flex.Item>
          )}

          {!!emagged && (
            <Flex.Item mt={0.3}>
              <Button
                fluid
                icon="undo"
                content="Restore Backup Routing Data"
                onClick={() => act('restoreBackupRoutingData')}
              />
            </Flex.Item>
          )}

          {!canMakeAnnouncement &&
            !canToggleEmergencyAccess &&
            !canMessageAssociates &&
            !canRequestNuke &&
            !emagged && <Flex.Item>No functions available</Flex.Item>}
        </Flex>
      </Section>

      {!!canMessageAssociates && messagingAssociates && (
        <MessageModal
          label={`Message to transmit to ${emagged ? '[ABNORMAL ROUTING COORDINATES]' : 'CentCom'} via quantum entanglement`}
          notice="Please be aware that this process is very expensive, and abuse will lead to...termination. Transmission does not guarantee a response. Use by heads of staff is only authorized during an emergency situation."
          icon="bullhorn"
          buttonText="Send"
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(message) => {
            setMessagingAssociates(false);
            act('messageAssociates', {
              message,
            });
          }}
        />
      )}

      {!!canRequestNuke && requestingNukeCodes && (
        <MessageModal
          label="Reason for requesting nuclear self-destruct codes"
          notice="Misuse of the nuclear request system will not be tolerated under any circumstances. Transmission does not guarantee a response."
          icon="bomb"
          buttonText="Request Codes"
          onBack={() => setRequestingNukeCodes(false)}
          onSubmit={(reason) => {
            setRequestingNukeCodes(false);
            act('requestNukeCodes', {
              reason,
            });
          }}
        />
      )}

      {!!callingShuttle && (
        <MessageModal
          label="Nature of emergency"
          icon="space-shuttle"
          buttonText="Call Shuttle"
          minLength={callShuttleReasonMinLength}
          onBack={() => setCallingShuttle(false)}
          onSubmit={(reason) => {
            setCallingShuttle(false);
            act('callShuttle', {
              reason,
            });
          }}
        />
      )}

      {!!canSetAlertLevel &&
        showAlertLevelConfirm &&
        confirmingAlertLevelTick === alertLevelTick && (
          <Modal>
            <Flex direction="column" textAlign="center" width="300px">
              <Flex.Item fontSize="16px" mb={2}>
                Swipe ID to confirm change
              </Flex.Item>

              <Flex.Item mr={2} mb={1}>
                <Button
                  icon="id-card-o"
                  content="Swipe ID"
                  color="good"
                  fontSize="16px"
                  onClick={() =>
                    act('changeSecurityLevel', {
                      newSecurityLevel: showAlertLevelConfirm,
                    })
                  }
                />

                <Button
                  icon="times"
                  content="Cancel"
                  color="bad"
                  fontSize="16px"
                  onClick={() => setShowAlertLevelConfirm(false)}
                />
              </Flex.Item>
            </Flex>
          </Modal>
        )}

      {!!canSendToSectors && (
        <Section title="Allied Sectors">
          <Button
            content="Send a message to allied stations"
            disabled={!importantActionReady}
            onClick={() => setMessagingSector(true)}
          />
        </Section>
      )}

      {!!canSendToSectors && messagingSector && (
        <MessageModal
          label="Message to send to allied station"
          notice="Please be aware that this process is very expensive, and abuse will lead to...termination."
          icon="bullhorn"
          buttonText="Send"
          onBack={() => setMessagingSector(null)}
          onSubmit={(message) => {
            act('sendToOtherSector', {
              message,
            });

            setMessagingSector(null);
          }}
        />
      )}
    </Box>
  );
};

const PageMessages = (props) => {
  const { act, data } = useBackend();
  const messages = data.messages || [];

  return (
    <Section fill scrollable title="Messages">
      {messages
        .map((message, messageIndex) => {
          let answers = null;

          if (Object.keys(message.possibleAnswers).length > 0) {
            answers = (
              <Box mt={1}>
                {Object.entries(message.possibleAnswers).map((answer) => (
                  <Button
                    content={answer[1]}
                    color={message.answered === answer[0] ? 'good' : undefined}
                    key={answer[0]}
                    onClick={
                      message.answered
                        ? undefined
                        : () =>
                            act('answerMessage', {
                              message: messageIndex + 1,
                              answer: answer[0],
                            })
                    }
                  />
                ))}
              </Box>
            );
          }

          const textHtml = {
            __html: sanitizeText(message.content),
          };

          return (
            <Section
              title={message.title}
              key={messageIndex}
              buttons={
                <Button.Confirm
                  icon="trash"
                  content="Delete"
                  color="red"
                  onClick={() =>
                    act('deleteMessage', {
                      message: messageIndex + 1,
                    })
                  }
                />
              }
            >
              <Box dangerouslySetInnerHTML={textHtml} />

              {answers}
            </Section>
          );
        })
        .reverse()}
    </Section>
  );
};

const ConditionalTooltip = (props) => {
  const { condition, children, ...rest } = props;

  if (!condition) {
    return children;
  }

  return <Tooltip {...rest}>{children}</Tooltip>;
};

export const CommunicationsConsole = (props) => {
  const { act, data } = useBackend();
  const {
    canRequestSafeCode,
    safeCodeDeliveryWait,
    safeCodeDeliveryArea,
    authenticated,
    authorizeName,
    canLogOut,
    emagged,
    hasConnection,
    page,
    canBuyShuttles,
  } = data;

  return (
    <Window width={800} height={550} theme={emagged ? 'syndicate' : undefined}>
      <Window.Content>
        <Flex
          height="100%"
          style={{
            gap: '5px',
            flexDirection: 'column',
          }}
        >
          {(canRequestSafeCode ? (
            <Flex.Item>
              <Section title="Emergency Safe Code">
                <Button
                  icon="key"
                  content="Request Safe Code"
                  color="good"
                  onClick={() => act('requestSafeCodes')}
                />
              </Section>
            </Flex.Item>
          ) : null) ||
            (safeCodeDeliveryWait ? (
              <Flex.Item>
                <Section title="Emergency Safe Code Delivery">
                  {`Drop pod to ${safeCodeDeliveryArea} in \
            ${Math.round(safeCodeDeliveryWait / 10)}s`}
                </Section>
              </Flex.Item>
            ) : null)}

          {authenticated ? (
            <Flex.Item grow>
              <Stack fill>
                <Stack.Item width="40%">
                  {canLogOut || !authenticated ? (
                    <Section title="Authentication">
                      <Button
                        icon={authenticated ? 'sign-out-alt' : 'sign-in-alt'}
                        content={
                          authenticated
                            ? `Log Out${authorizeName ? ` (${authorizeName})` : ''}`
                            : 'Log In'
                        }
                        color={authenticated ? 'bad' : 'good'}
                        onClick={() => act('toggleAuthentication')}
                      />
                    </Section>
                  ) : null}

                  {!!authenticated && <PageMain />}
                </Stack.Item>
                <Stack.Item width="60%">
                  <Stack vertical fill>
                    <Stack.Item>
                      <Section title="Menus" fitted>
                        <Tabs>
                          <Tabs.Tab
                            fluid
                            icon="desktop"
                            selected={page === STATE_CHANGING_STATUS}
                            onClick={() =>
                              act('setState', { state: STATE_CHANGING_STATUS })
                            }
                          >
                            Set Status Display
                          </Tabs.Tab>

                          <Tabs.Tab
                            fluid
                            icon="envelope-o"
                            selected={page === STATE_MESSAGES}
                            onClick={() =>
                              act('setState', { state: STATE_MESSAGES })
                            }
                          >
                            Message List
                          </Tabs.Tab>

                          {canBuyShuttles !== 0 && (
                            <ConditionalTooltip
                              condition={canBuyShuttles !== 1}
                              content={canBuyShuttles}
                            >
                              <Tabs.Tab
                                fluid
                                icon="shopping-cart"
                                selected={page === STATE_BUYING_SHUTTLE}
                                onClick={() =>
                                  act('setState', {
                                    state: STATE_BUYING_SHUTTLE,
                                  })
                                }
                              >
                                Purchase Shuttle
                              </Tabs.Tab>
                            </ConditionalTooltip>
                          )}
                        </Tabs>
                      </Section>
                    </Stack.Item>
                    <Stack.Item grow position="relative">
                      {!!authenticated &&
                        ((page === STATE_BUYING_SHUTTLE && (
                          <PageBuyingShuttle />
                        )) ||
                          (page === STATE_CHANGING_STATUS && (
                            <PageChangingStatus />
                          )) ||
                          (page === STATE_MESSAGES && <PageMessages />) || (
                            <Box>Page not implemented: {page}</Box>
                          ))}
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          ) : (
            <Flex.Item grow>
              <Flex height="100%" width="100%" justify="center" align="center">
                <Section title="Authentication">
                  <Button
                    icon="sign-in-alt"
                    content="Log In"
                    color="good"
                    onClick={() => act('toggleAuthentication')}
                    fluid
                  />
                </Section>
              </Flex>
            </Flex.Item>
          )}
        </Flex>

        {!hasConnection && <NoConnectionModal />}
      </Window.Content>
    </Window>
  );
};
