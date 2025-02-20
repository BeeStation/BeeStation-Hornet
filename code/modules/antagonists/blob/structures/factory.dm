/obj/structure/blob/special/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "A thick spire of tendrils."
	max_integrity = BLOB_FACTORY_MAX_HP
	max_hit_damage = BLOB_FACTORY_MAX_HP / 10
	health_regen = BLOB_FACTORY_HP_REGEN
	point_return = BLOB_REFUND_FACTORY_COST
	resistance_flags = LAVA_PROOF
	max_spores = BLOB_FACTORY_MAX_SPORES

/obj/structure/blob/special/factory/scannerreport()
	if(naut)
		return "It is currently sustaining a blobbernaut, making it fragile and unable to produce blob spores."
	return "Will produce a blob spore every few seconds."

/obj/structure/blob/special/factory/creation_action()
	if(overmind)
		overmind.factory_blobs += src

/obj/structure/blob/special/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
		naut.throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
	spores = null
	if(overmind)
		overmind.factory_blobs -= src
	return ..()

/obj/structure/blob/special/factory/Be_Pulsed()
	. = ..()
	produce_spores()

/obj/structure/blob/special/factory/lone //A blob factory that functions without a pulses

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/blob/special/factory/lone)

/obj/structure/blob/special/factory/lone/Initialize(mapload, owner_overmind)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/blob/special/factory/lone/process()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/blob/special/factory/lone, Be_Pulsed)), 10 SECONDS, TIMER_UNIQUE)

/obj/structure/blob/special/factory/lone/Be_Pulsed()
	. = ..()

/obj/structure/blob/special/node/lone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
