/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Left Arm"
	id = "l_arm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/arm/left
	category = list("initial","human","lizard","fly","moth","plasmaman")

/datum/design/rightarm
	name = "Right Arm"
	id = "r_arm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/arm/right
	category = list("initial","human","lizard","fly","moth","plasmaman")

/datum/design/leftleg
	name = "Left Leg"
	id = "l_leg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/leg/left
	category = list("initial","human","lizard","fly","moth","plasmaman")

/datum/design/rightleg
	name = "Right Leg"
	id = "r_leg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/leg/right
	category = list("initial","human","lizard","fly","moth","plasmaman")

/datum/design/armblade
	name = "Arm Blade"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list("other","emagged")
