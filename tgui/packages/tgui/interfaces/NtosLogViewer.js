import { NtosWindow } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { Section, Table, Button } from '../components';
import { Component, createRef } from 'inferno';

export const NtosLogViewer = (props, context) => {
  const { act, data } = useBackend(context);
  const [openFile, setOpenFile] = useLocalState(context, 'log_viewer_open', null);
  const { files = [] } = data;
  const openFileResult = files.find((file) => file.name === openFile && (!file.remote || file.online));
  return (
    <NtosWindow width={400} height={500}>
      <NtosWindow.Content>
        {!openFileResult ? (
          <Section fill scrollable>
            <Table>
              <Table.Row header>
                <Table.Cell>Filename</Table.Cell>
                <Table.Cell collapsing>Size</Table.Cell>
              </Table.Row>
              {files.map((file) => (
                <Table.Row key={file.name} className="candystripe">
                  <Table.Cell>{file.name}.log</Table.Cell>
                  <Table.Cell>{!file.remote ? `${file.size}GQ` : 'Remote'}</Table.Cell>
                  <Table.Cell collapsing style={{ 'text-align': 'right' }}>
                    {!!file.remote && (
                      <Button
                        disabled={!file.online}
                        icon="download"
                        tooltip="Download"
                        onClick={() => act('DownloadRemote', { name: file.name })}
                      />
                    )}
                    <Button
                      disabled={file.remote && !file.online}
                      tooltip={file.remote && !file.online ? 'Cannot establish NTNet link.' : null}
                      content="Open"
                      onClick={() => setOpenFile(file.name)}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        ) : (
          <Log file={openFileResult} setOpenFile={setOpenFile} />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

class Log extends Component {
  constructor(props) {
    super(props);
  }

  messagesEndRef = createRef();

  componentDidMount() {
    this.scrollToBottom();
  }
  componentDidUpdate(prevProps) {
    if (prevProps.file.data !== this.props.file.data) {
      this.scrollToBottom();
    }
  }
  scrollToBottom = () => {
    this.messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };
  render() {
    return (
      <Section
        title={this.props.file.name + '.log'}
        fill
        scrollable
        className="LogSection"
        buttons={<Button icon="arrow-left" content="Back" onClick={() => this.props.setOpenFile(null)} />}>
        {this.props.file.data}
        <div ref={this.messagesEndRef} />
      </Section>
    );
  }
}
