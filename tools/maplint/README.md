# maplint
maplint is a tool that lets you prohibit anti-patterns in maps through simple rules. You can use maplint to do things like ban variable edits for specific types, ban specific variable edits, ban combinations of types, etc.

## Making lints

To create a lint, create a new file in the `lints` folder. Lints use [YAML](https://learnxinyminutes.com/docs/yaml/), which is very expressive, though can be a little complex. If you get stuck, read other lints in this folder.

### Typepaths
The root of the file is your typepaths. This will match not only that type, but also subtypes. For example:

```yml
/mob/dog:
  # We'll get to this...
```

...will define rules for `/mob/dog`, `/mob/dog/corgi`, `/mob/dog/beagle`, etc.

If you only want to match a specific typepath, prefix it with `=`. This:

```yml
=/mob/dog:
```

...will only match `/mob/dog` specifically.

Alternatively, if you want to match ALL types, enter a single `*`, for wildcard.

### `banned`
The simplest rule is to completely ban a subtype. To do this, fill with `banned: true`.

For example, this lint will ban `/mob/dog` and all subtypes:

```yml
/mob/dog:
  banned: true # Cats FTW
```

### `banned_neighbors`
If you want to ban other objects being on the same tile as another, you can specify `banned_neighbors`.

This takes a few forms. The simplest is just a list of types to not be next to. This lint will ban either cat_toy *or* cat_food (or their subtypes) from being on the same tile as a dog.

```yml
/mob/dog:
  banned_neighbors:
  - /obj/item/cat_toy
  - /obj/item/cat_food
```

This also supports the `=` format as specified before. This will ban `/mob/dog` being on the same tile as `/obj/item/toy` *only*.

```yml
/mob/dog:
  banned_neighbors:
  - =/obj/item/toy # Only the best toys for our dogs
```

Anything in this list will *not* include the object itself, meaning you can use it to make sure two of the same object are not on the same tile. For example, this lint will ban two dogs from being on the same tile:

```yml
/mob/dog:
  banned_neighbors:
  - /mob/dog # We're a space station, not a dog park!
```

However, you can add a bit more specificity with `identical: true`. This will prohibit other instances of the *exact* same type *and* variable edits from being on the same tile.

```yml
/mob/dog:
  banned_neighbors:
    # Purebreeds are unnatural! We're okay with dogs as long as they're different.
    /mob/dog: { identical: true }
```

Finally, if you need maximum precision, you can specify a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) to match for a path. If we wanted to ban a `/mob/dog` from being on the same tile as `/obj/bowl/big/cat`, `/obj/bowl/small/cat`, etc, we can write:

```yml
/mob/dog:
  banned_neighbors:
    CAT_BOWLS: { pattern: ^/obj/bowl/.+/cat$ }
```

### `banned_variables`
To ban all variable edits, you can specify `banned_variables: true` for a typepath. For instance, if we want to block dogs from getting any var-edits, we can write:

```yml
/mob/dog:
  banned_variables: true # No var edits, no matter what
```

If we want to be more specific, we can write out the specific variables we want to ban.

```yml
/mob/dog
  banned_variables:
  - species # Don't var-edit species, use the subtypes
```

We can also explicitly create allowlists and denylists of values through `allow` and `deny`. For example, if we want to make sure we're not creating invalid bowls for animals, we can write:

```yml
/obj/bowl/dog:
  banned_variables:
    species:
      # If we specify a species, it's gotta be a dog
      allow: ["beagle", "corgi", "pomeranian"]

/obj/bowl/humans:
  banned_variables:
    species:
      # We're civilized, we don't want to eat from the same bowl that's var-edited for animals
      deny: ["cats", "dogs"]
```

Similar to [banned_neighbors](#banned_neighbors), you can specify a regular expression pattern for allow/deny.

```yml
/mob/dog:
  banned_variables:
    # Names must start with a capital letter
    name:
      allow: { pattern: '^[A-Z].*$' }
```

### `help`
If you want a custom message to go with your lint, you can specify "help" in the root.

```yml
help: Pugs haven't existed on Sol since 2450.
/mob/dog/pug:
  banned: true
```

### `disabled`

The disabled flag can be set in the root if the rule should be skipped. This is convenient if you have lints for a feature which is not ready to be linted against.

```yml
disabled: true
/mob/dog/pug:
  banned: true
```

### `when` - Conditional Rules

Sometimes it may be necessary for a rule to be given conditions which have to be met before it needs to be applied. All children of the when node must be satisfied for the rule to execute.

If we wanted to create a rule which disallows the placement of access helpers when an airlock's access has been manually set via a variable edit, then we could make the following rule:

```yml
/obj/machinery/door/airlock:
	when:
	- req_access_txt is set
	banned_neighbors:
	- /obj/effect/mapping_helper/airlock/access
```

The following conditions are valid:
- **{var_name} is set**: The variable named *var_name* has been modified.
- **{var_name} is not set**: The variable named *var_name* has not been modified.
- **{var_name} is '{value}'**: The variable named *var_name* has a specific value.
- **{var_name} is not '{value}'**: The variable named *var_name* does not have a specific value.
- **{var_name} like '{regex}'**: The variable named *var_name* matches the provided regex.

#### `any`

The any node may be added as a child to the when node to specify that it will be satisfied if any of its child conditions are met.

```yml
/mob/dog:
	# Rule only applies when the dog is any of the following breeds
	when:
	- any:
		- breed is 'labrador'
		- breed is 'pug'
		- breed is 'corgi'
	# These breeds of dogs must have a dogbed
	required_neighbors:
	- /obj/dogbed
```

#### `all`

The all node may be added as a child to the when node to specify that it will be satisfied only when all of its child conditions are met. Note that the `all` node only makes sense to use when the parent node is an `any` node, as the default behaviour of `when` is to require all conditions to be met.

```yml
/mob/dog:
	# Rule only applies if the dog breed is capitalised and has an owner
	when:
	- all:
		- breed like '[A-Z][a-z]*'
		- owner is set
	# These dogs must have a dogbed for their owner
	required_neighbors:
	- /obj/dogbed
```
