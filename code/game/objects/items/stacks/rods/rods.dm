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
	materials = list(/datum/material/iron=1000)
	max_amount = 50
	merge_type = /obj/item/stack/rods
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	embedding = list()
	novariants = TRUE

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")//it looks like theyre ur mum
	return BRUTELOSS

/obj/item/stack/rods/get_recipes()
	return GLOB.rod_recipes

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src)) // we can be deleted during merge, check before doing stuff
		return

	update_icon()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/stack/rods/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		target.attackby(src, user, click_parameters)

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this!</span>")
			return

		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/stack/sheet/iron/new_item = new(usr.loc)
			user.visible_message("[user.name] shaped [src] into iron with [W].", \
						 "<span class='notice'>You shape [src] into iron with [W].</span>", \
						 "<span class='italics'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(new_item)

	else if(istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = W
		if(amount != 1)
			to_chat(user, "<span class='warning'>You must use a single rod!</span>")
		else if(S.w_class > WEIGHT_CLASS_SMALL)
			to_chat(user, "<span class='warning'>The ingredient is too big for [src]!</span>")
		else
			var/obj/item/reagent_containers/food/snacks/customizable/A = new/obj/item/reagent_containers/food/snacks/customizable/kebab(get_turf(src))
			A.initialize_custom_food(src, S, user)
	else
		return ..()

