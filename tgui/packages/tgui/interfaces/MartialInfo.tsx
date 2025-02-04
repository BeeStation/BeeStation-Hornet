import { BlockQuote, Stack } from '../components';
import { Window } from '../layouts';

const goodstyle = {
  color: 'lightgreen',
};

const badstyle = {
  color: 'lightblue',
};

const noticestyle = {
  color: 'red',
};

const Move1 = '';
const Move2 = '';
const Move3 = '';
const Move4 = '';
const Move5 = '';
const AdditionText = '';

export const MartialInfo = (_props) => {
  return (
    <Window width={620} height={170} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item fontSize="25px">Guide to the Martial Arts...</Stack.Item>
          <Stack.Item>
            <BlockQuote>
              You are a martial artist, whether by circumstance, training, or brain injury;
              You are a most fearsome foe of any who would oppose you.
              Bring fear to the heart of men through your unique combat moves:
              {Move1 && <span style={noticestyle}>{Move1}</span>}
              {Move2 && <span style={noticestyle}>{Move2}</span>}
              {Move3 && <span style={noticestyle}>{Move3}</span>}
              {Move4 && <span style={noticestyle}>{Move4}</span>}
              {Move5 && <span style={noticestyle}>{Move5}</span>}
              {Move5 && <span style={noticestyle}>{Move5}</span>}
              {AdditionText && <span style={noticestyle}>{AdditionText}</span>}
            </BlockQuote>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
