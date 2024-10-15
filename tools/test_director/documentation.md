# Test Actions Documentation

## Overview
This documentation outlines the actions that can be performed in the testing framework for verifying interactions with devices and crafting functionality.

## Notes (Please Read)

- Common english prepositions (a/an/the) can be used and will have no impact on the
matches. They will be removed from any features when parsed (`the item` will be read
as `item`).
- Curly braces are documentation only, do not include them as variable names in the
test files that you create.

## Setup Rules

### Code Injection
```gherkin
Given the following code is injected:
  """
  /obj/item/assembly/unit_test
    var/pressed = FALSE

  /obj/item/assembly/unit_test/pulsed(mob/pulser)
    . = ..()
    pressed = TRUE
  """
```

### Allocate atoms and assign to variables
```gherkin
Given {variable_name} is defined as new {typepath}
```

### Allocate type from variable
```gherkin
Given {variable_name} is defined as {typepath} from {variable_name}
```

### Move player in-range
```gherkin
Given the player is next to {variable_name}
```

### Set variable of atom
```gherkin
Given the {variable_name} {dm_variable} is set to {variable_name}
Given the {variable_name} {dm_variable} is {variable_name}
```

### Ensure player holding item
```gherkin
Given the player is holding {variable_name}
```

## Event Actions

### Player click input
```gherkin
When the player clicks the {variable_name}
```

### Player use item in hand
```gherkin
When the player uses {variable_name}
```

## Assertions

### Assert variable status
```gherkin
Then {variable_name} {dm_variable} should be {value}
```

### Verify UI window was opened
```gherkin
Then a TGUI window should open
```

# Writing Actions

The action files are json files consisting of the following format:

```json
{
	"patterns": [
	  {
		"match": "regex pattern",
		"code": "player.ClickOn($1)"
	  },
	  {
		"match": "regex pattern",
		"code_injection": true
	  },
	]
  }

```

Certain variables may be injected into the matches.

`%TYPE%` will be replaced with a regex statement that matches typepaths. Example Match: `/datum/example`
`%NAME%` will be replaced with a regex statement that matches valid names. Example Match: `valid_variable_name`
`%PROC%` will be replaced with a regex statement that matches valid proc calls. Example Match: `call_function(1, 2, 3)`
`%VALUE%` will be replaced with a regex statement that matches any valid value. Example match: `"hello"`, `5`, `TRUE`, `a.b`
