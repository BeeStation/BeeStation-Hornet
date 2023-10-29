import { BlockQuote, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoTwisted = (_props, _context) => {
  return (
    <Window width={620} height={340} theme="neutral">
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="60%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="21px">You are a Twisted man.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    You are a creature remade by the will of the Unshaped, son of Nar&apos;sie.
                    Worship the Father in your base by bringing to him fresh sacrifice.
                    Raid the crew, put victims into crit, revive them with your fleshy binds and bring them back to your base.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Tip #1:&ensp;</span>
                  You are weak alone, stay in groups.
                  <br />
                  <span style={tipstyle}>Tip #2:&ensp;</span>
                  You only have one hand, so organize yourselves with the others to specialize.
                  <br />
                  <span style={tipstyle}>Tip #3:&ensp;</span>
                  You can walk through splinter walls and drag people into them, the crew wo&apos;t be able to follow you at first.
                  <br />
                  <span style={tipstyle}>Tip #4:&ensp;</span>
                  Your arm will fall off if your twisted shield loses its hp, you can ask someone else to pick up any arm on the ground to snap it back on you.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Powers">
              <LabeledList>
                <LabeledList.Item label="Arc Weldin Arm">
                  A multipurpose arm that can either harm others in harm intent, or heal other twisted men in help intent.
                </LabeledList.Item>
                <LabeledList.Item label="Flesh Craft">
                  You can craft items on the spot using your other hands, either bolas or zipties or shields. Your zipties will heal your victims.
                </LabeledList.Item>
                <LabeledList.Item label="Sacrifical dagger">
                  You can have Father latch on victims by stabbing them with the sacrificial dagger. Buckle them to the altar, carve them up, and then unbuckle them once Father has grabbed them. Make sure that nobody is pulling them!
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
