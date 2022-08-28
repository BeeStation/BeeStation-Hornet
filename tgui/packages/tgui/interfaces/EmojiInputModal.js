import { useBackend, useLocalState } from '../backend';
import { Box, Section, Button } from '../components';
import { Window } from '../layouts';

const clamp = (num, min, max) => Math.min(Math.max(num, min), max);

export const EmojiInputModal = (_, context) => {
  const { data, act } = useBackend(context);
  const {
    title,
    all_emojis = [],
  } = data;
  const [emojis, setEmojis] = useLocalState(context, 'emoji_input_text', []);
  const [cursor_pos, setCursorPos] = useLocalState(context, 'emoji_input_cursor', 0);

  const insert = (arr, index, newItem) => [
    ...arr.slice(0, index),
    newItem,
    ...arr.slice(index),
  ];
  const remove = (arr, index) => [
    ...arr.slice(0, index - 1),
    ...arr.slice(index),
  ];
  return (
    <Window title={title} width={400} height={500}>
      <style>
        {`@keyframes flickerAnimation {
          0%   { opacity: 1; }
          50%  { opacity: 0; }
          100% { opacity: 1; }
        }
        .EmojiButton {
          transition: outline linear 0.25s;
          outline: 1px solid transparent;
          outline-offset: -4px;
          &:hover {
            outline-color: white;
            transition-duration: 0;
          }
        }`}
      </style>
      <Window.Content scrollable>
        <Section title="Entry">
          <Button
            icon="arrow-left"
            onClick={() => {
              setCursorPos(clamp(cursor_pos - 1, 0, emojis.length));
            }} />
          <Button
            icon="arrow-right"
            onClick={() => {
              setCursorPos(clamp(cursor_pos + 1, 0, emojis.length));
            }} />
          <Button
            color="red"
            content="Backspace"
            onClick={() => {
              if (cursor_pos > 0 && cursor_pos <= emojis.length) {
                setEmojis(remove(emojis, cursor_pos));
                setCursorPos(cursor_pos - 1);
              }
            }} />
          <Box style={{ border: "1px solid white", "border-radius": "5px", height: "50px" }}>
            {insert(emojis.map(emoji => (<div
              key={emoji}
              className={`emoji48x48 ${emoji}`} />)), cursor_pos, <div style={
              { height: "40px",
                width: "0px",
                borderRadius: 0,
                border: "1px solid #aaaaaa",
                display: "inline-block",
                animation: "flickerAnimation 1s infinite",
              }
            } />)}
          </Box>
          <Button
            color="green"
            content="Submit"
            onClick={() => act('submit', { entry: emojis.map(emoji => `:${emoji}:`).join(" ") })} />
          <Button
            color="red"
            content="Cancel"
            onClick={() => act('cancel')} />
        </Section>
        <Section fitted title="Emojis">
          {Object.keys(all_emojis).slice(1).map(emoji => (<div
            key={emoji}
            value={emoji}
            className={`EmojiButton emoji48x48 ${emoji}`}
            onClick={event => {
              setEmojis(insert(emojis, cursor_pos,
                event.target.value));
              setCursorPos(cursor_pos + 1);
            }}
          />))}
        </Section>
      </Window.Content>
    </Window>
  );
};
