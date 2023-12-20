//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	novariants = TRUE

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"

/* Bones */

/obj/item/stack/sheet/bone
	name = "bones"
	icon_state = "bone"
	item_state = "sheet-bone"
	icon = 'icons/obj/stacks/organic.dmi'
	singular_name = "bone"
	desc = "Someone's been drinking their milk."
	force = 7
	throwforce = 5
	max_amount = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	grind_results = list(/datum/reagent/carbon = 10)
	merge_type = /obj/item/stack/sheet/bone

/* Sinew */

/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/stacks/organic.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	novariants = TRUE


GLOBAL_LIST_INIT(sinew_recipes, list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/restraints/handcuffs/cable/sinew, 1), \
))

/obj/item/stack/sheet/sinew/get_main_recipes()
	. = ..()
	. += GLOB.sinew_recipes

/obj/item/stack/sheet/splinter
	name = "splinters"
	icon_state = "sheet-trenchshards"
	item_state = "sheet-trenchshards"
	icon = 'icons/obj/stacks/organic.dmi'
	singular_name = "splinter"
	desc = "Shards gathered from the abyss. These prick your fingers slightly when you hold them, and you reckon they'd stick if you threw them at someone."
	force = 5
	throwforce = 10
	max_amount = 15
	embedding = list("armour_block" = 30, "embed_chance" = 50)
	throw_speed = 5
	grind_results = list(/datum/reagent/silver = 10)
	merge_type = /obj/item/stack/sheet/splinter
	sharpness = IS_SHARP

/obj/item/stack/sheet/splinter/Initialize(mapload)
	AddComponent(/datum/component/caltrop, force, _flags=CALTROP_BYPASS_SHOES|CALTROP_NO_PARALYSIS)
	. = ..()

/obj/item/stack/sheet/splinter/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	. = ..()
	var/hit_hand = ((thrower.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(ishuman(thrower))
		var/mob/living/carbon/human/H = thrower
		if(!H.gloves && !HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			to_chat(H, "<span class='warning'>[src] cuts into your hand as you throw it!</span>")
			H.apply_damage(src.force*0.5, BRUTE, hit_hand)
	else if(ismonkey(thrower))
		var/mob/living/carbon/monkey/M = thrower
		if(!HAS_TRAIT(M, TRAIT_PIERCEIMMUNE))
			to_chat(M, "<span class='warning'>[src] cuts into your hand as you throw it!</span>")
			M.apply_damage(src.force*0.5, BRUTE, hit_hand)
