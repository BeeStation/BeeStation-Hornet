/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)

/obj/structure/destructible/cult/Initialize(mapload)
	. = ..()
	generate_psychic_mask()

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	set_density(FALSE)
	visible_message(span_danger("[src] fades away."))
	invisibility = INVISIBILITY_SPIRIT
	alpha = 100 //To help ghosts distinguish hidden runes
	light_range = 0
	light_power = 0
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	set_density(initial(density))
	invisibility = 0
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is [anchored ? "":"not "]secured to the floor.")
	if((IS_CULTIST(user) || isobserver(user)) && cooldowntime > world.time)
		. += span_cultitalic("The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].")

/obj/structure/destructible/cult/examine_status(mob/user)
	if(IS_CULTIST(user) || isobserver(user))
		var/t_It = p_They()
		var/t_is = p_are()
		return span_cult("[t_It] [t_is] at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/artificer))
		if(atom_integrity < max_integrity)
			M.changeNext_move(CLICK_CD_MELEE)
			atom_integrity = min(max_integrity, atom_integrity + 5)
			Beam(M, icon_state="sendbeam", time=4)
			M.visible_message(span_danger("[M] repairs \the <b>[src]</b>."), \
				span_cult("You repair <b>[src]</b>, leaving [p_they()] at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability."))
		else
			to_chat(M, span_cult("You cannot repair [src], as [p_theyre()] undamaged!"))
	else
		..()

/obj/structure/destructible/cult/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	icon_state = "talismanaltar"
	break_message = span_warning("The altar shatters, leaving only the wailing of the damned!")

/obj/structure/destructible/cult/talisman/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/list/items = list(
		"Eldritch Whetstone" = image(icon = 'icons/obj/cult.dmi', icon_state = "cult_sharpener"),
		"Construct Shell" = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct_cult"),
		"Flask of Unholy Water" = image(icon = 'icons/obj/drinks/drinks.dmi', icon_state = "holyflask"),
		"Runic Golem Shell" = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype += /obj/item/sharpener/cult
		if("Construct Shell")
			pickedtype += /obj/structure/constructshell
		if("Flask of Unholy Water")
			pickedtype += /obj/item/reagent_containers/cup/glass/bottle/unholywater
		if("Runic Golem Shell")
			pickedtype += /obj/item/golem_shell/runic
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You kneel before the altar and your faith is rewarded with the [choice]!"))

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar'Sie."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = span_warning("The force breaks apart into shards with a howling scream!")

/obj/structure/destructible/cult/forge/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("The heat radiating from [src] pushes you back."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/list/items = list(
		"Shielded Robe" = image(icon = 'icons/obj/clothing/suits/armor.dmi', icon_state = "cult_armor"),
		"Flagellant's Robe" = image(icon = 'icons/obj/clothing/suits/armor.dmi', icon_state = "cultrobes"),
		"Mirror Shield" = image(icon = 'icons/obj/shields.dmi', icon_state = "mirror_shield")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Shielded Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Mirror Shield")
			pickedtype += /obj/item/shield/mirror
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You work the forge as dark knowledge guides your hands, creating the [choice]!"))

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = span_warning("The books and tomes of the archives burn into ash as the desk shatters!")

/obj/structure/destructible/cult/tome/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!IS_CULTIST(user))
		to_chat(user, span_warning("These books won't open and it hurts to even try and read the covers."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, span_cultitalic("The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)]."))
		return
	var/list/items = list(
		"Zealot's Blindfold" = image(icon = 'icons/obj/clothing/glasses.dmi', icon_state = "blindfold"),
		"Shuttle Curse" = image(icon = 'icons/obj/cult.dmi', icon_state = "shuttlecurse"),
		"Veil Walker Set" = image(icon = 'icons/obj/cult.dmi', icon_state = "shifter")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Zealot's Blindfold")
			pickedtype += /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			pickedtype += /obj/item/shuttle_curse
		if("Veil Walker Set")
			pickedtype += /obj/item/cult_shift
			pickedtype += /obj/item/flashlight/flare/culttorch
		else
			return
	if(src && !QDELETED(src) && anchored && pickedtype.len && Adjacent(user) && !user.incapacitated && IS_CULTIST(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You summon the [choice] from the archives!"))

/obj/structure/destructible/cult/tome/library //library archive
	debris = null

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return
