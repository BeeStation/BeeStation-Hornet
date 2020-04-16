
//make incision
/datum/surgery_step/incise
	name = "make incision"
	implements = list(TOOL_SCALPEL = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	time = 16

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to make an incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE

	return TRUE

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if ishuman(target)
		var/mob/living/carbon/human/H = target
		if (!(NOBLOOD in H.dna.species.species_traits))
			display_results(user, target, "<span class='notice'>Blood pools around the incision in [H]'s [parse_zone(target_zone)].</span>",
				"Blood pools around the incision in [H]'s [parse_zone(target_zone)].",
				"")
			H.bleed_rate += 3
	return TRUE

/datum/surgery_step/incise/nobleed //silly friendly!

/datum/surgery_step/incise/nobleed/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to <i>carefully</i> make an incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/incise/nobleed/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	return TRUE

//clamp bleeders
/datum/surgery_step/clamp_bleeders
	name = "clamp bleeders"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	time = 24

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to clamp bleeders in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].",
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(20,0)
	return ..()


//retract skin
/datum/surgery_step/retract_skin
	name = "retract skin"
	implements = list(TOOL_RETRACTOR = 100, TOOL_SCREWDRIVER = 45, TOOL_WIRECUTTER = 35)
	time = 24

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to retract the skin in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].")



//close incision
/datum/surgery_step/close
	name = "mend incision"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70,
		/obj/item = 30) // 30% success with any hot item.
	time = 24

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to mend the incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.is_hot()

	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(45,0)
	return ..()



//saw bone
/datum/surgery_step/saw
	name = "saw bone"
	implements = list(TOOL_SAW = 100,/obj/item/melee/arm_blade = 75,
	/obj/item/twohanded/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	time = 54

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to saw through the bone in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.apply_damage(50, BRUTE, "[target_zone]")
	display_results(user, target, "<span class='notice'>You saw [target]'s [parse_zone(target_zone)] open.</span>",
		"[user] saws [target]'s [parse_zone(target_zone)] open!",
		"[user] saws [target]'s [parse_zone(target_zone)] open!")
	return 1

//drill bone
/datum/surgery_step/drill
	name = "drill bone"
	implements = list(TOOL_DRILL = 100, /obj/item/screwdriver/power = 80, /obj/item/pickaxe/drill = 60, TOOL_SCREWDRIVER = 20)
	time = 30

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>",
		"[user] drills into [target]'s [parse_zone(target_zone)]!",
		"[user] drills into [target]'s [parse_zone(target_zone)]!")
	return 1
