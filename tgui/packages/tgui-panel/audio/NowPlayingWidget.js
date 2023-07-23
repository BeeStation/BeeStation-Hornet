/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Button, Collapsible, Flex, Knob, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectAudio } from './selectors';

export const NowPlayingWidget = (props, context) => {
  const audio = useSelector(context, selectAudio),
    dispatch = useDispatch(context),
    settings = useSettings(context),
    title = audio.meta?.title,
    url = audio.meta?.link,
    artist = audio.meta?.artist || 'Unknown Artist',
    upload_date = audio.meta?.upload_date || 'Unknown Date',
    album = audio.meta?.album || 'Unknown Album',
    duration = audio.meta?.duration,
    date = !isNaN(upload_date)
      ? upload_date?.substring(0, 4) + '-' + upload_date?.substring(4, 6) + '-' + upload_date?.substring(6, 8)
      : upload_date;

  return (
    <Flex align="center">
      {(audio.playing && (
        <Flex.Item
          mx={0.5}
          grow={1}
          style={{
            'white-space': 'nowrap',
            'overflow': 'hidden',
            'text-overflow': 'ellipsis',
          }}>
          {
            <Collapsible title={title || 'Unknown Track'} color={'blue'}>
              <Section>
                {url !== 'Song Link Hidden' && (
                  <Flex.Item grow={1} color="label">
                    URL: {url}
                  </Flex.Item>
                )}
                <Flex.Item grow={1} color="label">
                  Duration: {duration}
                </Flex.Item>
                {artist !== 'Song Artist Hidden' && artist !== 'Unknown Artist' && (
                  <Flex.Item grow={1} color="label">
                    Artist: {artist}
                  </Flex.Item>
                )}
                {album !== 'Song Album Hidden' && album !== 'Unknown Album' && (
                  <Flex.Item grow={1} color="label">
                    Album: {album}
                  </Flex.Item>
                )}
                {upload_date !== 'Song Upload Date Hidden' && upload_date !== 'Unknown Date' && (
                  <Flex.Item grow={1} color="label">
                    Uploaded: {date}
                  </Flex.Item>
                )}
              </Section>
            </Collapsible>
          }
        </Flex.Item>
      )) || (
        <Flex.Item grow={1} color="label">
          Nothing to play.
        </Flex.Item>
      )}
      {audio.playing && (
        <Flex.Item mx={0.5} fontSize="0.9em">
          <Button
            tooltip="Stop"
            icon="stop"
            onClick={() =>
              dispatch({
                type: 'audio/stopMusic',
              })
            }
          />
        </Flex.Item>
      )}
      <Flex.Item mx={0.5} fontSize="0.9em">
        <Knob
          minValue={0}
          maxValue={1}
          value={settings.adminMusicVolume}
          step={0.0025}
          stepPixelSize={1}
          format={(value) => toFixed(value * 100) + '%'}
          onDrag={(e, value) =>
            settings.update({
              adminMusicVolume: value,
            })
          }
        />
      </Flex.Item>
    </Flex>
  );
};
