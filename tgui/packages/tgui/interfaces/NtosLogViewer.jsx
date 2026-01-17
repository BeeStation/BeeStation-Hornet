import { Component, createRef } from 'react';

import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosLogViewer = (props) => {
  const { act, data } = useBackend();
  const [openFile, setOpenFile] = useLocalState('log_viewer_open', null);
  const { files = [] } = data;
  const openFileResult = files.find(
    (file) => file.name === openFile && (!file.remote || file.online),
  );
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
                  <Table.Cell>{file.name}</Table.Cell>
                  <Table.Cell>
                    {!file.remote ? `${file.size}GQ` : 'Remote'}
                  </Table.Cell>
                  <Table.Cell collapsing style={{ textAlign: 'right' }}>
                    {!!file.remote && (
                      <Button
                        disabled={!file.online}
                        icon="download"
                        tooltip="Download"
                        onClick={() =>
                          act('DownloadRemote', { name: file.name })
                        }
                      />
                    )}
                    <Button
                      disabled={file.remote && !file.online}
                      tooltip={
                        file.remote && !file.online
                          ? 'Cannot establish NTNet link.'
                          : null
                      }
                      content="Open"
                      onClick={() => setOpenFile(file.name)}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        ) : (
          <Log file={openFileResult} setOpenFile={setOpenFile} act={act} />
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
        title={this.props.file.name}
        fill
        scrollable
        className="LogSection"
        buttons={
          <>
            <Button
              icon="edit"
              content="Edit in Notepad"
              onClick={() =>
                this.props.act('EditInNotepad', {
                  data: this.props.file.data,
                })
              }
            />
            <Button
              icon="arrow-left"
              content="Back"
              onClick={() => this.props.setOpenFile(null)}
            />
          </>
        }
      >
        {this.props.file.data}
        <div ref={this.messagesEndRef} />
      </Section>
    );
  }
}
