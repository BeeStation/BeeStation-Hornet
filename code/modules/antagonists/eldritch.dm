/obj/eldritch
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = FALSE
	pixel_x = -236
	pixel_y = -256
	move_resist = INFINITY
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	plane = MASSIVE_OBJ_PLANE
	zmm_flags = ZMM_WIDE_LOAD
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

	/// The singularity component to move around Nar'Sie.
	/// A weak ref in case an admin removes the component to preserve the functionality.
	var/datum/weakref/singularity

/obj/eldritch/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/eldritch/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/eldritch/proc/consume()
	return
