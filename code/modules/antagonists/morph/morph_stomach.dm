/datum/morph_stomach
	var/name = "morph stomach"
	var/mob/living/simple_animal/hostile/morph/morph
	var/list/base64_cache = list()
	var/list/favorites = list()

/datum/morph_stomach/New(my_morph)
	. = ..()
	morph = my_morph

/datum/morph_stomach/Destroy()
	morph = null
	. = ..()

/datum/morph_stomach/ui_state(mob/user)
	return GLOB.always_state

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
	for(var/atom/movable/A in morph.contents)
		if(!isliving(A) && !isitem(A))
			continue
		var/list/element = list()
		element["living"] = isliving(A)
		element["name"] = A.name
		element["id"] = REF(A)
		element["favorite"] = favorites.Find(element["id"])
		element["digestable"] = TRUE
		var/base64 = null
		var/icon_state_temp = A.icon_state_preview || A.icon_state
		if(icon_state_temp == "" || icon_state_temp == null)
			if("[A.icon]" == "icons/mob/human.dmi")
				icon_state_temp = "ghost"
		if(icon_state_temp != "" && icon_state_temp != null)
			var/icon_key = "[A.icon]-[icon_state_temp]"
			if(base64_cache[icon_key] != null)
				base64 = base64_cache[icon_key]
			else
				base64 = icon2base64(icon(A.icon, icon_state_temp, frame=1, dir=SOUTH))
				base64_cache[icon_key] = base64
			element["img"] = base64
		if(isliving(A))
			data_living[element["id"]] = element
		else if(isitem(A))
			var/obj/item/I = A
			element["digestable"] = !(I.resistance_flags & UNACIDABLE) && !(I.resistance_flags & ACID_PROOF) && !(I.resistance_flags & INDESTRUCTIBLE)
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
	var/atom/movable/target = null
	for(var/atom/movable/A in morph.contents)
		if(REF(A) == ref)
			target = A
			break
	if(target == null || (!isliving(target) && !isitem(target)))
		return
	switch(action)
		if("drop")
			morph.RemoveContents(target)
			morph.visible_message("<span class='warning'>[morph] spits [target] out!</span>")
			playsound(morph, 'sound/effects/splat.ogg', 50, 1)
			return TRUE
		if("disguise")
			morph.ShiftClickOn(target)
			return FALSE
		if("throw")
			morph.throwatom = target
			to_chat(morph, "<span class='danger'>You prepare to throw [target]</span>")
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
		var/mob/living/L = target
		switch(action)
			if("digest")
				if(HAS_TRAIT(L, TRAIT_HUSK))
					to_chat(morph, "<span class='warning'>[L] has already been stripped of all nutritional value!</span>")
					return FALSE
				if(morph.throwatom == L)
					morph.throwatom = null
				to_chat(morph, "<span class='danger'>You begin digesting [L]</span>")
				if(do_after(morph, L.maxHealth))
					if(ishuman(L) || ismonkey(L) || isalienadult(L) || istype(L, /mob/living/simple_animal/pet/dog) || istype(L, /mob/living/simple_animal/parrot))
						var/list/turfs_to_throw = view(2, morph)
						for(var/obj/item/I in L.contents)
							L.dropItemToGround(I, TRUE)
							if(QDELING(I))
								continue //skip it
							I.throw_at(pick(turfs_to_throw), 3, 1, spin = FALSE)
							I.pixel_x = rand(-10, 10)
							I.pixel_y = rand(-10, 10)
					morph.RemoveContents(L)
					L.death(0)
					L.apply_damage(50, BURN)
					L.become_husk()
					morph.adjustHealth(-(L.maxHealth / 2))
					to_chat(morph, "<span class='danger'>You digest [L], restoring some health</span>")
					playsound(morph, 'sound/effects/splat.ogg', 50, 1)
					return TRUE
	else if(isitem(target))
		var/obj/item/I = target
		switch(action)
			if("use")
				I.attack_self(morph)
			if("usethrow")
				morph.throwatom = I
				to_chat(morph, "<span class='danger'> You prepare to throw [I]</span>")
				I.attack_self(morph)
				return TRUE
			if("digest")
				if(morph.throwatom == I)
					morph.throwatom = null
				if((I.resistance_flags & UNACIDABLE) || (I.resistance_flags & ACID_PROOF) || (I.resistance_flags & INDESTRUCTIBLE))
					to_chat(morph, "<span class='danger'>[I] cannot be digested.</span>")
				else
					playsound(morph, 'sound/items/welder.ogg', 150, 1)
					qdel(I)
					to_chat(morph, "<span class='danger'>You digest [I].</span>")
					return TRUE

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
