/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/datum/sprite_accessory
	/// The icon file the accessory is located in.
	var/icon
	/// The icon_state of the accessory.
	var/icon_state
	var/emissive_state	//state of the emissive overlay
	var/emissive_alpha = 255	//Alpha of the emissive
	/// The preview name of the accessory.
	var/name
	/// Something that can be worn by either gender, but looks different on each.
	var/gender_specific = FALSE
	/// Determines if the accessory will be skipped by color preferences.
	var/use_static
	/// Whether this accessory should be included in default/random selections.
	var/use_default = TRUE
	/// What gender should this accessory be used for in random generation? MALE, FEMALE, or NEUTER (all)
	var/use_default_gender = NEUTER
	/**
	 * Currently only used by mutantparts so don't worry about hair and stuff.
	 * This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	 */
	var/color_src = MUTANT_COLOR
	/// Is this part locked from roundstart selection? Used for parts that apply effects.
	var/locked = FALSE
	/// Should we center the sprite?
	var/center = FALSE
	/// The width of the sprite in pixels. Used to center it if necessary.
	var/dimension_x = 32
	/// The height of the sprite in pixels. Used to center it if necessary.
	var/dimension_y = 32
	/// Determines if this is considered "sane" for the purpose of [/proc/randomize_human_normie]
	/// Basically this is to blacklist the extremely wacky stuff from being picked in random human generation.
	var/natural_spawn = TRUE
	var/limbs_id // The limbs id supplied for full-body replacing features.

/datum/sprite_accessory/blank
	name = SPRITE_ACCESSORY_NONE
	icon_state = "None"

//////////////////////
// Hair Definitions //
//////////////////////
/datum/sprite_accessory/hair
	icon = 'icons/mob/human/human_face.dmi' // default icon for all hairs
	var/y_offset = 0 // Y offset to apply so we can have hair that reaches above the player sprite's visual bounding box

	// please make sure they're sorted alphabetically and, where needed, categorized
	// try to capitalize the names please~
	// try to spell
	// you do not need to define _s or _l sub-states, game automatically does this for you

/// Don't move these two, they go first
/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = null

/datum/sprite_accessory/hair/bald2
	name = "Bald 2"
	icon_state = "hair_bald2"

// --------

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "hair_afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro (Large)"
	icon_state = "hair_bigafro"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/antenna
	name = "Ahoge"
	icon_state = "hair_antenna"
	use_default = FALSE // Very unusual/anime style

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedheadv2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedheadv3"

/datum/sprite_accessory/hair/bedheadlong
	name = "Long Bedhead"
	icon_state = "hair_long_bedhead"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/bedheadfloorlength
	name = "Floorlength Bedhead"
	icon_state = "hair_floorlength_bedhead"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehivev2"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bob3
	name = "Bob Hair 3"
	icon_state = "hair_bobcut"

/datum/sprite_accessory/hair/bob4
	name = "Bob Hair 4"
	icon_state = "hair_bob4"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"

/datum/sprite_accessory/hair/bowlcut
	name = "Bowlcut"
	icon_state = "hair_bowlcut"

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowlcut 2"
	icon_state = "hair_bowlcut2"

/datum/sprite_accessory/hair/braid
	name = "Braid (Floorlength)"
	icon_state = "hair_braid"

/datum/sprite_accessory/hair/braided
	name = "Braided"
	icon_state = "hair_braided"

/datum/sprite_accessory/hair/front_braid
	name = "Braided Front"
	icon_state = "hair_braidfront"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/not_floorlength_braid
	name = "Braid (High)"
	icon_state = "hair_braid2"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/lowbraid
	name = "Braid (Low)"
	icon_state = "hair_hbraid"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/shortbraid
	name = "Braid (Short)"
	icon_state = "hair_shortbraid"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/braidtail
	name = "Braided Tail"
	icon_state = "hair_braidtail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/bun
	name = "Bun Head"
	icon_state = "hair_bun"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/largebun
	name = "Bun (Large)"
	icon_state = "hair_largebun"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/manbun
	name = "Bun (Manbun)"
	icon_state = "hair_manbun"
	// Keep default - this is specifically for men

/datum/sprite_accessory/hair/tightbun
	name = "Bun (Tight)"
	icon_state = "hair_tightbun"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/bun2
	name = "Bun Head 2"
	icon_state = "hair_bunhead2"

/datum/sprite_accessory/hair/bun3
	name = "Bun Head 3"
	icon_state = "hair_bun3"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "hair_business4"

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "hair_buzzcut"

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House"
	icon_state = "hair_coffeehouse"

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"

/datum/sprite_accessory/hair/cornrows1
	name = "Cornrows"
	icon_state = "hair_cornrows"

/datum/sprite_accessory/hair/cornrows2
	name = "Cornrows 2"
	icon_state = "hair_cornrows2"

/datum/sprite_accessory/hair/cornrowbun
	name = "Cornrow Bun"
	icon_state = "hair_cornrowbun"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/cornrowbraid
	name = "Cornrow Braid"
	icon_state = "hair_cornrowbraid"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/cornrowdualtail
	name = "Cornrow Tail"
	icon_state = "hair_cornrowtail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/curtains
	name = "Curtains"
	icon_state = "hair_curtains"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_c"

/datum/sprite_accessory/hair/dandpompadour
	name = "Dandy Pompadour"
	icon_state = "hair_dandypompadour"

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/doublebun
	name = "Double Bun"
	icon_state = "hair_doublebun"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "hair_dreads"

/datum/sprite_accessory/hair/drillhair
	name = "Drill Hair"
	icon_state = "hair_drillhair"
	use_default = FALSE // Very unusual/anime style

/datum/sprite_accessory/hair/drillhairextended
	name = "Drill Hair (Extended)"
	icon_state = "hair_drillhairextended"
	use_default = FALSE // Very unusual/anime style

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emofrine
	name = "Emo Fringe"
	icon_state = "hair_emofringe"

/datum/sprite_accessory/hair/nofade
	name = "Fade (None)"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/highfade
	name = "Fade (High)"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/medfade
	name = "Fade (Medium)"
	icon_state = "hair_medfade"

/datum/sprite_accessory/hair/lowfade
	name = "Fade (Low)"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/baldfade
	name = "Fade (Bald)"
	icon_state = "hair_baldfade"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "hair_sargeant"

/datum/sprite_accessory/hair/flair
	name = "Flair"
	icon_state = "hair_flair"

/datum/sprite_accessory/hair/bigflattop
	name = "Flat Top (Big)"
	icon_state = "hair_bigflattop"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "hair_gelled"

/datum/sprite_accessory/hair/gelledeyebrows
	name = "Gelled Spikes"
	icon_state = "hair_ebgel"

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "hair_halfbang"

/datum/sprite_accessory/hair/halfbang2
	name = "Half-banged Hair 2"
	icon_state = "hair_halfbang2"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-shaved"
	icon_state = "hair_halfshaved"

/datum/sprite_accessory/hair/hedgehog
	name = "Hedgehog Hair"
	icon_state = "hair_hedgehog"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"
	use_default = FALSE // Very specific anime style

/datum/sprite_accessory/hair/himecut2
	name = "Hime Cut 2"
	icon_state = "hair_himecut2"
	use_default = FALSE // Very specific anime style

/datum/sprite_accessory/hair/shorthime
	name = "Hime Cut (Short)"
	icon_state = "hair_shorthime"
	use_default = FALSE // Very specific anime style

/datum/sprite_accessory/hair/himeup
	name = "Hime Updo"
	icon_state = "hair_himeup"
	use_default = FALSE // Very specific anime style

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"

/datum/sprite_accessory/hair/jensen
	name = "Jensen Hair"
	icon_state = "hair_jensen"

/datum/sprite_accessory/hair/Joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	use_default = FALSE // Very specific anime reference
	natural_spawn = FALSE

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair 1"
	icon_state = "hair_long"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/long2
	name = "Long Hair 2"
	icon_state = "hair_long2"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/long3
	name = "Long Hair 3"
	icon_state = "hair_long3"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/long_over_eye
	name = "Long Over Eye"
	icon_state = "hair_longovereye"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/longbangs
	name = "Long Bangs"
	icon_state = "hair_lbangs"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "hair_longemo"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/sidepartlongalt
	name = "Long Side Part"
	icon_state = "hair_longsidepart"

/datum/sprite_accessory/hair/megaeyebrows
	name = "Mega Eyebrows"
	icon_state = "hair_megaeyebrows"

/datum/sprite_accessory/hair/messy
	name = "Messy"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_d"
	natural_spawn = FALSE // sorry little one

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/reversemohawk
	name = "Mohawk (Reverse)"
	icon_state = "hair_reversemohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Shaved)"
	icon_state = "hair_shavedmohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/shavedmohawk
	name = "Mohawk (Unshaven)"
	icon_state = "hair_unshaven_mohawk"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/moustache
	name = "Moustache"
	icon_state = "hair_moustache"

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"
	use_default = FALSE // Specific character reference

/datum/sprite_accessory/hair/mullet
	name = "Mullet"
	icon_state = "hair_mullet"

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "hair_odango"
	use_default = FALSE // Very specific anime style
	natural_spawn = FALSE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/oneshoulder
	name = "One Shoulder"
	icon_state = "hair_oneshoulder"
	use_default_gender = FALSE // Typically feminine

/datum/sprite_accessory/hair/over_eye
	name = "Over Eye"
	icon_state = "hair_shortovereye"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/parted2
	name = "Parted 2"
	icon_state ="hair_parted2"

/datum/sprite_accessory/hair/partedside
	name = "Parted (Side)"
	icon_state = "hair_part"

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "hair_kagami"
	use_default_gender = FEMALE // Feminine style
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail
	name = "Pigtails 2"
	icon_state = "hair_pigtails"
	use_default_gender = FEMALE // Feminine style
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pigtail2
	name = "Pigtails 3"
	icon_state = "hair_pigtails2"
	natural_spawn = FALSE

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"

/datum/sprite_accessory/hair/bigpompadour
	name = "Pompadour (Big)"
	icon_state = "hair_bigpompadour"

/datum/sprite_accessory/hair/hugepompadour
	name = "Pompadour (Huge)"
	icon_state = "hair_hugepompadour"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail"
	icon_state = "hair_ponytail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/ponytailalchemist
	name = "Ponytail (Alchemist)"
	icon_state = "hair_alchemist"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/highponytail
	name = "Ponytail (High)"
	icon_state = "hair_highponytail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/tightponytail
	name = "Ponytail (Tight)"
	icon_state = "hair_tightponytail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/stail
	name = "Ponytail (Short)"
	icon_state = "hair_stail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/longponytail
	name = "Ponytail (Long)"
	icon_state = "hair_longstraightponytail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/countryponytail
	name = "Ponytail (Country)"
	icon_state = "hair_country"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/fringetail
	name = "Ponytail (Fringe)"
	icon_state = "hair_fringetail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/sidetail
	name = "Ponytail (Side)"
	icon_state = "hair_sidetail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/sidetail2
	name = "Ponytail (Side) 2"
	icon_state = "hair_sidetail2"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/sidetail3
	name = "Ponytail (Side) 3"
	icon_state = "hair_sidetail3"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/sidetail4
	name = "Ponytail (Side) 4"
	icon_state = "hair_sidetail4"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/spikyponytail
	name = "Ponytail (Spiky)"
	icon_state = "hair_spikyponytail"

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"

/datum/sprite_accessory/hair/pride
	name = "Pride"
	icon_state = "hair_pride"

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/shavedpart
	name = "Shaved Part"
	icon_state = "hair_shavedpart"

/datum/sprite_accessory/hair/shortafro
	name = "Short Afro"
	icon_state = "hair_shortafro"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "hair_shortbangs"

/datum/sprite_accessory/hair/shortbangs2
	name = "Short Bangs 2"
	icon_state = "hair_shortbangs2"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_a"

/datum/sprite_accessory/hair/shorthair2
	name = "Short Hair 2"
	icon_state = "hair_shorthair2"

/datum/sprite_accessory/hair/shorthair3
	name = "Short Hair 3"
	icon_state = "hair_shorthair3"

/datum/sprite_accessory/hair/shorthair4
	name = "Short Hair 4"
	icon_state = "hair_d"

/datum/sprite_accessory/hair/shorthair5
	name = "Short Hair 5"
	icon_state = "hair_e"

/datum/sprite_accessory/hair/shorthair6
	name = "Short Hair 6"
	icon_state = "hair_f"

/datum/sprite_accessory/hair/shorthair7
	name = "Short Hair 7"
	icon_state = "hair_shorthairg"

/datum/sprite_accessory/hair/shorthaireighties
	name = "Short Hair 80s"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/rosa
	name = "Short Hair Rosa"
	icon_state = "hair_rosa"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_b"

/datum/sprite_accessory/hair/sidecut
	name = "Sidecut"
	icon_state = "hair_sidecut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/protagonist
	name = "Slightly Long Hair"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/spamton
	name = "Spamton"
	icon_state = "hair_spamton"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spikey"

/datum/sprite_accessory/hair/spiky2
	name = "Spiky 2"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/spiky3
	name = "Spiky 3"
	icon_state = "hair_spiky2"

/datum/sprite_accessory/hair/swept
	name = "Swept Back Hair"
	icon_state = "hair_swept"

/datum/sprite_accessory/hair/swept2
	name = "Swept Back Hair 2"
	icon_state = "hair_swept2"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning (Front)"
	icon_state = "hair_thinningfront"

/datum/sprite_accessory/hair/thinningrear
	name = "Thinning (Rear)"
	icon_state = "hair_thinningrear"

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"

/datum/sprite_accessory/hair/tressshoulder
	name = "Tress Shoulder"
	icon_state = "hair_tressshoulder"

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"

/datum/sprite_accessory/hair/trimflat
	name = "Trim Flat"
	icon_state = "hair_trimflat"

/datum/sprite_accessory/hair/twintails
	name = "Twintails"
	icon_state = "hair_twintail"
	use_default_gender = FEMALE // Feminine style

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"

/datum/sprite_accessory/hair/undercutleft
	name = "Undercut Left"
	icon_state = "hair_undercutleft"

/datum/sprite_accessory/hair/undercutright
	name = "Undercut Right"
	icon_state = "hair_undercutright"

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"

/datum/sprite_accessory/hair/longer
	name = "Very Long Hair"
	icon_state = "hair_vlong"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair 2"
	icon_state = "hair_longest"

/datum/sprite_accessory/hair/longest2
	name = "Very Long Over Eye"
	icon_state = "hair_longest2"

/datum/sprite_accessory/hair/veryshortovereye
	name = "Very Short Over Eye"
	icon_state = "hair_veryshortovereyealternate"

/datum/sprite_accessory/hair/longestalt
	name = "Very Long with Fringe"
	icon_state = "hair_vlongfringe"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"

/*
/////////////////////////////////////
/  =---------------------------=    /
/  == Gradient Hair Definitions ==  /
/  =---------------------------=    /
/////////////////////////////////////
*/

/datum/sprite_accessory/gradient
	icon = 'icons/mob/hair_gradients.dmi'
	///whether this gradient applies to hair and/or beards. Some gradients do not work well on beards.
	var/gradient_category = GRADIENT_APPLIES_TO_HAIR|GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/gradient/fadeup
	name = "Fade Up"
	icon_state = "fadeup"

/datum/sprite_accessory/gradient/fadedown
	name = "Fade Down"
	icon_state = "fadedown"

/datum/sprite_accessory/gradient/vertical_split
	name = "Vertical Split"
	icon_state = "vsplit"

/datum/sprite_accessory/gradient/horizontal_split
	name = "Horizontal Split"
	icon_state = "bottomflat"

/datum/sprite_accessory/gradient/reflected
	name = "Reflected"
	icon_state = "reflected_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected/beard
	icon_state = "reflected_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/reflected_inverse
	name = "Reflected Inverse"
	icon_state = "reflected_inverse_high"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/reflected_inverse/beard
	icon_state = "reflected_inverse_high_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy
	name = "Wavy"
	icon_state = "wavy"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/long_fade_up
	name = "Long Fade Up"
	icon_state = "long_fade_up"

/datum/sprite_accessory/gradient/long_fade_down
	name = "Long Fade Down"
	icon_state = "long_fade_down"

/datum/sprite_accessory/gradient/short_fade_up
	name = "Short Fade Up"
	icon_state = "short_fade_up"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_up/beard
	icon_state = "short_fade_down"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/short_fade_down
	name = "Short Fade Down"
	icon_state = "short_fade_down"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/short_fade_down/beard
	icon_state = "short_fade_down_beard"
	gradient_category = GRADIENT_APPLIES_TO_FACIAL_HAIR

/datum/sprite_accessory/gradient/wavy_spike
	name = "Spiked Wavy"
	icon_state = "wavy_spiked"
	gradient_category = GRADIENT_APPLIES_TO_HAIR

/datum/sprite_accessory/gradient/striped
	name = "striped"
	icon_state = "striped"

/datum/sprite_accessory/gradient/striped_vertical
	name = "Striped Vertical"
	icon_state = "striped_vertical"

/////////////////////////////
// Facial Hair Definitions //
/////////////////////////////

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/human/human_face.dmi'
	// By default, only characters generated as male can get facial hair

// please make sure they're sorted alphabetically and categorized

/// This one goes first. Don't move it
/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = null

/datum/sprite_accessory/facial_hair/eyebrows
	name = "Eyebrows"
	icon_state = "facial_eyebrows"

/datum/sprite_accessory/facial_hair/abe
	name = "Beard (Abraham Lincoln)"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/brokenman
	name = "Beard (Broken Man)"
	icon_state = "facial_brokenman"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Beard (Chinstrap)"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Beard (Dwarf)"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Beard (Full)"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/croppedfullbeard
	name = "Beard (Cropped Fullbeard)"
	icon_state = "facial_croppedfullbeard"

/datum/sprite_accessory/facial_hair/gt
	name = "Beard (Goatee)"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/hip
	name = "Beard (Hipster)"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/jensen
	name = "Beard (Jensen)"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Beard (Neckbeard)"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Beard (Very Long)"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/muttonmus
	name = "Beard (Muttonmus)"
	icon_state = "facial_muttonmus"

/datum/sprite_accessory/facial_hair/martialartist
	name = "Beard (Martial Artist)"
	icon_state = "facial_martialartist"
	natural_spawn = FALSE

/datum/sprite_accessory/facial_hair/chinlessbeard
	name = "Beard (Chinless Beard)"
	icon_state = "facial_chinlessbeard"

/datum/sprite_accessory/facial_hair/moonshiner
	name = "Beard (Moonshiner)"
	icon_state = "facial_moonshiner"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Beard (Long)"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/powerful
	name = "Beard (Powerful)"
	icon_state = "facial_powerful"

/datum/sprite_accessory/facial_hair/volaju
	name = "Beard (Volaju)"
	icon_state = "facial_volaju"

/datum/sprite_accessory/facial_hair/threeoclock
	name = "Beard (Three o Clock Shadow)"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/fiveoclock
	name = "Beard (Five o Clock Shadow)"
	icon_state = "facial_fiveoclock"

/datum/sprite_accessory/facial_hair/fiveoclockm
	name = "Beard (Five o Clock Moustache)"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenoclock
	name = "Beard (Seven o Clock Shadow)"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/sevenoclockm
	name = "Beard (Seven o Clock Moustache)"
	icon_state = "facial_7oclockmoustache"

/datum/sprite_accessory/facial_hair/thecolonel
	name = "Beard (The Colonel)"
	icon_state = "facial_thecolonel"

/datum/sprite_accessory/facial_hair/moustache
	name = "Moustache"
	icon_state = "facial_moustache"

/datum/sprite_accessory/facial_hair/pencilstache
	name = "Moustache (Pencilstache)"
	icon_state = "facial_pencilstache"

/datum/sprite_accessory/facial_hair/smallstache
	name = "Moustache (Smallstache)"
	icon_state = "facial_smallstache"

/datum/sprite_accessory/facial_hair/walrus
	name = "Moustache (Walrus)"
	icon_state = "facial_walrus"

/datum/sprite_accessory/facial_hair/fu
	name = "Moustache (Fu Manchu)"
	icon_state = "facial_fumanchu"

/datum/sprite_accessory/facial_hair/hogan
	name = "Moustache (Hulk Hogan)"
	icon_state = "facial_hogan" //-Neek

/datum/sprite_accessory/facial_hair/robotnik
	name = "Moustache (Robotnik)"
	icon_state = "facial_robotnik"

/datum/sprite_accessory/facial_hair/selleck
	name = "Moustache (Selleck)"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Moustache (Square)"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/stachenchops
	name = "Moustache ('Stache 'n Chops)"
	icon_state = "facial_stachenchops"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Moustache (Van Dyke)"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/watson
	name = "Moustache (Watson)"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/elvis
	name = "Sideburns (Elvis)"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/mutton
	name = "Sideburns (Mutton Chops)"
	icon_state = "facial_mutton"

/datum/sprite_accessory/facial_hair/sideburn
	name = "Sideburns"
	icon_state = "facial_sideburn"

///////////////////////////
// Underwear Definitions //
///////////////////////////

/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	use_static = FALSE


//MALE UNDERWEAR
/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null

/datum/sprite_accessory/underwear/male_briefs
	name = "Men's Briefs"
	icon_state = "male_briefs"

/datum/sprite_accessory/underwear/male_boxers
	name = "Men's Boxer"
	icon_state = "male_boxers"

/datum/sprite_accessory/underwear/male_stripe
	name = "Men's Striped Boxer"
	icon_state = "male_stripe"

/datum/sprite_accessory/underwear/male_midway
	name = "Men's Midway Boxer"
	icon_state = "male_midway"

/datum/sprite_accessory/underwear/male_longjohns
	name = "Men's Long Johns"
	icon_state = "male_longjohns"

/datum/sprite_accessory/underwear/male_kinky
	name = "Men's Kinky"
	icon_state = "male_kinky"

/datum/sprite_accessory/underwear/male_mankini
	name = "Mankini"
	icon_state = "male_mankini"

/datum/sprite_accessory/underwear/male_hearts
	name = "Men's Hearts Boxer"
	icon_state = "male_hearts"
	use_static = TRUE

/datum/sprite_accessory/underwear/male_commie
	name = "Men's Striped Commie Boxer"
	icon_state = "male_commie"
	use_static = TRUE

/datum/sprite_accessory/underwear/male_usastripe
	name = "Men's Striped Freedom Boxer"
	icon_state = "male_assblastusa"
	use_static = TRUE

/datum/sprite_accessory/underwear/male_uk
	name = "Men's Striped UK Boxer"
	icon_state = "male_uk"
	use_static = TRUE


//FEMALE UNDERWEAR
/datum/sprite_accessory/underwear/female_bikini
	name = "Ladies' Bikini"
	icon_state = "female_bikini"

/datum/sprite_accessory/underwear/female_lace
	name = "Ladies' Lace"
	icon_state = "female_lace"

/datum/sprite_accessory/underwear/female_bralette
	name = "Ladies' Bralette"
	icon_state = "female_bralette"

/datum/sprite_accessory/underwear/female_sport
	name = "Ladies' Sport"
	icon_state = "female_sport"

/datum/sprite_accessory/underwear/female_thong
	name = "Ladies' Thong"
	icon_state = "female_thong"

/datum/sprite_accessory/underwear/female_strapless
	name = "Ladies' Strapless"
	icon_state = "female_strapless"

/datum/sprite_accessory/underwear/female_babydoll
	name = "Babydoll"
	icon_state = "female_babydoll"

/datum/sprite_accessory/underwear/swimsuit_onepiece
	name = "Ladies' One Piece Swimsuit"
	icon_state = "swim_onepiece"

/datum/sprite_accessory/underwear/swimsuit_strapless_onepiece
	name = "Ladies' Strapless One Piece Swimsuit"
	icon_state = "swim_strapless_onepiece"

/datum/sprite_accessory/underwear/swimsuit_twopiece
	name = "Ladies' Two Piece Swimsuit"
	icon_state = "swim_twopiece"

/datum/sprite_accessory/underwear/swimsuit_strapless_twopiece
	name = "Ladies' Strapless Two Piece Swimsuit"
	icon_state = "swim_strapless_twopiece"

/datum/sprite_accessory/underwear/swimsuit_stripe
	name = "Ladies' Stripe Swimsuit"
	icon_state = "swim_stripe"

/datum/sprite_accessory/underwear/swimsuit_halter
	name = "Ladies' Halter Swimsuit"
	icon_state = "swim_halter"

/datum/sprite_accessory/underwear/female_white_neko
	name = "Ladies' White Neko"
	icon_state = "female_neko_white"

/datum/sprite_accessory/underwear/female_black_neko
	name = "Ladies' Black Neko"
	icon_state = "female_neko_black"

/datum/sprite_accessory/underwear/female_commie
	name = "Ladies' Commie"
	icon_state = "female_commie"

/datum/sprite_accessory/underwear/female_usastripe
	name = "Ladies' Freedom"
	icon_state = "female_assblastusa"

/datum/sprite_accessory/underwear/female_uk
	name = "Ladies' UK"
	icon_state = "female_uk"

/datum/sprite_accessory/underwear/female_kinky
	name = "Ladies' Kinky"
	icon_state = "female_kinky"

////////////////////////////
// Undershirt Definitions //
////////////////////////////

/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/undershirt/bluejersey
	name = "Jersey (Blue)"
	icon_state = "shirt_bluejersey"

/datum/sprite_accessory/undershirt/redjersey
	name = "Jersey (Red)"
	icon_state = "shirt_redjersey"

/datum/sprite_accessory/undershirt/bluepolo
	name = "Polo Shirt (Blue)"
	icon_state = "bluepolo"

/datum/sprite_accessory/undershirt/grayyellowpolo
	name = "Polo Shirt (Gray-Yellow)"
	icon_state = "grayyellowpolo"

/datum/sprite_accessory/undershirt/redpolo
	name = "Polo Shirt (Red)"
	icon_state = "redpolo"

/datum/sprite_accessory/undershirt/whitepolo
	name = "Polo Shirt (White)"
	icon_state = "whitepolo"

/datum/sprite_accessory/undershirt/alienshirt
	name = "Shirt (Alien)"
	icon_state = "shirt_alien"

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Shirt (Band)"
	icon_state = "band"

/datum/sprite_accessory/undershirt/shirt_black
	name = "Shirt (Black)"
	icon_state = "shirt_black"

/datum/sprite_accessory/undershirt/blueshirt
	name = "Shirt (Blue)"
	icon_state = "shirt_blue"

/datum/sprite_accessory/undershirt/clownshirt
	name = "Shirt (Clown)"
	icon_state = "shirt_clown"

/datum/sprite_accessory/undershirt/commie
	name = "Shirt (Commie)"
	icon_state = "shirt_commie"

/datum/sprite_accessory/undershirt/greenshirt
	name = "Shirt (Green)"
	icon_state = "shirt_green"

/datum/sprite_accessory/undershirt/shirt_grey
	name = "Shirt (Grey)"
	icon_state = "shirt_grey"

/datum/sprite_accessory/undershirt/ian
	name = "Shirt (Ian)"
	icon_state = "ian"

/datum/sprite_accessory/undershirt/ilovent
	name = "Shirt (I Love NT)"
	icon_state = "ilovent"

/datum/sprite_accessory/undershirt/lover
	name = "Shirt (Lover)"
	icon_state = "lover"

/datum/sprite_accessory/undershirt/matroska
	name = "Shirt (Matroska)"
	icon_state = "matroska"

/datum/sprite_accessory/undershirt/meat
	name = "Shirt (Meat)"
	icon_state = "shirt_meat"

/datum/sprite_accessory/undershirt/nano
	name = "Shirt (Nanotrasen)"
	icon_state = "shirt_nano"

/datum/sprite_accessory/undershirt/peace
	name = "Shirt (Peace)"
	icon_state = "peace"

/datum/sprite_accessory/undershirt/pacman
	name = "Shirt (Pogoman)"
	icon_state = "pogoman"

/datum/sprite_accessory/undershirt/question
	name = "Shirt (Question)"
	icon_state = "shirt_question"

/datum/sprite_accessory/undershirt/redshirt
	name = "Shirt (Red)"
	icon_state = "shirt_red"

/datum/sprite_accessory/undershirt/skull
	name = "Shirt (Skull)"
	icon_state = "shirt_skull"

/datum/sprite_accessory/undershirt/ss13
	name = "Shirt (SS13)"
	icon_state = "shirt_ss13"

/datum/sprite_accessory/undershirt/stripe
	name = "Shirt (Striped)"
	icon_state = "shirt_stripes"

/datum/sprite_accessory/undershirt/tiedye
	name = "Shirt (Tie-dye)"
	icon_state = "shirt_tiedye"

/datum/sprite_accessory/undershirt/uk
	name = "Shirt (UK)"
	icon_state = "uk"

/datum/sprite_accessory/undershirt/usa
	name = "Shirt (USA)"
	icon_state = "shirt_assblastusa"

/datum/sprite_accessory/undershirt/shirt_white
	name = "Shirt (White)"
	icon_state = "shirt_white"

/datum/sprite_accessory/undershirt/blackshortsleeve
	name = "Short-sleeved Shirt (Black)"
	icon_state = "blackshortsleeve"

/datum/sprite_accessory/undershirt/blueshortsleeve
	name = "Short-sleeved Shirt (Blue)"
	icon_state = "blueshortsleeve"

/datum/sprite_accessory/undershirt/greenshortsleeve
	name = "Short-sleeved Shirt (Green)"
	icon_state = "greenshortsleeve"

/datum/sprite_accessory/undershirt/purpleshortsleeve
	name = "Short-sleeved Shirt (Purple)"
	icon_state = "purpleshortsleeve"

/datum/sprite_accessory/undershirt/whiteshortsleeve
	name = "Short-sleeved Shirt (White)"
	icon_state = "whiteshortsleeve"

/datum/sprite_accessory/undershirt/sports_bra
	name = "Sports Bra"
	icon_state = "sports_bra"

/datum/sprite_accessory/undershirt/sports_bra2
	name = "Sports Bra (Alt)"
	icon_state = "sports_bra_alt"

/datum/sprite_accessory/undershirt/blueshirtsport
	name = "Sports Shirt (Blue)"
	icon_state = "blueshirtsport"

/datum/sprite_accessory/undershirt/greenshirtsport
	name = "Sports Shirt (Green)"
	icon_state = "greenshirtsport"

/datum/sprite_accessory/undershirt/redshirtsport
	name = "Sports Shirt (Red)"
	icon_state = "redshirtsport"

/datum/sprite_accessory/undershirt/tank_black
	name = "Tank Top (Black)"
	icon_state = "tank_black"
	// Conflicts with female underwear

/datum/sprite_accessory/undershirt/tankfire
	name = "Tank Top (Fire)"
	icon_state = "tank_fire"
	// Conflicts with female underwear

/datum/sprite_accessory/undershirt/tank_grey
	name = "Tank Top (Grey)"
	icon_state = "tank_grey"
	// Conflicts with female underwear

/datum/sprite_accessory/undershirt/female_midriff
	name = "Tank Top (Midriff)"
	icon_state = "tank_midriff"

/datum/sprite_accessory/undershirt/tank_red
	name = "Tank Top (Red)"
	icon_state = "tank_red"
	// Conflicts with female underwear

/datum/sprite_accessory/undershirt/tankstripe
	name = "Tank Top (Striped)"
	icon_state = "tank_stripes"

/datum/sprite_accessory/undershirt/tank_white
	name = "Tank Top (White)"
	icon_state = "tank_white"

/datum/sprite_accessory/undershirt/redtop
	name = "Top (Red)"
	icon_state = "redtop"

/datum/sprite_accessory/undershirt/whitetop
	name = "Top (White)"
	icon_state = "whitetop"

/datum/sprite_accessory/undershirt/tshirt_blue
	name = "T-Shirt (Blue)"
	icon_state = "blueshirt"

/datum/sprite_accessory/undershirt/tshirt_green
	name = "T-Shirt (Green)"
	icon_state = "greenshirt"

/datum/sprite_accessory/undershirt/tshirt_red
	name = "T-Shirt (Red)"
	icon_state = "redshirt"

/datum/sprite_accessory/undershirt/yellowshirt
	name = "T-Shirt (Yellow)"
	icon_state = "yellowshirt"

///////////////////////
// Socks Definitions //
///////////////////////

/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null

// please make sure they're sorted alphabetically and categorized

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high (Black)"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/commie_knee
	name = "Knee-High (Commie)"
	icon_state = "commie_knee"

/datum/sprite_accessory/socks/usa_knee
	name = "Knee-High (Freedom)"
	icon_state = "assblastusa_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high (Rainbow)"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high (Striped)"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high (Thin)"
	icon_state = "thin_knee"

/datum/sprite_accessory/socks/uk_knee
	name = "Knee-High (UK)"
	icon_state = "uk_knee"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high (White)"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/bee_knee
	name = "Knee-high (Bee)"
	icon_state = "bee_knee"

/datum/sprite_accessory/socks/black_norm
	name = "Normal (Black)"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_norm
	name = "Normal (White)"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"

/datum/sprite_accessory/socks/black_short
	name = "Short (Black)"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_short
	name = "Short (White)"
	icon_state = "white_short"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high (Black)"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/commie_thigh
	name = "Thigh-high (Commie)"
	icon_state = "commie_thigh"

/datum/sprite_accessory/socks/usa_thigh
	name = "Thigh-high (Freedom)"
	icon_state = "assblastusa_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high (Rainbow)"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high (Striped)"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high (Thin)"
	icon_state = "thin_thigh"

/datum/sprite_accessory/socks/uk_thigh
	name = "Thigh-high (UK)"
	icon_state = "uk_thigh"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high (White)"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/bee_thigh
	name = "Thigh-high (Bee)"
	icon_state = "bee_thigh"

/datum/sprite_accessory/socks/codersocks_pink
	name = "Coder Socks (Pink)"
	icon_state = "codersocks_pink"

/datum/sprite_accessory/socks/codersocks_blue
	name = "Coder Socks (Blue)"
	icon_state = "codersocks_blue"

/datum/sprite_accessory/socks/codersocks_trans
	name = "Coder Socks (Trans)"
	icon_state = "codersocks_trans"

//////////.//////////////////
// MutantParts Definitions //
/////////////////////////////

/datum/sprite_accessory/lizard_markings
	icon = 'icons/mob/human/species/lizard/lizard_markings.dmi'

/datum/sprite_accessory/lizard_markings/dtiger
	name = "Dark Tiger Body"
	icon_state = "dtiger"
	gender_specific = 1

/datum/sprite_accessory/lizard_markings/ltiger
	name = "Light Tiger Body"
	icon_state = "ltiger"
	gender_specific = 1

/datum/sprite_accessory/lizard_markings/lbelly
	name = "Light Belly"
	icon_state = "lbelly"
	gender_specific = 1

/datum/sprite_accessory/tails
	icon = 'icons/mob/mutant_bodyparts.dmi'
	/// Describes which tail spine sprites to use, if any.
	var/spine_key = NONE

/datum/sprite_accessory/tails/lizard
	icon = 'icons/mob/human/species/lizard/lizard_tails.dmi'
	spine_key = SPINE_KEY_LIZARD

/datum/sprite_accessory/tails/lizard/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/lizard/short
	name = "Short"
	icon_state = "short"
	spine_key = NONE

/datum/sprite_accessory/tails/human/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/tails/human/cat
	name = "Cat"
	icon = 'icons/mob/cat_features.dmi'
	icon_state = "default"
	color_src = HAIR_COLOR

/datum/sprite_accessory/tails/monkey
	//icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	color_src = FALSE

/datum/sprite_accessory/tails/monkey/standard
	name = "Monkey"
	icon_state = "monkey"


/datum/sprite_accessory/snouts
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/snouts/sharp
	name = "Sharp"
	icon_state = "sharp"

/datum/sprite_accessory/snouts/round
	name = "Round"
	icon_state = "round"

/datum/sprite_accessory/snouts/sharplight
	name = "Sharp + Light"
	icon_state = "sharplight"

/datum/sprite_accessory/snouts/roundlight
	name = "Round + Light"
	icon_state = "roundlight"

/datum/sprite_accessory/horns
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/horns/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/horns/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/horns/curled
	name = "Curled"
	icon_state = "curled"

/datum/sprite_accessory/horns/ram
	name = "Ram"
	icon_state = "ram"

/datum/sprite_accessory/horns/angler
	name = "Angeler"
	icon_state = "angler"

/datum/sprite_accessory/ears
	icon = 'icons/mob/cat_features.dmi'

/datum/sprite_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	color_src = HAIR_COLOR

/datum/sprite_accessory/wings
	icon = 'icons/mob/wings.dmi'

/datum/sprite_accessory/wings_open
	icon = 'icons/mob/wings.dmi'

/datum/sprite_accessory/wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/wings_open/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
/*
/datum/sprite_accessory/wings/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/megamoth
	name = "Megamoth"
	icon_state = "megamoth"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/mothra
	name = "Mothra"
	icon_state = "mothra"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
*/

/datum/sprite_accessory/wings/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/skeleton
	name = "Skeleton"
	icon_state = "skele"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/robotic
	name = "Robotic"
	icon_state = "robotic"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	locked = TRUE

/datum/sprite_accessory/wings_open/fly
	name = "Fly"
	icon_state = "fly"
	color_src = FALSE
	dimension_x = 96
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/bee
	name = "Bee"
	icon = 'icons/mob/apid_accessories/apid_wings.dmi'
	icon_state = "apid"
	color_src = 0
	dimension_x = 32
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings_open/bee
	name = "Bee"
	icon = 'icons/mob/apid_accessories/apid_wings.dmi'
	icon_state = "apid"
	color_src = 0
	dimension_x = 32
	center = TRUE
	dimension_y = 32

/datum/sprite_accessory/wings/robot
	name = "Robot"
	icon_state = "robo"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/wings_open/robot
	name = "Robot"
	icon_state = "robo"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34

/datum/sprite_accessory/frills
	icon = 'icons/mob/human/species/lizard/lizard_misc.dmi'

/datum/sprite_accessory/frills/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/frills/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/frills/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/tail_spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'

/datum/sprite_accessory/spines
	icon = 'icons/mob/human/species/lizard/lizard_spines.dmi'

/datum/sprite_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/tail_spines/short
	name = "Short"
	icon_state = "short"

/datum/sprite_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/tail_spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/sprite_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/tail_spines/long
	name = "Long"
	icon_state = "long"

/datum/sprite_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/tail_spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/sprite_accessory/spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/tail_spines/aquatic
	name = "Aquatic"
	icon_state = "aqua"

/datum/sprite_accessory/moth_wings
	icon = 'icons/mob/human/species/moth/moth_wings.dmi'
	color_src = null

/datum/sprite_accessory/moth_antennae
	icon = 'icons/mob/human/species/moth/moth_antennae.dmi'
	color_src = null

/datum/sprite_accessory/moth_wingsopen
	icon = 'icons/mob/human/species/moth/moth_wingsopen.dmi'
	color_src = null
	dimension_x = 76
	center = TRUE

/datum/sprite_accessory/moth_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_wingsopen/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wingsopen/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_wingsopen/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wingsopen/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/moth_wingsopen/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/moth_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_wingsopen/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wingsopen/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wingsopen/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wingsopen/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wings/punished
	name = "Burnt Off"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wingsopen/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wingsopen/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_wingsopen/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wingsopen/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wingsopen/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wings/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/moth_wingsopen/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/moth_wings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_wingsopen/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_wings/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_wingsopen/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_wings/bluespace
	name = "Bluespace"
	icon_state = "bluespace"

/datum/sprite_accessory/moth_wingsopen/bluespace
	name = "Bluespace"
	icon_state = "bluespace"

/datum/sprite_accessory/moth_wings/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_wingsopen/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_wings/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_wingsopen/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_wings/strawberry
	name = "Strawberry"
	icon_state = "strawberry"

/datum/sprite_accessory/moth_wingsopen/strawberry
	name = "Strawberry"
	icon_state = "strawberry"

/datum/sprite_accessory/moth_wings/angel
	name = "Angel"
	icon_state = "angel"
	color_src = 0
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	locked = TRUE

/datum/sprite_accessory/moth_antennae //Finally splitting the sprite
	icon = 'icons/mob/human/species/moth/moth_antennae.dmi'
	color_src = null

/datum/sprite_accessory/moth_antennae/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_antennae/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_antennae/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_antennae/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_antennae/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_antennae/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_antennae/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_antennae/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_antennae/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_antennae/punished
	name = "Burnt Off"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_antennae/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_antennae/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_antennae/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_antennae/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_antennae/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_antennae/snow
	name = "Snow"
	icon_state = "snow"

/datum/sprite_accessory/moth_antennae/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/sprite_accessory/moth_antennae/plasmafire
	name = "Plasmafire"
	icon_state = "plasmafire"

/datum/sprite_accessory/moth_antennae/bluespace
	name = "Bluespace"
	icon_state = "bluespace"

/datum/sprite_accessory/moth_antennae/brown
	name = "Brown"
	icon_state = "brown"

/datum/sprite_accessory/moth_antennae/rosy
	name = "Rosy"
	icon_state = "rosy"

/datum/sprite_accessory/moth_antennae/strawberry
	name = "Strawberry"
	icon_state = "strawberry"

/datum/sprite_accessory/moth_markings // the markings that moths can have. finally something other than the boring tan
	icon = 'icons/mob/human/species/moth/moth_markings.dmi'
	color_src = null

/datum/sprite_accessory/moth_markings/reddish
	name = "Reddish"
	icon_state = "reddish"

/datum/sprite_accessory/moth_markings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_markings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_markings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_markings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_markings/burnt_off
	name = "Burnt Off"
	icon_state = "burnt_off"
	locked = TRUE

/datum/sprite_accessory/moth_markings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_markings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_markings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_markings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_markings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_markings/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

// IPC accessories.

/datum/sprite_accessory/ipc_screens
	icon = 'icons/mob/ipc_accessories.dmi'
	emissive_state = "m_ipc_screen_emissive"
	emissive_alpha = 60
	color_src = EYE_COLOR

/datum/sprite_accessory/ipc_screens/blue
	name = "Blue"
	icon_state = "blue"
	color_src = 0

/datum/sprite_accessory/ipc_screens/bsod
	name = "BSOD"
	icon_state = "bsod"
	color_src = 0

/datum/sprite_accessory/ipc_screens/breakout
	name = "Breakout"
	icon_state = "breakout"

/datum/sprite_accessory/ipc_screens/console
	name = "Console"
	icon_state = "console"

/datum/sprite_accessory/ipc_screens/ecgwave
	name = "ECG Wave"
	icon_state = "ecgwave"

/datum/sprite_accessory/ipc_screens/eight
	name = "Eight"
	icon_state = "eight"

/datum/sprite_accessory/ipc_screens/eyes
	name = "Eyes"
	icon_state = "eyes"

/datum/sprite_accessory/ipc_screens/glider
	name = "Glider"
	icon_state = "glider"

/datum/sprite_accessory/ipc_screens/goggles
	name = "Goggles"
	icon_state = "goggles"

/datum/sprite_accessory/ipc_screens/green
	name = "Green"
	icon_state = "green"

/datum/sprite_accessory/ipc_screens/heart
	name = "Heart"
	icon_state = "heart"
	color_src = 0

/datum/sprite_accessory/ipc_screens/monoeye
	name = "Mono-eye"
	icon_state = "monoeye"

/datum/sprite_accessory/ipc_screens/nature
	name = "Nature"
	icon_state = "nature"

/datum/sprite_accessory/ipc_screens/orange
	name = "Orange"
	icon_state = "orange"

/datum/sprite_accessory/ipc_screens/pink
	name = "Pink"
	icon_state = "pink"

/datum/sprite_accessory/ipc_screens/purple
	name = "Purple"
	icon_state = "purple"

/datum/sprite_accessory/ipc_screens/rainbow
	name = "Rainbow"
	icon_state = "rainbow"
	color_src = 0

/datum/sprite_accessory/ipc_screens/red
	name = "Red"
	icon_state = "red"

/datum/sprite_accessory/ipc_screens/redtext
	name = "Red Text"
	icon_state = "redtext"
	color_src = 0

/datum/sprite_accessory/ipc_screens/rgb
	name = "RGB"
	icon_state = "rgb"

/datum/sprite_accessory/ipc_screens/scroll
	name = "Scanline"
	icon_state = "scroll"

/datum/sprite_accessory/ipc_screens/shower
	name = "Shower"
	icon_state = "shower"

/datum/sprite_accessory/ipc_screens/sinewave
	name = "Sinewave"
	icon_state = "sinewave"

/datum/sprite_accessory/ipc_screens/smile
	name = "Smile"
	icon_state = "smile"

/datum/sprite_accessory/ipc_screens/squarewave
	name = "Square wave"
	icon_state = "squarewave"

/datum/sprite_accessory/ipc_screens/static_screen
	name = "Static"
	icon_state = "static"

/datum/sprite_accessory/ipc_screens/yellow
	name = "Yellow"
	icon_state = "yellow"

/datum/sprite_accessory/ipc_screens/textdrop
	name = "Text drop"
	icon_state = "textdrop"

/datum/sprite_accessory/ipc_screens/stars
	name = "Stars"
	icon_state = "stars"

/datum/sprite_accessory/ipc_screens/loading
	name = "Loading"
	icon_state = "loading"

/datum/sprite_accessory/ipc_screens/windowsxp
	name = "Windows XP"
	icon_state = "windowsxp"

/datum/sprite_accessory/ipc_screens/tetris
	name = "Tetris"
	icon_state = "tetris"

/datum/sprite_accessory/ipc_screens/tv
	name = "Color Test"
	icon_state = "tv"

/datum/sprite_accessory/ipc_screens/mask
	name = "Mask"
	icon_state = "mask"

/datum/sprite_accessory/ipc_screens/alpha
	name = "Alpha"
	icon_state = "alpha"

/datum/sprite_accessory/ipc_screens/omega
	name = "Omega"
	icon_state = "omega"

/datum/sprite_accessory/ipc_screens/psi
	name = "Psi"
	icon_state = "psi"

/datum/sprite_accessory/ipc_screens/phi
	name = "Phi"
	icon_state = "phi"

/datum/sprite_accessory/ipc_screens/theta
	name = "Theta"
	icon_state = "theta"

/datum/sprite_accessory/ipc_screens/sigma
	name = "Sigma"
	icon_state = "sigma"

/datum/sprite_accessory/ipc_antennas
	icon = 'icons/mob/ipc_accessories.dmi'
	color_src = HAIR_COLOR

/datum/sprite_accessory/ipc_antennas/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/ipc_antennas/angled
	name = "Angled"
	icon_state = "antennae"

/datum/sprite_accessory/ipc_antennas/antlers
	name = "Antlers"
	icon_state = "antlers"

/datum/sprite_accessory/ipc_antennas/crowned
	name = "Crowned"
	icon_state = "crowned"

/datum/sprite_accessory/ipc_antennas/cyberhead
	name = "Cyberhead"
	icon_state = "cyberhead"

/datum/sprite_accessory/ipc_antennas/droneeyes
	name = "Drone Eyes"
	icon_state = "droneeyes"

/datum/sprite_accessory/ipc_antennas/light
	name = "Light"
	icon_state = "light"

/datum/sprite_accessory/ipc_antennas/sidelights
	name = "Sidelights"
	icon_state = "sidelights"

/datum/sprite_accessory/ipc_antennas/tesla
	name = "Tesla"
	icon_state = "tesla"

/datum/sprite_accessory/ipc_antennas/tv
	name = "TV Antenna"
	icon_state = "tvantennae"

/datum/sprite_accessory/ipc_chassis // Used for changing limb icons, doesn't need to hold the actual icon. That's handled in ipc.dm
	icon = null
	icon_state = "who cares fuck you" // In order to pull the chassis correctly, we need AN icon_state(see line 36-39). It doesn't have to be useful, because it isn't used.
	color_src = 0

/datum/sprite_accessory/insect_type
	icon = null
	icon_state = "NULL"
	color_src = 0

/datum/sprite_accessory/insect_type/fly
	name = "Common Fly"
	limbs_id = "fly"
	gender_specific = FALSE

/datum/sprite_accessory/insect_type/bee
	name = "Hoverfly"
	limbs_id = "bee"
	gender_specific = TRUE

/datum/sprite_accessory/ipc_chassis/mcgreyscale
	name = "Morpheus Cyberkinetics (Custom)"
	limbs_id = "mcgipc"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/ipc_chassis/bishopcyberkinetics
	name = "Bishop Cyberkinetics"
	limbs_id = "bshipc"

/datum/sprite_accessory/ipc_chassis/bishopcyberkinetics2
	name = "Bishop Cyberkinetics 2.0"
	limbs_id = "bs2ipc"

/datum/sprite_accessory/ipc_chassis/hephaestussindustries
	name = "Hephaestus Industries"
	limbs_id = "hsiipc"

/datum/sprite_accessory/ipc_chassis/hephaestussindustries2
	name = "Hephaestus Industries 2.0"
	limbs_id = "hi2ipc"

/datum/sprite_accessory/ipc_chassis/shellguardmunitions
	name = "Shellguard Munitions Standard Series"
	limbs_id = "sgmipc"

/datum/sprite_accessory/ipc_chassis/wardtakahashimanufacturing
	name = "Ward-Takahashi Manufacturing"
	limbs_id = "wtmipc"

/datum/sprite_accessory/ipc_chassis/xionmanufacturinggroup
	name = "Xion Manufacturing Group"
	limbs_id = "xmgipc"

/datum/sprite_accessory/ipc_chassis/xionmanufacturinggroup2
	name = "Xion Manufacturing Group 2.0"
	limbs_id = "xm2ipc"

/datum/sprite_accessory/ipc_chassis/zenghupharmaceuticals
	name = "Zeng-Hu Pharmaceuticals"
	limbs_id = "zhpipc"

//Psyphoza caps

/datum/sprite_accessory/psyphoza_cap
	icon = 'icons/mob/psyphoza_caps.dmi'
	color_src = MUTANT_COLOR

/datum/sprite_accessory/psyphoza_cap/wide
	name = "Portobello"
	icon_state = "wide"

/datum/sprite_accessory/psyphoza_cap/cup
	name = "Chanterelle"
	icon_state = "cup"

/datum/sprite_accessory/psyphoza_cap/round
	name = "Psilocybe"
	icon_state = "round"

/datum/sprite_accessory/psyphoza_cap/flat
	name = "Pleurotus"
	icon_state = "flat"

/datum/sprite_accessory/psyphoza_cap/string
	name = "Aseroe"
	icon_state = "string"

/datum/sprite_accessory/psyphoza_cap/fuzz
	name = "Enoki"
	icon_state = "fuzz"

/datum/sprite_accessory/psyphoza_cap/rizz
	name = "Verpa"
	icon_state = "rizz"

/datum/sprite_accessory/psyphoza_cap/brain
	name = "Laetiporus"
	icon_state = "brain"

/datum/sprite_accessory/psyphoza_cap/crown
	name = "Morel"
	icon_state = "crown"

/datum/sprite_accessory/psyphoza_cap/sponge
	name = "Helvella"
	icon_state = "sponge"

//dionae

/datum/sprite_accessory/diona_leaves
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_leaves/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_leaves/leaves
	name = "Diona Leaves"

/datum/sprite_accessory/diona_leaves/leaves/head
	name = "Diona Leaves"
	icon_state = "head"
/datum/sprite_accessory/diona_leaves/leaves/r_arm
	name = "Diona Leaves"
	icon_state = "r_arm"
/datum/sprite_accessory/diona_leaves/leaves/l_arm
	name = "Diona Leaves"
	icon_state = "l_arm"
/datum/sprite_accessory/diona_leaves/leaves/r_leg
	name = "Diona Leaves"
	icon_state = "r_leg"
/datum/sprite_accessory/diona_leaves/leaves/l_leg
	name = "Diona Leaves"
	icon_state = "l_leg"
/datum/sprite_accessory/diona_leaves/leaves/torso
	name = "Diona Leaves"
	icon_state = "chest"

/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_thorns
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_thorns/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_thorns/head
	name = "Diona Thorns (Head)"
	icon_state = "head"

/datum/sprite_accessory/diona_thorns/torso
	name = "Diona Thorns (Torso)"
	icon_state = "chest"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_flowers
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_flowers/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_flowers/head
	name = "Diona Flowers (Head)"
	icon_state = "head"

/datum/sprite_accessory/diona_flowers/torso
	name = "Diona Flowers (Torso)"
	icon_state = "chest"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_moss
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_moss/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_moss/torso
	name = "Diona Moss"
	icon_state = "chest"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_mushroom
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_mushroom/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_mushroom/head
	name = "Diona Mushroom"
	icon_state = "head"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_antennae
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_antennae/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_antennae/head
	name = "Diona Antennae"
	icon_state = "head"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_eyes
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_eyes/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_eyes/bug_eyes
	name = "Bug Eyes"
	icon_state = "bugeyes_head"

/datum/sprite_accessory/diona_eyes/human_eyes
	name = "Human Eyes"
	icon_state = "humaneyes_head"

/datum/sprite_accessory/diona_eyes/small_horns
	name = "Small Horns"
	icon_state = "smallhorns_head"

/datum/sprite_accessory/diona_eyes/horns
	name = "Horns"
	icon_state = "horns_head"

/datum/sprite_accessory/diona_eyes/treebeard
	name = "Treebeard"
	icon_state = "treebeard_head"

/datum/sprite_accessory/diona_eyes/tinyeye
	name = "Tiny Eye"
	icon_state = "tinyeye_head"

/datum/sprite_accessory/diona_eyes/eyebrow
	name = "Eyebrow"
	icon_state = "eyebrow_head"

/datum/sprite_accessory/diona_eyes/bullhorn
	name = "Bullhorn"
	icon_state = "bullhorn_head"

/datum/sprite_accessory/diona_eyes/mono_eye
	name = "Mono Eye"
	icon_state = "monoeye_head"

/datum/sprite_accessory/diona_eyes/trioptics
	name = "Trioptics"
	icon_state = "trioptics_head"

/datum/sprite_accessory/diona_eyes/lopsided
	name = "Lopsided"
	icon_state = "lopsided_head"

/datum/sprite_accessory/diona_eyes/helmethead
	name = "Helmethead"
	icon_state = "helmethead_head"

/datum/sprite_accessory/diona_eyes/eyestalk
	name = "Eyestalk"
	icon_state = "eyestalk_head"

/datum/sprite_accessory/diona_eyes/periscope
	name = "Periscope"
	icon_state = "periscope_head"

/datum/sprite_accessory/diona_eyes/glorp
	name = "Glorp"
	icon_state = "glorp_head"

/datum/sprite_accessory/diona_eyes/oak
	name = "Oak"
	icon_state = "oak_head"

/datum/sprite_accessory/diona_eyes/smallhorns
	name = "Small Horns"
	icon_state = "smallhorns_head"

/datum/sprite_accessory/diona_eyes/stump
	name = "Stump"
	icon_state = "stump_head"

/datum/sprite_accessory/diona_eyes/snout
	name = "Snout"
	icon_state = "snout_head"
/////////////////////////////////////////////////////
/datum/sprite_accessory/diona_pbody
	icon = 'icons/mob/diona_markings.dmi'
	color_src = null

/datum/sprite_accessory/diona_pbody/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/diona_pbody/pbody
	name = "P-Body"
	icon_state = "chest"
/datum/sprite_accessory/diona_pbody/blinking
	name = "Blinking P-Body"
	icon_state = "blinking_chest"
/////////////////////////////////////////////////////

//apids

/datum/sprite_accessory/apid_antenna
	icon = 'icons/mob/apid_accessories/apid_antenna.dmi'

/datum/sprite_accessory/apid_antenna/moth
	name = "Mothlike Antenna"
	icon_state = "moth"

/datum/sprite_accessory/apid_antenna/fluffy
	name = "Fluffy Antenna"
	icon_state = "fluffy"

/datum/sprite_accessory/apid_antenna/wavy
	name = "Wavy Antenna"
	icon_state = "wavy"

/datum/sprite_accessory/apid_antenna/slickback
	name = "Slickback Antenna"
	icon_state = "slickback"

/datum/sprite_accessory/apid_antenna/horns
	name = "Horned Antenna"
	icon_state = "horns"

/datum/sprite_accessory/apid_antenna/straight
	name = "Straight Antenna"
	icon_state = "straight"

/datum/sprite_accessory/apid_antenna/triangle
	name = "Triangle Antenna"
	icon_state = "triangle"

/datum/sprite_accessory/apid_antenna/electric
	name = "Electric Antenna"
	icon_state = "electric"

/datum/sprite_accessory/apid_antenna/leafy
	name = "Leafy Antenna"
	icon_state = "leafy"

/datum/sprite_accessory/apid_antenna/royal
	name = "Royal Antenna"
	icon_state = "royal"

/datum/sprite_accessory/apid_antenna/wisp
	name = "Wispy Antenna"
	icon_state = "wisp"

/datum/sprite_accessory/apid_antenna/plug
	name = "Plugged Antenna"
	icon_state = "plug"

/datum/sprite_accessory/apid_antenna/warrior
	name = "Warrior Antenna"
	icon_state = "warrior"

/datum/sprite_accessory/apid_antenna/sidelights
	name = "Sidelighted Antenna"
	icon_state = "sidelights"

/datum/sprite_accessory/apid_antenna/sprouts
	name = "Sprouting Antenna"
	icon_state = "sprouts"

/datum/sprite_accessory/apid_antenna/nubs
	name = "Nubby Antenna"
	icon_state = "nubs"

/datum/sprite_accessory/apid_antenna/ant
	name = "Antlike Antenna"
	icon_state = "ant"

/datum/sprite_accessory/apid_antenna/crooked
	name = "Crooked Antenna"
	icon_state = "crooked"

/datum/sprite_accessory/apid_antenna/curled
	name = "Curled Antenna"
	icon_state = "curled"

/datum/sprite_accessory/apid_antenna/snapped
	name = "Snapped Antenna"
	icon_state = "snapped"

/datum/sprite_accessory/apid_antenna/budding
	name = "Budding Antenna"
	icon_state = "budding"

/datum/sprite_accessory/apid_antenna/bumpers
	name = "Bumpery Antenna"
	icon_state = "bumpers"

/datum/sprite_accessory/apid_antenna/split
	name = "Split Antenna"
	icon_state = "split"

/datum/sprite_accessory/apid_stripes
	icon = 'icons/mob/apid_accessories/apid_body.dmi'
	gender_specific = TRUE

/datum/sprite_accessory/apid_stripes/none
	name = "No Stripes"
	icon_state = "none"

/datum/sprite_accessory/apid_stripes/full
	name = "Full Color"
	icon_state = "full"

/datum/sprite_accessory/apid_stripes/thick
	name = "Thick Stripes"
	icon_state = "thick"

/datum/sprite_accessory/apid_stripes/thin
	name = "Thin Stripes"
	icon_state = "thin"

/datum/sprite_accessory/apid_stripes/wasp
	name = "Wasp Stripes"
	icon_state = "wasp"

/datum/sprite_accessory/apid_stripes/arachnid
	name = "Arachnid Stripes"
	icon_state = "arachnid"

/datum/sprite_accessory/apid_headstripes
	icon = 'icons/mob/apid_accessories/apid_head.dmi'
	gender_specific = TRUE

/datum/sprite_accessory/apid_headstripes/none
	name = "No Headstripes"
	icon_state = "none"

/datum/sprite_accessory/apid_headstripes/full
	name = "Full Headcolor"
	icon_state = "full"

/datum/sprite_accessory/apid_headstripes/thick
	name = "Thick Headstripes"
	icon_state = "thick"

/datum/sprite_accessory/apid_headstripes/thin
	name = "Thin Headstripes"
	icon_state = "thin"

/datum/sprite_accessory/apid_headstripes/cap
	name = "Headstripe Cap"
	icon_state = "cap"

/datum/sprite_accessory/apid_headstripes/neck
	name = "Neck Headstripe"
	icon_state = "neck"


/datum/sprite_accessory/apid_headstripes/wasp
	name = "Wasp Headstripes"
	icon_state = "wasp"

/datum/sprite_accessory/apid_headstripes/arachnid
	name = "Arachnid Headstripes"
	icon_state = "arachnid"
