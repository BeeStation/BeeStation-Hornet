/// The max amount of health a morph can heal from food, as a percentage of the morph's maximum health.
#define MORPH_MAX_HEALING_FROM_FOOD		0.2
/// How long it takes for "food healed amt" to decay.
#define MORPH_FOOD_HEALING_DECAY_TIME	2.5 MINUTES

/datum/morph_stomach
	var/name = "morph stomach"
	var/mob/living/simple_animal/hostile/morph/morph
	var/list/base64_cache = list()
	var/list/favorites = list()
	var/food_healed = 0

/datum/morph_stomach/New(my_morph)
	. = ..()
	morph = my_morph

/datum/morph_stomach/Destroy()
	morph = null
	. = ..()

/datum/morph_stomach/ui_host(mob/user)
	return morph

/datum/morph_stomach/ui_state(mob/user)
	return GLOB.self_state

/datum/morph_stomach/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, morph, ui)
	if(!ui)
		ui = new(user, src, "Morph")
		ui.open()

/datum/morph_stomach/ui_data(mob/user)
	var/list/data = list()
	var/list/data_contents = list()
	var/list/data_living = list()
	var/list/data_items = list()
	for(var/atom/movable/consumed in morph.contents)
		if(!isliving(consumed) && !isitem(consumed))
			continue
		var/list/element = list()
		element["living"] = isliving(consumed)
		element["name"] = consumed.name
		element["id"] = REF(consumed)
		element["favorite"] = favorites.Find(element["id"])
		element["digestable"] = TRUE
		var/base64 = null
		var/icon_state_temp = consumed.icon_state_preview || consumed.icon_state
		if(icon_state_temp == "" || icon_state_temp == null)
			if("[consumed.icon]" == "icons/mob/human.dmi")
				icon_state_temp = "ghost"
		if(icon_state_temp != "" && icon_state_temp != null)
			var/icon_key = "[consumed.icon]-[icon_state_temp]"
			if(base64_cache[icon_key] != null)
				base64 = base64_cache[icon_key]
			else
				base64 = icon2base64(icon(consumed.icon, icon_state_temp, frame=1, dir=SOUTH))
				base64_cache[icon_key] = base64
			element["img"] = base64
		if(isliving(consumed))
			data_living[element["id"]] = element
		else if(isitem(consumed))
			var/obj/item/item = consumed
			element["digestable"] = !(item.resistance_flags & (UNACIDABLE | ACID_PROOF | INDESTRUCTIBLE))
			data_items[element["id"]] = element
	data_contents["living"] = data_living
	data_contents["items"] = data_items
	data["contents"] = data_contents
	data["throw_ref"] = REF(morph.throwatom)
	return data

/datum/morph_stomach/ui_act(action, params)
	if(..())
		return
	var/ref = params["id"]
	var/atom/movable/target = locate(ref) in morph.contents
	if(!target || (!isliving(target) && !isitem(target)))
		return
	switch(action)
		if("drop")
			morph.RemoveContents(target)
			morph.visible_message("<span class='warning'>[morph] spits <span class='name'>[target]</span> out!</span>")
			playsound(morph, 'sound/effects/splat.ogg', vol = 50, vary = TRUE)
			return TRUE
		if("disguise")
			morph.ShiftClickOn(target)
			return FALSE
		if("throw")
			morph.throwatom = target
			to_chat(morph, "<span class='danger'>You prepare to throw <span class='name'>[target]</span></span>")
			return TRUE
		if("unthrow")
			morph.throwatom = null
			return TRUE
		if("favorite")
			if(favorites.Find(ref))
				favorites -= ref
			else
				favorites += ref
			return TRUE
	if(isliving(target))
		var/mob/living/living_target = target
		switch(action)
			if("digest")
				if(HAS_TRAIT(living_target, TRAIT_HUSK))
					to_chat(morph, "<span class='warning'><span class='name'>[living_target]</span> has already been stripped of all nutritional value!</span>")
					return FALSE
				if(morph.throwatom == living_target)
					morph.throwatom = null
				to_chat(morph, "<span class='danger'>You begin digesting <span class='name'>[living_target]</span></span>")
				if(do_after(morph, living_target.maxHealth))
					if(ishuman(living_target) || ismonkey(living_target) || isalienadult(living_target) || istype(living_target, /mob/living/simple_animal/pet/dog) || istype(living_target, /mob/living/simple_animal/parrot))
						var/list/turfs_to_throw = view(2, morph)
						for(var/obj/item/item in living_target.contents)
							living_target.dropItemToGround(item, TRUE)
							if(QDELING(item))
								continue //skip it
							item.throw_at(pick(turfs_to_throw), 3, 1, spin = FALSE)
							item.pixel_x = rand(-10, 10)
							item.pixel_y = rand(-10, 10)
					morph.RemoveContents(living_target)
					living_target.death(FALSE)
					living_target.take_overall_damage(burn = 50)
					living_target.become_husk("burn") // Digested bodies can be fixed with synthflesh.
					morph.adjustHealth(-(living_target.maxHealth * 0.5))
					to_chat(morph, "<span class='danger'>You digest <span class='name'>[living_target]</span>, restoring some health</span>")
					playsound(morph, 'sound/effects/splat.ogg', vol = 50, vary = TRUE)
					return TRUE
	else if(isitem(target))
		var/obj/item/item = target
		switch(action)
			if("use")
				item.attack_self(morph)
			if("usethrow")
				morph.throwatom = item
				to_chat(morph, "<span class='danger'>You prepare to throw [item]</span>")
				item.attack_self(morph)
				return TRUE
			if("digest")
				if(morph.throwatom == item)
					morph.throwatom = null
				if(item.resistance_flags & (ACID_PROOF | UNACIDABLE | INDESTRUCTIBLE))
					to_chat(morph, "<span class='danger'>[item] cannot be digested.</span>")
				else
					if(item.reagents?.total_volume)
						var/nutriment_healing = clamp(CEILING(item.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 0.4, 1), 0, 5)
						var/vitamin_healing = clamp(CEILING(item.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment/vitamin) * 0.6, 1), 0, 5)
						if(max(nutriment_healing, vitamin_healing) <= 0)
							to_chat(morph, "<span class='warning'>There are not enough nutrients in [item] to heal from it!</span>")
						else
							var/max_heal_amt = round(morph.maxHealth * MORPH_MAX_HEALING_FROM_FOOD)
							var/left_to_heal = max_heal_amt - food_healed
							if(left_to_heal <= 0)
								to_chat(morph, "<span class='warning'>You cannot heal any more from food at the moment!</span>")
								return TRUE
							var/amt_healed = min(nutriment_healing + vitamin_healing, left_to_heal)
							if(amt_healed > 0)
								morph.adjustHealth(-amt_healed)
								food_healed += amt_healed
								addtimer(CALLBACK(src, PROC_REF(food_healing_decay_timer), amt_healed), MORPH_FOOD_HEALING_DECAY_TIME)
								playsound(morph, 'sound/items/eatfood.ogg', vol = 150, vary = TRUE)
								qdel(item)
								to_chat(morph, "<span class='danger'>You digest [item], regaining a small bit of health from its nutrients!</span>")
								return TRUE
					playsound(morph, 'sound/items/welder.ogg', vol = 150, vary = TRUE)
					qdel(item)
					to_chat(morph, "<span class='danger'>You digest [item].</span>")
					return TRUE

/datum/morph_stomach/proc/food_healing_decay_timer(amt)
	food_healed = max(food_healed - amt, 0)

/datum/action/innate/morph_stomach
	name = "Stomach Contents"
	icon_icon = 'icons/mob/animal.dmi'
	button_icon_state = "morph"
	var/datum/morph_stomach/morph_stomach

/datum/action/innate/morph_stomach/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/morph_stomach))
		morph_stomach = our_target
	else
		CRASH("morph_stomach action created with non stomach")

/datum/action/innate/morph_stomach/Activate()
	morph_stomach.ui_interact(owner)

#undef MORPH_FOOD_HEALING_DECAY_TIME
#undef MORPH_MAX_HEALING_FROM_FOOD
