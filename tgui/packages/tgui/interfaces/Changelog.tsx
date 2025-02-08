import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Component, Fragment } from 'react';
import { Box, Button, Collapsible, Dropdown, Icon, Section, Stack, Table } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import dateformat from 'dateformat';
import yaml from 'js-yaml';

const icons = {
  add: { icon: 'check-circle', color: 'green' },
  admin: { icon: 'user-shield', color: 'purple' },
  balance: { icon: 'balance-scale-right', color: 'yellow' },
  bugfix: { icon: 'bug', color: 'green' },
  code_imp: { icon: 'code', color: 'green' },
  config: { icon: 'cogs', color: 'purple' },
  expansion: { icon: 'check-circle', color: 'green' },
  experiment: { icon: 'radiation', color: 'yellow' },
  image: { icon: 'image', color: 'green' },
  imageadd: { icon: 'tg-image-plus', color: 'green' },
  imagedel: { icon: 'tg-image-minus', color: 'red' },
  qol: { icon: 'hand-holding-heart', color: 'green' },
  refactor: { icon: 'tools', color: 'green' },
  rscadd: { icon: 'check-circle', color: 'green' },
  rscdel: { icon: 'times-circle', color: 'red' },
  server: { icon: 'server', color: 'purple' },
  sound: { icon: 'volume-high', color: 'green' },
  soundadd: { icon: 'tg-sound-plus', color: 'green' },
  sounddel: { icon: 'tg-sound-minus', color: 'red' },
  spellcheck: { icon: 'spell-check', color: 'green' },
  tgs: { icon: 'toolbox', color: 'purple' },
  tweak: { icon: 'wrench', color: 'green' },
  unknown: { icon: 'info-circle', color: 'label' },
  wip: { icon: 'hammer', color: 'orange' },
};

type ChangelogEntry = Record<string, Record<string, ChangeEntry[]>>;
type ChangeEntry = Record<string, string>;

type Testmerge = {
  title: string;
  number: number;
  link: string;
  author: string;
  changes: Record<string, string[]>;
};

type ChangelogData = {
  dates: string[];
  testmerges?: Testmerge[];
};

const ChangeRow = (props: { kind: string; content: string }, _context) => {
  return (
    <Table.Row>
      <Table.Cell className={classes(['Changelog__Cell', 'Changelog__Cell--Icon'])}>
        <Icon
          color={icons[props.kind] ? icons[props.kind].color : icons['unknown'].color}
          name={icons[props.kind] ? icons[props.kind].icon : icons['unknown'].icon}
        />
      </Table.Cell>
      <Table.Cell className="Changelog__Cell">{props.content}</Table.Cell>
    </Table.Row>
  );
};

const Header = (props: { dropdown: any }, _context) => {
  return (
    <Section>
      <h1>Beestation</h1>
      <p>
        <b>Thanks to: </b>
        /TG/station, Baystation 12, /vg/station, NTstation, CDK Station devs, FacepunchStation, GoonStation devs, the original
        Space Station 13 developers, Invisty for the title image and the countless others who have contributed to the game,
        issue tracker or wiki over the years.
      </p>
      <p>
        {'Current organization members can be found '}
        <a href="https://github.com/orgs/BeeStation/people">here</a>
        {', recent GitHub contributors can be found '}
        <a href="https://github.com/BeeStation/BeeStation-Hornet/graphs/contributors">here</a>.
      </p>
      <p>
        {'You can also join our community outside of the game: '}
        <br />
        Navigate the community on our <a href="https://beestation13.com/">Website</a>
        <br />
        Discuss on <a href="https://beestation13.com/forum">Forums</a>
        <br />
        Learn more at our <a href="https://wiki.beestation13.com/">Wiki</a>
        <br />
        Check out our <a href="https://github.com/BeeStation/BeeStation-Hornet">Source</a>
        <br />
        Join our Discord <a href="https://discord.gg/ss13">Here!</a>.
      </p>
      {props.dropdown}
    </Section>
  );
};

const Footer = (props: { dropdown: any }, _context) => {
  return (
    <Section>
      {props.dropdown}
      <h3>GoonStation 13 Development Team</h3>
      <p>
        <b>Coders: </b>
        Stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob, Justicefries, 0staf, sniperchance, AngriestIBM,
        BrianOBlivion
      </p>
      <p>
        <b>Spriters: </b>
        Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No
      </p>
      <p>
        Beestation is thankful to the GoonStation 13 Development Team for its work on the game up to the
        {' r4407 release. The changelog for changes up to r4407 can be seen '}
        <a href="https://wiki.ss13.co/Changelog#April_2010">here</a>.
      </p>
      <p>
        {'Except where otherwise noted, Goon Station 13 is licensed under a '}
        <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
          Creative Commons Attribution-Noncommercial-Share Alike 3.0 License
        </a>
        {'. Rights are currently extended to '}
        <a href="http://forums.somethingawful.com/">SomethingAwful Goons</a>
        {' only.'}
      </p>
      <h3>Beestation License</h3>
      <p>
        {'All code after '}
        <a href={'https://github.com/tgstation/tgstation/commit/' + '333c566b88108de218d882840e61928a9b759d8f'}>
          commit 333c566b88108de218d882840e61928a9b759d8f on 2014/31/12 at 4:38 PM PST
        </a>
        {' is licensed under '}
        <a href="https://www.gnu.org/licenses/agpl-3.0.html">GNU AGPL v3</a>
        {'. All code before that commit is licensed under '}
        <a href="https://www.gnu.org/licenses/gpl-3.0.html">GNU GPL v3</a>
        {', including tools unless their readme specifies otherwise. See '}
        <a href="https://github.com/tgstation/tgstation/blob/master/LICENSE">LICENSE</a>
        {' and '}
        <a href="https://github.com/tgstation/tgstation/blob/master/GPLv3.txt">GPLv3.txt</a>
        {' for more details.'}
      </p>
      <p>
        The TGS DMAPI API is licensed as a subproject under the MIT license.
        {' See the footer of '}
        <a href={'https://github.com/tgstation/tgstation/blob/master' + '/code/__DEFINES/tgs.dm'}>code/__DEFINES/tgs.dm</a>
        {' and '}
        <a href={'https://github.com/tgstation/tgstation/blob/master' + '/code/modules/tgs/LICENSE'}>
          code/modules/tgs/LICENSE
        </a>
        {' for the MIT license.'}
      </p>
      <p>
        {'All assets including icons and sound are under a '}
        <a href="https://creativecommons.org/licenses/by-sa/3.0/">Creative Commons 3.0 BY-SA license</a>
        {' unless otherwise indicated.'}
      </p>
    </Section>
  );
};

const Testmerges = (_props) => {
  const {
    data: { testmerges },
  } = useBackend<ChangelogData>();
  if (!testmerges?.length) {
    return null;
  }
  return (
    <>
      <Section px={1}>
        <h4>
          These are features being actively tested and developed on the server. Please report any issues or feedback to the
          original PR, or on the feedback thread on the Discord if there is one.
        </h4>
      </Section>
      <Stack vertical>
        {testmerges.map((testmerge) => {
          const title = (
            <a href={testmerge.link}>
              #{testmerge.number}: &quot;{testmerge.title}&quot; by {testmerge.author}
            </a>
          );
          return (
            <Stack.Item key={testmerge.number}>
              <Section title={title}>
                <Collapsible color="transparent" title="Changelog" open>
                  <Box ml={3}>
                    <Table>
                      {Object.entries(testmerge.changes).map(([kind, changes]) =>
                        changes.map((desc) => <ChangeRow key={kind + desc} kind={kind} content={desc} />)
                      )}
                    </Table>
                  </Box>
                </Collapsible>
              </Section>
            </Stack.Item>
          );
        })}
      </Stack>
    </>
  );
};

export class Changelog extends Component {
  state: {
    selectedDate: string;
    selectedIndex: number;
    data: string | object;
  };
  dateChoices: string[];

  constructor(props) {
    super(props);
    this.state = {
      data: 'Loading changelog data...',
      selectedDate: '',
      selectedIndex: 0,
    };
    this.dateChoices = [];
  }

  setData(data: string | object) {
    this.setState({ data });
  }

  setSelectedDate(selectedDate: string) {
    this.setState({ selectedDate });
  }

  setSelectedIndex(selectedIndex: number) {
    this.setState({ selectedIndex });
  }

  getData = (date: string, attemptNumber = 1) => {
    const { act } = useBackend();
    const self = this;
    const maxAttempts = 6;

    if (attemptNumber > maxAttempts) {
      return this.setData('Failed to load data after ' + maxAttempts + ' attempts');
    }

    act('get_month', { date });

    fetch(resolveAsset(date + '.yml')).then(async (changelogData) => {
      const result = await changelogData.text();
      const errorRegex = /^Cannot find/;

      if (errorRegex.test(result)) {
        const timeout = 50 + attemptNumber * 50;

        self.setData('Loading changelog data' + '.'.repeat(attemptNumber + 3));
        setTimeout(() => {
          self.getData(date, attemptNumber + 1);
        }, timeout);
      } else {
        self.setData(yaml.load(result, { schema: yaml.CORE_SCHEMA }));
      }
    });
  };

  componentDidMount() {
    const {
      data: { dates = [] },
    } = useBackend<ChangelogData>();

    if (dates) {
      dates.forEach((date) => this.dateChoices.push(dateformat(date, 'mmmm yyyy', true)));
      this.setSelectedDate(this.dateChoices[0]);
      this.getData(dates[0]);
    }
  }

  render() {
    const { data, selectedDate, selectedIndex } = this.state;
    const {
      data: { dates, testmerges },
    } = useBackend<ChangelogData>();
    const { dateChoices } = this;

    const dateDropdown = dateChoices.length > 0 && (
      <Stack mb={1}>
        <Stack.Item>
          <Button
            className="Changelog__Button"
            disabled={selectedIndex === 0}
            icon={'chevron-left'}
            onClick={() => {
              const index = selectedIndex - 1;

              this.setData('Loading changelog data...');
              this.setSelectedIndex(index);
              this.setSelectedDate(dateChoices[index]);
              window.scrollTo(0, document.body.scrollHeight || document.documentElement.scrollHeight);
              return this.getData(dates[index]);
            }}
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            displayText={selectedDate}
            options={dateChoices}
            onSelected={(value) => {
              const index = dateChoices.indexOf(value);

              this.setData('Loading changelog data...');
              this.setSelectedIndex(index);
              this.setSelectedDate(value);
              window.scrollTo(0, document.body.scrollHeight || document.documentElement.scrollHeight);
              return this.getData(dates[index]);
            }}
            selected={selectedDate}
            width={'150px'}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            className="Changelog__Button"
            disabled={selectedIndex === dateChoices.length - 1}
            icon={'chevron-right'}
            onClick={() => {
              const index = selectedIndex + 1;

              this.setData('Loading changelog data...');
              this.setSelectedIndex(index);
              this.setSelectedDate(dateChoices[index]);
              window.scrollTo(0, document.body.scrollHeight || document.documentElement.scrollHeight);
              return this.getData(dates[index]);
            }}
          />
        </Stack.Item>
      </Stack>
    );

    const changes =
      typeof data === 'object' &&
      Object.keys(data).length > 0 &&
      Object.entries(data as ChangelogEntry)
        .reverse()
        .map(([date, authors]) => (
          <Section key={date} title={dateformat(date, 'd mmmm yyyy', true)}>
            <Box ml={3}>
              {Object.entries(authors).map(([name, changes]) => (
                <Fragment key={name}>
                  <h4>{name} changed:</h4>
                  <Box ml={3}>
                    <Table>
                      {changes.map((change) => {
                        const changeType = Object.keys(change)[0];
                        return (
                          <ChangeRow key={changeType + change[changeType]} kind={changeType} content={change[changeType]} />
                        );
                      })}
                    </Table>
                  </Box>
                </Fragment>
              ))}
            </Box>
          </Section>
        ));

    return (
      <Window title="Changelog" width={testmerges?.length ? 1000 : 675} height={650}>
        <Window.Content scrollable>
          <Header dropdown={dateDropdown} />
          <Stack>
            <Stack.Item grow>{changes}</Stack.Item>
            {!!testmerges?.length && (
              <Stack.Item width="50%">
                <Testmerges />
              </Stack.Item>
            )}
          </Stack>
          {typeof data === 'string' && <p>{data}</p>}
          <Footer dropdown={dateDropdown} />
        </Window.Content>
      </Window>
    );
  }
}
