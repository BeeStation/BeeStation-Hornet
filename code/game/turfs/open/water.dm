/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	baseturfs = /turf/open/floor/plating/asteroid
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	slowdown = 3
	bullet_sizzle = TRUE
	bullet_bounce_sound = 'sound/effects/splash.ogg' //needs a splashing sound one day. //today is that day

	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

// pool.dm copy paste

/turf/open/water/Initialize(mapload)
	. = ..()
	water_overlay = new /obj/effect/overlay/poolwater(get_turf(src))

/turf/open/water/proc/set_colour(colour)
	water_overlay.color = colour

/turf/open/water/end/ChangeTurf(path, list/new_baseturfs, flags)
	if(water_overlay)
		qdel(water_overlay)
	. = ..()

/turf/open/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //If you're swimming around, you don't really want to stop swimming just like that do you?
	if(S)
		return FALSE //If you're swimming, you can't swim into a regular turf, y'dig?
	. = ..()

/turf/open/water/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
	return (isliving(mover)) ? S : ..() //So you can do stuff like throw beach balls around the pool!

/turf/open/water/Entered(atom/movable/AM)
	. = ..()
	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	if(isliving(AM))
		var/datum/component/swimming/S = AM.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
		if(!S)
			var/mob/living/carbon/C = AM
			var/component_type = /datum/component/swimming
			if(istype(C) && C?.dna?.species)
				component_type = C.dna.species.swimming_component
			AM.AddComponent(component_type)

/turf/open/water/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(!istype(newloc, /turf/open/indestructible/sound/pool))
		var/datum/component/swimming/S = Obj.GetComponent(/datum/component/swimming) //Handling admin TPs here.
		S?.RemoveComponent()

/turf/open/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/atom/movable/AM = dropping
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming)
	if(S)
		if(do_after(user, 1 SECONDS, target = dropping))
			S.RemoveComponent()
			visible_message("<span class='notice'>[dropping] climbs out of the pool.</span>")
			AM.forceMove(src)
	else
		. = ..()

/turf/open/water/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming) //If they're already swimming, don't let them start swimming again.
	if(S)
		return FALSE
	. = ..()
	if(user != dropping)
		dropping.visible_message("<span class='notice'>[user] starts to lower [dropping] down into [src].</span>", \
		 "<span class='notice'>You start to lower [dropping] down into [src].</span>")
	else
		to_chat(user, "<span class='notice'>You start climbing down into [src]...")
	if(do_after(user, 4 SECONDS, target = dropping))
		splash(dropping)


/turf/open/water/proc/splash(mob/user)
	user.forceMove(src)
	playsound(src, 'sound/effects/splosh.ogg', 100, 1) //Credit to hippiestation for this sound file!
	user.visible_message("<span class='boldwarning'>SPLASH!</span>")
	var/zap = 0
	if(issilicon(user)) //Do not throw brick in a pool. Brick begs.
		zap = 1 //Sorry borgs! Swimming will come at a cost.
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		var/datum/species/SS = F.dna.species
		if(MOB_ROBOTIC in SS.inherent_biotypes)  //ZAP goes the IPC!
			zap = 2 //You can protect yourself from water damage with thick clothing.
		if(F.head && isclothing(F.head))
			var/obj/item/clothing/CH = F.head
			if (CH.clothing_flags & THICKMATERIAL) //Skinsuit should suffice! But IPCs are robots and probably not water-sealed.
				zap --
		if(F.wear_suit && isclothing(F.wear_suit))
			var/obj/item/clothing/CS = F.wear_suit
			if (CS.clothing_flags & THICKMATERIAL)
				zap --
	if(zap > 0)
		user.emp_act(zap)
		user.emote("scream") //Chad coders use M.say("*scream")
		do_sparks(zap, TRUE, user)
		to_chat(user, "<span class='userdanger'>WARNING: WATER DAMAGE DETECTED!</span>")
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "robotpool", /datum/mood_event/robotpool)
	else
		if(!check_clothes(user))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolparty)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolwet)

//Largely a copypaste from shower.dm. Checks if the mob was stupid enough to enter a pool fully clothed. We allow masks as to not discriminate against clown and mime players.
/turf/open/water/proc/check_clothes(mob/living/carbon/human/H)
	if(!istype(H) || iscatperson(H)) //Don't care about non humans.
		return FALSE
	if(H.wear_suit && (H.wear_suit.clothing_flags))
		// Do not check underclothing if the over-suit is suitable.
		// This stops people feeling dumb if they're showering
		// with a radiation suit on.
		return FALSE

	. = FALSE
	if(!(H.wear_suit?.clothing_flags))
		return TRUE
	if(!(H.w_uniform?.clothing_flags))
		return TRUE
	if(!(H.head?.clothing_flags))
		return TRUE

/turf/open/water/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
/turf/open/water/air/deep
	desc = "Deep water. What if there's sharks?"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOSS
	density = 1 //no swimming
