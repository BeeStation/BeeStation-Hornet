//Global defines for most of the unmentionables.
//Be sure to update the min/max of these if you do change them.
//Measurements are in imperial units. Inches, feet, yards, miles. Tsp, tbsp, cups, quarts, gallons, etc

//HUD stuff
#define  ui_arousal "EAST-1:28,CENTER-4:8"//Below the health doll
#define ui_stamina "EAST-1:28,CENTER:17" // replacing internals button
#define ui_overridden_resist "EAST-3:24,SOUTH+1:7"
#define ui_combat_toggle "EAST-4:22,SOUTH:5"

//1:1 HUD layout stuff
#define ui_boxcraft "EAST-4:22,SOUTH+1:6"
#define ui_boxarea "EAST-4:6,SOUTH+1:6"
#define ui_boxlang "EAST-5:22,SOUTH+1:6"
#define ui_boxvore	"EAST-5:22,SOUTH+1:6"

//Filters
#define CIT_FILTER_STAMINACRIT filter(type="drop_shadow", x=0, y=0, size=-3, color="#04080F")

//organ defines
#define VAGINA_LAYER_INDEX		1
#define TESTICLES_LAYER_INDEX	2
#define GENITAL_LAYER_INDEX		3
#define PENIS_LAYER_INDEX		4

#define GENITAL_LAYER_INDEX_LENGTH 4 //keep it updated with each new index added, thanks.

//genital flags
#define GENITAL_BLACKLISTED		(1<<0) //for genitals that shouldn't be added to GLOB.genitals_list.
#define GENITAL_INTERNAL		(1<<1)
#define GENITAL_HIDDEN			(1<<2)
#define GENITAL_THROUGH_CLOTHES	(1<<3)
#define GENITAL_FUID_PRODUCTION	(1<<4)
#define CAN_MASTURBATE_WITH		(1<<5)
#define MASTURBATE_LINKED_ORGAN	(1<<6) //used to pass our mission to the linked organ
#define CAN_CLIMAX_WITH			(1<<7)

#define COCK_SIZE_MIN		1
#define COCK_SIZE_MAX		20

#define COCK_GIRTH_RATIO_MAX		1.25
#define COCK_GIRTH_RATIO_DEF		0.75
#define COCK_GIRTH_RATIO_MIN		0.5

#define KNOT_GIRTH_RATIO_MAX		3
#define KNOT_GIRTH_RATIO_DEF		2.1
#define KNOT_GIRTH_RATIO_MIN		1.25

#define BALLS_VOLUME_BASE	25
#define BALLS_VOLUME_MULT	1

#define BALLS_SIZE_MIN		1
#define BALLS_SIZE_DEF		2
#define BALLS_SIZE_MAX		3

#define BALLS_SACK_SIZE_MIN 1
#define BALLS_SACK_SIZE_DEF	8
#define BALLS_SACK_SIZE_MAX 40

#define CUM_RATE			2 // holy shit what a really shitty define name - relates to units per arbitrary measure of time?
#define CUM_RATE_MULT		1
#define CUM_EFFICIENCY		1 //amount of nutrition required per life()

#define EGG_GIRTH_MIN		1//inches
#define EGG_GIRTH_DEF		6
#define EGG_GIRTH_MAX		16

#define BREASTS_VOLUME_BASE	50	//base volume for the reagents in the breasts, multiplied by the size then multiplier. 50u for A cups, 850u for HH cups.
#define BREASTS_VOLUME_MULT	1	//global multiplier for breast volume.

#define MILK_RATE			5
#define MILK_RATE_MULT		1
#define MILK_EFFICIENCY		1

//Individual logging define
#define INDIVIDUAL_LOOC_LOG "LOOC log"

#define ADMIN_MARKREAD(client) "(<a href='?_src_=holder;markedread=\ref[client]'>MARK READ</a>)"//marks an adminhelp as read and under investigation
#define ADMIN_IC(client) "(<a href='?_src_=holder;icissue=\ref[client]'>IC</a>)"//marks and adminhelp as an IC issue
#define ADMIN_REJECT(client) "(<a href='?_src_=holder;rejectadminhelp=\ref[client]'>REJT</a>)"//Rejects an adminhelp for being unclear or otherwise unhelpful. resets their adminhelp timer

//Citadel istypes
#define isgenital(A) (istype(A, /obj/item/organ/genital))

#define isborer(A) (istype(A, /mob/living/simple_animal/borer))

#define CITADEL_MENTOR_OOC_COLOUR "#224724"

//xenobio console upgrade stuff
#define XENOBIO_UPGRADE_MONKEYS				1
#define XENOBIO_UPGRADE_SLIMEBASIC			2
#define XENOBIO_UPGRADE_SLIMEADV			4

//stamina stuff
#define STAMINA_SOFTCRIT					100 //softcrit for stamina damage. prevents standing up, prevents performing actions that cost stamina, etc, but doesn't force a rest or stop movement
#define STAMINA_CRIT						140 //crit for stamina damage. forces a rest, and stops movement until stamina goes back to stamina softcrit
#define STAMINA_SOFTCRIT_TRADITIONAL		0	//same as STAMINA_SOFTCRIT except for the more traditional health calculations
#define STAMINA_CRIT_TRADITIONAL			-40 //ditto, but for STAMINA_CRIT

#define CRAWLUNDER_DELAY							30 //Delay for crawling under a standing mob

//Citadel toggles because bitflag memes
#define MEDIHOUND_SLEEPER	(1<<0)
#define EATING_NOISES		(1<<1)
#define DIGESTION_NOISES	(1<<2)
#define BREAST_ENLARGEMENT	(1<<3)
#define PENIS_ENLARGEMENT	(1<<4)
#define FORCED_FEM			(1<<5)
#define FORCED_MASC			(1<<6)
#define HYPNO				(1<<7)
#define NEVER_HYPNO			(1<<8)
#define NO_APHRO			(1<<9)
#define NO_ASS_SLAP			(1<<10)
#define BIMBOFICATION		(1<<11)

#define TOGGLES_CITADEL (EATING_NOISES|DIGESTION_NOISES|BREAST_ENLARGEMENT|PENIS_ENLARGEMENT)

//component stuff
#define COMSIG_COMBAT_TOGGLED "combatmode_toggled" //called by combat mode toggle on all equipped items. args: (mob/user, combatmode)

#define COMSIG_VORE_TOGGLED "voremode_toggled" // totally not copypasta

//belly sound pref things
#define NORMIE_HEARCHECK 4
