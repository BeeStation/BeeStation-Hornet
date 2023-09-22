import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Tabs, Button, BlockQuote } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

enum CurrentTab {
  Info,
  Research,
}

type Knowledge = {
  path: string;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  disabled: boolean;
  hereticPath: string;
  color: string;
};

type KnowledgeInfo = {
  available: Knowledge[];
  researched: Knowledge[];
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type SacrificeInfo = {
  total: number;
  command: number;
};

type Info = {
  points: number;
  sacrifices: SacrificeInfo;
  ascended: BooleanLike;
  objectives: Objective[];
  knowledge: KnowledgeInfo;
};

const IntroductionSection = () => {
  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="You are the Heretic!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <Stack.Item>
              <Stack>
                <Stack.Item width="45%">
                  <Stack vertical>
                    <GuideSection />
                    <Stack.Divider />
                  </Stack>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item width="50%">
                  <Stack vertical>
                    <InformationSection />
                    <Stack.Divider />
                    <ObjectivePrintout />
                  </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Another day at a meaningless job. You feel a&nbsp;
            <span style={hereticBlue}>shimmer</span>
            &nbsp;around you, as a realization of something&nbsp;
            <span style={hereticRed}>strange</span>
            &nbsp;in the air unfolds. You look inwards and discover something that will change your life.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            The <span style={hereticPurple}>Gates of Mansus</span>
            &nbsp;open up to your mind.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Find reality smashing&nbsp;
          <span style={hereticPurple}>influences</span>
          &nbsp;around the station invisible to the normal eye and&nbsp;
          <b>left click</b> on them to harvest them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. Tapping them makes them visible to all after a short time.
        </Stack.Item>
        <Stack.Item>
          - Use your&nbsp;
          <span style={hereticRed}>Living Heart action</span>
          &nbsp;to track down&nbsp;
          <span style={hereticRed}>sacrifice targets</span>, but be careful: Pulsing it will produce a heartbeat sound that
          nearby people may hear. This action is tied to your <b>heart</b> - if you lose it, you must complete a ritual to
          regain it.
        </Stack.Item>
        <Stack.Item>
          - Draw a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> by using a drawing tool (a pen or crayon) on the floor while
          having&nbsp;
          <span style={hereticGreen}>Mansus Grasp</span>
          &nbsp;active in your other hand. This rune allows you to complete rituals and sacrifices.
        </Stack.Item>
        <Stack.Item>
          - Follow your <span style={hereticRed}>Living Heart</span> to find your targets. Bring them back to a&nbsp;
          <span style={hereticGreen}>transmutation rune</span> to&nbsp;
          <span style={hereticRed}>sacrifice</span> them for&nbsp;
          <span style={hereticBlue}>knowledge points</span>. The Mansus <b>ONLY</b> accepts targets pointed to by the&nbsp;
          <span style={hereticRed}>Living Heart</span> (or any member of Command, if the Mansus asks that of you).
        </Stack.Item>
        <Stack.Item>
          - Create an item to use as a&nbsp;<span style={hereticYellow}>focus</span> for your&nbsp;
          <span style={hereticGreen}>spells</span>. You start with the&nbsp;
          <span style={hereticYellow}>Amber Focus</span> already researched, but other&nbsp;
          <span style={hereticBlue}>knowledge</span> may also allow you to&nbsp;
          <span style={hereticGreen}>transmutate</span> a new&nbsp;<span style={hereticYellow}>focus</span> item.
        </Stack.Item>
        <Stack.Item>
          - Accomplish all of your objectives to be able to learn the <span style={hereticYellow}>final ritual</span>. Complete
          the ritual to become all powerful!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (_props, context) => {
  const {
    data: { points, sacrifices, ascended },
  } = useBackend<Info>(context);

  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>You have</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ASCENDED
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          You have <b>{points || 0}</b>&nbsp;
          <span style={hereticBlue}>knowledge point{points !== 1 ? 's' : ''}</span>.
        </Stack.Item>
        <Stack.Item>
          You have made a total of&nbsp;
          <b>{sacrifices.total || 0}</b>&nbsp;
          <span style={hereticRed}>sacrifices</span>
          {sacrifices.command > 0 && (
            <>
              , <b>{sacrifices.command}</b> of which were <span style={hereticPurple}>high-value</span>
            </>
          )}
          .
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ObjectivePrintout = (_props, context) => {
  const {
    data: { objectives },
  } = useBackend<Info>(context);

  return (
    <Stack.Item>
      <Stack vertical fill>
        <Stack.Item bold>In order to ascend, you have these tasks to fulfill:</Stack.Item>
        <Stack.Item>
          {(!objectives && 'None!') ||
            objectives.map((objective) => (
              <Stack.Item key={objective.count}>
                {objective.count}: {objective.explanation}
              </Stack.Item>
            ))}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ResearchedKnowledge = (_props, context) => {
  const {
    data: {
      knowledge: { researched },
    },
  } = useBackend<Info>(context);

  return (
    <Stack.Item grow>
      <Section title="Researched Knowledge" fill scrollable>
        <Stack vertical>
          {(!researched.length && 'None!') ||
            researched.map((learned) => (
              <Stack.Item key={learned.name}>
                <Button
                  width="100%"
                  color={learned.color}
                  content={`${learned.hereticPath} - ${learned.name}`}
                  tooltip={learned.desc}
                />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const KnowledgeShop = (_props, context) => {
  const {
    data: {
      knowledge: { available },
    },
    act,
  } = useBackend<Info>(context);

  return (
    <Stack.Item grow>
      <Section title="Potential Knowledge" fill scrollable>
        {(!available.length && 'None!') ||
          available.map((toLearn) => (
            <Stack.Item key={toLearn.name} mb={1}>
              <Button
                width="100%"
                color={toLearn.color}
                disabled={toLearn.disabled}
                content={`${toLearn.hereticPath} - ${
                  toLearn.cost > 0
                    ? `${toLearn.name}: ${toLearn.cost}
                  point${toLearn.cost !== 1 ? 's' : ''}`
                    : toLearn.name
                }`}
                tooltip={toLearn.desc}
                onClick={() => act('research', { path: toLearn.path })}
              />
              {!!toLearn.gainFlavor && (
                <BlockQuote>
                  <i>{toLearn.gainFlavor}</i>
                </BlockQuote>
              )}
            </Stack.Item>
          ))}
      </Section>
    </Stack.Item>
  );
};

const ResearchInfo = (_props, context) => {
  const {
    data: { points },
  } = useBackend<Info>(context);

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item fontSize="20px" textAlign="center">
            You have <b>{points || 0}</b>&nbsp;
            <span style={hereticBlue}>knowledge point{points !== 1 ? 's' : ''}</span> to spend.
          </Stack.Item>
          <Stack.Item grow>
            <Stack height="100%">
              <ResearchedKnowledge />
              <KnowledgeShop />
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (_props, context) => {
  const {
    data: { ascended },
  } = useBackend<Info>(context);
  const [currentTab, setTab] = useLocalState<CurrentTab>(context, 'currentTab', CurrentTab.Info);

  return (
    <Window width={675} height={680}>
      <Window.Content
        style={{
          // 'font-family': 'Times New Roman',
          // 'fontSize': '20px',
          'background-image': 'none',
          'background': ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab icon="info" selected={currentTab === CurrentTab.Info} onClick={() => setTab(CurrentTab.Info)}>
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === CurrentTab.Research ? 'book-open' : 'book'}
                selected={currentTab === CurrentTab.Research}
                onClick={() => setTab(CurrentTab.Research)}>
                Research
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{(currentTab === CurrentTab.Info && <IntroductionSection />) || <ResearchInfo />}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
