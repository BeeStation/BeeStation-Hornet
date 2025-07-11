# Preferences

Credit to Mothblocks for writing the basis of this document and the preferences system.

Ported and heavily altered by itsmeow to BeeStation.

This does not contain all the information on specific values--you can find those as doc-comments in relevant paths, such as `/datum/preference`. Rather, this gives you an overview for creating _most_ preferences, and getting your foot in the door to create more advanced ones.

## Reading Preferences

Reading preferences is super simple:

```dm
prefs.read_player_preference(/datum/preference/toggle/sound_ship_ambience)
```

The above will read the ship ambiance toggle from player-prefs. If you want a character preference, you need to use `read_character_preference` instead. You can check the type of the preference datum by viewing its `preference_type` var.

```dm
prefs.read_character_preference(/datum/preference/name/real_name)
```

## Writing Preferences (outside the menu)

You can alter a preference from code using the following code:

```dm
prefs.update_preference(/datum/preference/toggle/sound_ship_ambience, TRUE)
```

This would enable the ship ambience preference. This will also automatically queue a save.

Altering an undatumized preference (e.g. one stored on the preferences datum itself, like job preferences) should always be followed by `prefs.mark_undatumized_dirty_player()` or `prefs.mark_undatumized_dirty_character()`, to ensure the preference saves. Datumized preferences will automatically save if update_preference is used.

## Anatomy of a preference (A.K.A. how do I make one?)

Most preferences consist of two parts:

1. A `/datum/preference` type.
2. A tgui representation in a TypeScript file.

Every `/datum/preference` requires these three values be set:

1. `category` - See [Categories](#Categories).
2. `db_key` - The value which will be saved in the database. This will also be the identifier for tgui.
3. `preference_type` - Whether or not this is a character specific preference (`PREFERENCE_CHARACTER`) or one that affects the player (`PREFERENCE_PLAYER`). As an example: hair color is `PREFERENCE_CHARACTER` while your UI settings are `PREFERENCE_PLAYER`, since they do not change between characters. This also affects which getter is used (get_player_preference or get_character_preference)

For the tgui representation, most preferences will create a `.tsx` file in `tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/`. If your preference is a character preference, make a new file in `character_preferences`. Otherwise, put it in `game_preferences`. The filename does not matter, and this file can hold multiple relevant preferences if you would like.

From here, you will want to write code resembling:

```ts
import { Feature } from "../base";

export const db_key_here: Feature<T> = {
	name: "Preference Name Here",
	component: Component,

	// Necessary for game preferences, unused for others
	category: "CATEGORY",

	// Optional, only shown in game preferences
	description: "This preference will blow your mind!",
};
```

`T` and `Component` depend on the type of preference you're making. Here are all common examples...

## Numeric preferences

Examples include age and FPS.

A numeric preference derives from `/datum/preference/numeric`.

```dm
/datum/preference/numeric/legs
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "legs"

	minimum = 1
	maximum = 8
```

You can optionally provide a `step` field. This value is 1 by default, meaning only integers are accepted.

Your `.tsx` file would look like:

```ts
import { Feature, FeatureNumberInput } from "../base";

export const legs: Feature<number> = {
	name: "Legs",
	component: FeatureNumberInput,
};
```

## Toggle preferences

Examples include enabling tooltips.

```dm
/datum/preference/toggle/enable_breathing
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "enable_breathing"

	// Optional, TRUE by default
	default_value = FALSE
```

Your `.tsx` file would look like:

```ts
import { CheckboxInput, FeatureToggle } from "../base";

export const enable_breathing: FeatureToggle = {
	name: "Enable breathing",
	component: CheckboxInput,
};
```

## Choiced preferences

A choiced preference is one where the only options are in a distinct few amount of choices. Examples include skin tone, shirt, and UI style.

To create one, derive from `/datum/preference/choiced`.

```dm
/datum/preference/choiced/favorite_drink
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "favorite_drink"
```

Now we need to tell the game what the choices are. We do this by overriding `init_possible_values()`. This will return a list of possible options.

```dm
/datum/preference/choiced/favorite_drink/init_possible_values()
	return list(
		"Milk",
		"Cola",
		"Water",
	)
```

Your `.tsx` file would then look like:

```tsx
import { FeatureChoiced, FeatureButtonedDropdownInput } from "../base";

export const favorite_drink: FeatureChoiced = {
	name: "Favorite drink",
	component: FeatureButtonedDropdownInput,
};
```

This will create a dropdown input for your preference, including buttons to cycle between options. Do note that if there are less than 4 options this will automatically be flattened into choice buttons.

### Choiced preferences - Icons

Choiced preferences can generate icons. This is how the clothing/species preferences work, for instance. However, if we just want a basic dropdown input with icons, it would look like this:

```dm
/datum/preference/choiced/favorite_drink
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "favorite_drink"
	should_generate_icons = TRUE // NEW! This is necessary.

// Instead of returning a flat list, this now returns an assoc list
// of values to icons.
/datum/preference/choiced/favorite_drink/init_possible_values()
	return list(
		"Milk" = icon('drinks.dmi', "milk"),
		"Cola" = icon('drinks.dmi', "cola"),
		"Water" = icon('drinks.dmi', "water"),
	)
```

Then, change your `.tsx` file to look like:

```tsx
import { FeatureChoiced, FeatureIconnedDropdownInput } from "../base";

export const favorite_drink: FeatureChoiced = {
	name: "Favorite drink",
	component: FeatureIconnedDropdownInput,
};
```

### Choiced preferences - Display names

Sometimes the values you want to save in code aren't the same as the ones you want to display. You can specify display names to change this.

The only thing you will add is "compiled data".

```dm
/datum/preference/choiced/favorite_drink/compile_constant_data()
	var/list/data = ..()

	// An assoc list of values to display names
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"Milk" = "Delicious Milk",
		"Cola" = "Crisp Cola",
		"Water" = "Plain Ol' Water",
	)

	return data
```

Your `.tsx` file does not change. The UI will figure it out for you!

## Color preferences

These refer to colors, such as your OOC color. When read, these values will be given as 6 hex digits, _without_ the pound sign.

```dm
/datum/preference/color/eyeliner_color
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	preference_type = PREFERENCE_CHARACTER
	db_key = "eyeliner_color"
```

Your `.tsx` file would look like:

```ts
import { FeatureColorInput, Feature } from "../base";

export const eyeliner_color: Feature<string> = {
	name: "Eyeliner color",
	component: FeatureColorInput,
};
```

## Name preferences

These refer to an alternative name. Examples include AI names and backup human names.

These exist in `code/modules/client/preferences/names.dm`.

These do not need a `.ts` file, and will be created in the UI automatically.

```dm
/datum/preference/name/doctor
	db_key = "doctor_name"

	// The name on the UI
	explanation = "Doctor name"

	// This groups together with anything else with the same group
	group = "medicine"

	// Optional, if specified the UI will show this name actively
	// when the player is a medical doctor.
	relevant_job = /datum/job/medical_doctor
```

## Color Palettes

This allows you to predefine color choices, and looks really nice. You can also lock it to specific colors or allow custom colors.

`StandardizedPalette` props:

-   `choices`: A list of actual values this palette will give to DM.
-   `choices_to_hex`: A map of choice keys to their actual hex values, for display purposes. This is not needed if hex_values is true.
-   `displayNames`: A map of actual values to display names, for tooltips.
-   `onSetValue`: Called when a value is chosen.
-   `value`: The currently selected value.
-   `hex_values`: A boolean saying if the color provided is a hex color or a string (see: skin color, which is a string)
-   `allow_custom`: A boolean saying if you can select a custom color. Only works with hex values.
-   `featureId`: The feature ID of this entry.
-   `act`: The act() function of this entry.
-   `includeHex`: If the hex value should be shown on the tooltip / display name. Useful for custom color presets.

```
import { Feature, FeatureValueProps, StandardizedPalette } from '../base';

const eyePresets = {
  '#aaccff': 'Baby Blue',
  '#0099bb': 'Blue-Green',
};

export const eye_color: Feature<string> = {
  name: 'Eye Color',
  small_supplemental: false,
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(eyePresets)}
        displayNames={eyePresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
        maxWidth="100%"
        includeHex
      />
    );
  },
};
```

## Attaching secondary preferences

Some preferences are attached to other preferences, like hair color to hair styles. This is called a supplementary feature.

To do this, first set its category to `PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES`:

```dm
/datum/preference/color/hair_color
	db_key = "hair_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
```

Then, on the parent feature, add to its constant data a SUPPLEMENTAL_FEATURE_KEY with the db_key of the supplemental:

```dm
/datum/preference/choiced/hairstyle/compile_constant_data()
	var/list/data = ..()
	data[SUPPLEMENTAL_FEATURE_KEY] = "hair_color"
	return data
```

Now, configure its TGUI entry. `small_supplemental` dictates if it is placed in the top corner or at the bottom of the feature popup.

`predictable` disables the TGUI-side prediction system that caches the value sent from the UI. This is important if the value sent is expected to be transformed in some way or updates atypically, such as with custom color palettes.

```js
export const hair_color: Feature<string> = {
  name: 'Hair Color',
  small_supplemental: false,
  predictable: false,
  component: /* ... */,
};
```

## Game Preferences

Most of the documentation above covers character preferences. Game preferences have a few unique features as well, such as descriptions and subcategories.

Here is an example:

```js
export const chat_radio: FeatureToggle = {
	name: "Hear Radio",
	category: "ADMIN",
	subcategory: "Chat",
	description: "Hear all radio messages while adminned.",
	component: CheckboxInput,
};
```

Category is which header it will fall under, and subcategory adds a subheader that will join with other entries in this category and subcategory. It will also show in search results. The description is shown on hover.

## Making your preference do stuff

There are a handful of procs preferences can use to act on their own:

```dm
/// Apply this preference onto the given client.
/// Called when the preference_type == PREFERENCE_PLAYER.
/datum/preference/proc/apply_to_client(client/client, value)

/// Fired when the preference is updated.
/// Calls apply_to_client by default, but can be overridden.
/datum/preference/proc/apply_to_client_updated(client/client, value)

/// Apply this preference onto the given human.
/// Must be overriden by subtypes.
/// Called when the preference_type == PREFERENCE_CHARACTER.
/datum/preference/proc/apply_to_human(mob/living/carbon/human/target, value)
```

For example, `/datum/preference/numeric/age` contains:

```dm
/datum/preference/numeric/age/apply_to_human(mob/living/carbon/human/target, value)
	target.age = value
```

If your preference is `PREFERENCE_CHARACTER`, it MUST override `apply_to_human`, even if just to immediately `return`.

You can also read preferences directly with `preferences.read_character/player_preference(/datum/preference/type/here)`, which will return the stored value.

## Categories

Every preference needs to be in a `category`. These can be found in `code/__DEFINES/preferences.dm`.

```dm
/// These will be shown in the character sidebar, but at the bottom.
#define PREFERENCE_CATEGORY_FEATURES "features"

/// Any preferences that will show to the sides of the character in the setup menu.
#define PREFERENCE_CATEGORY_CLOTHING "clothing"

/// Preferences that will be put into the 3rd list, and are not contextual.
#define PREFERENCE_CATEGORY_NON_CONTEXTUAL "non_contextual"

/// Will be put under the game preferences window.
#define PREFERENCE_CATEGORY_GAME_PREFERENCES "game_preferences"

/// These will show in the list to the right of the character preview.
#define PREFERENCE_CATEGORY_SECONDARY_FEATURES "secondary_features"

/// These are preferences that are supplementary for main features,
/// such as hair color being affixed to hair.
#define PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES "supplemental_features"
```

![Preference categories for the main page](https://raw.githubusercontent.com/tgstation/documentation-assets/main/preferences/preference_categories.png)

> SECONDARY_FEATURES or NON_CONTEXTUAL?

Secondary features tend to be species specific. Non contextual features shouldn't change much from character to character.

## Default values and randomization

There are three procs to be aware of in regards to this topic:

-   `create_default_value()`. This is used when a value deserializes improperly or when a new character is created.
-   `create_informed_default_value(datum/preferences/preferences)` - Used for more complicated default values, like how names require the gender. Will call `create_default_value()` by default.
-   `create_random_value(datum/preferences/preferences)` - Explicitly used for random values, such as when a character is being randomized.

`create_default_value()` in most preferences will create a random value. If this is a problem (like how default characters should always be human), you can override `create_default_value()`. By default (without overriding `create_random_value`), random values are just default values.

## Advanced - Server data

As previewed in [the display names implementation](#Choiced-preferences---Display-names), there exists a `compile_constant_data()` proc you can override.

Compiled data is used wherever the server needs to give the client some value it can't figure out on its own. Skin tones use this to tell the client what colors they represent, for example.

Compiled data is sent to the `serverData` field in the `FeatureValueProps`.

## Advanced - Creating your own tgui component

If you have good knowledge with tgui (especially TypeScript), you'll be able to create your own component to represent preferences.

The `component` field in a feature accepts **any** component that accepts `FeatureValueProps<TReceiving, TSending = TReceiving, TServerData = undefined>`.

This will give you the fields:

```ts
act: typeof sendAct,
featureId: string,
handleSetValue: (newValue: TSending) => void,
serverData: TServerData | undefined,
shrink?: boolean,
value: TReceiving,
```

`act` is the same as the one you get from `useBackend`.

`featureId` is the db_key of the feature.

`handleSetValue` is a function that, when called, will tell the server the new value, as well as changing the value immediately locally.

`serverData` is the [server data](#Advanced---Server-data), if it has been fetched yet (and exists).

`shrink` is whether or not the UI should appear smaller. This is only used for supplementary features.

`value` is the current value, could be predicted (meaning that the value was changed locally, but has not yet reached the server).

For a basic example of how this can look, observe `CheckboxInput`:

```tsx
export const CheckboxInput = (
	props: FeatureValueProps<BooleanLike, boolean>
) => {
	return (
		<Button.Checkbox
			checked={!!props.value}
			onClick={() => {
				props.handleSetValue(!props.value);
			}}
		/>
	);
};
```

## Advanced - Middleware

A `/datum/preference_middleware` is a way to inject your own data at specific points, as well as hijack actions.

Middleware can hijack actions by specifying `action_delegations`:

```dm
/datum/preference_middleware/congratulations
	action_delegations = list(
		"congratulate_me" = PROC_REF(congratulate_me),
	)

/datum/preference_middleware/congratulations/proc/congratulate_me(list/params, mob/user)
	to_chat(user, ("<span class='notice'>Wow, you did a great job learning about middleware!</span>"))
	return TRUE
```

Middleware can inject its own data at several points, such as providing new UI assets, compiled data (used by middleware such as quirks to tell the client what quirks exist), etc. Look at `code/modules/client/preferences/middleware/_middleware.dm` for full information.

---

## Antagonists

Role preferences are separate from antagonist datums and ban roles, but are connected. You can define a new role preference easily:

```
/datum/role_preference/antagonist/changeling
	name = "Changeling"
	description = "A highly intelligent alien predator that is capable of altering their \
	shape to flawlessly resemble a human.\n\
	Transform yourself or others into different identities, and buy from an \
	arsenal of biological weaponry with the DNA you collect."
	antag_datum = /datum/antagonist/changeling
```

Newlines (`\n`) are converted to Stack dividers in TGUI, making a horizontal line element. The antag_datum is used for checking bans / playtime.

Defining a `preview_outfit` with an outfit typepath will make the icon preview a human with said outfit.

You can also override `get_preview_icon()` to set a specific icon, look at other examples for more.

Using this preference is a simple matter of checking `client.role_preference_enabled(/datum/role_preference/antagonist/changeling)`

The parent type (`/datum/role_preference/antagonist`) determines what category it will show under. See `GLOB.role_preference_categories` for a list of categories.

## Species

Adding support for a species to the preference menu involves adding some proc overrides on the species datum (descriptions, traits, etc).

Most importantly, override `get_species_description()` and `get_species_lore()`. Then, add any unique perks to `create_pref_unique_perks()`, or add them to the respective procs (see `get_species_perks()`) if they could apply to another species.

You also need to set the plural_form for use in perk descriptions.

Do note that many perks are automatically generated, so a perk may not actually be "unique". Unique perks often include roleplay elements (such as Asimov Superiority) rather than specific gameplay elements, since those can be generic (such as temperature resistance).

A perk looks like this:

```
list(list(
	SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
	SPECIES_PERK_ICON = "radiation",
	SPECIES_PERK_NAME = "Radiation Immune",
	SPECIES_PERK_DESC = "[plural_form] are entirely immune to radiation.",
))
```

The icon can be a tgfont icon (tg-iconname) or a fontawesome icon. Finding exact FA icons can be difficult, but searching the v5 index for free icons usually works. We use v5.9, but the index is only v5.15, so there may be some incorrect icons on the index.

A perk can be `SPECIES_POSITIVE_PERK`, `SPECIES_NEGATIVE_PERK`, or `SPECIES_NEUTRAL_PERK`.

Changing the preview icon can be done via overriding `/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)`, by changing various dna features. Make sure the result is not random, or it will change between game loads, which could be confusing.

## Internals and Implementation details

### Database Read/Write

#### SSpreferences

The preferences system reads and writes from the database, and otherwise has no other form of serialization. To reduce database traffic, preference writes are queued by the SSpreferences subsystem, which accepts preference datums by ckey and holds writes in a queue. Duplicate writes are not performed, so the maximum amount a preferences datum can write is every fire of this SS (approx 5 seconds).

While preferences are in this queue, the TGUI is sent a status indicator with its queue status. When a write completes, the preferences menu updates a value stating if the write was successful or not, which is displayed on the UI, alongside a reason. This is shown in the title bar.

Do note that closing the preference menu essentially forces an immediate save, bypassing the queue system. This is useful during disconnections, as the UI is closed before full disconnect, triggering a save, and the preferences subsystem will not process disconnected clients.

#### Preference Holders

Character and player preferences both have their own `/datum/preferences_holder`, as they have different database schemas and need their own logic. The preferences_holder controls writing and reading datumized preferences to/from the database and initializing default preferences when there is no database.

##### Local Caching

Alongside queuing writes to reduce traffic, all preference values are cached locally, as querying the database for every preference retrieval would be a huge overhead. This is done via the preferences holder, which stores an associative list of db_keys to preference values.

##### Dirty Preferences

To reduce the amount of data written when an update is performed, only values that are changed are written to the database. Previously, any time "Save Preferences" was pressed, all preferences values, regardless of if they were changed or not, were immediately written. This poses a huge waste of database bandwidth and introduces potential problems with changing every other preference accidentally if some type of error were to occur.

Instead, a list of preference db_keys is maintained (`dirty_prefs`). When a value is updated, it adds its db_key to this list. Then, when a write is performed, this list forms the columns that will be updated, rather than simply including all of them. After the write, the list is cleared. This drastically reduces database use, during typical use.

##### Value Serialization

Game Preferences store all values as strings in the database, and so do many non-string character preferences. This means that before a write, all preferences are converted to strings and converted back when deserialized. This is performed in `/datum/preference/proc/deserialize` and ``/datum/preference/proc/serialize`. These procs are used both for reading/writing from the DB and reading/writing from the UI. For most things, strings are OK anyway, as many values are natively strings (choiced lists, colors, etc.), although numbers will do some basic number parsing.

This does complicate some choiced lists, as it may not be ideal to store the display name in the database, but you want to show pretty names in the UI. In this case, serialize() fails to act as desired, since you will get the "ugly" name in the UI. This is when things like get_constant_data are used to map ugly names to pretty names for the UI. It is always best to prioritize the database over the UI, since the UI can adapt easily.

Values inside the preference cache are always in their deserialized form, and are serialized ONLY when sent to the UI or database. This is because the value in the cache is what is directly returned when read in code.

When a preference is written to the cache, it is always deserialized, as it is expected to come from the UI or database. This could be problematic if the deserializer is badly implemented and alters the already deserialized form of the preference.

##### Undatumized system

save_preferences() and save_character() include additional logic for undatumized preferences. This system is important for values that cannot be easily represented in the small units of datumized preferences (like job preferences), or are not actually preferences (like the last changelog value). In order to reduce overall database use while minimizing code clutter, undatumized preferences can be marked globally dirty, so that all undatumized prefs will write if any one changes. While this is not perfect, it reduces the code work put in for these less common preferences while minimzing unnecessary queries.

Datumized and undatumized preferences use separate SQL queries for each write, so it is ideal to prevent writing one entirely if it can be done.

These are marked dirty by the procs: `mark_undatumized_dirty_player` and `mark_undatumized_dirty_character`, which also queue writes to the database in SSpreferences. Essentially, if you want to change an undatumized preference in code, you should always call the matching proc here so that the change is actually saved. Because undatumized preferences have no proc wrappers around their values and are stored directly on the preference datum, this is the only way the preference system knows if they have changed.

`ready_to_save_character()` and `ready_to_save_player()` will return if there are ANY dirty preferences (datumized or undatumized), if you want to know if any values have changed since last save.
