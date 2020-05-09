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
	var/cooldown = 0
	var/effect_stand_time = 0
	var/currently_affecting
	var/idle_color = "#FFFFFF"
	var/invokation_color = "#F1A03B"
	var/pulse_color = "#EBC670"
	var/fail_color = "#d47433"
	var/active_timer
	var/next_use_time

/obj/structure/destructible/clockwork/sigil/attack_hand(mob/user)
	. = ..()
	dispell()

/obj/structure/destructible/clockwork/sigil/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(world.time < next_use_time)
		return
	if(!isliving(AM))
		return
	if(currently_affecting)
		return
	if(active_timer)
		return
	currently_affecting = AM
	if(!effect_stand_time)
		apply_affects(AM)
		return
	do_sparks(5, TRUE, src)
	animate(src, color=invokation_color, alpha=SIGIL_INVOKATION_ALPHA, effect_stand_time)
	active_timer = addtimer(CALLBACK(src, .proc/apply_affects, AM), effect_stand_time, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/structure/destructible/clockwork/sigil/Uncrossed(atom/movable/AM)
	. = ..()
	if(currently_affecting != AM)
		return
	currently_affecting = null
	animate(src, color=idle_color, 5)
	if(active_timer)
		deltimer(active_timer)
		active_timer = null

/obj/structure/destructible/clockwork/sigil/proc/can_affect(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!isliving(M))
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

/obj/structure/destructible/clockwork/sigil/proc/apply_affects(mob/living/M)
	if(!can_affect(M))
		fail_invokation()
		return FALSE
	next_use_time = world.time + cooldown
	active_timer = null
	currently_affecting = null
	color = pulse_color
	transform = matrix() * 1.2
	alpha = SIGIL_INVOKED_ALPHA
	animate(src, transform=matrix(), color=idle_color, alpha = initial(alpha), time=5)
	return TRUE

/obj/structure/destructible/clockwork/sigil/proc/dispell()
	animate(src, transform = matrix() * 1.5, alpha = 0, time = 3)
	sleep(3)
	if(active_timer)
		deltimer(active_timer)
		active_timer = null
	qdel(src)

//==========Submission=========
/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "a strange sigil, with otherworldy drawings on it."
	icon_state = "sigilsubmission"
	effect_stand_time = 80
	idle_color = "#FFFFFF"
	invokation_color = "#cc941b"
	pulse_color = "#EBC670"
	fail_color = "#d47433"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/submission/apply_affects(mob/living/M)
	if(!..())
		return FALSE
	M.Stun(50)
	add_servant_of_ratvar(M)

//==========Transgression=========
/obj/structure/destructible/clockwork/sigil/transgression
	name = "sigil of transgression"
	icon_state = "sigiltransgression"
	alpha = 25
	effect_stand_time = 0
	pulse_color = "#88278b"
	cooldown = 80

/obj/structure/destructible/clockwork/sigil/transgression/can_affect(mob/living/M)
	if(!..())
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/sigil/transgression/apply_affects(mob/living/M)
	if(!..())
		return FALSE
	M.Paralyze(60)
	M.blind_eyes(120)
	var/mob/living/carbon/C = M
	if(istype(C))
		C.silent += 15
