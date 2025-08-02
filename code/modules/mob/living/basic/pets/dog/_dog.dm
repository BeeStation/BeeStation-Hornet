// Add 'walkies' as valid input
/datum/pet_command/follow/dog
	speech_commands = list("heel", "follow", "walkies", "come", "komm", "fuss")

// Add 'good dog' as valid input
/datum/pet_command/good_boy/dog
	speech_commands = list("good dog", "good boy", "brav")

// Set correct attack behaviour
/datum/pet_command/point_targetting/attack/dog
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/dog
	speech_commands = list("attack", "sic", "kill", "fass")

/datum/pet_command/point_targetting/attack/dog/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_DOG_HARASS_HARM, TRUE)

/datum/pet_command/point_targetting/fetch/dog
	speech_commands = list("fetch", "apport", "bring")

/datum/pet_command/play_dead/dog
	speech_commands = list("play dead", "tot stellen")

/mob/living/basic/pet/dog
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak_emote = list("barks", "woofs")
	faction = list(FACTION_NEUTRAL)
	can_be_held = TRUE
	ai_controller = /datum/ai_controller/basic_controller/dog
	// The dog attack pet command can raise melee attack above 0
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/point_targetting/attack/dog,
		/datum/pet_command/point_targetting/fetch/dog,
		/datum/pet_command/play_dead/dog,
	)

/mob/living/basic/pet/dog/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "woofs happily!")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddElement(/datum/element/unfriend_attacker, untamed_reaction = "%SOURCE% fixes %TARGET% with a look of betrayal.")
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat/slab/human/mutant/skeleton, /obj/item/stack/sheet/bone), tame_chance = 30, bonus_tame_chance = 15, after_tame = CALLBACK(src, PROC_REF(tamed)), unique = FALSE)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(D.update_owner(src)) //No muscling in on my turf you fucking parrot
			break

/mob/living/basic/pet/dog/proc/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("YAP", "Woof!", "Bark!", "AUUUUUU"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/proc/tamed(mob/living/tamer)
	visible_message(span_notice("[src] licks at [tamer] in a friendly manner!"))

/// A dog bone fully heals a dog, and befriends it if it's not your friend.
/obj/item/dog_bone
	name = "jumbo dog bone"
	desc = "A tasty femur full of juicy marrow, the perfect gift for your best friend."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "skeletonmeat"
	force = 3
	throwforce = 5
	attack_verb_continuous = list("attacks", "bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("attack", "bash", "batter", "bludgeon", "whack")

/obj/item/dog_bone/pre_attack(atom/target, mob/living/user, params)
	if (!isdog(target) || user.combat_mode)
		return ..()
	var/mob/living/basic/pet/dog/dog_target = target
	if (dog_target.stat != CONSCIOUS)
		return ..()
	dog_target.emote("spin")
	dog_target.fully_heal()
	if (dog_target.befriend(user))
		dog_target.tamed(user)
	new /obj/effect/temp_visual/heart(target.loc)
	qdel(src)
	return TRUE
