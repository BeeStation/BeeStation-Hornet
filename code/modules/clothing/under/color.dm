/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	worn_icon_state = "jumpsuit"
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	supports_variations = DIGITIGRADE_VARIATION
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/color/jumpskirt
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON //Doesn't require a new icon.
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	icon_state = "jumpskirt"

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/color/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - subtypesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost  - /obj/item/clothing/under/rank/prisoner)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/jumpskirt/random
	icon_state = "random_jumpsuit"		//Skirt variant needed

/obj/item/clothing/under/color/jumpskirt/random/Initialize(mapload)
	..()
	var/obj/item/clothing/under/color/jumpskirt/C = pick(subtypesof(/obj/item/clothing/under/color/jumpskirt) - /obj/item/clothing/under/color/jumpskirt/random)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "grey_ancient"
	item_state = "gy_suit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	can_adjust = FALSE

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.force_say(hitby)
	return 0

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	greyscale_colors = "#ffa69b"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	greyscale_colors = "#eb0c07"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	greyscale_colors = "#ffffff"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	greyscale_colors = "#ffe14d"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	greyscale_colors = "#3285ba"

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/color/jumpskirt/teal
	name = "teal jumpskirt"
	greyscale_colors = "#77f3b7"

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	greyscale_colors = "#9f70cc"

/obj/item/clothing/under/color/darkgreen
	name = "dark green jumpsuit"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/color/jumpskirt/darkgreen
	name = "dark green jumpskirt"
	greyscale_colors = "#6fbc22"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "light brown jumpskirt"
	greyscale_colors = "#c59431"

/obj/item/clothing/under/color/khaki
	name = "khaki jumpsuit"
	greyscale_colors = "#af9a43"

/obj/item/clothing/under/color/khaki/buster
	name = "buster jumpsuit"
	desc = "There seems to be a large stain in the left pocket. Someone must have squashed a really big twinkie."

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	greyscale_colors = "#a17229"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/color/jumpskirt/maroon
	name = "maroon jumpskirt"
	greyscale_colors = "#cc295f"

/obj/item/clothing/under/color/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	greyscale_colors = "#8291a1"
	armor = list("melee" = 10, "laser" = 10, "fire" = 40, "acid" = 10, "bomb" = 5, "stamina" = 30)

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	can_adjust = FALSE
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "A multi-colored jumpskirt!"
	icon_state = "rainbow_skirt"
	item_state = "rainbow"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
