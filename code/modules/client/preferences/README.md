# Preferences (by Mothblocks)

This does not contain all the information on specific values--you can find those as doc-comments in relevant paths, such as `/datum/preference`. Rather, this gives you an overview for creating _most_ preferences, and getting your foot in the door to create more advanced ones.

## Anatomy of a preference (A.K.A. how do I make one?)

Most preferences consist of two parts:

1. A `/datum/preference` type.
2. A tgui representation in a TypeScript file.

Every `/datum/preference` requires these three values be set:

1. `category` - See [Categories](#Categories).
2. `db_key` - The value which will be saved in the savefile. This will also be the identifier for tgui.
3. `preference_type` - Whether or not this is a character specific preference (`PREFERENCE_CHARACTER`) or one that affects the player (`PREFERENCE_PLAYER`). As an example: hair color is `PREFERENCE_CHARACTER` while your UI settings are `PREFERENCE_PLAYER`, since they do not change between characters.

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
import { FeatureChoiced, FeatureDropdownInput } from "../base";

export const favorite_drink: FeatureChoiced = {
	name: "Favorite drink",
	component: FeatureDropdownInput,
};
```

This will create a dropdown input for your preference.

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

You can also read preferences directly with `preferences.read_preference(/datum/preference/type/here)`, which will return the stored value.

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
	to_chat(user, span_notice("Wow, you did a great job learning about middleware!"))

	return TRUE
```

Middleware can inject its own data at several points, such as providing new UI assets, compiled data (used by middleware such as quirks to tell the client what quirks exist), etc. Look at `code/modules/client/preferences/middleware/_middleware.dm` for full information.

---

## Antagonists

TODO: See \_role_preference.dm and role_preferences.dm
