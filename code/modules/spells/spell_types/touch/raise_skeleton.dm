/datum/action/spell/touch/raise_skeleton
	name = "Raise Lesser Skeleton"
	desc = "This spell can be used to rip the skeleton out of a corpse and raise it as a loyal minion. Works even without available souls."
	button_icon_state = "raise_skeleton"
	sound = 'sound/magic/RATTLEMEBONES.ogg'

	school = SCHOOL_NECROMANCY
	cooldown_time = 3 MINUTES
	cooldown_reduction_per_rank = 30 SECONDS //Very slow with only one rank, but gets pretty good when its your main focus

	invocation = "VIT MORTE!"
	invocation_type = INVOCATION_SHOUT

	hand_path = /obj/item/melee/touch_attack/raise_skeleton

/datum/action/spell/touch/raise_skeleton/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(!ishuman(victim))
		to_chat(caster, (span_warningbold("This spell only works on humanoid targets.")))
		return FALSE

	if(victim.stat < DEAD)
		to_chat(caster, (span_warningbold("To rip the skeleton from a corpse, it must first be a corpse.")))
		return FALSE

	var/mob/living/carbon/human/human_victim = victim

	//dump all the organs out, we don't need those but we don't want to lose the brain when we destroy the head
	human_victim.spew_organ(amt = length(human_victim.internal_organs))

	//we also don't want any limbs left behind, we took the bones after all
	for(var/obj/item/bodypart/parts in human_victim.bodyparts)
		qdel(parts)

	var/turf/skeleton_turf = get_turf(human_victim)
	var/obj/effect/rune/narsie/necromantic_rune = new(skeleton_turf)
	necromantic_rune.color = COLOR_BLACK
	var/obj/effect/temp_visual/dir_setting/curse/long/necromantic_summon_effect = new(skeleton_turf)

	//We are left with a nugget, get rid of it to be replaced with our skeleton minion when the spell completes.
	human_victim.gib()
	human_victim.investigate_log("has been gibbed by the raise skeleton spell.", INVESTIGATE_DEATHS)

	var/datum/poll_config/config = new
	config.question ="Do you wish to be a wizard's skeletal minion?"
	config.check_jobban = ROLE_BRAINWASHED
	config.poll_time = 30 SECONDS
	config.ignore_category = POLL_IGNORE_WIZARD_HELPER
	config.jump_target = victim
	config.role_name_text = "spooky scary skeleton"
	config.alert_pic = /mob/living/carbon/human/species/skeleton
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)

	qdel(necromantic_rune)
	qdel(necromantic_summon_effect) //because the summon will be instant if no ghosts are available

	playsound(skeleton_turf, 'sound/magic/RATTLEMEBONES.ogg', 75, FALSE)
	if(!candidate)
		to_chat(caster, span_warning("This skeleton seems a bit mindless..."))
		var/mob/living/simple_animal/hostile/skeleton/mindless_skeleton = new(skeleton_turf)
		mindless_skeleton.faction = list(FACTION_WIZARD)
		mindless_skeleton.maxHealth = rand(80, 125)
		mindless_skeleton.melee_damage = rand(12, 20)
		mindless_skeleton.loot = list(/obj/item/bodypart/arm/left/skeleton, /obj/item/bodypart/arm/right/skeleton, /obj/item/bodypart/leg/left/skeleton, /obj/item/bodypart/leg/right/skeleton, /obj/item/bodypart/head/skeleton, /obj/item/bodypart/chest/skeleton)
		return TRUE //Technically a success

	var/datum/mind/candidate_mind = new /datum/mind(candidate.key)
	var/mob/living/carbon/human/species/skeleton/skelebones = new(skeleton_turf)
	skelebones.real_name = "Necro Skelebones ([rand(1,999)])"

	//Same equipment restrictions as golems. No hiding their identity or putting on any real armor
	skelebones.dna.species.no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE

	candidate_mind.active = 1
	candidate_mind.transfer_to(skelebones)
	to_chat(skelebones, span_userdanger("You have been brought into this world to serve your master [caster.real_name]. Obey any orders they give you."))
	return TRUE //Actually a success

/obj/item/melee/touch_attack/raise_skeleton
	name = "\improper necromantic touch"
	desc = "This hand of mine glows with the power to command the dead!"
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
