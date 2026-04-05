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
		list("path" = /obj/item/toy/sword, "cost" = 50, "max_supply" = 8),
		list("path" = /obj/item/toy/foamblade, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/batong, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/gun, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/ammo/gun, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/katana, "cost" = 200, "max_supply" = 3),
		list("path" = /obj/item/toy/toy_dagger, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/dualsaber/toy, "cost" = 200, "max_supply" = 5),
		// -- Throwables --
		list("path" = /obj/item/toy/snappop, "cost" = 10, "max_supply" = 20),
		list("path" = /obj/item/toy/snappop/phoenix, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/toy/waterballoon, "cost" = 10, "max_supply" = 20),
		list("path" = /obj/item/toy/snowball, "cost" = 5, "max_supply" = 20),
		// -- Balloons --
		list("path" = /obj/item/toy/balloon, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/balloon/corgi, "cost" = 25, "max_supply" = 5),
		// -- Novelty items --
		list("path" = /obj/item/toy/spinningtoy, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/nuke, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/toy/minimeteor, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/redbutton, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/beach_ball, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/clockwork_watch, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/toy/eightball, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/windupToolbox, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/toy/cattoy, "cost" = 10, "max_supply" = 10),
		list("path" = /obj/item/toy/dummy, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/toy/reality_pierce, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/cog, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/toy/replica_fabricator, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/hot_potato/harmless/toy, "cost" = 75, "max_supply" = 5),
		list("path" = /obj/item/gobbler, "cost" = 100, "max_supply" = 3),
		list("path" = /obj/item/bikehorn, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/bikehorn/rubberducky, "cost" = 80, "max_supply" = 10),
		list("path" = /obj/item/restraints/handcuffs/fake, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/card/emagfake, "cost" = 75, "max_supply" = 5),
		// -- Talking toys --
		list("path" = /obj/item/toy/talking/AI, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/owl, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/griffin, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/talking/codex_gigas, "cost" = 75, "max_supply" = 3),
		list("path" = /obj/item/toy/eldrich_book, "cost" = 75, "max_supply" = 3),
		// -- Action figures (non-crew) --
		list("path" = /obj/item/toy/toy_xeno, "cost" = 50, "max_supply" = 5),
		// -- Piñatas --
		list("path" = /obj/item/pinata, "cost" = 300, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/pinata/donk, "cost" = 350, "max_supply" = 3, "small_item" = FALSE),
	)

// =============================================================================
// FOAM FORCE  (Foam dart guns, laser tag)
// =============================================================================

/datum/cargo_list/toys_foamforce
	entries = list(
		// -- Foam dart guns --
		list("path" = /obj/item/gun/ballistic/shotgun/toy, "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/gun/ballistic/shotgun/toy/crossbow, "cost" = 150, "max_supply" = 8, "small_item" = TRUE),
		list("path" = /obj/item/gun/ballistic/automatic/toy, "cost" = 350, "max_supply" = 6),
		list("path" = /obj/item/ammo_box/magazine/toy/smg, "cost" = 75, "max_supply" = 10, "small_item" = TRUE),
		list("path" = /obj/item/gun/ballistic/automatic/toy/pistol, "cost" = 300, "max_supply" = 6),
		list("path" = /obj/item/ammo_box/magazine/toy/pistol, "cost" = 50, "max_supply" = 10, "small_item" = TRUE),
		// -- Laser tag --
		list("path" = /obj/item/storage/box/lasertagpins, "cost" = 500, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/gun/energy/laser/redtag, "cost" = 250, "max_supply" = 6),
		list("path" = /obj/item/gun/energy/laser/bluetag, "cost" = 250, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/redtag, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/clothing/suit/bluetag, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/clothing/head/helmet/redtaghelm, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
		list("path" = /obj/item/clothing/head/helmet/bluetaghelm, "cost" = 100, "max_supply" = 6, "small_item" = TRUE),
	)

// =============================================================================
// GAMES - Board games, card games, dice, and tabletop items
// =============================================================================

/datum/cargo_list/toys_games
	small_item = TRUE
	entries = list(
		// -- Card decks --
		list("path" = /obj/item/toy/cards/deck, "cost" = 25, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/cas, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/cas/black, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/unum, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/cards/deck/tarot, "cost" = 50, "max_supply" = 5),
		// -- Dice --
		list("path" = /obj/item/storage/pill_bottle/dice, "cost" = 25, "max_supply" = 10),
		list("path" = /obj/item/storage/box/yatzy, "cost" = 50, "max_supply" = 5),
		// -- Board games --
		list("path" = /obj/item/chess_board, "cost" = 100, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/chess_board/checkers, "cost" = 100, "max_supply" = 3, "small_item" = FALSE),
		// -- Miscellaneous --
		list("path" = /obj/item/hourglass, "cost" = 25, "max_supply" = 5),
	)

// =============================================================================
// CHESS PIECES
// =============================================================================

/datum/cargo_list/toys_chess
	crate_type = /obj/structure/closet/crate/large
	entries = list(
		// -- White pieces --
		list("path" = /obj/structure/chess/whiteking, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/structure/chess/whitequeen, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/structure/chess/whiterook, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/whiteknight, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/whitebishop, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/whitepawn, "cost" = 25, "max_supply" = 16),
		// -- Black pieces --
		list("path" = /obj/structure/chess/blackking, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/structure/chess/blackqueen, "cost" = 100, "max_supply" = 2),
		list("path" = /obj/structure/chess/blackrook, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackknight, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackbishop, "cost" = 50, "max_supply" = 4),
		list("path" = /obj/structure/chess/blackpawn, "cost" = 25, "max_supply" = 16),
	)

// =============================================================================
// PLUSHIES
// =============================================================================

/datum/cargo_list/toys_plushies
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/plush/carpplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/bubbleplush, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/plushvar, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/toy/plush/narplush, "cost" = 150, "max_supply" = 3),
		list("path" = /obj/item/toy/plush/lizard_plushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/lizard_plushie/green, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/lizard_plushie/space, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/snakeplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/nukeplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/pink, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/green, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/blue, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/red, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/slimeplushie/rainbow, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/awakenedplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/beeplushie, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/rouny, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/crossed, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/runtime, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/gondola, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/flushed, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/flushed/rainbow, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/shark, "cost" = 150, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/donkpocket, "cost" = 100, "max_supply" = 5),
	)

// =============================================================================
// PLUSHIES (MOTH)
// =============================================================================

/datum/cargo_list/toys_plushies_moth
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/plush/moth, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/monarch, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/luna, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/atlas, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/redish, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/royal, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/gothic, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/lovers, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/whitefly, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/punished, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/firewatch, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/deadhead, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/poison, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/ragged, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/snow, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/clockwork, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/moonfly, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/witchwing, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/bluespace, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/plasmafire, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/brown, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/rosy, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/plush/moth/rainbow, "cost" = 100, "max_supply" = 5),
	)

// =============================================================================
// MECH ACTION FIGURES
// =============================================================================

/datum/cargo_list/toys_mech_figures
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/mecha/ripley, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/ripleymkii, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/hauler, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/clarke, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/odysseus, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/gygax, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/durand, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/phazon, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/honk, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/darkgygax, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/mauler, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/darkhonk, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/deathripley, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/reticence, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/marauder, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/seraph, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/mecha/firefighter, "cost" = 50, "max_supply" = 5),
	)

// =============================================================================
// CREW ACTION FIGURES
// =============================================================================

/datum/cargo_list/toys_crew_figures
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/toy/figure/assistant, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/atmos, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/bartender, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/borg, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/botanist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/captain, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/cargotech, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ce, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chaplain, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chef, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/chemist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/clown, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/cmo, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/detective, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/engineer, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/geneticist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/hop, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/hos, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/qm, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ian, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/janitor, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/lawyer, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/curator, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/md, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/paramedic, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/psychologist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/mime, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/miner, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/rd, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/roboticist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/scientist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/secofficer, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/virologist, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/warden, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/dsquad, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/ninja, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/wizard, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/syndie, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/toy/figure/prisoner, "cost" = 50, "max_supply" = 5),
	)
