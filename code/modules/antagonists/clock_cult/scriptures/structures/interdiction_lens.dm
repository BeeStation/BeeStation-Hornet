#define INTERDICTION_LENS_RANGE 3

/obj/structure/destructible/clockwork/gear_base/interdiction_lens
	name = "interdiction lens"
	desc = "A mesmorising light that flashes to a rhythm that you just can't stop tapping to."
	clockwork_desc = "A small device which will slow down nearby attackers at a small power cost."
	default_icon_state = "interdiction_lens"
	anchored = TRUE
	break_message = "<span class='warning'>The interdiction lens breaks into multiple fragments, which gently float to the ground.</span>"
	var/enabled = FALSE

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Destroy()
	if(enabled)
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		enabled = !enabled
		to_chat(user, "<span class='brass'>You toggle \the [src] [enabled?"on":"off"].</span>")
		if(enabled)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
	else
		. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/process()
	if(!anchored)
		enabled = FALSE
		STOP_PROCESSING(SSobj, src)
		return
	if(prob(5))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	for(var/mob/living/L in range(INTERDICTION_LENS_RANGE, src))
		if(!is_servant_of_ratvar(L))
			L.apply_status_effect(STATUS_EFFECT_INTERDICTION)
	for(var/obj/item/projectile/P in range(INTERDICTION_LENS_RANGE, src))
		if(isliving(P) || !is_servant_of_ratvar(P.firer))
			P.speed /= 2
			P.damage /= 1.4
			P.visible_message("<span class='warning'>\The [P] appears to slow in midair!</span>")
	for(var/obj/mecha/M in range(INTERDICTION_LENS_RANGE, src))
		M.use_power(1000)
		M.take_damage(25)
		do_sparks(4, TRUE, M)
