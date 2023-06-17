import { Box, Tooltip } from '../../components';
import { PreferencesMenuData } from './data';
import { useBackend } from '../../backend';

export const SaveStatus = (props, context) => {
  const { data } = useBackend<PreferencesMenuData>(context);
  const { save_in_progress = false, is_db = true, is_guest = false } = data;
  const innerBox = (
    <Box
      backgroundColor={is_guest || !is_db ? '#cc0000' : save_in_progress ? '#666666' : '#00cc00'}
      textColor="white"
      textAlign="center"
      ml={1}
      style={{
        'border-radius': '2px',
        display: 'inline',
        padding: '2px 5px',
      }}>
      {!is_db ? <strong>No DB</strong> : is_guest ? <strong>Guest</strong> : null}
      {!is_guest && is_db ? (
        save_in_progress ? (
          <span>
            Saving
            <span class="loading-one">.</span>
            <span class="loading-two">.</span>
            <span class="loading-three">.</span>
          </span>
        ) : (
          <strong>Saved</strong>
        )
      ) : null}
    </Box>
  );
  if (!is_db || is_guest) {
    return (
      <Tooltip
        content={`Cannot save your preferences due to ${
          !is_db ? 'not having a database connected.' : 'being a guest user. Please register and log in with a BYOND account.'
        }`}
        position="bottom">
        {innerBox}
      </Tooltip>
    );
  }
  return innerBox;
};
