/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = null
	icon_state = "jumpsuit"
	item_state = "jumpsuit"
	alternate_worn_icon = 'icons/mob/uniform.dmi'

/obj/item/clothing/under/color/jumpskirt
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	icon_state = "jumpskirt"

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize()
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - subtypesof(/obj/item/clothing/under/skirt/color) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost  - /obj/item/clothing/under/rank/prisoner)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/jumpskirt/random
	icon_state = "random_jumpsuit"		//Skirt variant needed

/obj/item/clothing/under/color/jumpskirt/random/Initialize()
	..()
	var/obj/item/clothing/under/color/jumpskirt/C = pick(subtypesof(/obj/item/clothing/under/skirt/color) - /obj/item/clothing/under/color/jumpskirt/random)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), ITEM_SLOT_ICLOTHING)
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	item_color = "black"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"
	item_color = "black_skirt"	

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"
	item_color = "grey"

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	greyscale_colors = "#b3b3b3"
	item_color = "grey_skirt"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "grey_ancient"
	item_state = "gy_suit"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.forcesay(GLOB.hit_appends)
	return 0

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	icon_state = "blue_skirt"
	greyscale_colors = "#52aecc"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	greyscale_colors = "#9ed63a"
	item_color = "green"

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	icon_state = "green_skirt"
	greyscale_colors = "#9ed63a"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	greyscale_colors = "#ff8c19"
	item_color = "orange"

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	icon_state = "orange_skirt"
	greyscale_colors = "#ff8c19"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	greyscale_colors = "#ffa69b"
	item_color = "pink"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	greyscale_colors = "#ffa69b"
	item_color = "pink_skirt"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	greyscale_colors = "#eb0c07"
	item_color = "red"

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	greyscale_colors = "#eb0c07"
	item_color = "red_skirt"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	greyscale_colors = "#ffffff"
	item_color = "white"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	greyscale_colors = "#ffffff"
	item_color = "white_skirt"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	greyscale_colors = "#ffe14d"
	item_color = "yellow"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	greyscale_colors = "#ffe14d"
	item_color = "yellow_skirt"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	greyscale_colors = "#3285ba"
	item_color = "darkblue"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	greyscale_colors = "#3285ba"
	item_color = "darkblue_skirt"

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	greyscale_colors = "#77f3b7"
	item_color = "teal"

/obj/item/clothing/under/color/jumpskirt/teal
	name = "teal jumpskirt"
	greyscale_colors = "#77f3b7"
	item_color = "teal_skirt"

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	greyscale_colors = "#9f70cc"
	item_color = "lightpurple"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	greyscale_colors = "#9f70cc"
	item_color = "lightpurple_skirt"

/obj/item/clothing/under/color/darkgreen
	name = "dark green jumpsuit"
	greyscale_colors = "#6fbc22"
	item_color = "darkgreen"

/obj/item/clothing/under/color/jumpskirt/darkgreen
	name = "dark green jumpskirt"
	greyscale_colors = "#6fbc22"
	item_color = "darkgreen_skirt"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	greyscale_colors = "#c59431"
	item_color = "lightbrown"

/obj/item/clothing/under/skirt/color/lightbrown
	name = "light brown jumpskirt"
	greyscale_colors = "#c59431"
	item_color = "lightbrown_skirt"

/obj/item/clothing/under/color/khaki
	name = "khaki jumpsuit"
	greyscale_colors = "af9a43"
	item_color = "khakij"

/obj/item/clothing/under/color/khaki/buster
	name = "buster jumpsuit"
	desc = "There seems to be a large stain in the left pocket. Someone must have squashed a really big twinkie."

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	greyscale_colors = "#a17229"
	item_color = "brown"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	greyscale_colors = "#a17229"
	item_color = "brown_skirt"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	greyscale_colors = "#cc295f"
	item_color = "maroon"

/obj/item/clothing/under/color/jumpskirt/maroon
	name = "maroon jumpskirt"
	greyscale_colors = "#cc295f"
	item_color = "maroon_skirt"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"
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
	item_color = "rainbow_skirt"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
