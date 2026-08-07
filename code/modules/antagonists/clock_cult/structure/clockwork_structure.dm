//The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	break_message = span_warning("Sparks fly as the brass structure shatters across the ground.")
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg'
	debris = list(
		/obj/item/clockwork/alloy_shards/large = 1,
		/obj/item/clockwork/alloy_shards/medium = 2,
		/obj/item/clockwork/alloy_shards/small = 3
	)

	/// Extra text shown to servants when they examine the structure
	var/clockwork_desc
	/// The icon used when the structure is unanchored, doubles as the var for if it can be unanchored
	var/unanchored_icon
	/// If set to FALSE, a replica fabricator cannot repair this
	var/can_be_repaired = TRUE
	/// The mind that placed this structure
	var/datum/mind/owner = null

/obj/structure/destructible/clockwork/examine(mob/user)
	. = ..()
	if(IS_SERVANT_OF_RATVAR(user) && clockwork_desc)
		. += clockwork_desc
