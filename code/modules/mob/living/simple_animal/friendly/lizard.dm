/mob/living/simple_animal/hostile/lizard
	name = "Lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	speak_emote = list("hisses")
	health = 5
	maxHealth = 5
	faction = list("Lizard")
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	melee_damage = 1
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/static/list/edibles = typecacheof(list(/mob/living/simple_animal/butterfly, /mob/living/basic/cockroach)) //list of atoms, however turfs won't affect AI, but will affect consumption.
	chat_color = "#64F88A"

/mob/living/simple_animal/hostile/lizard/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE
	if(is_type_in_typecache(the_target,edibles))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/lizard/AttackingTarget()
	if(is_type_in_typecache(target,edibles)) //Makes sure player lizards only consume edibles.
		visible_message("[name] consumes [target] in a single gulp.", "<span class='notice'>You consume [target] in a single gulp.</span>")
		QDEL_NULL(target) //Nom
		adjustBruteLoss(-2)
		return TRUE
	else
		return ..()
