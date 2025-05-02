import { Component, ReactNode } from 'react';

import { loadedMappings, resolveAsset } from '../../assets';
import { Box, Dimmer } from '../../components';
import { fetchRetry } from '../../http';
import { ServerData } from './data';

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;
let lastError: any = null;

export class ServerPreferencesFetcher extends Component<
  {
    render: (serverData: ServerData | undefined) => ReactNode;
  },
  {
    serverData?: ServerData;
    errored: boolean;
  }
> {
  constructor(props) {
    super(props);
    this.state = {
      serverData: undefined,
      errored: false,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset('preferences.json'))
        .then((response) => response.json())
        .catch((err) => {
          this.setState({
            errored: true,
          });
          lastError = err;
        });
    }

    const preferencesData: ServerData = await fetchServerData;

    this.setState({
      serverData: preferencesData,
    });
  }

  render() {
    return this.state !== null &&
      this.state.serverData !== null &&
      this.state.errored === false &&
      lastError === null ? (
      this.props?.render?.(this.state.serverData)
    ) : lastError !== null ? (
      <Dimmer
        textColor="red"
        fontSize="30px"
        textAlign="center"
        style={{
          backgroundColor: 'rgba(0, 0, 0, 0.75)',
          fontWeight: 'bold',
        }}
      >
        Error: Unable to fetch preferences clientside data.
        <br />
        (Your character data is OK, this is a UI error)
        <br />
        Contact a maintainer or create an issue report by pressing Report Issue
        in the top right of the game window.
        <br />
        Reconnecting will also likely fix this issue.
        <br />
        <Box
          textAlign="left"
          fontSize="12px"
          textColor="white"
          style={{ whiteSpace: 'pre-wrap' }}
        >
          Error Details:{'\n'}
          {typeof lastError === 'object' &&
          Object.keys(lastError).includes('stack')
            ? lastError.stack
            : lastError.toString()}
          {'\n'}
          Asset Mappings: {JSON.stringify(loadedMappings, null, 2)}
        </Box>
      </Dimmer>
    ) : (
      'Loading...'
    );
  }
}
