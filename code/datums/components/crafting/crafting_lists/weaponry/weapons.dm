
/// Weapon Crafting

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/grenade/iedcasing
	time = 1.5 SECONDS
	reqs = list(
		/datum/reagent/fuel = 50,
		/obj/item/stack/cable_coil = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/reagent_containers/cup/soda_cans = 1
	)
	parts = list(/obj/item/reagent_containers/cup/soda_cans = 1)
	category = CAT_CHEMISTRY
	dangerous_craft = TRUE

/datum/crafting_recipe/lance
	name = "Explosive Lance (Grenade)"
	result = /obj/item/spear/explosive
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	parts = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	blacklist = list(/obj/item/spear/bonespear)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/strobeshield
	name = "Strobe Shield"
	result = /obj/item/shield/riot/flash
	time = 4 SECONDS
	reqs = list(
		/obj/item/wallframe/flasher = 1,
		/obj/item/assembly/flash/handheld = 1,
		/obj/item/shield/riot = 1
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/strobeshield/New()
	..()
	blacklist |= subtypesof(/obj/item/shield/riot)

/datum/crafting_recipe/molotov
	name = "Molotov"
	result = /obj/item/reagent_containers/cup/glass/bottle/molotov
	time = 4 SECONDS
	reqs = list(
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/reagent_containers/cup/glass/bottle = 1
	)
	parts = list(/obj/item/reagent_containers/cup/glass/bottle = 1)
	category = CAT_CHEMISTRY
	dangerous_craft = TRUE

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result = /obj/item/melee/baton/security/cattleprod
	time = 4 SECONDS
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/teleprod
	name = "Teleprod"
	result = /obj/item/melee/baton/security/cattleprod/teleprod
	time = 4 SECONDS
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/rods = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/ore/bluespace_crystal = 1
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/bola
	name = "Bola"
	result = /obj/item/restraints/legcuffs/bola
	time = 2 SECONDS//15 faster than crafting them by hand!
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/sheet/iron = 6
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/gonbola
	name = "Gonbola"
	result = /obj/item/restraints/legcuffs/bola/gonbola
	time = 4 SECONDS
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/sheet/animalhide/gondola = 1
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/tailclub
	name = "Tail Club"
	result = /obj/item/club/tailclub
	time = 4 SECONDS
	reqs = list(
		/obj/item/organ/tail/lizard = 1,
		/obj/item/stack/sheet/iron = 1
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/club
	name = "improvised maul"
	result = /obj/item/club/ghettoclub
	time = 4 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/rods = 1,
		/obj/item/restraints/handcuffs/cable = 2,
		/obj/item/stack/sheet/cotton/cloth = 3
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/tailwhip
	name = "Liz O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip
	time = 4 SECONDS
	reqs = list(
		/obj/item/organ/tail/lizard = 1,
		/obj/item/stack/cable_coil = 1
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/catwhip
	name = "Cat O' Nine Tails"
	result = /obj/item/melee/chainofcommand/tailwhip/kitty
	time = 4 SECONDS
	reqs = list(
		/obj/item/organ/tail/cat = 1,
		/obj/item/stack/cable_coil = 1
	)
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but arguably underused for what it is...
	name = "Pneumatic Cannon"
	result = /obj/item/pneumatic_cannon/ghetto
	time = 5 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/package_wrap = 8,
		/obj/item/pipe = 2
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = /obj/item/flamethrower
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/weldingtool = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/rods = 1
	)
	parts = list(
		/obj/item/assembly/igniter = 1,
		/obj/item/weldingtool = 1
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/pipebow
	name = "Pipe Bow"
	result = /obj/item/gun/ballistic/bow/pipe
	time = 12 SECONDS
	reqs = list(
		/obj/item/pipe = 5,
		/obj/item/stack/sheet/plastic = 15,
		/obj/item/weaponcrafting/silkstring = 4
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/woodenbow
	name = "Wooden Bow"
	result = /obj/item/gun/ballistic/bow
	time = 12 SECONDS
	reqs = list(
		/obj/item/stack/sheet/wood = 8,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/weaponcrafting/silkstring = 4
	)
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/ishotgun
	name = "Improvised Shotgun"
	result = /obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/pipe = 1,
		/obj/item/weaponcrafting/stock = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/package_wrap = 5
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/piperifle
	name = "Singleshot Pipe Rifle"
	result = /obj/item/gun/ballistic/rifle/pipe
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/pipe = 1,
		/obj/item/weaponcrafting/stock = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/package_wrap = 5
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/pipesmg
	name = "Mag-Fed Pipe Repeater"
	result = /obj/item/gun/ballistic/automatic/pipe_smg
	time = 10 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WELDER)
	reqs = list(
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/pipe = 2,
		/obj/item/stack/rods = 2,
		/obj/item/stack/sheet/wood = 2,
		/obj/item/assembly/igniter = 1,
		/obj/item/stack/package_wrap = 5
	)
	category = CAT_WEAPON_RANGED
	dangerous_craft = TRUE

/datum/crafting_recipe/chainsaw
	name = "Chainsaw"
	result = /obj/item/chainsaw
	time = 5 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/circular_saw = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/plasteel = 5
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/spear
	name = "Spear"
	result = /obj/item/spear
	time = 4 SECONDS
	reqs = list(
		/obj/item/restraints/handcuffs/cable = 1,
		/obj/item/shard = 1,
		/obj/item/stack/rods = 1
	)
	parts = list(/obj/item/shard = 1)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/switchblade_kitchen
	name = "Iron Switchblade"
	result = /obj/item/switchblade/kitchen
	time = 4 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/knife = 1,
		/obj/item/stack/cable_coil = 2
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/switchblade_kitchenupgrade
	name = "Plastitanium Switchblade"
	result = /obj/item/switchblade/plastitanium
	time = 2 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/switchblade/kitchen = 1,
		/obj/item/stack/sheet/mineral/plastitanium = 2
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/switchblade_plastitanium
	name = "Plastitanium Switchblade"
	result = /obj/item/switchblade/plastitanium
	time = 6.5 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/weaponcrafting/stock = 1,
		/obj/item/weaponcrafting/receiver = 1,
		/obj/item/knife = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/mineral/plastitanium = 2
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/chemical_payload
	name = "Chemical Payload"
	result = /obj/item/bombcore/chemical
	time = 3 SECONDS
	reqs = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/assembly/igniter = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	parts = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/grenade/chem_grenade = 2
	)
	category = CAT_CHEMISTRY
	dangerous_craft = TRUE

// Shank - Makeshift weapon that can embed on throw
/datum/crafting_recipe/shank
	name = "Shank"
	result = /obj/item/knife/shiv
	time = 2 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/shard = 1,
		/obj/item/stack/cable_coil = 10
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/sharpmop
	name = "Sharpened Mop"
	result = /obj/item/mop/sharp
	time = 3 SECONDS
	tool_behaviors = list(TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/mop = 1,
		/obj/item/shard = 1
	)
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/stake
	name = "Stake"
	result = /obj/item/stake
	reqs = list(/obj/item/stack/sheet/wood = 3)
	time = 8 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/hardened_stake
	name = "Hardened Stake"
	result = /obj/item/stake/hardened
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/rods = 1)
	time = 6 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE
	crafting_flags = CRAFT_MUST_BE_LEARNED

/datum/crafting_recipe/silver_stake
	name = "Silver Stake"
	result = /obj/item/stake/hardened/silver
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stake/hardened = 1,
	)
	time = 8 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE
	crafting_flags = CRAFT_MUST_BE_LEARNED
