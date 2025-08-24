import { Button, Dimmer, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const STORY_VALUE_KEY = -1;
const STORY_VALUE_SHIT = 0;
const STORY_VALUE_NONE = 1;
const STORY_VALUE_MEH = 2;
const STORY_VALUE_OKAY = 3;
const STORY_VALUE_AMAZING = 4;
const STORY_VALUE_LEGENDARY = 5;

const MemoryQuality = (props) => {
  const { act } = useBackend();
  const { quality } = props;

  if (quality === STORY_VALUE_KEY) {
    return (
      <Button
        icon="key"
        color="transparent"
        tooltipPosition="right"
        tooltip={`
          This is a key memory. It contains important information
          you may want to double-check in the future.
        `}
      />
    );
  }
  if (quality === STORY_VALUE_SHIT) {
    return (
      <Button
        icon="poop"
        color="transparent"
        tooltipPosition="right"
        tooltip={`
          This memory is not interesting at all! It does not make for
          good art and is unlikely to pass to future generations.
        `}
      />
    );
  }
  if (quality === STORY_VALUE_NONE) {
    return (
      <Button
        icon="star"
        color="transparent"
        tooltipPosition="right"
        tooltip={`
          This memory pretty bland. It would make for some pretty
          mediocre art and is not likely to pass to future generations.
  `}
      />
    );
  }
  if (quality === STORY_VALUE_MEH) {
    return (
      <Button
        icon="star"
        style={{
          background:
            'linear-gradient(to right, #964B30, #D68B60, #B66B30, #D68B60, #964B30);',
        }}
        tooltipPosition="right"
        tooltip={`
          This memory is not super interesting. It could turn into
          an okay story but don't bet on it.
    `}
      />
    );
  }
  if (quality === STORY_VALUE_OKAY) {
    return (
      <Button
        icon="star"
        style={{
          background:
            'linear-gradient(to right, #636363, #a3a3a3, #6e6e6e, #a3a3a3, #636363);',
        }}
        tooltipPosition="right"
        tooltip={`
          This memory is pretty okay! Some good stories could be told
          from this and it might even come back in future generations.
      `}
      />
    );
  }
  if (quality === STORY_VALUE_AMAZING) {
    return (
      <Button
        icon="star"
        style={{
          background:
            'linear-gradient(to right, #AA771C, #BCB68A, #B38728, #BCB68A, #AA771C);',
        }}
        tooltipPosition="right"
        tooltip={`
          This memory is great! You could tell a great story from it,
          and it would have a good chanced pass to future generations!
      `}
      />
    );
  }
  if (quality === STORY_VALUE_LEGENDARY) {
    return (
      <Button
        icon="crown"
        style={{
          background:
            'linear-gradient(to right, #56A5B3, #75D4E2, #56A5B3, #75D4E2, #56A5B3)',
        }}
        tooltipPosition="right"
        tooltip={`
          This memory is the stuff of legends! It would make for
          legendary art and is likely to pass to future generations.
        `}
      />
    );
  }
  // Default return / error
  return (
    <Button
      icon="question"
      tooltipPosition="right"
      tooltip={`
        This memory has no valid quality assigned. We have no idea how good
        or bad it may be. This is a bug, and should be reported!
      `}
    />
  );
};

export const MemoryPanel = (props) => {
  const { act, data } = useBackend();
  const memories = data.memories || [];
  return (
    <Window title="Memory Panel" width={400} height={500}>
      <Window.Content>
        <Section
          maxHeight="32px"
          title="Memories"
          buttons={
            <Button
              color="transparent"
              tooltip={`
                These are your memories. You gain them from doing notable things
                and you can use them in art!
              `}
              tooltipPosition="bottom-start"
              icon="info"
            />
          }
        />
        {(!memories && (
          <Dimmer fontSize="28px" align="center">
            You have no memories!
          </Dimmer>
        )) || (
          <Stack vertical>
            {memories.map((memory) => (
              <Stack.Item key={memory.name}>
                <Section>
                  <MemoryQuality quality={memory.quality} /> {memory.name}
                </Section>
              </Stack.Item>
            ))}
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
