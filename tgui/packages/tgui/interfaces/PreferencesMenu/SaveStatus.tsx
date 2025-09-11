import { useBackend } from '../../backend';
import { Box, Tooltip } from '../../components';
import { PreferencesMenuData } from './data';

export const SaveStatus = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  const {
    save_in_progress = false,
    is_db = true,
    is_guest = false,
    save_sucess = true,
  } = data;
  const innerBox = (
    <Box
      backgroundColor={
        is_guest || !is_db
          ? '#cc0000'
          : save_in_progress
            ? '#666666'
            : save_sucess
              ? '#00cc00'
              : '#cc0000'
      }
      textColor="white"
      textAlign="center"
      ml={1}
      style={{
        borderRadius: '2px',
        display: 'inline',
        padding: '2px 5px',
      }}
    >
      {!is_db ? (
        <strong>No DB</strong>
      ) : is_guest ? (
        <strong>Guest</strong>
      ) : null}
      {!is_guest && is_db ? (
        save_in_progress ? (
          <span>
            Saving
            <span className="loading-one">.</span>
            <span className="loading-two">.</span>
            <span className="loading-three">.</span>
          </span>
        ) : (
          <strong>{save_sucess ? 'Saved' : 'Error'}</strong>
        )
      ) : null}
    </Box>
  );
  if (!is_db || is_guest) {
    return (
      <Tooltip
        content={`Cannot save your preferences due to ${
          !is_db
            ? 'not having a database connected.'
            : 'being a guest user. Please register and log in with a BYOND account.'
        }`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  if (!save_in_progress && !save_sucess) {
    return (
      <Tooltip
        content={`Failed to save your data. Please inform the server operator or a maintainer of this error.`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  if (save_in_progress) {
    return (
      <Tooltip
        content={`Please wait up to 5 seconds for your data to be saved. Saving may take longer during high load - please be assured your data is still queued to be saved.`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  return innerBox;
};
