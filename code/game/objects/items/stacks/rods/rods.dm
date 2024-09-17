/obj/item/stack/rods
	name = "iron rod"
	desc = "Some rods. Can be used for building or something."
	singular_name = "iron rod"
	icon_state = "rods"
	item_state = "rods"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	mats_per_unit = list(/datum/material/iron=1000)
	max_amount = 50
	merge_type = /obj/item/stack/rods
	attack_verb_continuous = list("hits", "bludgeons", "whacks")
	attack_verb_simple = list("hit", "bludgeon", "whack")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	embedding = list()
	novariants = TRUE
	matter_amount = 2
	cost = 250
	source = /datum/robot_energy_storage/metal

	///What is the result when we weld 2 rods together?
	var/obj/item/welding_result = /obj/item/stack/sheet/iron
	///How many of this rod do we need to be able to weld it into a sheet of usable material
	var/amount_needed = 2

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")//it looks like theyre ur mum
	return BRUTELOSS

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/rods)

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src)) // we can be deleted during merge, check before doing stuff
		return

	update_icon()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/stack/rods/get_recipes()
	return GLOB.rod_recipes

/obj/item/stack/rods/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		target.attackby(src, user, click_parameters)

/obj/item/stack/rods/update_icon_state()
	. = ..()
	var/amount = get_amount()
	if(amount <= 5)
		icon_state = "[initial(icon_state)]-[amount]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < amount_needed)
			to_chat(user, "<span class='warning'>You need at least [amount_needed] of [src] to do this!</span>")
			return

		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/result = new welding_result(usr.loc)
			user.visible_message("[user.name] shaped [src] into [result] with [W].", \
						"<span class='notice'>You shape [src] into [result] with [W].</span>", \
						"<span class='italics'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(result)

	else
		return ..()

/obj/item/stack/rods/glass
	name = "glass scraps"
	desc = "Some glass scraps that can be used in arts and crafts."
	singular_name = "glass scrap"
	icon_state = "glass-rods"
	item_state = "glass-rods"
	flags_1 = NONE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 100,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100, STAMINA = 0, BLEED = 0)
	mats_per_unit = list(/datum/material/glass=1000)
	merge_type = /obj/item/stack/rods/glass
	attack_verb_continuous = list("stabs", "slashes", "slices", "cuts")
	attack_verb_simple = list("stab", "slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	source = /datum/robot_energy_storage/glass
	welding_result = /obj/item/stack/sheet/glass

/obj/item/stack/rods/glass/get_recipes()
	return GLOB.glass_rod_recipes
