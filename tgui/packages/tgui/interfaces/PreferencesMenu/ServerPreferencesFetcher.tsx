import { Component } from 'inferno';
import type { InfernoNode } from 'inferno';
import { resolveAsset } from '../../assets';
import { fetchRetry } from '../../http';
import { ServerData } from './data';

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class ServerPreferencesFetcher extends Component<
  {
    render: (serverData: ServerData | undefined) => InfernoNode;
  },
  {
    serverData?: ServerData;
  }
> {
  constructor() {
    super();
    this.state = {
      serverData: undefined,
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset('preferences.json')).then((response) => response.json());
    }

    const preferencesData: ServerData = await fetchServerData;

    this.setState({
      serverData: preferencesData,
    });
  }

  render() {
    return this.state !== null && this.state.serverData !== null
      ? this.props.render(this.state.serverData)
      : 'Error: Unable to fetch preferences data.';
  }
}
