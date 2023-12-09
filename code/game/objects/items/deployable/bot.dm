/obj/item/carried_bot
	name = "deployable bot" //should never be visible
	desc = "if you're seeing this contact coders ASAP"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/carried_bot/Initialize(mapload)
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(self_destruct))
	return ..()

/obj/item/carried_bot/ComponentInitialize()
	. = ..()
	// Deploy contents instead
	AddComponent(/datum/component/deployable, null, ignores_mob_density = TRUE, dense_deployment = TRUE)

/obj/item/carried_bot/proc/self_destruct()
	SIGNAL_HANDLER
	for(var/atom/movable/A in contents)
		return
	qdel(src)
