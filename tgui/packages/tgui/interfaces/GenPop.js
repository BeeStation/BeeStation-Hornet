// From NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, ProgressBar, Input } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';
import { createSearch } from 'common/string';

const searchFor = (searchText) => createSearch(searchText, ([_, thing]) => thing.name + thing.tooltip);

export const GenPop = (props, context) => {
  const { act, data } = useBackend(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window
      resizable
      width={625}
      height={400}>
      <Window.Content scrollable>
        <Section
          title="Prisoner ID Printer:"
          buttons={(
            <Fragment>
              <Button
                icon="cogs"
                content={data.desire_crimes ? data.desired_crime : "Enter A Crime"}
                onClick={() => act("crime")} />
              <Button
                icon="id-card-alt"
                content={data.desired_name ? data.desired_name : "Enter Prisoner Name"}
                onClick={() => act("prisoner_name")} />
              <Button
                icon="print"
                content="Finalize ID"
                color="good"
                disabled={!data.canPrint}
                onClick={() => act('print')} />

            </Fragment>
          )}>
          <Button
            icon="fast-backward"
            onClick={() => act('time', { adjust: -120 })} />
          <Button
            icon="backward"
            onClick={() => act('time', { adjust: -60 })} />
          {' '}
          {String(data.sentence / 60)} min:
          {' '}
          <Button
            icon="forward"
            onClick={() => act('time', { adjust: 60 })} />
          <Button
            icon="fast-forward"
            onClick={() => act('time', { adjust: 120 })} />
          <br />
          <Button
            icon="hourglass-start"
            content="Minor"
            color="yellow"
            onClick={() => act('preset', { preset: 'short' })} />
          <Button
            icon="hourglass-start"
            content="Misdemeanor"
            color="orange"
            onClick={() => act('preset', { preset: 'medium' })} />
          <Button
            icon="hourglass-start"
            content="Major"
            color="bad"
            onClick={() => act('preset', { preset: 'long' })} />
          <Button
            icon="exclamation-triangle"
            content="CAPITAL"
            color="grey"
            onClick={() => act('preset', { preset: 'perma' })} />
          <br />
        </Section>
        <Section title="Infractions">
          <Input
              autoFocus
              placeholder="Search infraction..."
              width={20}
              key={searchText}
              onInput={(_, value) => setSearchText(value)}
            />
          <br />
          {Object.keys(data.allCrimes).map(key => {
            let value = data.allCrimes[key];
            return (
              <Button
                key={key}
                content={value.name}
                color={value.colour}
                icon={value.icon}
                tooltip={value.tooltip}
                onClick={() => act('presetCrime', { preset: value.sentence, crime: value.name })}
              />
            );
          })}
        </Section>
        <Section title="Prison Management:">
          {Object.keys(data.allPrisoners).map(key => {
            let value = data.allPrisoners[key];
            return (
              <Section key={value} title={value.name} buttons={
                <Fragment>
                  <Button
                    icon="backward"
                    onClick={() => act('adjust_time', { adjust: -60, id: value.id })} />
                  <Button
                    icon="forward"
                    onClick={() => act('adjust_time', { adjust: 60, id: value.id })} />
                  <Button
                    icon="hourglass-start"
                    content="Release"
                    onClick={() => act('release', { id: value.id })} />
                </Fragment>
              }>
                Incarcerated for: {value.crime} <br />
                <ProgressBar
                  value={(value.served_time / value.sentence * 100) * 0.01}
                  ranges={{
                    good: [0.99, Infinity],
                    average: [0.40, 0.99],
                    bad: [-Infinity, 0.40],
                  }}>
                  {toFixed(value.served_time / 60)} min / {toFixed(value.sentence / 60)} min
                </ProgressBar>
              </Section>
            );
          })}
        </Section>

      </Window.Content>
    </Window>
  );
};
