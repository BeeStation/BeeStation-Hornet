///SNAIL
/obj/item/bodypart/head/snail
	limb_id = SPECIES_SNAIL
	is_dimorphic = FALSE
	head_flags = HEAD_EYESPRITES|HEAD_DEBRAIN
	burn_modifier = 1.5

/obj/item/bodypart/chest/snail
	limb_id = SPECIES_SNAIL
	is_dimorphic = FALSE
	wing_types = NONE
	burn_modifier = 1.5

/obj/item/bodypart/arm/left/snail
	limb_id = SPECIES_SNAIL
	unarmed_attack_verb = "slap"
	unarmed_attack_effect = ATTACK_EFFECT_DISARM
	unarmed_damage = 3 //snails are soft and squishy
	movespeed_contribution = 3 //disgustingly slow
	burn_modifier = 1.5

/obj/item/bodypart/arm/right/snail
	limb_id = SPECIES_SNAIL
	unarmed_attack_verb = "slap"
	unarmed_attack_effect = ATTACK_EFFECT_DISARM
	unarmed_damage = 3
	movespeed_contribution = 3 //disgustingly slow
	burn_modifier = 1.5

/obj/item/bodypart/leg/left/snail
	limb_id = SPECIES_SNAIL
	unarmed_damage = 3
	burn_modifier = 1.5

/obj/item/bodypart/leg/right/snail
	limb_id = SPECIES_SNAIL
	unarmed_damage = 3
	burn_modifier = 1.5

///ABDUCTOR
/obj/item/bodypart/head/abductor
	limb_id = SPECIES_ABDUCTOR
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = NONE

/obj/item/bodypart/chest/abductor
	limb_id = SPECIES_ABDUCTOR
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	wing_types = NONE

/obj/item/bodypart/arm/left/abductor
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/abductor
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/leg/left/abductor
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/abductor
	limb_id = SPECIES_ABDUCTOR
	should_draw_greyscale = FALSE

///SLIME
/obj/item/bodypart/head/slime
	limb_id = SPECIES_SLIMEPERSON
	is_dimorphic = FALSE
	dmg_overlay_type = null
	head_flags = HEAD_ALL_FEATURES

/obj/item/bodypart/chest/slime
	limb_id = SPECIES_SLIMEPERSON
	is_dimorphic = TRUE
	dmg_overlay_type = null
	wing_types = NONE

/obj/item/bodypart/arm/left/slime
	limb_id = SPECIES_SLIMEPERSON
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/slime
	limb_id = SPECIES_SLIMEPERSON
	dmg_overlay_type = null

/obj/item/bodypart/leg/left/slime
	limb_id = SPECIES_SLIMEPERSON
	dmg_overlay_type = null

/obj/item/bodypart/leg/right/slime
	limb_id = SPECIES_SLIMEPERSON
	dmg_overlay_type = null

///LUMINESCENT
/obj/item/bodypart/head/luminescent
	limb_id = SPECIES_LUMINESCENT
	is_dimorphic = TRUE
	dmg_overlay_type = null
	head_flags = HEAD_ALL_FEATURES

/obj/item/bodypart/chest/luminescent
	limb_id = SPECIES_LUMINESCENT
	is_dimorphic = TRUE
	dmg_overlay_type = null
	wing_types = NONE

/obj/item/bodypart/arm/left/luminescent
	limb_id = SPECIES_LUMINESCENT
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/luminescent
	limb_id = SPECIES_LUMINESCENT
	dmg_overlay_type = null

/obj/item/bodypart/leg/left/luminescent
	limb_id = SPECIES_LUMINESCENT
	dmg_overlay_type = null

/obj/item/bodypart/leg/right/luminescent
	limb_id = SPECIES_LUMINESCENT
	dmg_overlay_type = null

///ZAMBONI
/obj/item/bodypart/head/zombie
	limb_id = SPECIES_ZOMBIE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = HEAD_EYESPRITES|HEAD_DEBRAIN

/obj/item/bodypart/chest/zombie
	limb_id = SPECIES_ZOMBIE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	wing_types = NONE

/obj/item/bodypart/arm/left/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/zombie
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/zombie/infectious
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.8 //braaaaains

/obj/item/bodypart/leg/right/zombie/infectious
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.8 //braaaaains

/obj/item/bodypart/leg/left/zombie/viral
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0 //braaaaains

/obj/item/bodypart/leg/right/zombie/viral
	limb_id = SPECIES_ZOMBIE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0 //braaaaains

///FLY
/obj/item/bodypart/head/fly
	limb_id = SPECIES_FLYPERSON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.4
	brute_modifier = 1.4

/obj/item/bodypart/chest/fly
	limb_id = SPECIES_FLYPERSON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.4
	brute_modifier = 1.4
	wing_types = list(/obj/item/organ/wings/fly)

/obj/item/bodypart/arm/left/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE
	burn_modifier = 1.4
	brute_modifier = 1.4

/obj/item/bodypart/arm/right/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE
	burn_modifier = 1.4
	brute_modifier = 1.4

/obj/item/bodypart/leg/left/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.35
	burn_modifier = 1.4
	brute_modifier = 1.4

/obj/item/bodypart/leg/right/fly
	limb_id = SPECIES_FLYPERSON
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.35
	burn_modifier = 1.4
	brute_modifier = 1.4

///SHADOW
/obj/item/bodypart/head/shadow
	limb_id = SPECIES_SHADOW
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	head_flags = NONE

/obj/item/bodypart/chest/shadow
	limb_id = SPECIES_SHADOW
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)

/obj/item/bodypart/arm/left/shadow
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/shadow
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/shadow
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/shadow
	limb_id = SPECIES_SHADOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/shadow/nightmare
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/bodypart/arm/right/shadow/nightmare
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)

///SKELETON
/obj/item/bodypart/head/skeleton
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	head_flags = NONE

/obj/item/bodypart/chest/skeleton
	limb_id = SPECIES_SKELETON
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = null
	wing_types = list(/obj/item/organ/wings/skeleton)

/obj/item/bodypart/arm/left/skeleton
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/arm/right/skeleton
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/leg/left/skeleton
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/leg/right/skeleton
	limb_id = SPECIES_SKELETON
	should_draw_greyscale = FALSE
	dmg_overlay_type = null

///GOLEMS (i hate xenobio)
/obj/item/bodypart/head/golem
	limb_id = SPECIES_GOLEM
	is_dimorphic = FALSE
	dmg_overlay_type = null
	head_flags = NONE

/obj/item/bodypart/chest/golem
	limb_id = SPECIES_GOLEM
	is_dimorphic = FALSE
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)
	wing_types = NONE

/obj/item/bodypart/arm/left/golem
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage = 11 // I'd like to take the moment that maintaining all of these random ass golem species is hell and oranges was right

/obj/item/bodypart/arm/right/golem
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage = 11
	movespeed_contribution = 1

/obj/item/bodypart/leg/left/golem
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage = 11
	movespeed_contribution = 1

/obj/item/bodypart/leg/right/golem
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage = 11

/obj/item/bodypart/leg/left/golem/gold
	movespeed_contribution = 0.5

/obj/item/bodypart/leg/right/golem/gold
	movespeed_contribution = 0.5

/obj/item/bodypart/leg/left/golem/copper
	movespeed_contribution = 0.75

/obj/item/bodypart/leg/right/golem/copper
	movespeed_contribution = 0.75

//Alloy
/obj/item/bodypart/head/golem/alloy
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/alloy
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/alloy
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/alloy
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/alloy
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.5 //faster

/obj/item/bodypart/leg/right/golem/alloy
	should_draw_greyscale = FALSE
	movespeed_contribution = 0.5 //faster

//Wood
/obj/item/bodypart/head/golem/wood
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/chest/golem/wood
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/left/golem/wood
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/right/golem/wood
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/leg/left/golem/wood
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/leg/right/golem/wood
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

///
/obj/item/bodypart/head/golem/bananium
	limb_id = "ba_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/bananium
	limb_id = "ba_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/bananium
	limb_id = "ba_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/bananium
	limb_id = "ba_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/bananium
	limb_id = "ba_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/bananium
	limb_id = "ba_golem"
	should_draw_greyscale = FALSE

///
/obj/item/bodypart/head/golem/runic
	limb_id = "cultgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

/obj/item/bodypart/chest/golem/runic
	limb_id = "cultgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

/obj/item/bodypart/arm/left/golem/runic
	limb_id = "cultgolem"
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

/obj/item/bodypart/arm/right/golem/runic
	limb_id = "cultgolem"
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

/obj/item/bodypart/leg/left/golem/runic
	limb_id = "cultgolem"
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

/obj/item/bodypart/leg/right/golem/runic
	limb_id = "cultgolem"
	should_draw_greyscale = FALSE
	movespeed_contribution = 0

///
/obj/item/bodypart/head/golem/clock
	limb_id = "clockgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"

/obj/item/bodypart/chest/golem/clock
	limb_id = "clockgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"

/obj/item/bodypart/arm/left/golem/clock
	limb_id = "clockgolem"
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"

/obj/item/bodypart/arm/right/golem/clock
	limb_id = "clockgolem"
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"
	movespeed_contribution = 0

/obj/item/bodypart/leg/left/golem/clock
	limb_id = "clockgolem"
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"
	movespeed_contribution = 0

/obj/item/bodypart/leg/right/golem/clock
	limb_id = "clockgolem"
	should_draw_greyscale = FALSE
	dmg_overlay_type = "synth"

///
/obj/item/bodypart/head/golem/cloth
	limb_id = "clothgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 2 // don't get burned

/obj/item/bodypart/chest/golem/cloth
	limb_id = "clothgolem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 2 // don't get burned

/obj/item/bodypart/arm/left/golem/cloth
	limb_id = "clothgolem"
	should_draw_greyscale = FALSE
	unarmed_damage = 6
	burn_modifier = 2 // don't get burned

/obj/item/bodypart/arm/right/golem/cloth
	limb_id = "clothgolem"
	should_draw_greyscale = FALSE
	unarmed_damage = 6
	burn_modifier = 2 // don't get burned

/obj/item/bodypart/leg/left/golem/cloth
	limb_id = "clothgolem"
	should_draw_greyscale = FALSE
	unarmed_damage = 6
	movespeed_contribution = 0.5 // not as heavy as stone
	burn_modifier = 2 // don't get burned

/obj/item/bodypart/leg/right/golem/cloth
	limb_id = "clothgolem"
	should_draw_greyscale = FALSE
	unarmed_damage = 6
	movespeed_contribution = 0.5 // not as heavy as stone
	burn_modifier = 2 // don't get burned

///
/obj/item/bodypart/head/golem/cardboard
	limb_id = "c_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/chest/golem/cardboard
	limb_id = "c_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/left/golem/cardboard
	limb_id = "c_golem"
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "whip"
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage = 6
	burn_modifier = 1.25

/obj/item/bodypart/arm/right/golem/cardboard
	limb_id = "c_golem"
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "whip"
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage = 6
	burn_modifier = 1.25

/obj/item/bodypart/leg/left/golem/cardboard
	limb_id = "c_golem"
	should_draw_greyscale = FALSE
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage = 6
	movespeed_contribution = 0.75
	burn_modifier = 1.25

/obj/item/bodypart/leg/right/golem/cardboard
	limb_id = "c_golem"
	should_draw_greyscale = FALSE
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage = 6
	movespeed_contribution = 0.75
	burn_modifier = 1.25

///
/obj/item/bodypart/head/golem/durathread
	limb_id = "d_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/durathread
	limb_id = "d_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/durathread
	limb_id = "d_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/durathread
	limb_id = "d_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/durathread
	limb_id = "d_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/durathread
	limb_id = "d_golem"
	should_draw_greyscale = FALSE

///
/obj/item/bodypart/head/golem/bone
	limb_id = "b_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/bone
	limb_id = "b_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/bone
	limb_id = "b_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/bone
	limb_id = "b_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/bone
	limb_id = "b_golem"
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/bone
	limb_id = "b_golem"
	should_draw_greyscale = FALSE

///
/obj/item/bodypart/head/golem/snow
	limb_id = "sn_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

/obj/item/bodypart/chest/golem/snow
	limb_id = "sn_golem"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

/obj/item/bodypart/arm/left/golem/snow
	limb_id = "sn_golem"
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

/obj/item/bodypart/arm/right/golem/snow
	limb_id = "sn_golem"
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

/obj/item/bodypart/leg/left/golem/snow
	limb_id = "sn_golem"
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

/obj/item/bodypart/leg/right/golem/snow
	limb_id = "sn_golem"
	should_draw_greyscale = FALSE
	burn_modifier = 3 //melts easily

///
/obj/item/bodypart/head/golem/uranium
	brute_modifier = 0.5

/obj/item/bodypart/chest/golem/uranium
	brute_modifier = 0.5

/obj/item/bodypart/arm/left/golem/uranium
	attack_type = BURN
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage = 8
	brute_modifier = 0.5

/obj/item/bodypart/arm/right/golem/uranium
	attack_type = BURN
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage = 8
	brute_modifier = 0.5

/obj/item/bodypart/leg/left/golem/uranium
	attack_type = BURN
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage = 8
	brute_modifier = 0.5

/obj/item/bodypart/leg/right/golem/uranium
	attack_type = BURN
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage = 8
	brute_modifier = 0.5

//Sand
/obj/item/bodypart/head/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

/obj/item/bodypart/chest/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

/obj/item/bodypart/arm/left/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

/obj/item/bodypart/arm/right/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

/obj/item/bodypart/leg/left/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

/obj/item/bodypart/leg/right/golem/sand
	brute_modifier = 3 //melts easily
	brute_modifier = 0.25

//Glass
/obj/item/bodypart/head/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

/obj/item/bodypart/chest/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

/obj/item/bodypart/arm/left/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

/obj/item/bodypart/arm/right/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

/obj/item/bodypart/leg/left/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

/obj/item/bodypart/leg/right/golem/glass
	brute_modifier = 3 //very fragile
	burn_modifier = 0.25

//Plasteel
/obj/item/bodypart/arm/left/golem/plasteel
	unarmed_attack_verb = "smash"
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard
	unarmed_damage = 18

/obj/item/bodypart/arm/right/golem/plasteel
	unarmed_attack_verb = "smash"
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage = 18
	movespeed_contribution = 2 //pretty fucking slow

/obj/item/bodypart/leg/left/golem/plasteel
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage = 18
	movespeed_contribution = 2 //pretty fucking slow

/obj/item/bodypart/leg/right/golem/plasteel
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage = 18


//Titanium
/obj/item/bodypart/head/golem/titanium
	burn_modifier = 0.9

/obj/item/bodypart/chest/golem/titanium
	burn_modifier = 0.9

/obj/item/bodypart/arm/left/golem/titanium
	burn_modifier = 0.9

/obj/item/bodypart/arm/right/golem/titanium
	burn_modifier = 0.9

/obj/item/bodypart/leg/left/golem/titanium
	burn_modifier = 0.9

/obj/item/bodypart/leg/right/golem/titanium
	burn_modifier = 0.9


//Plastitanium
/obj/item/bodypart/head/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/chest/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/arm/left/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/arm/right/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/leg/left/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/leg/right/golem/plastitanium
	burn_modifier = 0.8

/obj/item/bodypart/arm/left/golem/bananium
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage = 0

/obj/item/bodypart/arm/right/golem/bananium
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage = 0

/obj/item/bodypart/leg/right/golem/bananium
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage = 0

/obj/item/bodypart/leg/left/golem/bananium
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage = 0

/// Pumpkin people

/obj/item/bodypart/head/pumpkin_man
	limb_id = "pumpkin_man"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25
	/*
	///Carved overlay
	var/image/carved_overlay

/obj/item/bodypart/head/pumpkin_man/Initialize(mapload)
	carved_overlay = image('icons/mob/pumpkin_faces.dmi', "blank", layer = CALCULATE_MOB_OVERLAY_LAYER(BODY_LAYER))
	. = ..() // set after carved_overlay is set

/obj/item/bodypart/head/pumpkin_man/get_limb_icon(dropped)
	. = ..()
	if(owner)
		owner.cut_overlay(carved_overlay)
	. += carved_overlay
	*/

/obj/item/bodypart/chest/pumpkin_man
	limb_id = "pumpkin_man"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/arm/left/pumpkin_man
	limb_id = "pumpkin_man"
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "punch"
	unarmed_attack_effect = ATTACK_EFFECT_PUNCH
	unarmed_attack_sound = 'sound/weapons/punch1.ogg'
	unarmed_miss_sound = 'sound/weapons/punchmiss.ogg'
	burn_modifier = 1.25

/obj/item/bodypart/arm/right/pumpkin_man
	limb_id = "pumpkin_man"
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "punch"
	unarmed_attack_effect = ATTACK_EFFECT_PUNCH
	unarmed_attack_sound = 'sound/weapons/punch1.ogg'
	unarmed_miss_sound = 'sound/weapons/punchmiss.ogg'
	burn_modifier = 1.25

/obj/item/bodypart/leg/left/pumpkin_man
	limb_id = "pumpkin_man"
	should_draw_greyscale = FALSE
	burn_modifier = 1.25

/obj/item/bodypart/leg/right/pumpkin_man
	limb_id = "pumpkin_man"
	should_draw_greyscale = FALSE
	burn_modifier = 1.25
