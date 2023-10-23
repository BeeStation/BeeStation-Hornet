/datum/component/splintering
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/weapon // the weapon in question
	var/is_embedded = FALSE // whether the weapon is embedded in the user
	var/growth // how close the weapon is to embedding itself into the user
	var/growth_per_hit // how much growth is gained per hit
	var/growth_decay // amount of growth lost per process
	var/self_damage_min // minimum amount of damage sustained when damage is randomly applied
	var/self_damage_max // maximum amount of damage sustained when damage is randomly applied
	var/blood_siphoned // how much blood is siphoned from the target on hit
	var/embed_damage // how much damage is taken by the mob if it is dug in or out of their flesh

/datum/component/splintering/Initialize(obj/item/_weapon, _growth_per_hit, _growth_decay, _self_damage_min, _self_damage_max, _blood_siphoned, _embed_damage)
	if(!iscarbon(parent) || !isitem(_weapon))
		return COMPONENT_INCOMPATIBLE

	weapon = _weapon
	growth_per_hit = _growth_per_hit
	growth_decay = _growth_decay
	self_damage_min = _self_damage_min
	self_damage_max = _self_damage_max
	blood_siphoned = _blood_siphoned
	embed_damage = _embed_damage

	START_PROCESSING(SSdcs, src)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(onMove))
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/splintering/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ITEM_ATTACK))

/datum/component/splintering/proc/onMove()
	SIGNAL_HANDLER

	var/mob/living/M = parent
	var/hit_hand = ((M.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(M.is_holding(weapon) && prob(5))
		M.apply_damage(rand(self_damage_min, self_damage_max), hit_hand)
		to_chat(M, "<span class='warning'>You prick yourself on the [weapon]!</span>")

/datum/component/splintering/proc/onItemAttack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	growth = min(growth + growth_per_hit, 100)
	target.blood_volume = clamp(target.blood_volume - blood_siphoned, 0, BLOOD_VOLUME_MAXIMUM)
	if(prob(growth) && !is_embedded)
		embed()

/datum/component/splintering/process(delta_time)
	growth = max(growth - growth_decay * delta_time, 0)

/datum/component/splintering/proc/embed()
	var/mob/living/M = parent
	if(!HAS_TRAIT(weapon, TRAIT_NODROP))
		ADD_TRAIT(weapon, TRAIT_NODROP, EMBEDDED_SPINY_ITEM_TRAIT)
	playsound(get_turf(M), 'sound/weapons/slice.ogg', 100, 1)
	is_embedded = TRUE
	weapon.icon_state += "_stuck"
	var/datum/component/two_handed/comp_twohand = weapon.GetComponent(/datum/component/two_handed)
	if(comp_twohand)
		comp_twohand.icon_wielded += "_stuck"
		weapon.update_icon()
	else
		weapon.item_state += "_stuck"
	var/hit_hand = ((M.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	M.apply_damage(embed_damage * 0.25, BRUTE, hit_hand)
	M.throw_alert("splintered", /atom/movable/screen/alert/splintered)
	to_chat(M, "<span class='danger'>The [weapon] digs painfully into your arm!</span>")

/datum/component/splintering/proc/unembed()
	var/mob/living/M = parent
	REMOVE_TRAIT(weapon, TRAIT_NODROP, EMBEDDED_SPINY_ITEM_TRAIT)
	playsound(get_turf(M), 'sound/weapons/slice.ogg', 100, 1)
	is_embedded = FALSE
	growth = 0
	weapon.icon_state = initial(weapon.icon_state)
	var/datum/component/two_handed/comp_twohand = weapon.GetComponent(/datum/component/two_handed)
	if(comp_twohand)
		comp_twohand.icon_wielded = replacetext(comp_twohand.icon_wielded, "_stuck", "")
		weapon.update_icon()
	else
		weapon.item_state = initial(weapon.item_state)
	var/hit_hand = ((M.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	M.apply_damage(embed_damage, BRUTE, hit_hand)
	M.clear_alert("splintered", /atom/movable/screen/alert/splintered)
