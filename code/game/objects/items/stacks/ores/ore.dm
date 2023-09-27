
#define ORESTACK_OVERLAYS_MAX 10

/obj/item/stack/ore
	name = "rock"
	desc = "A rather dull rock for a stone."
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "ore"
	item_state = "ore"
	full_w_class = WEIGHT_CLASS_BULKY
	singular_name = "ore chunk"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into
	novariants = TRUE // Ore stacks handle their icon updates themselves to keep the illusion that there's more going
	var/list/stack_overlays
	var/scan_state = "" //Used by mineral turfs for their scan overlay.
	var/spreadChance = 0 //Also used by mineral turfs for spreading veins

/obj/item/stack/ore/update_icon()
	var/difference = min(ORESTACK_OVERLAYS_MAX, amount) - (LAZYLEN(stack_overlays)+1)
	if(difference == 0)
		return
	else if(difference < 0 && LAZYLEN(stack_overlays))			//amount < stack_overlays, remove excess.
		cut_overlays()
		if (LAZYLEN(stack_overlays)-difference <= 0)
			stack_overlays = null;
		else
			stack_overlays.len += difference
	else if(difference > 0)			//amount > stack_overlays, add some.
		cut_overlays()
		for(var/i in 1 to difference)
			var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
			newore.pixel_x = rand(-8,8)
			newore.pixel_y = rand(-8,8)
			LAZYADD(stack_overlays, newore)
	if (stack_overlays)
		add_overlay(stack_overlays)

/obj/item/stack/ore/welder_act(mob/living/user, obj/item/I)
	if(!refined_type)
		return TRUE

	if(I.use_tool(src, user, 0, volume=50, amount=15))
		new refined_type(drop_location())
		use(1)

	return TRUE

/obj/item/stack/ore/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(isnull(refined_type))
		return
	else
		var/probability = (rand(0,100))/100
		var/burn_value = probability*amount
		var/amountrefined = round(burn_value, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(drop_location(),amountrefined)
			qdel(src)

/obj/item/stack/ore/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	pixel_x = base_pixel_x + rand(0,16) - 8
	pixel_y = base_pixel_y + rand(0,8) - 8

/obj/item/stack/ore/ex_act(severity, target)
	if (!severity || severity >= 2)
		return
	qdel(src)

#undef ORESTACK_OVERLAYS_MAX
