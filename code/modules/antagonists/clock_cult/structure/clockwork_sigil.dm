#define SIGIL_INVOKATION_ALPHA 120
#define SIGIL_INVOKED_ALPHA 200

//==========Sigil Base=========
/obj/structure/destructible/clockwork/sigil
	name = "sigil"
	desc = "It's a sigil that does something."
	max_integrity = 10
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "sigilvitality"
	density = FALSE
	alpha = 60
	var/effect_stand_time = 0	//How long you stand on the sigil before affect is applied
	var/currently_affecting		//The atom/movable that this is currently affecting
	var/idle_color = "#FFFFFF"			//Colour while not used
	var/invokation_color = "#F1A03B"	//Colour faded to while someone stands on top
	var/pulse_color = "#EBC670"			//Colour pulsed when effect applied
	var/fail_color = "#d47433"			//Colour pulsed when effect fails
	var/active_timer			//Active timer
	var/looping = FALSE			//TRUE if the affect repeatedly applied an affect to the thing above it
	var/living_only = TRUE		//FALSE if the rune can affect non-living atoms

/obj/structure/destructible/clockwork/sigil/attack_hand(mob/user)
	. = ..()
	dispell()

/obj/structure/destructible/clockwork/sigil/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(!isliving(AM) && living_only)
		return
	if(currently_affecting)
		return
	if(active_timer)
		return
	currently_affecting = AM
	if(!effect_stand_time)
		apply_effects(AM)
		return
	do_sparks(5, TRUE, src)
	animate(src, color=invokation_color, alpha=SIGIL_INVOKATION_ALPHA, effect_stand_time)
	active_timer = addtimer(CALLBACK(src, .proc/apply_effects, AM), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/structure/destructible/clockwork/sigil/Uncrossed(atom/movable/AM)
	. = ..()
	if(currently_affecting != AM)
		return
	currently_affecting = null
	animate(src, color=idle_color, alpha=initial(alpha), time=5)
	if(active_timer)
		deltimer(active_timer)
		active_timer = null

//If the sigil does not affect living, do not inherit this
/obj/structure/destructible/clockwork/sigil/proc/can_affect(atom/movable/AM)
	var/mob/living/M = AM
	if(!istype(M))
		return FALSE
	var/amc = M.anti_magic_check()
	if(amc)
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/proc/fail_invokation()
	active_timer = null
	currently_affecting = null
	color = fail_color
	transform = matrix() * 1.2
	alpha = 140
	animate(src, transform=matrix(), color=idle_color, alpha = initial(alpha), time=5)

/obj/structure/destructible/clockwork/sigil/proc/apply_effects(atom/movable/AM)
	if(!can_affect(AM))
		fail_invokation()
		return FALSE
	color = pulse_color
	transform = matrix() * 1.2
	alpha = SIGIL_INVOKED_ALPHA
	if(looping)
		animate(src, transform=matrix(), color=invokation_color, alpha=SIGIL_INVOKATION_ALPHA, effect_stand_time)
		active_timer = addtimer(CALLBACK(src, .proc/apply_effects, AM), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)
	else
		active_timer = null
		currently_affecting = null
		animate(src, transform=matrix(), color=idle_color, alpha = initial(alpha), time=5)
	return TRUE

/obj/structure/destructible/clockwork/sigil/proc/dispell()
	animate(src, transform = matrix() * 1.5, alpha = 0, time = 3)
	sleep(3)
	if(active_timer)
		deltimer(active_timer)
		active_timer = null
	qdel(src)

//==========Transgression=========
/obj/structure/destructible/clockwork/sigil/transgression
	name = "sigil of transgression"
	icon_state = "sigiltransgression"
	alpha = 25
	effect_stand_time = 0
	pulse_color = "#88278b"

/obj/structure/destructible/clockwork/sigil/transgression/can_affect(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/transgression/apply_effects(mob/living/M)
	if(!..())
		return FALSE
	M.Paralyze(60)
	M.blind_eyes(120)
	var/mob/living/carbon/C = M
	if(istype(C))
		C.silent += 15
	qdel(src)
