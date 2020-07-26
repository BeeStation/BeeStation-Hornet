import { Fragment, Component } from 'inferno';
import { createSearch, capitalize } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Input, Section, LabeledList, ColorBox, Box, Icon } from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';
import { isFalsy } from 'common/react';


const colorboxify = item => {
  // add a helpful little ColorBox to visually tell
  // which color a string represents. cool, eh?
  if (item.type === "Text"
    && item.value[1] === "#"
    && item.value.length === 9) {
    // entry.value should be something like "#aabbcc" (commas included)
    return (
      <Fragment>
        <ColorBox color={item.value.slice(1, 8)} />
        {" "}
        {item.value}
      </Fragment>
    ); }
  return (item.value);
};

const matrixify = item => {
  const M = item.matrix;
  if (isFalsy(M)) {
    return;
  }
  return (
    <Flex inline direction="column">
      <Flex.Item>{M[0]} {M[1]} 0</Flex.Item>
      <Flex.Item>{M[2]} {M[3]} 0</Flex.Item>
      <Flex.Item>{M[4]} {M[5]} 1</Flex.Item>
    </Flex>
  );
};

export const ViewVariables = (props, context) => {
  const { act, data } = useBackend(context);
  const { objectinfo, vars, snowflake, dropdown, flags } = data;

  // verSection first, it's the simplest.
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const testSearchTerms = createSearch(searchText, entry => (
    entry.name + String(entry.value)
  ));


  const Label = (item, islist) => {
    let LabelOnClick;
    if (islist) {
      LabelOnClick = e => {
        if (e.shiftKey && e.ctrlKey) {
          act("listremove", { targetvar: item.index });
        }
        else if (e.shiftKey) {
          act("listchange", { targetvar: item.index });
        }
        else {
          act("listedit", { targetvar: item.index });
        }
      };
    }
    else {
      LabelOnClick = e => {
        if (e.shiftKey && e.ctrlKey) {
          act("massedit", { targetvar: item.name });
        }
        else if (e.shiftKey) {
          act("datumchange", { targetvar: item.name });
        }
        /* nothing for now
        else if (e.ctrlKey) {
          act("", { target: item.ref} )
        }
        */
        else {
          act("datumedit", { targetvar: item.name });
        }
      };
    }

    return (
      <Button
        content={item.name}
        title={item.ref
          ? `View ${item.name}`
          : `Edit ${item.name} (${item.type})`}
        fluid
        ellipsis
        maxWidth={15}
        color="transparent"
        onClick={e => LabelOnClick(e)} />
    );
  };

  const Value = item => {
    return (
      <Fragment>
        <Button
          onClick={item.ref
            ? () => act("view", { target: item.ref })
            : () => act("datumedit", { targetvar: item.name })}>
          {item.file && <Icon name="file" mr={1} />}
          {item.icon && <Icon name="image" mr={1} />}
          {matrixify(item) || colorboxify(item) || item.value}
        </Button>
        {item.items && item.items.map(
          item => { return Entry(item); })}
      </Fragment>
    );
  };

  const Entry = item => {
    // So for some reason the bounding box of these
    // overflows the section and I dunno how to fix it
    return (
      <LabeledList.Item
        className="candystripe"
        label={Label(item, (objectinfo.name === "/list"))}
        content={Value(item)} />
    );
  };

  const varSection = (
    <Section
      title="Variables"
      buttons={
        <Fragment>

          <Input inline
            placeholder="Search"
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1}
          />

          <Button
            onClick={() => act("to_asay")}
            title="Share to admin chat"
            icon="share" />

          <Button
            onClick={() => act("refresh")}
            title="Refresh"
            icon="sync" />

        </Fragment>
      }>
      <LabeledList>
        {vars
          .filter(testSearchTerms)
          .map(Entry)}
      </LabeledList>

    </Section>
  );


  // topSection time.
  let Sprite;
  if (snowflake?.sprite_base64) {
    Sprite = (
      <img
        height={256}
        width={256}
        src={`data:image/jpeg;base64,${snowflake.sprite_base64}`} />
    );
  }

  let BasicInfo = (
    <Flex direction="column" align="center">

      <FlexItem>
        <Button
          color="transparent"
          textColor="white"
          fontSize={1.5}
          onClick={() => act("vv_rename")}>
          {objectinfo.name}
        </Button>
      </FlexItem>

      {snowflake?.direction && (
        <FlexItem>
          <Button m={0} color="transparent" icon="undo"
            onClick={() => act("rotate", { dir: "left" })} />

          <Box inline fontSize={1.2}>{capitalize(snowflake.direction)}</Box>

          <Button m={0} color="transparent" icon="redo"
            onClick={() => act("rotate", { dir: "right" })} />
        </FlexItem>) }

      <FlexItem>
        {objectinfo.type}
      </FlexItem>

    </Flex>
  );

  const basicsnowflake = (
    <FlexItem grow={1}>
      {Sprite}
      <Box mx={2}>{BasicInfo}</Box>
      {LivingInfo}
    </FlexItem>
  );

  const damagebuttonswitch = dmg => {
    switch (dmg[0]) {
      case "brute":
        return ["#FF0000", "Brute"];
      case "fire":
        return ["#FF6600", "Fire"];
      case "toxin":
        return ["#008000", "Toxin"];
      case "oxygen":
        return ["#1515AA", "Oxy"];
      case "clone":
        return ["#990099", "Clone"];
      case "stamina":
        return ["#B7A200", "Stamina"];

      case "brain":
        return ["#6d697a", "Brain"];
      case "stomach":
        return ["#6d697a", "Stomach"];
      case "ears":
        return ["#6d697a", "Ears"];
      case "eye_sight":
        return ["#6d697a", "Eyes"];
      case "lungs":
        return ["#6d697a", "Lungs"];
      case "heart":
        return ["#6d697a", "Heart"];
      case "liver":
        return ["#6d697a", "Liver"];

      default: // the fuq did you give me
        return ["#6d697a", dmg[0]];
    } };

  let LivingInfo;
  if (snowflake?.DamageStats) {
    const Body = Object.entries(snowflake.DamageStats.Body);
    const Organ = Object.entries(snowflake.DamageStats.Organ);
    const makedamagebutton = entry => {
      let [color, content] = damagebuttonswitch(entry);
      return (
        <FlexItem grow={1}>
          <Button
            fluid
            backgroundColor={color}
            content={`${content}: ${entry[1]}`||""}
            onClick={() => act("adjustdamage",
              { type: entry[0] })} />
        </FlexItem>
      );
    };
    const [
      OrganButtonsOpen,
      SetDamageButtons,
    ] = useLocalState(context, 'DamageButtons', false);
    LivingInfo = (
      // Plan for the future is to make a complete health manipulation screen:
      // Ability to add implants, change organs, specific limb damage too.
      // Complete package.
      // But for now... We'll stay simple.
      <Flex mt={1} wrap="wrap" spacing={1} justify="center">
        {OrganButtonsOpen
          ?Organ.map(makedamagebutton)
          :Body.map(makedamagebutton)}
        <Button
          color="transparent"
          textColor="#dd0000" // lil bit more red than the "red" preset
          icon={OrganButtonsOpen?"heartbeat":"plus"}
          onClick={() => SetDamageButtons(!OrganButtonsOpen)} />
      </Flex>
    );
  }


  // Neither Dropdown or Checkbox or literally anything else served
  // So I had to make this amalgamation. I am not proud of it.

  const [
    DropdownOpen,
    Setdropdown,
  ] = useLocalState(context, 'DropdownOpen', false);

  const DropdownButton = (
    <Button
      color="transparent"
      icon="bars"
      selected={DropdownOpen}
      onClick={() => Setdropdown(!DropdownOpen)} />
  );

  const makeDropdown = item => {
    return (
      <Button
        fluid
        content={item[1]}
        onClick={() => act(item[0])} />
    );
  };

  const DropdownMenu = (DropdownOpen && (
    // I am literally unable to figure out how to make this thing's height
    // Match basicsnowflake's height. Seriously. It's been two hours. I CAN'T.
    <Flex ml={1} height={26} overflowY="scroll" direction="column">
      {dropdown.map(makeDropdown)}
    </Flex>
  ));

  const Flags = flags && (
    <Flex position="absolute" direction="column">
      {flags.map(flag => { return (
        <FlexItem key={flag}>
          <Button
            color="red"
            content={flag} />
        </FlexItem>
      ); })}
    </Flex>
  );


  const topSection = (
    <Section
      title={`${objectinfo.name} (${objectinfo.class})`}
      buttons={DropdownButton}>
      <Section
        textAlign="center">
        {Flags}
        <Flex align="start">
          {basicsnowflake}
          {DropdownMenu}
        </Flex>
        {LivingInfo}
      </Section>
    </Section>
  );

  return (
    <Window
      theme="admin"
      resizable>
      <Window.Content scrollable>
        {topSection}
        {varSection}
      </Window.Content>
    </Window>
  );
};
