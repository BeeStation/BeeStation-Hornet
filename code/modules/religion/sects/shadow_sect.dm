// Shadow sect - Original code by DingoDongler
/datum/religion_sect/shadow_sect
	starter = FALSE
	name = "Shadow"
	desc = "A sect dedicated to the darkness. The manifested obelisks will generate favor from being in darkness."
	quote = "Turn out the lights, and let the darkness cover the world!"
	tgui_icon = "moon"
	alignment = ALIGNMENT_EVIL
	favor = 100 //Starts off with enough favor to make an obelisk
	max_favor = 50000
	desired_items = list(
		/obj/item/flashlight)
	rites_list = list(
		/datum/religion_rites/expand_shadows,
		/datum/religion_rites/shadow_obelisk,
		/datum/religion_rites/shadow_conversion,
		/datum/religion_rites/shadow_blessing,
		/datum/religion_rites/shadow_eyes,
		/datum/religion_rites/final_darkness)
	altar_icon_state = "convertaltar-dark"
	var/light_reach = 1
	var/light_power = 0
	var/list/obelisks = list()
	var/faithful_used = FALSE

/datum/religion_sect/shadow_sect/is_available(mob/user)
    if(isshadow(user))
        return TRUE
    return FALSE

//Shadow sect doesn't heal
/datum/religion_sect/shadow_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/shadow_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/flashlight))
		return
	adjust_favor(5, L)
	to_chat(L, "<span class='notice'>You offer [N] to [GLOB.deity], pleasing them and gaining 5 favor in the process.</span>")
	qdel(N)
	return TRUE

/datum/religion_sect/shadow_sect/on_select(atom/religious_tool, mob/living/user)
	. = ..()
	if(!religious_tool || !user)
		return
	religious_tool.AddComponent(/datum/component/dark_favor, user)

/datum/religion_sect/shadow_sect/on_conversion(mob/living/chap) //When sect is selected, and when a new chaplain joins after sect has been selected
	. = ..()
	if(is_special_character(chap))
		to_chat(chap,  "<span class='big notice'>As you are an antagonist role, you are free to spread darkness across the station.</span>")
		if(chap.mind.is_murderbone())
			to_chat(chap,  "<span class='big notice'>As you have a murderbone objective, Faithsworn will spawn with the Final Darkness rite.</span>")
	else
		to_chat(chap,  "<span class='userdanger'>You are not an antagonist, please do not spread darkness outside of the chapel without Command Staff approval.</span>")

// Shadow sect construction
/obj/structure/destructible/religion/shadow_obelisk
	name = "Shadow Obelisk"
	desc = "Grants favor from being shrouded in shadows."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "shadow-obelisk"
	anchored = FALSE
	break_message = "<span class='warning'>The Obelisk crumbles before you!</span>"
	var/heal_delay = 20
	var/last_heal = 0
	var/spread_delay = 45
	var/last_spread = 0

/obj/structure/destructible/religion/shadow_obelisk/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/religion/shadow_obelisk/process(delta_time)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect.faithful_used)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(L.health == L.maxHealth)
				continue
			if(!isshadow(L) && !L.mind?.holy_role && !isfaithless(L))
				continue
			new /obj/effect/temp_visual/heal(get_turf(src), "#29005f")
			if(isshadow(L) || L.mind?.holy_role || isfaithless(L))
				L.adjustBruteLoss(-2*delta_time, 0)
				L.adjustToxLoss(-2*delta_time, 0)
				L.adjustOxyLoss(-2*delta_time, 0)
				L.adjustFireLoss(-2*delta_time, 0)
				L.adjustCloneLoss(-2*delta_time, 0)
				L.updatehealth()
				if(L.blood_volume < BLOOD_VOLUME_NORMAL)
					L.blood_volume += 1.0

	if(last_spread <= world.time)
		var/list/validturfs = list()
		var/list/shadowturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/black))
				shadowturfs |= T
				continue
			var/static/list/blacklisted_obelisk_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/black,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm,
				/turf/open/openspace,
				/turf/open/floor/plating/beach,
				/turf/open/indestructible,
				/turf/open/floor/prison))
			if(is_type_in_typecache(T, blacklisted_obelisk_turfs))
				continue
			else
				validturfs |= T
		last_spread = world.time + spread_delay
		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/black, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/black, flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/black/F = safepick(shadowturfs)
			if(F)
				new /obj/effect/temp_visual/religion/turf/floor(F)
			else
				// Are we in space or something? No black turfs or
				// convertable turfs?
				last_spread = world.time + spread_delay*2

/obj/structure/destructible/religion/shadow_obelisk/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		if(user.mind?.holy_role == NONE)
			to_chat(user, "<span class='warning'>Only the faithful may control the disposition of [src]!</span>")
			return
		anchored = !anchored
		user.visible_message("<span class ='notice'>[user] [anchored ? "" : "un"]anchors [src] [anchored ? "to" : "from"] the floor with [I].</span>", "<span class ='notice'>You [anchored ? "" : "un"]anchor [src] [anchored ? "to" : "from"] the floor with [I].</span>")
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.do_attack_animation(src)
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		return
	return ..()

// Favor generator component. Used on the altar and obelisks
/datum/component/dark_favor //Original code by DingoDongler
	var/mob/living/creator

/datum/component/dark_favor/Initialize(mob/living/L)
	. = ..()
	if(!L)
		return
	creator = L
	START_PROCESSING(SSobj, src)

/datum/component/dark_favor/Destroy() //Original code by DingoDongler
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/component/dark_favor/process(delta_time) //Original code by DingoDongler
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!istype(parent, /atom) || !istype(creator) || !istype(sect))
		return
	var/atom/P = parent
	var/turf/T = P.loc
	if(!istype(T))
		return
	var/light_amount = T.get_lumcount()
	var/favor_gained = max(1 - light_amount, 0) * delta_time
	sect.adjust_favor(favor_gained, creator)

/**** Shadow rites ****/ //Original code by DingoDongler

#define DARKNESS_INVERSE_COLOR "#AAD84B" //The color of light has to be inverse, since we're using negative light power

/datum/religion_rites/shadow_conversion
	name = "Shadowperson Conversion"
	desc = "Converts a humanoid into a shadowperson, a race blessed by darkness."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Let the darkness seep into you...",
		"... And cover you, envelope you ...",
		"... And make you one with it ...")
	invoke_msg = "... And let you be born again!"
	favor_cost = 1200

/datum/religion_rites/shadow_conversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to convert the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(isshadow(user))
			to_chat(user,"<span class='warning'>You've already converted yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to convert yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/shadow_conversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/shadow)
	rite_target.visible_message("<span class='notice'>[rite_target] has been converted by the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/shadow_obelisk
	name = "Obelisk Manifestation"
	desc = "Creates an obelisk that generates favor when in a dark area."
	ritual_length = 45 SECONDS
	ritual_invocations = list(
		"Let the shadows combine...",
		"... Solidify and grow ...",
		"... Make an idol to eminate shadows ...")
	invoke_msg = "I summon forth an obelisk, to appease the darkness."
	favor_cost = 100 //Sect starts with 100 favor to begin

/datum/religion_rites/shadow_obelisk/invoke_effect(mob/living/user, atom/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	var/obj/structure/destructible/religion/shadow_obelisk/obelisk = new(altar_turf)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	sect.obelisks += obelisk
	obelisk.AddComponent(/datum/component/dark_favor, user)
	obelisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/expand_shadows
	name = "Shadow Expansion"
	desc = "Grow the reach of shadows extending from the altar, and any obelisks."
	ritual_length = 40 SECONDS
	ritual_invocations = list(
		"Spread out...",
		"... Kill the light ...",
		"... Encompass it all in darkness ...")
	invoke_msg = "Shadows, reach your tendrils from my altar, and extend thy domain."
	favor_cost = 175

/datum/religion_rites/expand_shadows/perform_rite(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if((sect.light_power <= -5) || (sect.light_reach >= 10))
		to_chat(user, "<span class='warning'>The shadows emanating from your idols is as strong as it could be.</span>")
		return FALSE
	return ..()

/datum/religion_rites/expand_shadows/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(!sect)
		return
	sect.light_reach += 2
	sect.light_power -= 1
	religious_tool.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	for(var/obj/structure/destructible/religion/shadow_obelisk/D in sect.obelisks)
		D.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)

/datum/religion_rites/shadow_blessing
	name = "Shadow Blessing"
	desc = "Bless someone with the power of shadows, and make them immune to all magic."
	ritual_length = 60 SECONDS
	ritual_invocations = list(
		"Let the darkness reside within us...",
		"... Let the power flow ...",
		"... Encompass our souls in shade ...",
		"... And let the demons know ...",
		"... That their powers will not work apon us any more...",)
	invoke_msg = "Bless thy brethen, and grant them immunity!"
	favor_cost = 8000

/datum/religion_rites/shadow_blessing/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to bless the one buckled on [movable_reltool].</span>")
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return FALSE
		if(isshadow(user))
			to_chat(user,"<span class='warning'>You've already blessed yourself. To convert others, they must be buckled to [movable_reltool].</span>")
			return FALSE
		to_chat(user,"<span class='warning'>You're going to bless yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/shadow_blessing/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	ADD_TRAIT(rite_target, TRAIT_ANTIMAGIC, MAGIC_TRAIT)
	to_chat(rite_target, "<span class='userdanger'>You are grateful to have been converted to the dark by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
	playsound(rite_target, 'sound/weapons/fwoosh.ogg', 75, 0)
	rite_target.visible_message("<span class='notice'>[rite_target] has been blessed by the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/shadow_eyes
	name = "Grant Shadow Eyes"
	desc = "Grants either the caster, or the buckled person, shadow eyes that give night vision."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Grant us the sight ...",
		"... We call upon the shadows ...",
		"... Show us the way ...")
	invoke_msg = "... Let the darkness be our guide!!"
	favor_cost = 1000

/datum/religion_rites/shadow_eyes/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(length(movable_reltool.buckled_mobs))
		to_chat(user,"<span class='warning'>You're going to grant the eyes to the one buckled on [movable_reltool].</span>")
	else if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
		to_chat(user,"<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	else
		to_chat(user,"<span class='warning'>You're going to grant the eyes to yourself with this ritual.</span>")
	return ..()

/datum/religion_rites/shadow_eyes/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	var/obj/item/organ/eyes/night_vision/organ = new()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!length(movable_reltool.buckled_mobs))
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	organ.Insert(rite_target)
	rite_target.visible_message("<span class='notice'>[organ] have been merged into [rite_target] by the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/final_darkness
	name = "Final Darkness"
	desc = "The endgame, Activates the obelisk heal and summons Faithsworn entities from every obelisk in existence. THIS IS ONE USE ONLY."
	ritual_length = 60 SECONDS
	ritual_invocations = list(
		"Join us in this darkness ...",
		"... Protect us from the light ...",
		"... Destroy those who defy us ...")
	invoke_msg = "... Let the darkness come and fight!!"
	favor_cost = 50000

/datum/religion_rites/final_darkness/invoke_effect(mob/living/user, atom/religious_tool)
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	if(sect.faithful_used)
		to_chat(user,"<span class='warning'>This rite has already been used, your favor has been refuned.</span>")
		GLOB.religious_sect?.adjust_favor(50000, user)
		return ..()
	sect.faithful_used = TRUE
	var/altar_turf = get_turf(religious_tool)
	var/obj/structure/destructible/religion/shadow_obelisk/lisk = new(altar_turf)
	sect.obelisks += lisk
	lisk.AddComponent(/datum/component/dark_favor, user)
	lisk.set_light(sect.light_reach, sect.light_power, DARKNESS_INVERSE_COLOR)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	priority_announce("May our lord, [GLOB.deity], have mercy on your soul as darkness reigns apon you all.", "Faith Alert", SSstation.announcer.get_rand_alert_sound())
	addtimer(CALLBACK(lisk, TYPE_PROC_REF(/obj/structure/destructible/religion/shadow_obelisk, final_darkness_activate)), 100)

/obj/structure/destructible/religion/shadow_obelisk/proc/final_darkness_activate()
	var/datum/religion_sect/shadow_sect/sect = GLOB.religious_sect
	for(var/obj/structure/destructible/religion/shadow_obelisk/obs in sect.obelisks)
		START_PROCESSING(SSobj, obs)
		var/obelisk_turf = get_turf(obs)
		for(var/i in 1 to 3)
			var/mob/living/simple_animal/hostile/faithless/faithful/faithful = new(obelisk_turf)
			faithful.AddComponent(/datum/component/dark_favor, faithful)
			faithful.set_light(2, -2, DARKNESS_INVERSE_COLOR)
		playsound(obs, 'sound/hallucinations/wail.ogg', 50, TRUE)
