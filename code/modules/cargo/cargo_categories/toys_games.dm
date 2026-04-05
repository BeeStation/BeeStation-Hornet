/**
 * # Toys & Games Cargo Items
 *
 * Foam Force, laser tag, chess pieces, plushies, action figures, and misc toys.
 * Split into: Toys, Foam Force, Games, Chess Pieces, Plushies, Plushies (Moth),
 * Mech Action Figures, and Crew Action Figures.
 */

// =============================================================================
// TOYS - General
// =============================================================================

/datum/cargo_list/toys_general
	small_item = TRUE
	entries = list(
		// -- Toy weapons --
		list("path" = /obj/item/toy/sword, "cost" = 30, "max_supply" = 8),
		list("path" = /obj/item/toy/foamblade, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/batong, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/gun, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/ammo/gun, "cost" = 5, "max_supply" = 10),
		list("path" = /obj/item/toy/toy_dagger, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/dualsaber/toy, "cost" = 100, "max_supply" = 5),
		// -- Throwables --
		list("path" = /obj/item/toy/snappop, "cost" = 5, "max_supply" = 20),
		list("path" = /obj/item/toy/snappop/phoenix, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/waterballoon, "cost" = 5, "max_supply" = 20),
		list("path" = /obj/item/toy/snowball, "cost" = 5, "max_supply" = 20),
		// -- Balloons --
		list("path" = /obj/item/toy/balloon, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/balloon/corgi, "cost" = 15, "max_supply" = 5),
		// -- Novelty items --
		list("path" = /obj/item/toy/spinningtoy, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/nuke, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/toy/minimeteor, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/redbutton, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/beach_ball, "cost" = 15, "max_supply" = 5),
		list("path" = /obj/item/toy/clockwork_watch, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/toy/eightball, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/windupToolbox, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/toy/cattoy, "cost" = 5, "max_supply" = 10),
		list("path" = /obj/item/toy/dummy, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/toy/reality_pierce, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/cog, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/replica_fabricator, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/hot_potato/harmless/toy, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/gobbler, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/bikehorn, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/bikehorn/rubberducky, "cost" = 30, "max_supply" = 10),
		list("path" = /obj/item/restraints/handcuffs/fake, "cost" = 15, "max_supply" = 10),
		list("path" = /obj/item/card/emagfake, "cost" = 40, "max_supply" = 5),
		// -- Talking toys --
		list("path" = /obj/item/toy/talking/AI, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/owl, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/griffin, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/codex_gigas, "cost" = 40, "max_supply" = 3),
		list("path" = /obj/item/toy/eldrich_book, "cost" = 40, "max_supply" = 3),
		// -- Action figures (non-crew) --
		list("path" = /obj/item/toy/toy_xeno, "cost" = 25, "max_supply" = 5),
		// -- Piñatas --
		list("path" = /obj/item/pinata, "cost" = 150, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/pinata/donk, "cost" = 200, "max_supply" = 3, "small_item" = FALSE),
	)

// =============================================================================
// FOAM FORCE  (Foam dart guns, laser tag)
// =============================================================================

/datum/cargo_list/toys_foamforce
	entries = list(
		// -- Foam dart guns --
		list("path" = /obj/item/gun/ballistic/shotgun/toy, "cost" = 100, "max_supply" = 8),
		list("path" = /obj/item/gun/ballistic/shotgun/toy/crossbow, "cost" = 75, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/gun/ballistic/automatic/toy, "cost" = 175, "max_supply" = 6),
		list("path" = /obj/item/ammo_box/magazine/toy/smg, "cost" = 30, "max_supply" = 10, "small_item" = TRUE),
		list("path" = /obj/item/gun/ballistic/automatic/toy/pistol, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/ammo_box/magazine/toy/pistol, "cost" = 25, "max_supply" = 10, "small_item" = TRUE),
		// -- Laser tag --
		list("path" = /obj/item/storage/box/lasertagpins, "cost" = 200, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/gun/energy/laser/redtag, "cost" = 125, "max_supply" = 6),
		list("path" = /obj/item/gun/energy/laser/bluetag, "cost" = 125, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/redtag, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/bluetag, "cost" = 75, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/helmet/redtaghelm, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/helmet/bluetaghelm, "cost" = 50, "max_supply" = 6, "small_item" = TRUE),
	)

// =============================================================================
// GAMES - Board games, card games, dice, and tabletop items
// =============================================================================

/datum/cargo_list/toys_games
	small_item = TRUE
	entries = list(
		// -- Card decks --
		list("path" = /obj/item/toy/cards/deck, "cost" = 15, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/cas, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/cas/black, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/unum, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/tarot, "cost" = 35, "max_supply" = 5),
		// -- Dice --
		list("path" = /obj/item/storage/pill_bottle/dice, "cost" = 15, "max_supply" = 10),
		list("path" = /obj/item/storage/box/yatzy, "cost" = 30, "max_supply" = 5),
		// -- Board games --
		list("path" = /obj/item/chess_board, "cost" = 75, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/chess_board/checkers, "cost" = 75, "max_supply" = 3, "small_item" = FALSE),
		// -- Miscellaneous --
		list("path" = /obj/item/hourglass, "cost" = 10, "max_supply" = 5),
	)

// =============================================================================
// CHESS PIECES
// =============================================================================

/datum/cargo_list/toys_chess
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		// -- White pieces --
		list("path" = /obj/structure/chess/whiteking, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/structure/chess/whitequeen, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/structure/chess/whiterook, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/whiteknight, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/whitebishop, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/whitepawn, "cost" = 20, "max_supply" = 16),
		// -- Black pieces --
		list("path" = /obj/structure/chess/blackking, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/structure/chess/blackqueen, "cost" = 75, "max_supply" = 2),
		list("path" = /obj/structure/chess/blackrook, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackknight, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackbishop, "cost" = 40, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackpawn, "cost" = 20, "max_supply" = 16),
	)

// =============================================================================
// PLUSHIES
// =============================================================================

/datum/cargo_list/toys_plushies
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/plush/carpplushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/bubbleplush, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/plushvar, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/toy/plush/narplush, "cost" = 50, "max_supply" = 3),
		list("path" = /obj/item/toy/plush/lizard_plushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/lizard_plushie/green, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/lizard_plushie/space, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/snakeplushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/nukeplushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/pink, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/green, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/blue, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/red, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/rainbow, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/awakenedplushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/beeplushie, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/rouny, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/crossed, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/runtime, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/gondola, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/flushed, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/flushed/rainbow, "cost" = 40, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/shark, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/donkpocket, "cost" = 35, "max_supply" = 5),
	)

// =============================================================================
// PLUSHIES (MOTH)
// =============================================================================

/datum/cargo_list/toys_plushies_moth
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/plush/moth, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/monarch, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/luna, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/atlas, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/redish, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/royal, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/gothic, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/lovers, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/whitefly, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/punished, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/firewatch, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/deadhead, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/poison, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/ragged, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/snow, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/clockwork, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/moonfly, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/witchwing, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/bluespace, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/plasmafire, "cost" = 35, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/brown, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/rosy, "cost" = 30, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/rainbow, "cost" = 35, "max_supply" = 5),
	)

// =============================================================================
// MECH ACTION FIGURES
// =============================================================================

/datum/cargo_list/toys_mech_figures
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/mecha/ripley, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/ripleymkii, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/hauler, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/clarke, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/odysseus, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/gygax, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/durand, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/phazon, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/honk, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/darkgygax, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/mauler, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/darkhonk, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/deathripley, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/reticence, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/marauder, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/seraph, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/firefighter, "cost" = 25, "max_supply" = 5),
	)

// =============================================================================
// CREW ACTION FIGURES
// =============================================================================

/datum/cargo_list/toys_crew_figures
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/figure/assistant, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/atmos, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/bartender, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/borg, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/botanist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/captain, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/cargotech, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ce, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chaplain, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chef, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chemist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/clown, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/cmo, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/detective, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/engineer, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/geneticist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/hop, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/hos, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/qm, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ian, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/janitor, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/lawyer, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/curator, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/md, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/paramedic, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/psychologist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/mime, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/miner, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/rd, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/roboticist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/scientist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/secofficer, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/virologist, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/warden, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/dsquad, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ninja, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/wizard, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/syndie, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/prisoner, "cost" = 25, "max_supply" = 5),
	)
