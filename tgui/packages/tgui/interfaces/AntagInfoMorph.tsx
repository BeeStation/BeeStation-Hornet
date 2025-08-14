import { BlockQuote, Stack } from '../components';
import { Window } from '../layouts';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'red',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoMorph = (_props) => {
  return (
    <Window width={620} height={310} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">You are a morph...</Stack.Item>
          <Stack.Item>
            <BlockQuote>
              ...a shapeshifting abomination that can eat almost anything.
              <br />
              <br />
              You may take the form of anything you can see by{' '}
              <span style={noticestyle}>shift-clicking</span> it. Disguising
              yourself will alert nearby observers and your{' '}
              <span style={badstyle}>disguise will be broken </span>
              for 20 seconds if you are attacked or perform an attack. You may
              also willingly drop your disguise by{' '}
              <span style={noticestyle}>shift-clicking</span> yourself.
              <br />
              <br />
              You move slower while morphed, but can surprise creatures with an{' '}
              <span style={goodstyle}>ambush attack </span>
              by clicking on them or by fooling them with a tempting disguise
              that convinces them to willingly interact with you using an open
              hand. Ambushes will cause your victim to drop anything they are
              holding and knock them down. If they attempted to interact with
              you using an open hand it will also{' '}
              <span style={goodstyle}>inject a debilitating venom </span>
              making them easy prey for consumption. <br />
              <br />
              You can consume any dead or dying creatures as well as loose items
              by clicking them. Digesting anything will
              <span style={goodstyle}> restore your health</span>, but dead
              creatures and food will restore more.
              <br />
              <br />
              You can crawl through the station&apos;s vents and scrubbers by{' '}
              <span style={noticestyle}>alt-clicking</span> them.
            </BlockQuote>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
