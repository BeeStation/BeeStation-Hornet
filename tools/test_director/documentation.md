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

### Move player in-range
```gherkin
Given the player is next to {variable_name}
```

### Set variable of atom
```gherkin
Given the {variable_name} device is set to {variable_name}
```

### Ensure player holding item
```gherkin
Given the player is holding {type}
```

## Test Actions

### Player click input
```gherkin
When the player clicks the {variable_name}
```

### Player use item in hand
```gherkin
When the human uses {variable_name}
```

## Assertions

### Assert variable status
```gherkin
Then {variable_name} pressed should be {value}
```

### Verify UI window was opened
```gherkin
Then a TGUI window should open
```
