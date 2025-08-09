// Flags for the obj_flags var on /obj


#define EMAGGED (1<<0)
#define IN_USE (1<<1)  //! If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define CAN_BE_HIT (1<<2)  //! can this be bludgeoned by items?
#define BEING_SHOCKED (1<<3)  //! Whether this thing is currently (already) being shocked by a tesla
#define DANGEROUS_POSSESSION (1<<4)  //! Admin possession yes/no
#define ON_BLUEPRINTS (1<<5)  //! Are we visible on the station blueprints at roundstart?
#define UNIQUE_RENAME (1<<6)  //! can you customize the description/name of the thing?
#define USES_TGUI (1<<7)  //! put on things that use tgui on ui_interact instead of custom/old UI.
#define OBJ_EMPED (1<<8)  //! Object is affected by EMP
#define SCANNED (1<<9)  //! Object has been scanned by the prison_scanner
#define BLOCKS_CONSTRUCTION (1<<10) //! Does this object prevent things from being built on it?
#define BLOCKS_CONSTRUCTION_DIR (1<<11) //! Does this object prevent same-direction things from being built on it?
#define IGNORE_DENSITY (1<<12) //! Can we ignore density when building on this object? (for example, directional windows and grilles)

// If you add new ones, be sure to add them to /obj/Initialize as well for complete mapping support

// Flags for the item_flags var on /obj/item

#define BEING_REMOVED			(1<<0)
#define PICKED_UP				(1<<1)  //! Has this item been picked up by a mob and on their person? Handles pickup() behaviour, tooltips and outlining. Does not include backpack contents, that is covered by IN_STORAGE>
#define FORCE_STRING_OVERRIDE	(1<<2)  //! used for tooltips
#define NEEDS_PERMIT			(1<<3)  //! Used by security bots to determine if this item is safe for public use.
#define SLOWS_WHILE_IN_HAND		(1<<4)
#define NO_MAT_REDEMPTION		(1<<5)  //! Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define DROPDEL					(1<<6)  //! When dropped, it calls qdel on itself
#define NOBLUDGEON				(1<<7)	//! when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define ABSTRACT				(1<<9) 	//! for all things that are technically items but used for various different stuff
#define IMMUTABLE_SLOW			(1<<10) //! When players should not be able to change the slowdown of the item (Speed potions, etc)
#define IN_STORAGE				(1<<11) //! is this item in the storage item, such as backpack? used for tooltips
#define ILLEGAL					(1<<12)	//! this item unlocks illegal tech
#define NO_PIXEL_RANDOM_DROP 	(1<<13) //if dropped, it wont have a randomized pixel_x/pixel_y
#define WAS_THROWN				(1<<14) //if the item was thrown and shouldn't have the drop_item animation applied
#define ISWEAPON				(1<<15) //! If this item should hit living mobs when used on harm intent
#define EXAMINE_SKIP			(1<<16) //! Examine will not read out this item
#define ISCARVABLE			    (1<<17) //! Examine will not read out this item
#define NO_WORN_SLOWDOWN		(1<<18)	//! Doesn't slow you down while worn, which is only useful in combination with SLOWS_WHILE_IN_HAND
#define HAND_ITEM (1<<18) // If an item is just your hand (circled hand, slapper) and shouldn't block things like riding
///Can be equipped on digitigrade legs.
#define IGNORE_DIGITIGRADE (1<<19)
#define SURGICAL_TOOL (1<<20)
/// No blood overlay is allowed to appear on this item, and it cannot gain blood DNA forensics
#define NO_BLOOD_ON_ITEM (1 << 22)

// Flags for the clothing_flags var on /obj/item/clothing

/// Protects from lava
#define LAVAPROTECT (1<<0)
/// SUIT and HEAD items which stop pressure damage. To stop you taking all pressure damage you must have both a suit and head item with this flag.
#define STOPSPRESSUREDAMAGE (1<<1)
/// Blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define BLOCK_GAS_SMOKE_EFFECT (1<<2)
/// Mask allows internals
#define MASKINTERNALS (1<<3)
/// Prevents from slipping on wet floors, in space etc
#define NOSLIP (1<<4)
/// Prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define THICKMATERIAL (1<<5)
/// The voicebox in this clothing can be toggled.
#define VOICEBOX_TOGGLABLE (1<<6)
/// The voicebox is currently turned off.
#define VOICEBOX_DISABLED (1<<7)
/// Prevents shovies against a dense object from knocking the wearer down.
#define BLOCKS_SHOVE_KNOCKDOWN (1<<8)
/// Prevents hat throwing from knocking this hat off
#define SNUG_FIT (1<<9)
/// For hats with an effect that shouldn't get knocked off ie finfoil
#define EFFECT_HAT (1<<10)
/// For masks, allows you to breathe from internals on adjacent tiles
#define MASKEXTENDRANGE (1<<11)
/// Moths cannot eat clothing with that flag
#define NOTCONSUMABLE (1<<12)
/// prevents from placing on plasmaman helmet or modsuit hat holder
#define STACKABLE_HELMET_EXEMPT (1<<15)
/// Usable as casting clothes by wizards (matters for suits, glasses and headwear)
#define CASTING_CLOTHES (1<<13)
/// Headgear/helmet allows internals
#define HEADINTERNALS (1<<18)
/// noslip with only works if wearer is walking
#define NOSLIP_WALKING (1<<19)
/// noslip with includes the higher level sliping hazards, like ice or lube, witch only works if wearer is walking
#define NOSLIP_ALL_WALKING (1<<20)

/// Integrity defines for clothing (not flags but close enough)
#define CLOTHING_PRISTINE 0 // We have no damage on the clothing
#define CLOTHING_DAMAGED 1 // There's some damage on the clothing but it still has at least one functioning bodypart and can be equipped
#define CLOTHING_SHREDDED 2 // The clothing is useless and cannot be equipped unless repaired first

/// Flags for the pod_flags var on /obj/structure/closet/supplypod

#define FIRST_SOUNDS (1<<0) // If it shouldn't play sounds the first time it lands, used for reverse mode
