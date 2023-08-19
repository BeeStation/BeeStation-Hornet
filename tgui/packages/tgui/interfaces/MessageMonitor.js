import { Component, createRef } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Tabs, Section, Icon, Button, Box, Flex, Dimmer, Table, BlockQuote } from '../components';
import { ButtonConfirm } from '../components/Button';
import { Window } from '../layouts';
import { MessageContent } from './NtosMessenger';
import { sanitizeText } from '../sanitize';

const processedText = (value) => {
  return {
    __html: sanitizeText(value),
  };
};

export const MessageMonitor = (_, context) => {
  const { data } = useBackend(context);
  const { authenticated } = data;
  return (
    <Window height={600} width={480}>
      <Window.Content scrollable={authenticated}>
        <MessageMonitorContent />
      </Window.Content>
    </Window>
  );
};

export const MessageMonitorContent = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    server_on,
    authenticated,
    no_server,
    hacking,
    can_hack,
    pda_messages = [],
    request_messages = [],
    emoji_names = [],
  } = data;
  const [selectedTab, setSelectedTab] = useLocalState(context, 'selected_tab', 'pda');
  if (hacking) {
    return (
      <Flex direction="column" height="100%">
        <Flex.Item>
          <Section
            fontFamily="monospace"
            backgroundColor="black"
            style={{
              'color': 'red',
              'white-space': 'pre-wrap',
            }}>
            {`-------------------
Crypto-Breaker 5000
-------------------
Brute Force In Progress
Please Wait...`}
          </Section>
        </Flex.Item>
        <Flex.Item mt={1} grow={1} basis="78vh">
          <PasswordScroller tickInterval={1} />
        </Flex.Item>
      </Flex>
    );
  }
  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Section
          title={
            <Box inline fontSize={1.25}>
              <Icon name="server" mr={0.5} /> SERVER CONNECTION
            </Box>
          }
          fontSize={1.25}
          color={!no_server && server_on ? 'good' : 'bad'}
          buttons={
            <>
              {!no_server && authenticated ? (
                <Button
                  fontSize={1.15}
                  mt={0.25}
                  icon="power-off"
                  content={server_on ? 'Disable Server' : 'Enable Server'}
                  color={server_on ? 'bad' : 'good'}
                  onClick={() => act('power')}
                />
              ) : null}
              <Button
                fontSize={1.15}
                mt={0.25}
                icon="sync-alt"
                content={no_server ? 'Link' : 'Re-Link'}
                color={no_server ? 'good' : null}
                onClick={() => act('link')}
              />
            </>
          }>
          {no_server ? 'NOT FOUND' : server_on ? 'OK' : 'OFFLINE'}
        </Section>
      </Flex.Item>
      <Flex.Item mt={1} grow={!authenticated ? 1 : null} basis={!authenticated ? '78vh' : null}>
        <Section fill={!authenticated}>
          {!authenticated ? (
            <Dimmer
              style={{
                'background-color': 'transparent',
              }}>
              <Flex direction="column" align="center" fontSize="15px">
                <Flex.Item fontSize="20px">Awaiting Decryption Key...</Flex.Item>
                <Flex direction="column" align="stretch">
                  <Flex.Item mt={1}>
                    <Button align="center" fluid content="Enter Key" color="good" onClick={() => act('login')} />
                  </Flex.Item>
                  {can_hack ? (
                    <Flex.Item mt={1}>
                      <Button
                        align="center"
                        fluid
                        icon="exclamation-circle"
                        content="Brute Force"
                        color="bad"
                        onClick={() => act('hack')}
                      />
                    </Flex.Item>
                  ) : null}
                </Flex>
              </Flex>
            </Dimmer>
          ) : (
            <Table>
              <Table.Row>
                <Table.Cell collapsing verticalAlign="middle" fontSize={1.25}>
                  <strong>
                    <Icon name="key" mr={0.5} /> AUTHENTICATION
                  </strong>
                </Table.Cell>
                <Table.Cell />
                <Table.Cell collapsing verticalAlign="middle">
                  <Button icon="key" content="Reset Encryption Key" onClick={() => act('reset_key')} />
                  <Button content="Log Out" color="bad" onClick={() => act('logout')} />
                </Table.Cell>
              </Table.Row>
            </Table>
          )}
        </Section>
      </Flex.Item>
      {authenticated ? (
        <Flex.Item mt={1} grow={1} basis={0}>
          <Section>
            <Table>
              <Table.Row>
                <Table.Cell collapsing verticalAlign="middle">
                  <Tabs>
                    <Tabs.Tab selected={selectedTab === 'pda'} onClick={() => setSelectedTab('pda')}>
                      PDA Logs
                    </Tabs.Tab>
                    <Tabs.Tab selected={selectedTab === 'request'} onClick={() => setSelectedTab('request')}>
                      Request Logs
                    </Tabs.Tab>
                  </Tabs>
                </Table.Cell>
                <Table.Cell />
                <Table.Cell collapsing verticalAlign="middle">
                  {selectedTab === 'pda' ? (
                    <Button icon="envelope" content="Send Admin Message" onClick={() => act('admin_message')} />
                  ) : null}
                  <ButtonConfirm
                    icon="times"
                    content="Clear Logs"
                    color="bad"
                    onClick={() => act('clear_logs', { type: selectedTab })}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
          {selectedTab === 'pda'
            ? pda_messages.map((message) => (
              <Section
                key={message.ref}
                title={`${message.sender} to ${message.recipient}`}
                buttons={
                  <ButtonConfirm
                    icon="times"
                    content="Delete"
                    onClick={() => act('delete_log', { type: 'pda', ref: message.ref })}
                  />
                }
                mb={2}>
                <MessageContent
                  contents={message.contents}
                  photo={message.photo}
                  photo_width={message.photo_width}
                  photo_height={message.photo_height}
                  emojis={message.emojis}
                  emoji_names={emoji_names}
                />
              </Section>
            ))
            : request_messages.map((request) => (
              <Section
                key={request.ref}
                title={`${request.sending_department} to ${request.receiving_department}`}
                buttons={
                  <ButtonConfirm
                    icon="times"
                    content="Delete"
                    onClick={() => act('delete_log', { type: 'request', ref: request.ref })}
                  />
                }>
                <Box inline bold={request.priority !== 'Normal'} color={request.priority !== 'Normal' ? 'bad' : null}>
                  {request.priority} Priority
                </Box>
                <br />
                {request.stamp && request.stamp !== 'Unstamped' ? (
                  <>
                    <Box inline dangerouslySetInnerHTML={processedText(request.stamp)} />
                    <br />
                  </>
                ) : null}
                {request.id_auth && request.id_auth !== 'Unauthenticated' ? (
                  <>
                    <Box inline dangerouslySetInnerHTML={processedText(request.id_auth)} />
                    <br />
                  </>
                ) : null}
                <BlockQuote>{request.message}</BlockQuote>
              </Section>
            ))}
          {(selectedTab === 'pda' && !pda_messages?.length) || (selectedTab === 'request' && !request_messages?.length) ? (
            <Section fill minHeight="380px" maxHeight="calc(100% - 50px)">
              <Dimmer
                color="label"
                fontSize={2}
                style={{
                  'background-color': 'transparent',
                }}>
                No Data
              </Dimmer>
            </Section>
          ) : null}
        </Flex.Item>
      ) : null}
    </Flex>
  );
};

const L1 = [
  'the',
  'if',
  'of',
  'as',
  'in',
  'a',
  'you',
  'from',
  'to',
  'an',
  'too',
  'little',
  'snow',
  'dead',
  'drunk',
  'rosebud',
  'duck',
  'al',
  'le',
];
const L2 = [
  'diamond',
  'beer',
  'mushroom',
  'assistant',
  'clown',
  'captain',
  'twinkie',
  'security',
  'nuke',
  'small',
  'big',
  'escape',
  'yellow',
  'gloves',
  'monkey',
  'engine',
  'nuclear',
  'ai',
];
const L3 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

class PasswordScroller extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.reset();
    this.state = {
      text: '---DECRYPTION KEY BRUTE-FORCE BEGIN---\n',
    };
    this.endRef = createRef();
  }

  reset() {
    this.index1 = 0;
    this.index2 = 0;
    this.index3 = 0;
  }

  tick() {
    this.setState((oldState) => {
      return { text: oldState.text + L1[this.index1] + L2[this.index2] + L3[this.index3] + '\n' };
    });
    if (this.index3 < L3.length - 1) {
      this.index3++;
    } else {
      if (this.index2 < L2.length - 1) {
        this.index2++;
      } else {
        if (this.index1 < L1.length - 1) {
          this.index1++;
        } else {
          this.index1 = 0;
          this.setState({
            text: '---DECRYPTION KEY BRUTE-FORCE BEGIN---\n',
          });
        }
        this.index2 = 0;
      }
      this.index3 = 0;
    }
    this.endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), this.props.tickInterval);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Section
        fill
        scrollable
        backgroundColor="black"
        fontFamily="monospace"
        style={{
          'color': 'red',
          'white-space': 'pre-wrap',
          '-ms-overflow-style': 'none',
          'scrollbar-width': 'none',
        }}>
        {this.state.text}
        <div ref={this.endRef} />
      </Section>
    );
  }
}
