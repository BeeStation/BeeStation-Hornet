/**
 * # Toys & Games Cargo Items
 *
 * Foam Force, laser tag, chess pieces, plushies, action figures, and misc toys.
 * Split into Toys, Foam Force, Chess, Plushies, Plushies (Moth), Mech Figures, and Crew Figures.
 */

// =============================================================================
// TOYS - General
// =============================================================================

/datum/cargo_item/toys
	small_item = TRUE

/datum/cargo_item/toys/toy_sword
	name = "Toy Sword"
	item_path = /obj/item/toy/sword
	cost = 50
	max_supply = 8

/datum/cargo_item/toys/foam_armblade
	name = "Foam Armblade"
	item_path = /obj/item/toy/foamblade
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/batong
	name = "Batong"
	item_path = /obj/item/toy/batong
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/cap_gun
	name = "Cap Gun"
	item_path = /obj/item/toy/gun
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/cap_ammo
	name = "Cap Gun Ammo"
	item_path = /obj/item/toy/ammo/gun
	cost = 10
	max_supply = 10

/datum/cargo_item/toys/toy_katana
	name = "Replica Katana"
	item_path = /obj/item/toy/katana
	cost = 200
	max_supply = 3

/datum/cargo_item/toys/toy_dagger
	name = "Toy Dagger"
	item_path = /obj/item/toy/toy_dagger
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/snap_pops
	name = "Snap Pops"
	item_path = /obj/item/toy/snappop
	cost = 10
	max_supply = 20

/datum/cargo_item/toys/water_balloon
	name = "Water Balloon"
	item_path = /obj/item/toy/waterballoon
	cost = 10
	max_supply = 20

/datum/cargo_item/toys/balloon
	name = "Balloon"
	item_path = /obj/item/toy/balloon
	cost = 10
	max_supply = 10

/datum/cargo_item/toys/balloon_corgi
	name = "Corgi Balloon"
	item_path = /obj/item/toy/balloon/corgi
	cost = 25
	max_supply = 5

/datum/cargo_item/toys/spinning_toy
	name = "Gravitational Singularity Toy"
	item_path = /obj/item/toy/spinningtoy
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/nuke_toy
	name = "Toy Nuclear Fission Explosive"
	item_path = /obj/item/toy/nuke
	cost = 100
	max_supply = 3

/datum/cargo_item/toys/mini_meteor
	name = "Mini-Meteor"
	item_path = /obj/item/toy/minimeteor
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/big_red_button
	name = "Big Red Button"
	item_path = /obj/item/toy/redbutton
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/beach_ball
	name = "Beach Ball"
	item_path = /obj/item/toy/beach_ball
	cost = 25
	max_supply = 5

/datum/cargo_item/toys/clockwork_watch
	name = "Steampunk Watch"
	item_path = /obj/item/toy/clockwork_watch
	cost = 75
	max_supply = 5

/datum/cargo_item/toys/toy_xeno
	name = "Xenomorph Action Figure"
	item_path = /obj/item/toy/toy_xeno
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/toy_ai
	name = "Toy AI Core"
	item_path = /obj/item/toy/talking/AI
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/toy_owl
	name = "Owl Action Figure"
	item_path = /obj/item/toy/talking/owl
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/toy_griffin
	name = "Griffin Action Figure"
	item_path = /obj/item/toy/talking/griffin
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/toy_codex
	name = "Toy Codex Gigas"
	item_path = /obj/item/toy/talking/codex_gigas
	cost = 75
	max_supply = 3

/datum/cargo_item/toys/eldrich_book
	name = "Toy Codex Cicatrix"
	item_path = /obj/item/toy/eldrich_book
	cost = 75
	max_supply = 3

/datum/cargo_item/toys/deck_of_cards
	name = "Deck of Cards"
	item_path = /obj/item/toy/cards/deck
	cost = 25
	max_supply = 5

/datum/cargo_item/toys/windup_toolbox
	name = "Windup Toolbox"
	item_path = /obj/item/toy/windupToolbox
	cost = 75
	max_supply = 3

/datum/cargo_item/toys/cat_toy
	name = "Toy Mouse"
	item_path = /obj/item/toy/cattoy
	cost = 10
	max_supply = 10

/datum/cargo_item/toys/dummy
	name = "Ventriloquist Dummy"
	item_path = /obj/item/toy/dummy
	cost = 75
	max_supply = 3

/datum/cargo_item/toys/reality_pierce
	name = "Toy Pierced Reality"
	item_path = /obj/item/toy/reality_pierce
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/bikehorn
	name = "Bike Horn"
	item_path = /obj/item/bikehorn
	cost = 50
	max_supply = 5

/datum/cargo_item/toys/rubber_duck
	name = "Rubber Duck"
	item_path = /obj/item/bikehorn/rubberducky
	cost = 80
	max_supply = 10

/datum/cargo_item/toys/pinata
	name = "Piñata"
	item_path = /obj/item/pinata
	cost = 300
	max_supply = 3
	small_item = FALSE

// =============================================================================
// FOAM FORCE
// =============================================================================

/datum/cargo_item/foamforce

/datum/cargo_item/foamforce/shotgun
	name = "Foam Dart Shotgun"
	item_path = /obj/item/gun/ballistic/shotgun/toy
	cost = 200
	max_supply = 8

/datum/cargo_item/foamforce/pistol
	name = "Foam Dart Pistol"
	item_path = /obj/item/gun/ballistic/automatic/toy/pistol
	cost = 300
	max_supply = 6

/datum/cargo_item/foamforce/pistol_mag
	name = "Foam Dart Pistol Magazine"
	item_path = /obj/item/ammo_box/magazine/toy/pistol
	cost = 50
	max_supply = 10
	small_item = TRUE

/datum/cargo_item/foamforce/lasertag_pins
	name = "Laser Tag Firing Pins"
	item_path = /obj/item/storage/box/lasertagpins
	cost = 500
	max_supply = 3
	small_item = TRUE

/datum/cargo_item/foamforce/redtag_gun
	name = "Red Laser Tag Gun"
	item_path = /obj/item/gun/energy/laser/redtag
	cost = 250
	max_supply = 6

/datum/cargo_item/foamforce/bluetag_gun
	name = "Blue Laser Tag Gun"
	item_path = /obj/item/gun/energy/laser/bluetag
	cost = 250
	max_supply = 6

/datum/cargo_item/foamforce/redtag_suit
	name = "Red Laser Tag Suit"
	item_path = /obj/item/clothing/suit/redtag
	cost = 150
	max_supply = 6

/datum/cargo_item/foamforce/bluetag_suit
	name = "Blue Laser Tag Suit"
	item_path = /obj/item/clothing/suit/bluetag
	cost = 150
	max_supply = 6

/datum/cargo_item/foamforce/redtag_helm
	name = "Red Laser Tag Helmet"
	item_path = /obj/item/clothing/head/helmet/redtaghelm
	cost = 100
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/foamforce/bluetag_helm
	name = "Blue Laser Tag Helmet"
	item_path = /obj/item/clothing/head/helmet/bluetaghelm
	cost = 100
	max_supply = 6
	small_item = TRUE

// =============================================================================
// CHESS
// =============================================================================

/datum/cargo_item/chess

// --- White Pieces ---

/datum/cargo_item/chess/white_king
	name = "White King"
	item_path = /obj/structure/chess/whiteking
	cost = 100
	max_supply = 2

/datum/cargo_item/chess/white_queen
	name = "White Queen"
	item_path = /obj/structure/chess/whitequeen
	cost = 100
	max_supply = 2

/datum/cargo_item/chess/white_rook
	name = "White Rook"
	item_path = /obj/structure/chess/whiterook
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/white_knight
	name = "White Knight"
	item_path = /obj/structure/chess/whiteknight
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/white_bishop
	name = "White Bishop"
	item_path = /obj/structure/chess/whitebishop
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/white_pawn
	name = "White Pawn"
	item_path = /obj/structure/chess/whitepawn
	cost = 25
	max_supply = 16

// --- Black Pieces ---

/datum/cargo_item/chess/black_king
	name = "Black King"
	item_path = /obj/structure/chess/blackking
	cost = 100
	max_supply = 2

/datum/cargo_item/chess/black_queen
	name = "Black Queen"
	item_path = /obj/structure/chess/blackqueen
	cost = 100
	max_supply = 2

/datum/cargo_item/chess/black_rook
	name = "Black Rook"
	item_path = /obj/structure/chess/blackrook
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/black_knight
	name = "Black Knight"
	item_path = /obj/structure/chess/blackknight
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/black_bishop
	name = "Black Bishop"
	item_path = /obj/structure/chess/blackbishop
	cost = 50
	max_supply = 4

/datum/cargo_item/chess/black_pawn
	name = "Black Pawn"
	item_path = /obj/structure/chess/blackpawn
	cost = 25
	max_supply = 16

// =============================================================================
// PLUSHIES
// =============================================================================

/datum/cargo_item/plushies
	small_item = TRUE

/datum/cargo_item/plushies/carp
	name = "Space Carp Plushie"
	item_path = /obj/item/toy/plush/carpplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/bubblegum
	name = "Bubblegum Plushie"
	item_path = /obj/item/toy/plush/bubbleplush
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/ratvar
	name = "Ratvar Plushie"
	item_path = /obj/item/toy/plush/plushvar
	cost = 150
	max_supply = 3

/datum/cargo_item/plushies/narsie
	name = "Nar'Sie Plushie"
	item_path = /obj/item/toy/plush/narplush
	cost = 150
	max_supply = 3

/datum/cargo_item/plushies/lizard
	name = "Lizard Plushie"
	item_path = /obj/item/toy/plush/lizard_plushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/lizard_green
	name = "Green Lizard Plushie"
	item_path = /obj/item/toy/plush/lizard_plushie/green
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/space_lizard
	name = "Space Lizard Plushie"
	item_path = /obj/item/toy/plush/lizard_plushie/space
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/snake
	name = "Snake Plushie"
	item_path = /obj/item/toy/plush/snakeplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/nuke_op
	name = "Operative Plushie"
	item_path = /obj/item/toy/plush/nukeplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime
	name = "Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime_pink
	name = "Pink Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie/pink
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime_green
	name = "Green Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie/green
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime_blue
	name = "Blue Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie/blue
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime_red
	name = "Red Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie/red
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/slime_rainbow
	name = "Rainbow Slime Plushie"
	item_path = /obj/item/toy/plush/slimeplushie/rainbow
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/awakened
	name = "Awakened Plushie"
	item_path = /obj/item/toy/plush/awakenedplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/bee
	name = "Bee Plushie"
	item_path = /obj/item/toy/plush/beeplushie
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/runner
	name = "Runner Plushie"
	item_path = /obj/item/toy/plush/rouny
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/ghost
	name = "Ghost Plushie"
	item_path = /obj/item/toy/plush/crossed
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/runtime
	name = "Runtime Plushie"
	item_path = /obj/item/toy/plush/runtime
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/gondola
	name = "Gondola Plushie"
	item_path = /obj/item/toy/plush/gondola
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/flushed
	name = "Flushed Plushie"
	item_path = /obj/item/toy/plush/flushed
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/flushed_rainbow
	name = "Rainbow Flushed Plushie"
	item_path = /obj/item/toy/plush/flushed/rainbow
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies/shark
	name = "Shark Plushie"
	item_path = /obj/item/toy/plush/shark
	cost = 150
	max_supply = 5

/datum/cargo_item/plushies/donkpocket
	name = "Donk Pocket Plushie"
	item_path = /obj/item/toy/plush/donkpocket
	cost = 100
	max_supply = 5

// =============================================================================
// PLUSHIES (MOTH)
// =============================================================================

/datum/cargo_item/plushies_moth
	small_item = TRUE

/datum/cargo_item/plushies_moth/default
	name = "Moth Plushie"
	item_path = /obj/item/toy/plush/moth
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/monarch
	name = "Monarch Moth Plushie"
	item_path = /obj/item/toy/plush/moth/monarch
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/luna
	name = "Luna Moth Plushie"
	item_path = /obj/item/toy/plush/moth/luna
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/atlas
	name = "Atlas Moth Plushie"
	item_path = /obj/item/toy/plush/moth/atlas
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/redish
	name = "Redish Moth Plushie"
	item_path = /obj/item/toy/plush/moth/redish
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/royal
	name = "Royal Moth Plushie"
	item_path = /obj/item/toy/plush/moth/royal
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/gothic
	name = "Gothic Moth Plushie"
	item_path = /obj/item/toy/plush/moth/gothic
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/lovers
	name = "Lovers Moth Plushie"
	item_path = /obj/item/toy/plush/moth/lovers
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/whitefly
	name = "Whitefly Moth Plushie"
	item_path = /obj/item/toy/plush/moth/whitefly
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/punished
	name = "Punished Moth Plushie"
	item_path = /obj/item/toy/plush/moth/punished
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/firewatch
	name = "Firewatch Moth Plushie"
	item_path = /obj/item/toy/plush/moth/firewatch
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/deadhead
	name = "Deadhead Moth Plushie"
	item_path = /obj/item/toy/plush/moth/deadhead
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/poison
	name = "Poison Moth Plushie"
	item_path = /obj/item/toy/plush/moth/poison
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/ragged
	name = "Ragged Moth Plushie"
	item_path = /obj/item/toy/plush/moth/ragged
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/snow
	name = "Snow Moth Plushie"
	item_path = /obj/item/toy/plush/moth/snow
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/clockwork
	name = "Clockwork Moth Plushie"
	item_path = /obj/item/toy/plush/moth/clockwork
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/moonfly
	name = "Moonfly Moth Plushie"
	item_path = /obj/item/toy/plush/moth/moonfly
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/witchwing
	name = "Witchwing Moth Plushie"
	item_path = /obj/item/toy/plush/moth/witchwing
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/bluespace
	name = "Bluespace Moth Plushie"
	item_path = /obj/item/toy/plush/moth/bluespace
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/plasmafire
	name = "Plasmafire Moth Plushie"
	item_path = /obj/item/toy/plush/moth/plasmafire
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/brown
	name = "Brown Moth Plushie"
	item_path = /obj/item/toy/plush/moth/brown
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/rosy
	name = "Rosy Moth Plushie"
	item_path = /obj/item/toy/plush/moth/rosy
	cost = 100
	max_supply = 5

/datum/cargo_item/plushies_moth/rainbow
	name = "Rainbow Moth Plushie"
	item_path = /obj/item/toy/plush/moth/rainbow
	cost = 100
	max_supply = 5

// =============================================================================
// MECH ACTION FIGURES
// =============================================================================

/datum/cargo_item/mech_figures
	small_item = TRUE

/datum/cargo_item/mech_figures/ripley
	name = "Toy Ripley MK-I"
	item_path = /obj/item/toy/mecha/ripley
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/ripleymkii
	name = "Toy Ripley MK-II"
	item_path = /obj/item/toy/mecha/ripleymkii
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/hauler
	name = "Toy Hauler"
	item_path = /obj/item/toy/mecha/hauler
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/clarke
	name = "Toy Clarke"
	item_path = /obj/item/toy/mecha/clarke
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/odysseus
	name = "Toy Odysseus"
	item_path = /obj/item/toy/mecha/odysseus
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/gygax
	name = "Toy Gygax"
	item_path = /obj/item/toy/mecha/gygax
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/durand
	name = "Toy Durand"
	item_path = /obj/item/toy/mecha/durand
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/phazon
	name = "Toy Phazon"
	item_path = /obj/item/toy/mecha/phazon
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/honk
	name = "Toy H.O.N.K."
	item_path = /obj/item/toy/mecha/honk
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/darkgygax
	name = "Toy Dark Gygax"
	item_path = /obj/item/toy/mecha/darkgygax
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/mauler
	name = "Toy Mauler"
	item_path = /obj/item/toy/mecha/mauler
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/darkhonk
	name = "Toy Dark H.O.N.K."
	item_path = /obj/item/toy/mecha/darkhonk
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/deathripley
	name = "Toy Death-Ripley"
	item_path = /obj/item/toy/mecha/deathripley
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/reticence
	name = "Toy Reticence"
	item_path = /obj/item/toy/mecha/reticence
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/marauder
	name = "Toy Marauder"
	item_path = /obj/item/toy/mecha/marauder
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/seraph
	name = "Toy Seraph"
	item_path = /obj/item/toy/mecha/seraph
	cost = 50
	max_supply = 5

/datum/cargo_item/mech_figures/firefighter
	name = "Toy Firefighter"
	item_path = /obj/item/toy/mecha/firefighter
	cost = 50
	max_supply = 5

// =============================================================================
// CREW ACTION FIGURES
// =============================================================================

/datum/cargo_item/crew_figures
	small_item = TRUE

/datum/cargo_item/crew_figures/assistant
	name = "Assistant Action Figure"
	item_path = /obj/item/toy/figure/assistant
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/atmos
	name = "Atmospheric Technician Action Figure"
	item_path = /obj/item/toy/figure/atmos
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/bartender
	name = "Bartender Action Figure"
	item_path = /obj/item/toy/figure/bartender
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/borg
	name = "Cyborg Action Figure"
	item_path = /obj/item/toy/figure/borg
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/botanist
	name = "Botanist Action Figure"
	item_path = /obj/item/toy/figure/botanist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/captain
	name = "Captain Action Figure"
	item_path = /obj/item/toy/figure/captain
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/cargotech
	name = "Cargo Technician Action Figure"
	item_path = /obj/item/toy/figure/cargotech
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/ce
	name = "Chief Engineer Action Figure"
	item_path = /obj/item/toy/figure/ce
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/chaplain
	name = "Chaplain Action Figure"
	item_path = /obj/item/toy/figure/chaplain
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/chef
	name = "Cook Action Figure"
	item_path = /obj/item/toy/figure/chef
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/chemist
	name = "Chemist Action Figure"
	item_path = /obj/item/toy/figure/chemist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/clown
	name = "Clown Action Figure"
	item_path = /obj/item/toy/figure/clown
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/cmo
	name = "Chief Medical Officer Action Figure"
	item_path = /obj/item/toy/figure/cmo
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/detective
	name = "Detective Action Figure"
	item_path = /obj/item/toy/figure/detective
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/engineer
	name = "Station Engineer Action Figure"
	item_path = /obj/item/toy/figure/engineer
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/geneticist
	name = "Geneticist Action Figure"
	item_path = /obj/item/toy/figure/geneticist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/hop
	name = "Head of Personnel Action Figure"
	item_path = /obj/item/toy/figure/hop
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/hos
	name = "Head of Security Action Figure"
	item_path = /obj/item/toy/figure/hos
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/qm
	name = "Quartermaster Action Figure"
	item_path = /obj/item/toy/figure/qm
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/ian
	name = "Ian Action Figure"
	item_path = /obj/item/toy/figure/ian
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/janitor
	name = "Janitor Action Figure"
	item_path = /obj/item/toy/figure/janitor
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/lawyer
	name = "Lawyer Action Figure"
	item_path = /obj/item/toy/figure/lawyer
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/curator
	name = "Curator Action Figure"
	item_path = /obj/item/toy/figure/curator
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/md
	name = "Medical Doctor Action Figure"
	item_path = /obj/item/toy/figure/md
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/paramedic
	name = "Paramedic Action Figure"
	item_path = /obj/item/toy/figure/paramedic
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/psychologist
	name = "Psychologist Action Figure"
	item_path = /obj/item/toy/figure/psychologist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/mime
	name = "Mime Action Figure"
	item_path = /obj/item/toy/figure/mime
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/miner
	name = "Shaft Miner Action Figure"
	item_path = /obj/item/toy/figure/miner
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/rd
	name = "Research Director Action Figure"
	item_path = /obj/item/toy/figure/rd
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/roboticist
	name = "Roboticist Action Figure"
	item_path = /obj/item/toy/figure/roboticist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/scientist
	name = "Scientist Action Figure"
	item_path = /obj/item/toy/figure/scientist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/secofficer
	name = "Security Officer Action Figure"
	item_path = /obj/item/toy/figure/secofficer
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/virologist
	name = "Virologist Action Figure"
	item_path = /obj/item/toy/figure/virologist
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/warden
	name = "Warden Action Figure"
	item_path = /obj/item/toy/figure/warden
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/dsquad
	name = "Deathsquad Officer Action Figure"
	item_path = /obj/item/toy/figure/dsquad
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/ninja
	name = "Space Ninja Action Figure"
	item_path = /obj/item/toy/figure/ninja
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/wizard
	name = "Wizard Action Figure"
	item_path = /obj/item/toy/figure/wizard
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/syndie
	name = "Nuclear Operative Action Figure"
	item_path = /obj/item/toy/figure/syndie
	cost = 50
	max_supply = 5

/datum/cargo_item/crew_figures/prisoner
	name = "Prisoner Action Figure"
	item_path = /obj/item/toy/figure/prisoner
	cost = 50
	max_supply = 5
