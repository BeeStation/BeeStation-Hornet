import { Box, Section } from 'tgui/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PlantScanner = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule, last_time } = data;
  return (
    <Window width={750} height={870} theme="plant_menu">
      <Window.Content>
        <Section textAlign={'center'}>
          {last_target || 'No Buffer Target'}
        </Section>
        <Section>
          {render_rule === 'RENDER_RULE_PLANTSEED' ? <SeedRule /> : null}
          {render_rule === 'RENDER_RULE_FRUIT' ? <FruitRule /> : null}
          {render_rule === 'RENDER_RULE_TRAY' ? <TrayRule /> : null}
          {buffer.length ? null : 'buffer cleared 0x0000'}
        </Section>
        {/* World building fluff top banner */}
        <Box height={'8px'} />
        <Section textAlign={'start'} mb={'-5px'}>
          <Box>Yamato OS [Version 19.89.3.5]</Box>
          <Box>© 2554 Yamato. All Rights Reserved.</Box>
          <br />
          <Box>
            {'C:\\Users\\admin> pit buffer attach -m target -f'}
            <br />
            {`> Atached buffer at ${last_time}`}
            <br />
            <br />
            {'C:\\Users\\admin>'}
            <span className={'terminal'}>|</span>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SeedRule = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule } = data;
  return (
    <Box className={'scrollbox'} height={'660px'} overflowY="scroll">
      {Object.entries(buffer).map(([buffer_key, buffer_data]) => (
        <Box key={buffer_key}>
          <Box
            className="plant__dialogue"
            style={{ whiteSpace: 'pre-line' }}
            my={'2px'}
          >
            {Object.entries(buffer_data['feature']).map(
              ([feature_key, feature_data]) => (
                <Box key={feature_key}>
                  {feature_data}
                  {feature_data === '' ? null : <br />}
                </Box>
              ),
            )}
            {Object.entries(buffer_data['needs']).map(
              ([need_key, need_data]) => (
                <Box key={need_key}>
                  {need_data}
                  <br />
                  <br />
                </Box>
              ),
            )}
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const FruitRule = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule } = data;
  return (
    <Box className={'scrollbox'} height={'660px'} overflowY="scroll">
      {Object.entries(buffer['genes']).map(([buffer_key, buffer_data]) => (
        <Box key={buffer_key}>
          <Box
            className="plant__dialogue"
            style={{ whiteSpace: 'pre-line' }}
            my={'2px'}
          >
            {Object.entries(buffer_data['feature']).map(
              ([feature_key, feature_data]) => (
                <Box key={feature_key}>
                  {feature_data}
                  {feature_data === '' ? null : <br />}
                </Box>
              ),
            )}
            {Object.entries(buffer_data['needs']).map(
              ([need_key, need_data]) => (
                <Box key={need_key}>
                  {need_data}
                  <br />
                  <br />
                </Box>
              ),
            )}
          </Box>
        </Box>
      ))}
      <Box
        className="plant__dialogue"
        style={{ whiteSpace: 'pre-line' }}
        my={'2px'}
      >
        Contains:
        <br />
        <br />
        {Object.entries(buffer['reagents']).map(
          ([reagent_key, reagent_data]) => (
            <Box key={reagent_key}>{`${reagent_data}`}</Box>
          ),
        )}
      </Box>
    </Box>
  );
};

const TrayRule = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule } = data;
  return (
    <Box className={'scrollbox'} height={'660px'} overflowY="scroll">
      {Object.entries(buffer).map(([buffer_key, buffer_data]) => (
        <Box
          className={buffer_data === '' ? null : 'plant__dialogue'}
          key={buffer_key}
          my={'2px'}
          style={{ whiteSpace: 'pre-line' }}
        >
          {`${buffer_data}`}
          {buffer_data === '' ? null : <br />}
        </Box>
      ))}
    </Box>
  );
};
