
/// Primal stuff crafting

/datum/crafting_recipe/bonearmor
	name = "Bone Armor"
	result = /obj/item/clothing/suit/armor/bone
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 6)
	category = CAT_CLOTHING

/datum/crafting_recipe/heavybonearmor
	name = "Heavy Bone Armor"
	result = /obj/item/clothing/suit/hooded/cloak/bone
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 8,
		/obj/item/stack/sheet/sinew = 3
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bonetalisman
	name = "Bone Talisman"
	result = /obj/item/clothing/accessory/talisman
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/sinew = 1
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bonecodpiece
	name = "Skull Codpiece"
	result = /obj/item/clothing/accessory/skullcodpiece
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 1
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/bracers
	name = "Bone Bracers"
	result = /obj/item/clothing/gloves/bracer
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 2,
		/obj/item/stack/sheet/sinew = 1
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/skullhelm
	name = "Skull Helmet"
	result = /obj/item/clothing/head/helmet/skull
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 4)
	category = CAT_CLOTHING

/datum/crafting_recipe/goliathcloak
	name = "Goliath Cloak"
	result = /obj/item/clothing/suit/hooded/cloak/goliath
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 2 //it takes 4 goliaths to make 1 cloak if the plates are skinned
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/drakecloak
	name = "Ash Drake Armour"
	result = /obj/item/clothing/suit/hooded/cloak/drake
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/ashdrake = 5
	)
	category = CAT_CLOTHING
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/watcherbola
	name = "Watcher Bola"
	result = /obj/item/restraints/legcuffs/bola/watcher
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/animalhide/goliath_hide = 2,
		/obj/item/restraints/handcuffs/cable/sinew = 1
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/goliathshield
	name = "Goliath shield"
	result = /obj/item/shield/riot/goliath
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 4,
		/obj/item/stack/sheet/animalhide/goliath_hide = 3
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/bonesword
	name = "Bone Sword"
	result = /obj/item/claymore/bone
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 3,
		/obj/item/stack/sheet/sinew = 2
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/hunterbelt
	name = "Hunters Belt"
	result = /obj/item/storage/belt/mining/primitive
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/goliath_hide = 2
	)
	category = CAT_CLOTHING

/datum/crafting_recipe/quiver
	name = "Quiver"
	result = /obj/item/storage/belt/quiver
	time = 8 SECONDS
	reqs = list(
		/obj/item/stack/sheet/leather = 3,
		/obj/item/stack/sheet/sinew = 4
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/bone_bow
	name = "Bone Bow"
	result = /obj/item/gun/ballistic/bow/ashen
	time = 20 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 8,
		/obj/item/stack/sheet/sinew = 4
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/bonedagger
	name = "Bone Dagger"
	result = /obj/item/knife/combat/bone
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/bonespear
	name = "Bone Spear"
	result = /obj/item/spear/bonespear
	time = 3 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 4,
		/obj/item/stack/sheet/sinew = 1
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/boneaxe
	name = "Bone Axe"
	result = /obj/item/fireaxe/boneaxe
	time = 5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 6,
		/obj/item/stack/sheet/sinew = 3
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/bonfire
	name = "Bonfire"
	time = 6 SECONDS
	reqs = list(/obj/item/grown/log = 5)
	parts = list(/obj/item/grown/log = 5)
	blacklist = list(/obj/item/grown/log/steel)
	result = /obj/structure/bonfire
	category = CAT_STRUCTURE

/datum/crafting_recipe/skeleton_key
	name = "Skeleton Key"
	time = 3 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 5)
	result = /obj/item/skeleton_key
	category = CAT_MISC
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/headpike
	name = "Spike Head (Glass Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear = 1,
		/obj/item/bodypart/head = 1
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear = 1
	)
	blacklist = list(/obj/item/spear/explosive, /obj/item/spear/bonespear, /obj/item/spear/bamboospear)
	result = /obj/structure/headpike/glass
	category = CAT_ENTERTAINMENT
	dangerous_craft = TRUE

/datum/crafting_recipe/headpikebone
	name = "Spike Head (Bone Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear/bonespear = 1,
		/obj/item/bodypart/head = 1
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear/bonespear = 1
	)
	result = /obj/structure/headpike/bone
	category = CAT_ENTERTAINMENT
	dangerous_craft = TRUE

/datum/crafting_recipe/headpikebamboo
	name = "Spike Head (Bamboo Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear/bamboospear = 1,
		/obj/item/bodypart/head = 1
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear/bamboospear = 1
	)
	result = /obj/structure/headpike/bamboo
	category = CAT_ENTERTAINMENT
	dangerous_craft = TRUE

/datum/crafting_recipe/primal_lasso
	name= "Primal Lasso"
	result = /obj/item/mob_lasso/primal
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/animalhide/goliath_hide = 3,
		/obj/item/stack/sheet/sinew = 4
	)
	category = CAT_EQUIPMENT
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/dragon_lasso
	name = "Ash Drake Lasso"
	result = /obj/item/mob_lasso/drake
	time = 2 SECONDS
	reqs = list(
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
		/obj/item/stack/sheet/animalhide/ashdrake = 5
	)
	category = CAT_EQUIPMENT
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/mushroom_bowl
	name = "Mushroom Bowl"
	result = /obj/item/reagent_containers/cup/bowl/mushroom_bowl
	time = 3 SECONDS
	reqs = list(/obj/item/food/grown/ash_flora/shavings = 5)
	category = CAT_CONTAINERS

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(
		/obj/item/stack/sheet/wood = 1,
		/datum/reagent/ash = 30
	)
	time = 3 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/oar
	name = "Goliath Bone Oar"
	result = /obj/item/oar
	time = 1.5 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 2)
	category = CAT_TOOLS

/datum/crafting_recipe/boat
	name = "Goliath Hide Boat (lava boat)"
	result = /obj/vehicle/ridden/lavaboat
	time = 5 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	category = CAT_TOOLS
