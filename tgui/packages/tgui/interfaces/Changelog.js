import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Component, Fragment } from 'inferno';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import dateformat from 'dateformat';
import yaml from 'js-yaml';

const icons = {
  bugfix: { icon: 'bug', color: 'green' },
  wip: { icon: 'hammer', color: 'orange' },
  qol: { icon: 'hand-holding-heart', color: 'green' },
  soundadd: { icon: 'tg-sound-plus', color: 'green' },
  sounddel: { icon: 'tg-sound-minus', color: 'red' },
  add: { icon: 'check-circle', color: 'green' },
  rscadd: { icon: 'check-circle', color: 'green' },
  rscdel: { icon: 'times-circle', color: 'red' },
  imageadd: { icon: 'tg-image-plus', color: 'green' },
  imagedel: { icon: 'tg-image-minus', color: 'red' },
  spellcheck: { icon: 'spell-check', color: 'green' },
  experiment: { icon: 'radiation', color: 'yellow' },
  balance: { icon: 'balance-scale-right', color: 'yellow' },
  code_imp: { icon: 'code', color: 'green' },
  refactor: { icon: 'tools', color: 'green' },
  config: { icon: 'cogs', color: 'purple' },
  admin: { icon: 'user-shield', color: 'purple' },
  server: { icon: 'server', color: 'purple' },
  tgs: { icon: 'toolbox', color: 'purple' },
  tweak: { icon: 'wrench', color: 'green' },
  unknown: { icon: 'info-circle', color: 'label' },
};

export class Changelog extends Component {
  constructor() {
    super();
    this.state = {
      data: 'Loading changelog data...',
      selectedDate: '',
      selectedIndex: 0,
    };
    this.dateChoices = [];
  }

  setData(data) {
    this.setState({ data });
  }

  setSelectedDate(selectedDate) {
    this.setState({ selectedDate });
  }

  setSelectedIndex(selectedIndex) {
    this.setState({ selectedIndex });
  }

  getData = (date, attemptNumber = 0) => {
    const { act } = useBackend(this.context);
    const self = this;

    if (attemptNumber > 2) {
      return this.setData('Failed to load data after 3 attempts');
    }

    act('get_month', { date });

    fetch(resolveAsset(date + '.yml'))
      .then(async (changelogData) => {
        const result = await changelogData.text();
        const errorRegex = /^Cannot find/;

        if (errorRegex.test(result)) {
          const timeout = 50 + attemptNumber * 100;

          self.setData(
            'Loading changelog data' + '.'.repeat(attemptNumber + 3)
          );
          setTimeout(() => {
            self.getData(date, attemptNumber + 1);
          }, timeout);
        } else {
          self.setData(yaml.load(result, { schema: yaml.CORE_SCHEMA }));
        }
      });
  };

  componentDidMount() {
    const { data: { dates = [] } } = useBackend(this.context);

    if (dates) {
      dates.forEach(
        date => this.dateChoices.push(dateformat(date, 'mmmm yyyy'))
      );
      this.setSelectedDate(this.dateChoices[0]);
      this.getData(dates[0]);
    }
  }

  render() {
    const { data, selectedDate, selectedIndex } = this.state;
    const { data: { dates } } = useBackend(this.context);
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
              window.scrollTo(
                0,
                document.body.scrollHeight
                || document.documentElement.scrollHeight
              );
              return this.getData(dates[index]);
            }} />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            displayText={selectedDate}
            options={dateChoices}
            onSelected={value => {
              const index = dateChoices.indexOf(value);

              this.setData('Loading changelog data...');
              this.setSelectedIndex(index);
              this.setSelectedDate(value);
              window.scrollTo(
                0,
                document.body.scrollHeight
                || document.documentElement.scrollHeight
              );
              return this.getData(dates[index]);
            }}
            selected={selectedDate}
            width={'150px'} />
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
              window.scrollTo(
                0,
                document.body.scrollHeight
                || document.documentElement.scrollHeight
              );
              return this.getData(dates[index]);
            }} />
        </Stack.Item>
      </Stack>
    );

    const header = (
      <Section>
        <h1>Traditional Games Space Station 13</h1>
        <p>
          <b>Thanks to: </b>
          Baystation 12, /vg/station, NTstation, CDK Station devs,
          FacepunchStation, GoonStation devs, the original Space Station 13
          developers, Invisty for the title image and the countless others who
          have contributed to the game, issue tracker or wiki over the years.
        </p>
        <p>
          {'Current project maintainers can be found '}
          <a href="https://github.com/tgstation?tab=members">
            here
          </a>
          {', recent GitHub contributors can be found '}
          <a href="https://github.com/tgstation/tgstation/pulse/monthly">
            here
          </a>.
        </p>
        <p>
          {'You can also join our discord '}
          <a href="https://tgstation13.org/phpBB/viewforum.php?f=60">
            here
          </a>.
        </p>
        {dateDropdown}
      </Section>
    );

    const footer = (
      <Section>
        {dateDropdown}
        <h3>GoonStation 13 Development Team</h3>
        <p>
          <b>Coders: </b>
          Stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob,
          Justicefries, 0staf, sniperchance, AngriestIBM, BrianOBlivion
        </p>
        <p>
          <b>Spriters: </b>
          Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange,
          I Said No
        </p>
        <p>
          BeeStation Space Station 13 is thankful to the
          GoonStation 13 Development Team for its work on the game up to the
          {' r4407 release. The changelog for changes up to r4407 can be seen '}
          <a href="https://wiki.ss13.co/Changelog#April_2010">
            here
          </a>
          .
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
        <p>
          {'Traditional Games Space Station 13 is licensed under a '}
          <a href="https://www.gnu.org/licenses/agpl-3.0.en.html">
            GNU Affero General Public 3.0 License
          </a>
          .
        </p>
      </Section>
    );

    const changes = typeof data === 'object' && Object.keys(data).length > 0 && (
      Object.entries(data).reverse().map(([date, authors]) => (
        <Section key={date} title={dateformat(date, 'd mmmm yyyy')}>
          <Box ml={3}>
            {Object.entries(authors).map(([name, changes]) => (
              <Fragment key={name}>
                <h4>{name} changed:</h4>
                <Box ml={3}>
                  <Table>
                    {changes.map(change => {
                      const changeType = Object.keys(change)[0];
                      return (
                        <Table.Row key={changeType + change[changeType]}>
                          <Table.Cell
                            className={classes([
                              'Changelog__Cell',
                              'Changelog__Cell--Icon',
                            ])}
                          >
                            <Icon
                              color={
                                icons[changeType]
                                  ? icons[changeType].color
                                  : icons['unknown'].color
                              }
                              name={
                                icons[changeType]
                                  ? icons[changeType].icon
                                  : icons['unknown'].icon
                              }
                            />
                          </Table.Cell>
                          <Table.Cell className="Changelog__Cell">
                            {change[changeType]}
                          </Table.Cell>
                        </Table.Row>
                      );
                    })}
                  </Table>
                </Box>
              </Fragment>
            ))}
          </Box>
        </Section>
      ))
    );

    return (
      <Window title="Changelog" width={675} height={650}>
        <Window.Content scrollable>
          {header}
          {changes}
          {typeof data === 'string' && <p>{data}</p>}
          {footer}
        </Window.Content>
      </Window>
    );
  }
}
