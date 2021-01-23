#define STYLE_STANDARD 1
#define STYLE_BLUESPACE 2
#define STYLE_CENTCOM 3
#define STYLE_SYNDICATE 4
#define STYLE_BLUE 5
#define STYLE_CULT 6
#define STYLE_MISSILE 7
#define STYLE_RED_MISSILE 8
#define STYLE_BOX 9
#define STYLE_HONK 10
#define STYLE_FRUIT 11
#define STYLE_INVISIBLE 12
#define STYLE_GONDOLA 13
#define STYLE_SEETHROUGH 14

#define POD_ICON_STATE 1
#define POD_NAME 2
#define POD_DESC 3

#define POD_STYLES list(\
    list("supplypod", "supply pod", "A Nanotrasen supply drop pod."),\
    list("bluespacepod", "bluespace supply pod" , "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."),\
    list("centcompod", "\improper Centcom supply pod", "A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to Centcom after delivery."),\
    list("syndiepod", "blood-red supply pod", "A dark, intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this."),\
    list("squadpod", "\improper MK. II supply pod", "A Nanotrasen supply pod. This one has been marked the markings of some sort of elite strike team."),\
    list("cultpod", "bloody supply pod", "A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes."),\
    list("missilepod", "cruise missile", "A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."),\
    list("smissilepod", "\improper Syndicate cruise missile", "A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."),\
    list("boxpod", "\improper Aussec supply crate", "An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side."),\
    list("honkpod", "\improper HONK pod", "A brightly-colored supply pod. It likely originated from the Clown Federation."),\
    list("fruitpod", "\improper Orange", "An angry orange."),\
    list("", "\improper S.T.E.A.L.T.H. pod MKVII", "A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?"),\
    list("gondolapod", "gondola", "The silent walker. This one seems to be part of a delivery agency."),\
    list("", "", "")\
)

#define CONTRABAND_SYNDIE list(\
	/obj/item/poster/random_contraband,\
	/obj/item/reagent_containers/food/snacks/grown/cannabis,\
	/obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow,\
	/obj/item/reagent_containers/food/snacks/grown/cannabis/white,\
	/obj/item/storage/pill_bottle/zoom,\
	/obj/item/storage/pill_bottle/happy,\
	/obj/item/storage/pill_bottle/lsd,\
	/obj/item/storage/pill_bottle/aranesp,\
	/obj/item/storage/pill_bottle/stimulant,\
	/obj/item/toy/cards/deck/syndicate,\
	/obj/item/reagent_containers/food/drinks/bottle/absinthe,\
	/obj/item/clothing/under/syndicate/tacticool,\
	/obj/item/storage/fancy/cigarettes/cigpack_syndicate,\
	/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,\
	/obj/item/clothing/mask/gas/syndicate,\
	/obj/item/clothing/neck/necklace/dope,\
	/obj/item/vending_refill/donksoft\
)

#define CONTRABAND_PRISON list(\
	/obj/item/clothing/mask/cigarette/space_cigarette,\
	/obj/item/clothing/mask/cigarette/robust,\
	/obj/item/clothing/mask/cigarette/carp,\
	/obj/item/clothing/mask/cigarette/uplift,\
	/obj/item/clothing/mask/cigarette/dromedary,\
	/obj/item/clothing/mask/cigarette/robustgold,\
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,\
	/obj/item/storage/fancy/cigarettes,\
	/obj/item/clothing/mask/cigarette/rollie/cannabis,\
	/obj/item/toy/crayon/spraycan,\
	/obj/item/crowbar,\
	/obj/item/restraints/handcuffs/cable/zipties,\
	/obj/item/restraints/handcuffs,\
	/obj/item/radio/off,\
	/obj/item/reagent_containers/syringe/contraband/space_drugs,\
	/obj/item/reagent_containers/syringe/contraband/krokodil,\
	/obj/item/reagent_containers/syringe/contraband/crank,\
	/obj/item/reagent_containers/syringe/contraband/methamphetamine,\
	/obj/item/reagent_containers/syringe/contraband/bath_salts,\
	/obj/item/reagent_containers/syringe/contraband/fentanyl,\
	/obj/item/reagent_containers/syringe/contraband/morphine,\
	/obj/item/reagent_containers/food/drinks/beer,\
	/obj/item/reagent_containers/food/drinks/bottle/whiskey,\
	/obj/item/grenade/smokebomb,\
	/obj/item/flashlight/seclite,\
	/obj/item/melee/shank,\
	/obj/item/coin/arcade_token,\
	/obj/item/kitchen/knife/carrotshiv,\
	/obj/item/storage/pill_bottle/zoom,\
	/obj/item/storage/pill_bottle/happy,\
	/obj/item/storage/pill_bottle/lsd,\
	/obj/item/storage/pill_bottle/aranesp,\
	/obj/item/storage/pill_bottle/stimulant,\
	/obj/item/storage/pill_bottle/psicodine,\
	/obj/item/poster/random_contraband\
)