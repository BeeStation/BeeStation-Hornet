import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Flex, NoticeBox, Section, Stack, Tabs, TextArea } from '../components';
import { Window } from '../layouts';
import { formatTime } from '../format';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { phase, roleinfo, admin_controls } = data;
  const [mafia_tab, setMafiaMode] = useLocalState(
    context,
    mafia_tab,
    'Role list'
  );
  return (
    <Window
      title="Mafia"
      theme={roleinfo && roleinfo.role_theme}
      width={650}
      height={580}>
      <Window.Content>
        <Stack fill vertical>
          {!roleinfo && (
            <Stack.Item grow>
              <MafiaLobby />
            </Stack.Item>
          )}
          {!!roleinfo && (
            <>
              <Stack.Item>
                <MafiaRole />
              </Stack.Item>
              {phase === 'Judgment' && (
                <Stack.Item>
                  <MafiaJudgement />
                </Stack.Item>
              )}
            </>
          )}
          {!!admin_controls && <MafiaAdmin />}
          {phase !== 'No Game' && (
            <Stack.Item grow>
              <Stack grow fill>
                <>
                  <Stack.Item grow>
                    <MafiaPlayers />
                  </Stack.Item>
                  <Stack.Item fluid grow>
                    <Stack.Item>
                      <Tabs fluid>
                        <Tabs.Tab
                          align="center"
                          selected={mafia_tab === 'Role list'}
                          onClick={() => setMafiaMode('Role list')}>
                          Role list
                          <Button
                            color="transparent"
                            icon="address-book"
                            tooltipPosition="bottom-start"
                            tooltip={multiline`
                            This is the list of roles in the game. You can
                            press the question mark to get a quick blurb
                            about the role itself.`}
                          />
                        </Tabs.Tab>
                        <Tabs.Tab
                          align="center"
                          selected={mafia_tab === 'Notes'}
                          onClick={() => setMafiaMode('Notes')}>
                          Notes
                          <Button
                            color="transparent"
                            icon="pencil"
                            tooltipPosition="bottom-start"
                            tooltip={multiline`
                            This is your notes, anything you want to write
                            can be saved for future reference. You can
                            also send it to chat with a button.`}
                          />
                        </Tabs.Tab>
                      </Tabs>
                    </Stack.Item>
                    {mafia_tab === 'Role list' && <MafiaListOfRoles />}
                    {mafia_tab === 'Notes' && <MafiaNotesTab />}
                  </Stack.Item>
                </>
              </Stack>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MafiaLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const { lobbydata } = data;
  const readyGhosts = lobbydata
    ? lobbydata.filter((player) => player.status === 'Ready')
    : null;
  return (
    <Section
      fill
      scrollable
      title="Lobby"
      buttons={
        <>
          <Button
            icon="clipboard-check"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              Signs you up for the next game. If there
              is an ongoing one, you will be signed up
              for the next.
            `}
            content="Sign Up"
            onClick={() => act('mf_signup')}
          />
          <Button
            icon="eye"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              Spectates games until you turn it off.
              Automatically enabled when you die in game,
              because I assumed you would want to see the
              conclusion. You won't get messages if you
              rejoin SS13.
            `}
            content="Spectate"
            onClick={() => act('mf_spectate')}
          />
          <Button
            icon="arrow-right"
            tooltipPosition="bottom-start"
            tooltip={multiline`
              Submit a vote to start the game early.
              Starts when half of the current signup list have voted to start.
              Requires a bare minimum of six players.
            `}
            content="Start Now!"
            onClick={() => act('vote_to_start')}
          />
        </>
      }>
      <NoticeBox info>
        The lobby currently has {readyGhosts ? readyGhosts.length : '0'}/12
        valid players signed up.
      </NoticeBox>
      {lobbydata?.map((lobbyist) => (
        <Stack key={lobbyist} className="candystripe" p={1} align="baseline">
          <Stack.Item grow>{lobbyist.name}</Stack.Item>
          <Stack.Item>Status:</Stack.Item>
          <Stack.Item color={lobbyist.status === 'Ready' ? 'green' : 'red'}>
            {lobbyist.status} {lobbyist.spectating}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const MafiaRole = (props, context) => {
  const { act, data } = useBackend(context);
  const { phase, turn, roleinfo, timeleft } = data;
  return (
    <Section
      title={phase + turn}
      minHeight="100px"
      maxHeight="50px"
      buttons={
        <Box
          style={{
            'font-family': 'Consolas, monospace',
            'font-size': '14px',
            'line-height': 1.5,
            'font-weight': 'bold',
          }}>
          {formatTime(timeleft)}
        </Box>
      }>
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>You are the {roleinfo.role}</Box>
          <Box italic>{roleinfo.desc}</Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            className={classes(['mafia32x32', roleinfo.revealed_icon])}
            style={{
              'transform': 'scale(2) translate(0px, 10%)',
              'vertical-align': 'middle',
            }}
          />
          <Box
            className={classes(['mafia32x32', roleinfo.hud_icon])}
            style={{
              'transform': 'scale(2) translate(-5px, -5px)',
              'vertical-align': 'middle',
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaListOfRoles = (props, context) => {
  const { act, data } = useBackend(context);
  const { all_roles } = data;
  return (
    <Section fill>
      <Flex direction="column">
        {all_roles?.map((r) => (
          <Flex.Item key={r} className="Section__title candystripe">
            <Flex align="center" justify="space-between">
              <Flex.Item>{r}</Flex.Item>
              <Flex.Item textAlign="right">
                <Button
                  color="transparent"
                  icon="question"
                  onClick={() =>
                    act('mf_lookup', {
                      role_name: r.slice(0, -3),
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaNotesTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { user_notes } = data;
  const [note_message, setNotesMessage] = useLocalState(
    context,
    'Notes',
    user_notes
  );
  return (
    <Section grow fill>
      <TextArea
        height="80%"
        maxLength={600}
        className="Section__title candystripe"
        onChange={(_, value) => setNotesMessage(value)}
        placeholder={'Insert Notes...'}
        value={note_message}
      />
      <Stack grow>
        <Stack.Item grow fill>
          <Button
            color="good"
            fluid
            content="Save"
            textAlign="center"
            onClick={() => act('change_notes', { new_notes: note_message })}
            tooltip="Saves whatever is written as your notepad. This can't be done while dead."
          />
          <Button.Confirm
            color="bad"
            fluid
            content="Send to Chat"
            textAlign="center"
            onClick={() => act('send_notes_to_chat')}
            tooltip="Sends your notes immediately into the chat for everyone to hear."
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaJudgement = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section title="Judgement">
      <Flex justify="space-around">
        <Button
          icon="smile-beam"
          content="INNOCENT!"
          color="good"
          onClick={() => act('vote_innocent')}
        />
        <Box>It is now time to vote, vote the accused innocent or guilty!</Box>
        <Button icon="angry" color="bad" onClick={() => act('vote_guilty')}>
          GUILTY!
        </Button>
      </Flex>
      <Flex justify="center">
        <Button icon="meh" color="white" onClick={() => act('vote_abstain')}>
          Abstain
        </Button>
      </Flex>
    </Section>
  );
};

const MafiaPlayers = (props, context) => {
  const { act, data } = useBackend(context);
  const { players } = data;
  return (
    <Section fill scrollable title="Players">
      <Flex direction="column">
        {players?.map((player) => (
          <Flex.Item
            height="30px"
            className="Section__title candystripe"
            key={player.ref}>
            <Stack height="18px" align="center">
              <Stack.Item grow color={!player.alive && 'red'}>
                {player.name} {!player.alive && '(DEAD)'}
              </Stack.Item>
              <Stack.Item shrink={0}>
                {player.votes !== undefined &&
                  !!player.alive &&
                  `Votes: ${player.votes}`}
              </Stack.Item>
              <Stack.Item shrink={0} minWidth="42px" textAlign="center">
                {player.possible_actions?.map((action) => (
                  <Button
                    key={action.name}
                    onClick={() =>
                      act('perform_action', {
                        action_ref: action.ref,
                        target: player.ref,
                      })
                    }>
                    {action.name}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaAdmin = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Collapsible title="ADMIN CONTROLS" color="red">
      <Section>
        <Collapsible title="A kind, coder warning" color="transparent">
          Almost all of these are all built to help me debug the game (ow,
          debugging a 12 player game!) So they are rudamentary and prone to
          breaking at the drop of a hat. Make sure you know what you&apos;re
          doing when you press one. Also because an admin did it: do not
          gib/delete/dust anyone! It will runtime the game to death
        </Collapsible>
        <Button icon="arrow-right" onClick={() => act('next_phase')}>
          Next Phase
        </Button>
        <Button icon="home" onClick={() => act('players_home')}>
          Send All Players Home
        </Button>
        <Button icon="sync-alt" onClick={() => act('new_game')}>
          New Game
        </Button>
        <Button icon="skull" onClick={() => act('nuke')}>
          Nuke
        </Button>
        <br />
        <Button icon="paint-brush" onClick={() => act('debug_setup')}>
          Create Custom Setup
        </Button>
        <Button icon="paint-roller" onClick={() => act('cancel_setup')}>
          Reset Custom Setup
        </Button>
        <Button icon="magic" onClick={() => act('start_now')}>
          Start now!
        </Button>
      </Section>
    </Collapsible>
  );
};
