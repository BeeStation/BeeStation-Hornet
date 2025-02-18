#define LONG_FUSE_THRESHOLD 61
#define MEDIUM_FUSE_THRESHOLD 21
#define SHORT_FUSE_THRESHOLD 11

/datum/wires/syndicatebomb
	holder_type = /obj/machinery/syndicatebomb
	randomize = TRUE
	/// If the delay wire has been pulsed
	var/delayed_chirp = FALSE
	/// If the activation wire has been pulsed
	var/delayed_hesitate = FALSE
	/// If the boom wire has been pulsed before
	var/fake_delayed_hesitate = FALSE
	/// If the time's been cut in half by a bad pulse
	var/time_cut = FALSE

/datum/wires/syndicatebomb/New(atom/holder)
	wires = list(
		WIRE_BOOM, WIRE_UNBOLT,
		WIRE_ACTIVATE, WIRE_DELAY, WIRE_PROCEED
	)
	..()

/datum/wires/syndicatebomb/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return TRUE

/datum/wires/syndicatebomb/repair()
	. = ..()
	delayed_chirp = FALSE
	delayed_hesitate = FALSE
	fake_delayed_hesitate = FALSE
	time_cut = FALSE

/datum/wires/syndicatebomb/on_pulse(wire)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_BOOM) // Only on cutting
			if(fake_delayed_hesitate)
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] Nothing happens."))
			else
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The bomb seems to hesitate for a moment."))
				fake_delayed_hesitate = TRUE
		if(WIRE_UNBOLT)
			holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The bolts spin in place for a moment."))
		if(WIRE_DELAY)
			if(delayed_chirp)
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] Nothing happens."))
			else
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The bomb chirps."))
				playsound(B, 'sound/machines/chime.ogg', 30, 1)
				B.detonation_timer += 10 SECONDS
				if(B.active)
					delayed_chirp = TRUE
		if(WIRE_PROCEED)
			holder.visible_message(span_danger("[icon2html(B, viewers(holder))] The bomb buzzes ominously!"))
			playsound(B, 'sound/machines/buzz-sigh.ogg', 30, 1)
			var/seconds_left = B.seconds_remaining()
			if(seconds_left >= LONG_FUSE_THRESHOLD) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.detonation_timer = world.time + 60 SECONDS
			else if(seconds_left >= MEDIUM_FUSE_THRESHOLD)
				if(time_cut)
					return
				B.detonation_timer -= seconds_left * 0.5 SECONDS
				time_cut = TRUE
			else if(seconds_left >= SHORT_FUSE_THRESHOLD) // Both to prevent negative timers and to have a little mercy.
				B.detonation_timer = world.time + 10 SECONDS
		if(WIRE_ACTIVATE)
			if(!B.active)
				holder.visible_message(span_danger("[icon2html(B, viewers(holder))] You hear the bomb start ticking!"))
				B.activate()
				B.update_icon()
			else if(delayed_hesitate)
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] Nothing happens."))
			else
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The bomb seems to hesitate for a moment."))
				B.detonation_timer += 10 SECONDS
				delayed_hesitate = TRUE

/datum/wires/syndicatebomb/on_cut(wire, mob/user, mend)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_BOOM)
			if(!mend && B.active)
				holder.visible_message(span_danger("[icon2html(B, viewers(holder))] An alarm sounds! It's go-"))
				B.explode_now = TRUE
				tell_admins(B)
		if(WIRE_UNBOLT)
			if(!mend && B.anchored)
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The bolts lift out of the ground!"))
				playsound(B, 'sound/effects/stealthoff.ogg', 30, 1)
				B.set_anchored(FALSE)
		if(WIRE_PROCEED)
			if(!mend && B.active)
				holder.visible_message(span_danger("[icon2html(B, viewers(holder))] An alarm sounds! It's go-"))
				B.explode_now = TRUE
				tell_admins(B)
		if(WIRE_ACTIVATE)
			if(!mend && B.active)
				holder.visible_message(span_notice("[icon2html(B, viewers(holder))] The timer stops! The bomb has been defused!"))
				B.active = FALSE
				delayed_hesitate = FALSE
				delayed_chirp = FALSE
				fake_delayed_hesitate = FALSE
				B.update_icon()

/datum/wires/syndicatebomb/proc/tell_admins(obj/machinery/syndicatebomb/B)
	if(istype(B, /obj/machinery/syndicatebomb/training))
		return
	var/turf/T = get_turf(B)
	log_game("\A [B] was detonated via boom wire at [AREACOORD(T)].")
	message_admins("A [B.name] was detonated via boom wire at [ADMIN_VERBOSEJMP(T)].")

#undef LONG_FUSE_THRESHOLD
#undef MEDIUM_FUSE_THRESHOLD
#undef SHORT_FUSE_THRESHOLD
