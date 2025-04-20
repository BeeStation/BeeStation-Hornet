import { useBackend } from '../backend';
import { BlockQuote, Stack } from '../components';
import { Window } from '../layouts';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'lightblue',
};

const noticestyle = {
  color: 'lightred',
};

const tipstyle = {
  color: 'white',
};

type Info = {
  name: string;
  Move1: string;
  Move2: string;
  Move3: string;
  Move4: string;
  Move5: string;
  AdditionText: string;
};

export const MartialInfo = (_props) => {
  const { data } = useBackend<Info>();
  const { name, Move1, Move2, Move3, Move4, Move5, AdditionText } = data;
  return (
    <Window width={620} height={350} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">
            Guide to the {name} Martial Arts...
          </Stack.Item>
          <Stack.Item>
            <BlockQuote>
              You are a {name} martial artist, whether by circumstance,
              training, or brain injury;
              <br />
              You are a most fearsome foe of any who would oppose you.
              <br />
              Bring fear to the heart of men through your unique combat moves:
              <br />
              {Move1 && <span style={goodstyle}>{Move1}</span>}
              <br />
              {Move2 && <span style={badstyle}>{Move2}</span>}
              <br />
              {Move3 && <span style={goodstyle}>{Move3}</span>}
              <br />
              {Move4 && <span style={badstyle}>{Move4}</span>}
              <br />
              {Move5 && <span style={goodstyle}>{Move5}</span>}
              <br />
              {AdditionText && <span style={tipstyle}>{AdditionText}</span>}
            </BlockQuote>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
