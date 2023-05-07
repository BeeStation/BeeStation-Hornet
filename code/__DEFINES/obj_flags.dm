// Flags for the obj_flags var on /obj


#define EMAGGED					(1<<0)
#define IN_USE					(1<<1)  //! If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define CAN_BE_HIT				(1<<2)  //! can this be bludgeoned by items?
#define BEING_SHOCKED			(1<<3)  //! Whether this thing is currently (already) being shocked by a tesla
#define DANGEROUS_POSSESSION	(1<<4)  //! Admin possession yes/no
#define ON_BLUEPRINTS			(1<<5)  //! Are we visible on the station blueprints at roundstart?
#define UNIQUE_RENAME			(1<<6)  //! can you customize the description/name of the thing?
#define USES_TGUI				(1<<7)  //! put on things that use tgui on ui_interact instead of custom/old UI.
#define FROZEN					(1<<8)
#define BLOCK_Z_OUT_DOWN		(1<<9)  // Should this object block z falling from loc?
#define BLOCK_Z_OUT_UP			(1<<10) // Should this object block z uprise from loc?
#define BLOCK_Z_IN_DOWN			(1<<11) // Should this object block z falling from above?
#define BLOCK_Z_IN_UP			(1<<12) // Should this object block z uprise from below?
#define OBJ_EMPED				(1<<13) // Object is affected by EMP

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

// Flags for the clothing_flags var on /obj/item/clothing

#define LAVAPROTECT             (1<<0)
#define STOPSPRESSUREDAMAGE		(1<<1)	//! SUIT and HEAD items which stop pressure damage. To stop you taking all pressure damage you must have both a suit and head item with this flag.
#define BLOCK_GAS_SMOKE_EFFECT	(1<<2)	//! blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define MASKINTERNALS		    (1<<3)	//! mask allows internals
#define NOSLIP                  (1<<4)  //! prevents from slipping on wet floors, in space etc
#define THICKMATERIAL			(1<<5)	//! prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define VOICEBOX_TOGGLABLE      (1<<6)  //! The voicebox in this clothing can be toggled.
#define VOICEBOX_DISABLED       (1<<7)  //! The voicebox is currently turned off.
#define SNUG_FIT                (1<<9)  //! prevents hat throwing from knocking this hat off
#define EFFECT_HAT              (1<<10) //! For hats with an effect that shouldn't get knocked off ie finfoil
#define SCAN_REAGENTS           (1<<11) //! Allows helmets and glasses to scan reagents.
#define SCAN_BOOZEPOWER         (1<<12) //! Allows helmets and glasses to scan reagents.
#define MASKEXTENDRANGE			(1<<13) //! For masks, allows you to breathe from internals on adjecent tiles
#define NOTCONSUMABLE			(1<<14) //! Moths cannot eat clothing with that flag
#define HEADINTERNALS 			(1<<15) //! Headgear/helmet allows internals

/// Flags for the organ_flags var on /obj/item/organ

#define ORGAN_SYNTHETIC			(1<<0)	//Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_FROZEN			(1<<1)	//Frozen organs, don't deteriorate
#define ORGAN_FAILING			(1<<2)	//Failing organs perform damaging effects until replaced or fixed
#define ORGAN_EXTERNAL			(1<<3)	//Was this organ implanted/inserted/etc, if true will not be removed during species change.
#define ORGAN_VITAL				(1<<4)	//Currently only the brain
#define ORGAN_EDIBLE			(1<<5)	//is a snack? :D

/// Flags for the pod_flags var on /obj/structure/closet/supplypod

#define FIRST_SOUNDS (1<<0) // If it shouldn't play sounds the first time it lands, used for reverse mode
