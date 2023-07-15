/obj/item/deployable/bot
	name = "deployable bot" //should never be visible
	desc = "if you're seeing this contact coders ASAP"
	dense_deployment = TRUE
	w_class = WEIGHT_CLASS_BULKY
	//All other variables are set within living/simple_animal/bot/MouseDrop()

/obj/item/deployable/bot/Initialize(mapload)
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(self_destruct))

/obj/item/deployable/bot/proc/self_destruct()
	SIGNAL_HANDLER
	for(var/atom/movable/A in contents)
		return
	qdel(src)
