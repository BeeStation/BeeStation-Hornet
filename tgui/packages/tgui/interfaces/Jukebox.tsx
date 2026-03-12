import { sortBy } from 'common/collections';
import {
  Box,
  Button,
  Dropdown,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Track = {
  track: string;
  author: string;
  index: number;
};

type Data = {
  playing: BooleanLike;
  volume: number;
  track: string;
  author: string;
  tracks: Track[];
};

export const Jukebox = () => {
  const { act, data } = useBackend<Data>();
  const { playing, track, author, volume, tracks } = data;

  const tracks_sorted: Track[] = sortBy(tracks, (t: Track) => t.track);

  return (
    <Window width={370} height={340}>
      <Window.Content>
        <Section
          title="Song Player"
          buttons={
            <>
              <Button
                icon="backward"
                disabled={!!playing}
                onClick={() => act('last')}
              />
              <Button
                icon={playing ? 'pause' : 'play'}
                selected={playing}
                onClick={() => act('toggle')}
              >
                {playing ? 'Stop' : 'Play'}
              </Button>
              <Button
                icon="forward"
                disabled={!!playing}
                onClick={() => act('next')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Current Track">
              {track || 'None'}
              {author ? ` — ${author}` : ''}
            </LabeledList.Item>
            <LabeledList.Item label="Track Selected">
              <Dropdown
                width="240px"
                options={tracks_sorted.map((t) => t.track)}
                disabled={!!playing}
                selected={track || 'Select a Track'}
                onSelected={(value) => {
                  const selected = tracks.find((t) => t.track === value);
                  if (selected) {
                    act('track', { index: selected.index });
                  }
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Machine Settings">
          <LabeledControls justify="center">
            <LabeledControls.Item label="Volume">
              <Box position="relative">
                <Knob
                  size={3.2}
                  color={volume >= 25 ? 'red' : 'green'}
                  value={volume}
                  unit="%"
                  minValue={0}
                  maxValue={50}
                  step={1}
                  stepPixelSize={1}
                  onChange={(e, value) =>
                    act('volume', {
                      volume: value,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-22px"
                  color="transparent"
                  icon="fast-backward"
                  onClick={() =>
                    act('volume', {
                      volume: -1,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-22px"
                  color="transparent"
                  icon="fast-forward"
                  onClick={() =>
                    act('volume', {
                      volume: -2,
                    })
                  }
                />
              </Box>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
