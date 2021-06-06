import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const GenPop = (props, context) => {
  const { act, data } = useBackend(context);
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
                content={data.desired_crime ? data.desired_crime : "Enter A Crime"}
                onClick={() => act("crime")} />
              <Button
                icon="id-card-alt"
                content={data.desired_name ? data.desired_name : "Enter Prisoner Name"}
                onClick={() => act("prisoner_name")} />
              <Button
                icon="print"
                content="Finalize ID"
                color="average"
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
            content="Short"
            onClick={() => act('preset', { preset: 'short' })} />
          <Button
            icon="hourglass-start"
            content="Medium"
            onClick={() => act('preset', { preset: 'medium' })} />
          <Button
            icon="hourglass-start"
            content="Long"
            onClick={() => act('preset', { preset: 'long' })} />
          <Button
            icon="exclamation-triangle"
            content="PERMA"
            color="bad"
            onClick={() => act('preset', { preset: 'perma' })} />
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
                onClick={() => act('presetCrime', { preset: value.sentence, crime: value.tooltip })}
              />
            );
          })}
        </Section>
        <Section title="Prison Management:">
          {Object.keys(data.allPrisoners).map(key => {
            let value = data.allPrisoners[key];
            return (
              <Section key={value} title={value.name} buttons={
                <Button
                  icon="hourglass-start"
                  content="Release"
                  onClick={() => act('release', { id: value.id })} />
              }>
                Incarcerated for: {value.crime} <br />
                <ProgressBar
                  value={(value.served_time / value.sentence * 100) * 0.01}
                  ranges={{
                    good: [0.99, Infinity],
                    average: [0.40, 0.99],
                    bad: [-Infinity, 0.40],
                  }}>
                  {toFixed(value.served_time / 60)} min /
                  {toFixed(value.sentence / 60)} min
                </ProgressBar>
              </Section>
            );
          })}
        </Section>

      </Window.Content>
    </Window>
  );
};
