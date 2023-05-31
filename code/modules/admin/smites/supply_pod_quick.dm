#define SUPPLY_POD_QUICK_DAMAGE 40
#define SUPPLY_POD_QUICK_FIRE_RANGE 2

/// Quickly throws a supply pod at the target, optionally with an item
/datum/smite/supply_pod_quick
	name = "Supply Pod (Quick)"

	/// What is sent down with the pod
	var/target_path

/datum/smite/supply_pod_quick/configure(client/user)
	var/attempted_target_path = input(
		user,
		"Enter typepath of an atom you'd like to send with the pod (type \"empty\" to send an empty pod):",
		"Typepath",
		"/obj/item/food/grown/harebell",
	) as null|text

	if (isnull(attempted_target_path)) //The user pressed "Cancel"
		return FALSE

	if (attempted_target_path == "empty")
		target_path = null
		return

	// if you didn't type empty, we want to load the pod with a delivery
	var/delivery = text2path(attempted_target_path)
	if(!ispath(delivery))
		delivery = pick_closest_path(attempted_target_path)
		if(!delivery)
			alert(user, "ERROR: Incorrect / improper path given.")
			return FALSE
	target_path = delivery

/datum/smite/supply_pod_quick/effect(client/user, mob/living/target)
	. = ..()

	var/obj/structure/closet/supplypod/centcompod/pod = new
	pod.damage = SUPPLY_POD_QUICK_DAMAGE
	pod.explosionSize = list(0, 0, 0, SUPPLY_POD_QUICK_FIRE_RANGE)
	pod.effectStun = TRUE

	if (!isnull(target_path))
		new target_path(pod)

	new /obj/effect/pod_landingzone(get_turf(target), pod)

#undef SUPPLY_POD_QUICK_DAMAGE
#undef SUPPLY_POD_QUICK_FIRE_RANGE
