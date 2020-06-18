import { Fragment, Component } from 'inferno';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Input, Section, Collapsible, LabeledList, Modal, ColorBox, Box, Icon, Dropdown } from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';


const colorboxify = entry => {
  // add a helpful little ColorBox to visually tell
  // which color a string represents. cool, eh?
  if (entry.type === "Text"
    && entry.value[1] === "#"
    && entry.value.length === 9) {
    // entry.value should be something like "#aabbcc" (commas included)
    return (
      <Fragment>
        <ColorBox color={entry.value.slice(1, 8)} />
        {" "}
        {entry.value}
      </Fragment>
    ); }
  return (entry.value);
};


const damagebuttonswitch = dmg => {
  switch (dmg[0]) {
    case "brute":
      return ["#FF0000", "Brute"];
    case "fire":
      return ["#FF6600", "Fire"];
    case "toxin":
      return ["#008000", "Toxin"];
    case "oxy":
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

export const ViewVariables = (props, context) => {
  const { act, data } = useBackend(context);
  const { objectinfo, vars, snowflake, dropdown } = data;

  // verSection first, it's the simplest.
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const Search = createSearch(searchText, item => {
    return item;
  });

  const varSearch = entry => {
    return Search(entry.name)||Search(entry.value.toString());
  };

  const Label = entry => {
    return (
      <Button
        content={entry.name}
        title={entry.ref
          ? "View "+entry.ref
          : "Edit "+entry.name+" ("+entry.type+")"}
        fluid
        ellipsis
        maxWidth={15}
        color="transparent"
        onClick={entry.ref
          // if ref is defined, we wanna open it in another
          // window instead of attempting to edit
          // see debug_variables.dm @/proc/debug_variable2
          ? () => act("view", { target: entry.ref })
          : () => act("edit", {
            targetdatum: objectinfo.ref,
            targetvar: entry.name })} />
    );
  };

  const Value = entry => {
    return (
      <Fragment>
        {colorboxify(entry) || "null"}
        {entry.items && entry.items.map(
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
        label={Label(item)}
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
            onClick={() => act("refresh")}
            icon="sync" />

        </Fragment>
      }>
      <LabeledList>
        {vars
          .filter(varSearch)
          .map(Entry)}
      </LabeledList>

    </Section>
  );


  // topSection time.
  let Sprite;
  if (snowflake.sprite_base64) {
    Sprite = (
      <img src={`data:image/jpeg;base64,${snowflake.sprite_base64}`} />
    );
  }

  let BasicInfo = (
    <Flex direction="column" align="center">

      <FlexItem>
        <Button color="transparent" textColor="white" fontSize={1.5}>
          {objectinfo.name}
        </Button>
      </FlexItem>

      <FlexItem>
        <Button color="transparent" icon="undo"
          onClick={() => act("rotateLeft")} />

        <Box inline fontSize={1.2}>{"South"}</Box>

        <Button color="transparent" icon="redo"
          onClick={() => act("rotateRight")} />
      </FlexItem>

      <FlexItem>
        {objectinfo.type}
      </FlexItem>

    </Flex>
  );

  let LivingInfo;
  if (snowflake.DamageStats) {
    let Body = Object.entries(snowflake.DamageStats.Body);
    // let Organ = Object.entries(snowflake.DamageStats.Organ);
    const makedamagebutton = entry => {
      let [color, content] = damagebuttonswitch(entry);
      return (
        <FlexItem grow={1}>
          <Button
            fluid

            backgroundColor={color}
            content={content+": "+entry[1]||" "}
            onClick={() => act("adjustdamage", { type: entry[0] })} />
        </FlexItem>
      );
    };

    LivingInfo = (
      <Section>
        <Flex wrap="wrap" spacing={1} justify="center">
          {Body.map(makedamagebutton)}
        </Flex>
      </Section>

    );
  }
  // {Organ.map(makedamagebutton)}
  // Plan for the future is to make a complete health manipulation screen.
  // Ability to add implants, change organs, specific limb damage too.
  // Complete package.


  const makeDropdown = item => {
    return (
      <Button
        fluid
        content={item[1]}
        onClick={() => act(item[0])} />
    );
  };

  // Neither Dropdown or Checkbox or literally anything else served
  // So I had to make this amalgamation. I am not proud of it.

  const [
    DropdownOpen,
    Setdropdown,
  ] = useLocalState(context, 'DropdownOpen', false);

  const DropdownBoi = () => {
    if (DropdownOpen) {
      return (
        <Button
          color="transparent"
          icon={DropdownOpen ? 'check-square-o' : 'square-o'}
          selected={DropdownOpen}
          onClick={() => Setdropdown(!DropdownOpen)}
          content="aa" />
      );
    }

    else {
      return (
        <Button
          color="transparent"
          icon={DropdownOpen ? 'check-square-o' : 'square-o'}
          selected={DropdownOpen}
          onClick={() => Setdropdown(!DropdownOpen)}
          content="bb" />
      );
    }
  };


  const topSection = (
    <Section
      title="AAAAAAAAAA"
      buttons={DropdownBoi()}>
      <Flex
        justify="center"
        wrap="wrap"
        textAlign="center"
        align="center">


        <FlexItem grow={1}>
          <Section>
            {Sprite}
            {BasicInfo}
          </Section>
        </FlexItem>

        {
        // For some reason the flex LivingInfo has
        // doesn't wrap if this width isn't set
        // It then scales properly to fit so no problem
        }
        <FlexItem width={100}>
          {LivingInfo}
        </FlexItem>

      </Flex>
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
