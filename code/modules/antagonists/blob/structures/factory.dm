/obj/structure/blob/factory
	name = "factory blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "A thick spire of tendrils."
	max_integrity = BLOB_FACTORY_MAX_HP
	max_hit_damage = 40
	health_regen = BLOB_FACTORY_HP_REGEN
	point_return = BLOB_REFUND_FACTORY_COST
	resistance_flags = LAVA_PROOF
	var/list/spores = list()
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = null
	var/max_spores = BLOB_FACTORY_MAX_SPORES
	var/spore_delay = 0
	var/spore_cooldown = BLOBMOB_SPORE_SPAWN_COOLDOWN


/obj/structure/blob/factory/scannerreport()
	if(naut)
		return "It is currently sustaining a blobbernaut, making it fragile and unable to produce blob spores."
	return "Will produce a blob spore every few seconds."

/obj/structure/blob/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, span_userdanger("Your factory was destroyed! You feel yourself dying!"))
		naut.throw_alert("nofactory", /atom/movable/screen/alert/nofactory)
	spores = null
	return ..()

/obj/structure/blob/factory/Be_Pulsed()
	. = ..()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return
	flick("blob_factory_glow", src)
	spore_delay = world.time + spore_cooldown
	var/mob/living/simple_animal/hostile/blob/blobspore/BS = new/mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		BS.overmind = overmind
		BS.update_icons()
		overmind.blob_mobs.Add(BS)

/obj/structure/blob/factory/lone //A blob factory that functions without a pulses

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/blob/factory/lone)

/obj/structure/blob/factory/lone/Initialize(mapload, owner_overmind)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/blob/factory/lone/process()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/blob/factory/lone, Be_Pulsed)), 10 SECONDS, TIMER_UNIQUE)

/obj/structure/blob/factory/lone/Be_Pulsed()
	. = ..()

/obj/structure/blob/node/lone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
