/////////////////////////////Proteon/////////////////////////
/mob/living/simple_animal/hostile/construct/proteon
	name = "Proteon"
	real_name = "Proteon"
	desc = "A weaker construct meant to scour ruins for objects of Nar'Sie's affection. Those barbed claws are no joke."
	icon_state = "proteon"
	icon_living = "proteon"
	maxHealth = 35
	health = 35
	melee_damage = 9
	retreat_distance = 4 //AI proteons will rapidly move in and out of combat to avoid conflict, but will still target and follow you.
	attack_verb_continuous = "pinches"
	attack_verb_simple = "pinch"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch2.ogg'
	playstyle_string = "<b>You are a Proteon. Your abilities in combat are outmatched by most combat constructs, but you are still fast and nimble. Run metal and supplies, and cooperate with your fellow cultists.</b>"

/mob/living/simple_animal/hostile/construct/proteon/hostile //Style of mob spawned by trapped cult runes in the cleric ruin.
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //standard ai construct behavior, breaks things if it wants, but not walls.
