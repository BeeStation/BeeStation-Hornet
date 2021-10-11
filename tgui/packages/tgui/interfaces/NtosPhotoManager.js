import { useBackend } from '../backend';
import { Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPhotoManager = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    files = [],
  } = data;
  return (
    <NtosWindow
      width={500}
      height={500}>
      <NtosWindow.Content scrollable>
        <Section>
          <Button
            content="Scan Photo"
            onClick={() => act('PRG_scan')} />
          <Button
            content="Print Photo"
            onClick={() => act('PRG_print')} />
          <Button
            icon="eject"
            content="Toggle Camera"
            onClick={() => act('PRG_camera')} />
        </Section>
        <PicTable
          files={files}
          onLoad={file => act('PRG_load', {name: file})}
          onRename={(file, newName) => act('PRG_rename', {
            name: file,
            new_name: newName,
          })}/>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const PicTable = props => {
  const {
    files = [],
    onLoad,
    onRename,
  } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>
          Picture
        </Table.Cell>
      </Table.Row>
      {files.map(file => (
        <Table.Row key={file.name} className="candystripe">
          <Table.Cell>
            {!file.undeletable ? (
              <Button.Input
                fluid
                content={file.name}
                currentValue={file.name}
                tooltip="Rename"
                onCommit={(e, value) => onRename(file.name, value)} />
            ) : (
              file.name
            )}
          </Table.Cell>
          <Table.Cell>
              <Button
                icon="upload"
                onClick={() => onLoad(file.name)} />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
