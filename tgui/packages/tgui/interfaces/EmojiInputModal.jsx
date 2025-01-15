import { KEY_BACKSPACE, KEY_ENTER, KEY_LEFT, KEY_RIGHT } from 'common/keycodes';
import { useBackend, useLocalState } from '../backend';
import { Box, Section, Button } from '../components';
import { Window } from '../layouts';

const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export const EmojiInputModal = (_, context) => {
  const { data, act } = useBackend(context);
  const { title, all_emojis = [] } = data;
  const [emojis, setEmojis] = useLocalState(context, 'emoji_input_text', []);
  const [cursor_pos, setCursorPos] = useLocalState(context, 'emoji_input_cursor', 0);

  const insert = (arr, index, newItem) => [...arr.slice(0, index), newItem, ...arr.slice(index)];
  const remove = (arr, index) => [...arr.slice(0, index - 1), ...arr.slice(index)];
  const submit = () => act('submit', { entry: emojis.map((emoji) => `:${emoji}:`).join(' ') });
  const backspace = () => {
    if (cursor_pos > 0 && cursor_pos <= emojis.length) {
      setEmojis(remove(emojis, cursor_pos));
      setCursorPos(cursor_pos - 1);
    }
  };
  const left = () => setCursorPos(clamp(cursor_pos - 1, 0, emojis.length));
  const right = () => setCursorPos(clamp(cursor_pos + 1, 0, emojis.length));
  return (
    <Window title={title} width={400} height={500}>
      <style>
        {`@keyframes flickerAnimation {
          0%   { opacity: 1; }
          50%  { opacity: 0; }
          100% { opacity: 1; }
        }
        #cursor {
          display: inline-block;
          height: 40px;
          width: 0px;
          border-radius: 0;
          border: 1px solid #aaaaaa;
          animation: flickerAnimation 1s infinite;
        }
        .EmojiButton {
          width: 48px;
          height: 48px;
          transition: outline linear 0.25s;
          outline: 1px solid transparent;
          outline-offset: -4px;
        }
        .EmojiButton:hover {
          outline-color: white;
          transition-duration: 0;
        }
        #emoji-input {
          border: 1px solid white;
          border-radius: 2px;
          min-height: 54px;
          transition: 1s linear border-color;
        }
        .emoji-contents {
          width: 100%;
          padding: 0;
          max-height: 270px;
          overflow-y: scroll;
        }
        `}
      </style>
      <Window.Content
        scrollable
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.code;
          const e = window.event ? window.event : event;
          switch (keyCode) {
            case KEY_ENTER:
              submit();
              e.preventDefault();
              break;
            case KEY_BACKSPACE:
              backspace();
              e.preventDefault();
              break;
            case KEY_LEFT:
              left();
              e.preventDefault();
              break;
            case KEY_RIGHT:
              right();
              e.preventDefault();
              break;
          }
        }}>
        <Section title="Entry">
          <Button icon="arrow-left" onClick={left} />
          <Button icon="arrow-right" onClick={right} />
          <Button color="red" content="Backspace" onClick={backspace} />
          <div id="emoji-input">
            {insert(
              emojis.map((emoji) => <div key={emoji} className={`emoji48x48 ${emoji}`} />),
              cursor_pos,
              <div id="cursor" />
            )}
          </div>
          <Button color="green" content="Submit" onClick={submit} />
          <Button color="red" content="Cancel" onClick={() => act('cancel')} />
        </Section>
        <Section fitted title="Emojis">
          <div className="emoji-contents">
            {Object.keys(all_emojis)
              .slice(1)
              .map((emoji) => (
                <Box
                  key={emoji}
                  value={emoji}
                  className={`EmojiButton emoji48x48 ${emoji}`}
                  onClick={(event) => {
                    setEmojis(insert(emojis, cursor_pos, event.target.value));
                    setCursorPos(cursor_pos + 1);
                  }}
                />
              ))}
          </div>
        </Section>
      </Window.Content>
    </Window>
  );
};
