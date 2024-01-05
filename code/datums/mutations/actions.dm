/datum/mutation/telepathy
	name = "Telepathy"
	desc = "A rare mutation that allows the user to telepathically communicate to others."
	quality = POSITIVE
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/telepathy
	instability = 10

/datum/mutation/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	energy_coeff = 1

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. With an empty hand, you'll track the scent you've remembered."
	charge_max = 10 SECONDS
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		for(var/mob/living/carbon/potential_target in GLOB.carbon_list)
			if(prints[rustg_hash_string(RUSTG_HASH_MD5, potential_target.dna.uni_identity)])
				possible |= potential_target
		if(!length(possible))
			to_chat(user, "<span class='warning'>Despite your best efforts, there are no scents to be found on [sniffed]...</span>")
			return
		tracking_target = tgui_input_list(user, "Choose a scent to remember.", "Scent Tracking", sort_names(possible))
		if(!tracking_target)
			if(!old_target)
				to_chat(user,"<span class='warning'>You decide against remembering any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was.</span>")
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,"<span class='notice'>You pick up the scent of <span class='name'>[tracking_target]</span>. The hunt begins.</span>")
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not holding anything to smell, and you haven't smelled anything you can track. You smell your palm instead; it's kinda salty.</span>")
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,"<span class='warning'>You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug.</span>")
		return
	if(tracking_target == user)
		to_chat(user,"<span class='warning'>You smell out the trail to yourself. Yep, it's you.</span>")
		return
	if(usr.get_virtual_z_level() < tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>The trail leads... way up above you? Huh. They must be really, really far away.</span>")
		return
	else if(usr.get_virtual_z_level() > tracking_target.get_virtual_z_level())
		to_chat(user,"<span class='warning'>The trail leads... way down below you? Huh. They must be really, really far away.</span>")
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,"<span class='notice'>You consider <span class='name'>[tracking_target]</span>'s scent. The trail leads <b>[direction_text].</b></span>")

/datum/mutation/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1
	species_allowed = list(SPECIES_LIZARD)

/datum/mutation/firebreath/modify()
	..()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/firebreath = power
		firebreath.strength = GET_MUTATION_POWER(src)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = "You can breathe fire at a target."
	school = "evocation"
	invocation = ""
	invocation_type = INVOCATION_NONE
	charge_max = 1 MINUTES
	clothes_req = FALSE
	range = 20
	projectile_type = /obj/projectile/magic/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises
	active_msg = "You built up heat in your mouth."
	deactive_msg = "You swallow the flame."
	var/strength = 1

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	var/mob/living/carbon/user = usr
	if(!istype(user))
		return
	if(user.is_mouth_covered())
		user.adjust_fire_stacks(2)
		user.IgniteMob()
		to_chat(user, "<span class='warning'>Something in front of your mouth caught fire!</span>")
		return FALSE

/obj/effect/proc_holder/spell/aimed/firebreath/ready_projectile(obj/projectile/magic/fireball/fireball, atom/target, mob/user, iteration)
	if(!istype(fireball))
		return
	fireball.exp_light = strength - 1
	fireball.exp_fire += strength

/obj/projectile/magic/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire = 4
	magic = FALSE

/datum/mutation/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	instability = 30
	power = /obj/effect/proc_holder/spell/self/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/void/on_life()
	if(!isturf(owner.loc))
		return
	if(prob((0.5 + ((100 - dna.stability) / 20))) * GET_MUTATION_SYNCHRONIZER(src)) //very rare, but enough to annoy you hopefully. +0.5 probability for every 10 points lost in stability
		new /obj/effect/immortality_talisman/void(get_turf(owner), owner)

/obj/effect/proc_holder/spell/self/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	school = "evocation"
	clothes_req = FALSE
	charge_max = 1 MINUTES
	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "void_magnet"

/obj/effect/proc_holder/spell/self/void/can_cast(mob/user = usr)
	if(!isturf(user.loc))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/self/void/cast(mob/user = usr)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)

/datum/mutation/self_amputation
	name = "Autotomy"
	desc = "Allows a creature to voluntary discard a random appendage."
	quality = POSITIVE
	instability = 30
	power = /obj/effect/proc_holder/spell/self/self_amputation
	energy_coeff = 1

/obj/effect/proc_holder/spell/self/self_amputation
	name = "Drop a limb"
	desc = "Concentrate to make a random limb pop right off your body."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 10 SECONDS
	action_icon_state = "autotomy"

/obj/effect/proc_holder/spell/self/self_amputation/cast(mob/living/carbon/user = usr)
	if(!istype(user) || HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return
	var/list/parts = list()
	for(var/obj/item/bodypart/part as() in user.bodyparts)
		if(part.body_part != HEAD && part.body_part != CHEST && part.dismemberable)
			parts += part
	if(!length(parts))
		to_chat(user, "<span class='notice'>You can't shed any more limbs!</span>")
		return
	var/obj/item/bodypart/yeeted_limb = pick(parts)
	yeeted_limb.dismember()

/datum/mutation/overload
	name = "Overload"
	desc = "Allows an Ethereal to overload their skin to cause a bright flash."
	quality = POSITIVE
	locked = TRUE
	instability = 30
	power = /obj/effect/proc_holder/spell/self/overload
	species_allowed = list(SPECIES_ETHEREAL)
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/overload/modify()
	..()
	if(power)
		var/static/max_range = min(getviewsize(world.view)[1], getviewsize(world.view)[2]) - 2
		var/obj/effect/proc_holder/spell/self/overload/overload = power
		overload.max_distance = min(max_range, initial(overload.max_distance) * GET_MUTATION_POWER(src))

/obj/effect/proc_holder/spell/self/overload
	name = "Overload"
	desc = "Concentrate to make your skin energize."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 40 SECONDS
	action_icon_state = "blind"
	var/max_distance = 4

/obj/effect/proc_holder/spell/self/overload/cast(mob/living/carbon/human/user)
	if(!isethereal(user))
		return
	var/list/mob/targets = oviewers(max_distance, get_turf(user))
	visible_message("<span class='disarm'>[user] emits a blinding light!</span>")
	for(var/mob/living/carbon/target in targets)
		if(target.flash_act(1))
			target.Paralyze(10 + (5 * max_distance))

	for(var/mob/living/carbon/C in targets)
		if(C.flash_act(1))
			C.Paralyze(10 + (5*max_distance))

/datum/mutation/overload/modify()
	if(power)
		var/obj/effect/proc_holder/spell/self/overload/S = power
		S.max_distance = 4 * GET_MUTATION_POWER(src)

//Psyphoza species mutation
/datum/mutation/spores
	name = "Agaricale Pores" //Pores, not spores
	desc = "An ancient mutation that gives psyphoza the ability to produce spores."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	power = /obj/effect/proc_holder/spell/self/spores
	instability = 30
	energy_coeff = 1
	power_coeff = 1

/obj/effect/proc_holder/spell/self/spores
	name = "Release Spores"
	desc = "A rare genome that forces the subject to evict spores from their pores."
	school = "evocation"
	invocation = ""
	clothes_req = FALSE
	charge_max = 600
	invocation_type = INVOCATION_NONE
	base_icon_state = "smoke"
	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/self/spores/cast(mob/user = usr)
	. = ..()
	//Setup reagents
	var/datum/reagents/holder = new()
	//If our user is a carbon, use their blood
	var/mob/living/carbon/C = user
	if(iscarbon(user) && C.blood_volume > 0)
		C.blood_volume = max(0, C.blood_volume-15)
		if(C.get_blood_id())
			holder.add_reagent(C.get_blood_id(), min(C.blood_volume, 15))
		else
			holder.add_reagent(/datum/reagent/blood, min(C.blood_volume, 15))
	else
		holder.add_reagent(/datum/reagent/drug/mushroomhallucinogen, 15)

	var/location = get_turf(user)
	var/smoke_radius = round(sqrt(holder.total_volume / 2), 1)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder?.my_atom)
		holder.clear_reagents()
