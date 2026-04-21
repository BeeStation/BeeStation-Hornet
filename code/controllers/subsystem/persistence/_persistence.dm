SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	flags = SS_NO_FIRE

	///instantiated wall engraving components
	var/list/wall_engravings = list()
	///all saved persistent engravings loaded from JSON
	var/list/saved_engravings = list()
	///tattoo stories that we're saving.
	var/list/prison_tattoos_to_save = list()
	///tattoo stories that have been selected for this round.
	var/list/prison_tattoos_to_use = list()

	var/list/saved_messages = list()

	/// Library trophies
	var/list/saved_trophies = list()

	/// Pictures and photo albums
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums

	/// Antag reputation
	var/list/antag_rep = list()
	var/list/antag_rep_change = list()

	/// Used to track SM delamination statistics
	var/rounds_since_engine_exploded = 0
	var/delam_highscore = 0

/datum/controller/subsystem/persistence/Initialize()
	if(CONFIG_GET(flag/use_antag_rep))
		load_antag_reputation()
	load_poly()
	load_wall_engravings()
	load_prisoner_tattoos()
	load_trophies()
	load_photo_persistence()
	load_custom_outfits()
	load_delamination_counter()
	return SS_INIT_SUCCESS

/**
 * Collects all data that is saved in-between rounds
 **/
/datum/controller/subsystem/persistence/proc/collect_data()
	if(CONFIG_GET(flag/use_antag_rep))
		collect_antag_reputation()
	save_wall_engravings()
	save_prisoner_tattoos()
	collect_trophies()
	save_photo_persistence()
	save_custom_outfits()
	save_delamination_counter()
	save_gamemode_execution()

/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/simple_animal/parrot/Poly/stupid_bird in GLOB.alive_mob_list)
		twitterize(stupid_bird.speech_buffer, "polytalk")
		break //Who's been duping the bird?!
