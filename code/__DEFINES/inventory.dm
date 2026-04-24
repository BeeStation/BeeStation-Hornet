/*ALL DEFINES RELATED TO INVENTORY OBJECTS, MANAGEMENT, ETC, GO HERE*/

//! ## ITEM INVENTORY WEIGHT, FOR w_class

//! Usually items smaller then a human hand, (e.g. playing cards, lighter, scalpel, coins/holochips)
#define WEIGHT_CLASS_TINY 1
//! Pockets can hold small and tiny items, (e.g. flashlight, multitool, grenades, GPS device)
#define WEIGHT_CLASS_SMALL 2
//! Items which do not fit in pockets, but still fit easily into a backpack, (e.g. gas mask, iron sheets)
#define WEIGHT_CLASS_NORMAL 4

#define WEIGHT_CLASS_MEDIUM 6
//! The upper end of items that fit in backpacks, and take up a large amount of its space (e.g. Boxes, Stun Batons, Fire extinguishers)
#define WEIGHT_CLASS_LARGE 8
//! Items that can be wielded or equipped but not stored in an inventory, (e.g. defibrillator, backpack, space suits)
#define WEIGHT_CLASS_BULKY 10
//! Usually represents objects that require two hands to operate, (e.g. shotgun, two-handed melee weapons)
#define WEIGHT_CLASS_HUGE 12
//! Essentially means it cannot be picked up or placed in an inventory, (e.g. mech parts, safe)
#define WEIGHT_CLASS_GIGANTIC 15

//Inventory depth: limits how many nested storage items you can access directly.
//1: stuff in mob, 2: stuff in backpack, 3: stuff in box in backpack, etc
#define INVENTORY_DEPTH		3
#define STORAGE_VIEW_DEPTH	2

//ITEM INVENTORY SLOT BITMASKS
/// Suit slot (armors, costumes, space suits, etc.)
#define ITEM_SLOT_OCLOTHING (1<<0)
/// Jumpsuit slot
#define ITEM_SLOT_ICLOTHING (1<<1)
/// Glove slot
#define ITEM_SLOT_GLOVES (1<<2)
/// Glasses slot
#define ITEM_SLOT_EYES (1<<3)
/// Ear slot (radios, earmuffs)
#define ITEM_SLOT_EARS (1<<4)
/// Mask slot
#define ITEM_SLOT_MASK (1<<5)
/// Head slot (helmets, hats, etc.)
#define ITEM_SLOT_HEAD (1<<6)
/// Shoe slot
#define ITEM_SLOT_FEET (1<<7)
/// ID slot
#define ITEM_SLOT_ID (1<<8)
/// Belt slot
#define ITEM_SLOT_BELT (1<<9)
/// Back slot
#define ITEM_SLOT_BACK (1<<10)
/// Dextrous simplemob "hands" (used for Drones and Dextrous Guardians)
#define ITEM_SLOT_DEX_STORAGE (1<<11)
/// Neck slot (ties, bedsheets, scarves)
#define ITEM_SLOT_NECK (1<<12)
/// A character's hand slots
#define ITEM_SLOT_HANDS (1<<13)
/// Inside of a character's backpack
#define ITEM_SLOT_BACKPACK (1<<14)
/// Suit Storage slot
#define ITEM_SLOT_SUITSTORE (1<<15)
/// Left Pocket slot
#define ITEM_SLOT_LPOCKET (1<<16)
/// Right Pocket slot
#define ITEM_SLOT_RPOCKET (1<<17)
/// Handcuff slot
#define ITEM_SLOT_HANDCUFFED (1<<18)
/// Legcuff slot (bolas, beartraps)
#define ITEM_SLOT_LEGCUFFED (1<<19)

#define SLOTS_AMT 20 // Keep this up to date!

DEFINE_BITFIELD(no_equip_flags, list(
	"EXOSUIT" = ITEM_SLOT_OCLOTHING,
	"JUMPSUIT" = ITEM_SLOT_ICLOTHING,
	"GLOVES" = ITEM_SLOT_GLOVES,
	"GLASSES" = ITEM_SLOT_EYES,
	"EARPIECES" = ITEM_SLOT_EARS,
	"MASKS" = ITEM_SLOT_MASK,
	"HATS" = ITEM_SLOT_HEAD,
	"SHOES" = ITEM_SLOT_FEET,
	"BACKPACKS" = ITEM_SLOT_BACK,
	"TIES" = ITEM_SLOT_NECK,
))

//SLOT GROUP HELPERS
#define ITEM_SLOT_POCKETS (ITEM_SLOT_LPOCKET|ITEM_SLOT_RPOCKET)

//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
//Make sure to update check_obscured_slots() if you add more.
//! ## FLAGS FOR flags_inv
#define HIDEGLOVES (1<<0)
#define HIDESUITSTORAGE (1<<1)
#define HIDEJUMPSUIT (1<<2) //these first four are only used in exterior suits
#define HIDESHOES (1<<3)
#define HIDEMASK (1<<4) //these next seven are only used in masks and headgear.
#define HIDEEARS (1<<5) // (ears means headsets and such)
#define HIDEEYES (1<<6) // Whether eyes and glasses are hidden
#define HIDEFACE (1<<7) // Whether we appear as unknown.
#define HIDEHAIR (1<<8)
#define HIDEFACIALHAIR (1<<9)
#define HIDENECK (1<<10)
/// for wigs, only obscures the headgear
#define HIDEHEADGEAR (1<<11)
///for lizard snouts, because some HIDEFACE clothes don't actually conceal that portion of the head.
#define HIDESNOUT (1<<12)
///hides mutant/moth wings
#define HIDEMUTWINGS (1<<13)
///hides belts and riggings
#define HIDEBELT (1<<14)
///hides antennae
#define HIDEANTENNAE (1<<15)


//bitflags for clothing coverage - also used for limbs
#define HEAD (1<<0)
#define CHEST (1<<1)
#define GROIN (1<<2)
#define LEG_LEFT (1<<3)
#define LEG_RIGHT (1<<4)
#define LEGS (LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT (1<<5)
#define FOOT_RIGHT (1<<6)
#define FEET (FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT (1<<7)
#define ARM_RIGHT (1<<8)
#define ARMS (ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT (1<<9)
#define HAND_RIGHT (1<<10)
#define HANDS (HAND_LEFT | HAND_RIGHT)
#define NECK (1<<11)
#define FULL_BODY (~0)

//defines for the index of hands
#define LEFT_HANDS 1
#define RIGHT_HANDS 2

//flags for female outfits: How much the game can safely "take off" the uniform without it looking weird
/// For when there's simply no need for a female version of this uniform.
#define NO_FEMALE_UNIFORM 0
/// For the game to take off everything, disregards other flags.
#define FEMALE_UNIFORM_FULL (1<<0)
/// For when you really need to avoid the game cutting off that one pixel between the legs, to avoid the comeback of the infamous "dixel".
#define FEMALE_UNIFORM_TOP_ONLY (1<<1)
/// For when you don't want the "breast" effect to be applied (the one that cuts two pixels in the middle of the front of the uniform when facing east or west).
#define FEMALE_UNIFORM_NO_BREASTS (1<<2)

//flags for alternate styles: These are hard sprited so don't set this if you didn't put the effort in
#define NORMAL_STYLE 0
#define ALT_STYLE 1
#define DIGITIGRADE_STYLE 2

//flags for outfits that have mutantrace variants (try not to use this): Currently only needed if you're trying to add tight fitting bootyshorts
//This system takes priority over Sprite Sheets.

//Flags (actual flags, fucker ^) for /obj/item/var/supports_variations_flags
///No alternative sprites based on bodytype
#define CLOTHING_NO_VARIATION (1<<0)
///Has a sprite for digitigrade legs specifically.
#define CLOTHING_DIGITIGRADE_VARIATION (1<<1)
///The sprite works fine for digitigrade legs as-is.
#define CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON (1<<2)

#define NOT_DIGITIGRADE				0
#define FULL_DIGITIGRADE			1
#define SQUISHED_DIGITIGRADE		2

//! ## flags for covering body parts
#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)		//! get rid of some of the other stupidity in these flags
#define HEADCOVERSEYES		(1<<2)		//! feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH		(1<<3)		//! on other items, these are just for mask/head
#define HEADCOVERSMOUTH		(1<<4)

#define TINT_DARKENED 2			//! Threshold of tint level to apply weld mask overlay
#define TINT_BLIND 3			//! Threshold of tint level to obscure vision fully

//Allowed equipment lists for security vests and hardsuits.

GLOBAL_LIST_INIT(advanced_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun,
	/obj/item/melee/baton,
	/obj/item/melee/tonfa,
	/obj/item/reagent_containers/peppercloud_deployer,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals,
)))

GLOBAL_LIST_INIT(security_hardsuit_allowed, typecacheof(list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/gun/grenadelauncher,
	/obj/item/melee/baton,
	/obj/item/melee/tonfa,
	/obj/item/reagent_containers/peppercloud_deployer,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals,
)))

GLOBAL_LIST_INIT(detective_vest_allowed, (list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/detective_scanner,
	/obj/item/flashlight,
	/obj/item/taperecorder,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/gun/grenadelauncher,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/tonfa,
	/obj/item/reagent_containers/peppercloud_deployer,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_vest_allowed, (list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/gun/grenadelauncher,
	/obj/item/knife/combat,
	/obj/item/melee/baton,
	/obj/item/melee/tonfa,
	/obj/item/melee/baton/telescopic,
	/obj/item/reagent_containers/peppercloud_deployer,
	/obj/item/restraints/handcuffs,
	/obj/item/storage/belt/sabre/carbon_fiber,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman)))

GLOBAL_LIST_INIT(security_wintercoat_allowed, (list(
	/obj/item/ammo_box,
	/obj/item/ammo_casing,
	/obj/item/flashlight,
	/obj/item/storage/fancy/cigarettes,
	/obj/item/gun/ballistic,
	/obj/item/gun/energy,
	/obj/item/gun/grenadelauncher,
	/obj/item/lighter,
	/obj/item/melee/baton,
	/obj/item/melee/tonfa,
	/obj/item/melee/baton/telescopic,
	/obj/item/reagent_containers/peppercloud_deployer,
	/obj/item/restraints/handcuffs,
	/obj/item/tank/internals/emergency_oxygen,
	/obj/item/tank/internals/plasmaman,
	/obj/item/toy)))

// Collection flags for RPED inventory
#define COLLECT_ONE 0
#define COLLECT_EVERYTHING 1
#define COLLECT_SAME 2
