import { Component } from 'inferno';
import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Section, TextArea, Button } from '../components';

export const NtosNotepad = (props, context) => {
  const { act, data } = useBackend(context);
  const { note, has_paper } = data;
  return (
    <NtosWindow width={400} height={600}>
      <NtosWindow.Content>
        <Section
          title={'Notes'}
          buttons={!!has_paper && <Button icon="file-alt" content="Show Scanned Paper" onClick={() => act('ShowPaper')} />}
          fill
          fitted>
          <BufferedNotepad note={note} />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const NOTEPAD_UPDATE_INTERVAL = 4000;

class BufferedNotepad extends Component {
  constructor(props) {
    super(props);
    this.state = {
      bufferedNotes: props.note || '',
      notesChanged: false,
    };
  }

  componentDidMount() {
    this.bufferTimer = setInterval(this.pushBuffer.bind(this), NOTEPAD_UPDATE_INTERVAL);
  }

  componentWillUnmount() {
    this.pushBuffer();
    clearInterval(this.bufferTimer);
  }

  pushBuffer = () => {
    const { act } = useBackend(this.context);
    const { bufferedNotes, notesChanged } = this.state;
    if (notesChanged) {
      act('UpdateNote', { newnote: bufferedNotes });
      this.setState({ notesChanged: false });
    }
  };

  render() {
    const { bufferedNotes } = this.state;
    const updateBuffer = (_, value) => {
      this.setState({ bufferedNotes: value, notesChanged: true });
    };

    return (
      <TextArea
        fluid
        style={{ height: '100%' }}
        backgroundColor="black"
        textColor="white"
        onInput={updateBuffer}
        onChange={this.pushBuffer.bind(this)}
        value={bufferedNotes}
      />
    );
  }
}
