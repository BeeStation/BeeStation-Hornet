/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = FALSE
	///for how many deciseconds after user death will the implant work?
	var/lifespan_postmortem = 10 MINUTES
	///The id of the timer that's qdeleting us
	var/deletion_timer

/obj/item/implant/tracking/Initialize()
	. = ..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	deltimer(deletion_timer)
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implant/tracking/on_implanted(mob/living/user)
	. = ..()
	if(!istype(user) || !lifespan_postmortem)
		return
	RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_user_revive))

/obj/item/implant/tracking/removed(mob/living/source, silent, special)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_REVIVE)

/obj/item/implant/tracking/on_mob_death()
	if(!deletion_timer && lifespan_postmortem)
		deletion_timer = QDEL_IN(src, lifespan_postmortem)

/obj/item/implant/tracking/proc/on_user_revive(full_heal, admin_revive)
	SIGNAL_HANDLER
	deltimer(deletion_timer)
	deletion_timer = null

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	lifespan_postmortem = null
	var/lifespan = 5 MINUTES //how many deciseconds does the implant last?

/obj/item/implant/tracking/c38/Initialize()
	. = ..()
	deletion_timer = QDEL_IN(src, lifespan)
/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage."}
	return dat
