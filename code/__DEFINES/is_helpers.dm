// simple is_type and similar inline helpers

#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

/// Within given range, but not counting z-levels
#define IN_GIVEN_RANGE(source, other, given_range) (get_dist(source, other) <= given_range && (get_step(source, 0)?:z) == (get_step(other, 0)?:z))

#define isatom(A) (isloc(A))

#define isdatum(thing) (istype(thing, /datum))

#define isweakref(D) (istype(D, /datum/weakref))

#define isimage(thing) (istype(thing, /image))

GLOBAL_VAR_INIT(magic_appearance_detecting_image, new /image) // appearances are awful to detect safely, but this seems to be the best way ~ninjanomnom
#define isappearance(thing) (!isimage(thing) && !ispath(thing) && istype(GLOB.magic_appearance_detecting_image, thing))

// The filters list has the same ref type id as a filter, but isnt one and also isnt a list, so we have to check if the thing has Cut() instead
GLOBAL_VAR_INIT(refid_filter, TYPEID(filter(type="angular_blur")))
#define isfilter(thing) (!islist(thing) && hascall(thing, "Cut") && TYPEID(thing) == GLOB.refid_filter)

GLOBAL_DATUM_INIT(regex_rgb_text, /regex, regex(@"^#?(([0-9a-fA-F]{8})|([0-9a-fA-F]{6})|([0-9a-fA-F]{3}))$"))
#define iscolortext(thing) (istext(thing) && GLOB.regex_rgb_text.Find(thing))

// simple check whether or not a player is a guest using their key
#define IS_GUEST_KEY(key) (findtextEx(key, "Guest-", 1, 7))
/// use client.logged_in where possible
#define IS_PREAUTH_KEY(key) (findtextEx(key, "Guest-preauth", 1, 14))
/// use client.logged_in where possible
#define IS_PREAUTH_CKEY(key) (findtextEx(key, "guestpreauth", 1, 13))

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/open/space,
	/turf/open/chasm,
	/turf/open/lava,
	/turf/open/water,
	/turf/open/openspace,
)))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))

#define isopenturf(A) (istype(A, /turf/open))

#define istransitturf(A) (istype(A, /turf/open/space/transit))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isanyfloor(A) (isfloorturf(A) || isindestructiblefloor(A))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/closed/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/lava))

#define ischasm(A) (istype(A, /turf/open/chasm))

#define isplatingturf(A) (istype(A, /turf/open/floor/plating))

#define istransparentturf(A) (TURF_IS_MIMICKING(A))

#define isopenspace(A) (istype(A, /turf/open/openspace))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define ishumantesting(A) (istype(A, /mob/living/carbon/human/consistent) || istype(A, /mob/living/carbon/human/dummy))

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define isashwalker(A) (is_species(A, /datum/species/lizard/ashwalker))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define isdiona(A) (is_species(A, /datum/species/diona))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isslimeperson(A) (is_species(A, /datum/species/oozeling/slime))
#define isluminescent(A) (is_species(A, /datum/species/oozeling/luminescent))
#define isstargazer(A) (is_species(A, /datum/species/oozeling/stargazer))
#define isoozeling(A) (is_species(A, /datum/species/oozeling))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define isshadow(A) (is_species(A, /datum/species/shadow))
#define isblessedshadow(A) (is_species(A, /datum/species/shadow/blessed))
#define isnightmare(A) (is_species(A, /datum/species/shadow/nightmare))
#define ismoth(A) (is_species(A, /datum/species/moth))
#define ishumanbasic(A) (is_species(A, /datum/species/human) && !is_species(A, /datum/species/human/krokodil_addict))
#define iscatperson(A) (is_species(A, /datum/species/human/felinid) )
#define isethereal(A) (is_species(A, /datum/species/ethereal))
#define isipc(A) (is_species(A, /datum/species/ipc))
#define isapid(A) (is_species(A, /datum/species/apid))
#define isandroid(A) (is_species(A, /datum/species/android))
#define ispsyphoza(A) (is_species(A, /datum/species/psyphoza))

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid) || istype(A, /mob/living/simple_animal/hostile/alien))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienroyal(A) (istype(A, /mob/living/carbon/alien/humanoid/royal))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/royal/queen))

#define isnymph(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/nymph))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define issiliconoradminghost(A) (istype(A, /mob/living/silicon) || IsAdminGhost(A))

#define iscyborg(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

// basic mobs

#define isbasicmob(A) (istype(A, /mob/living/basic))

/// returns whether or not the atom is either a basic mob OR simple animal
#define isanimal_or_basicmob(A) (istype(A, /mob/living/simple_animal) || istype(A, /mob/living/basic))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isrevenant(A) (istype(A, /mob/living/simple_animal/revenant))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/basic/mouse))

#define isslime(A) (istype(A, /mob/living/simple_animal/slime))

#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define isdog(A) (istype(A, /mob/living/basic/pet/dog))

#define iscorgi(A) (istype(A, /mob/living/basic/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isswarmer(A) (istype(A, /mob/living/simple_animal/hostile/swarmer))

#define isholopara(A) (istype(A, /mob/living/simple_animal/hostile/holoparasite))

#define isclockmob(A) (istype(A, /mob/living/simple_animal/hostile/clockwork))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define ismegafauna(A) (istype(A, /mob/living/simple_animal/hostile/megafauna))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

#define iseminence(A) (istype(A, /mob/living/simple_animal/eminence))

#define iscogscarab(A) (istype(A, /mob/living/simple_animal/drone/cogscarab))

#define isfaithless(A) (istype(A, /mob/living/simple_animal/hostile/faithless))

#define ismimite(A) (istype(A, /mob/living/simple_animal/hostile/mimite))

#define isspider(A) (istype(A, /mob/living/simple_animal/hostile/poison/giant_spider))

//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define iscameramob(A) (istype(A, /mob/camera))

#define isaicamera(A) (istype(A, /mob/camera/ai_eye))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isstack(A) (istype(A, /obj/item/stack))

#define isgrenade(A) (istype(A, /obj/item/grenade))

#define islandmine(A) (istype(A, /obj/effect/mine))

#define isammocasing(A) (istype(A, /obj/item/ammo_casing))

#define isidcard(I) (istype(I, /obj/item/card/id))

#define isstructure(A) (istype(A, /obj/structure))

#define ismachinery(A) (istype(A, /obj/machinery))

#define isvehicle(A) (istype(A, /obj/vehicle))

#define ismecha(A) (istype(A, /obj/vehicle/sealed/mecha))

#define ismopable(A) (A && (A.layer <= FLOOR_CLEAN_LAYER)) //If something can be cleaned by floor-cleaning devices such as mops or clean bots

#define isorgan(A) (istype(A, /obj/item/organ))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define ispickedupmob(A) (istype(A, /obj/item/mob_holder)) // Checks if clothing item is actually a held mob

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/pen,
	/obj/item/screwdriver,
	/obj/item/reagent_containers/syringe,
	/obj/item/kitchen/fork,
)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

#define isprojectile(A) (istype(A, /obj/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

#define isammobox(A) (istype(A, /obj/item/ammo_box))

#define is_reagent_container(O) (istype(O, /obj/item/reagent_containers))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass,
)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

#define iseffect(O) (istype(O, /obj/effect))

#define isholoeffect(O) (istype(O, /obj/effect/holodeck_effect))

#define isblobmonster(O) (istype(O, /mob/living/simple_animal/hostile/blob))

#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))

#define isbook(O) (is_type_in_typecache(O, GLOB.book_types))

GLOBAL_LIST_INIT(book_types, typecacheof(list(
	/obj/item/book,
	/obj/item/spellbook,
	/obj/item/storage/book,
)))

/// isnum() returns TRUE for NaN. Also, NaN != NaN. Checkmate, BYOND.
#define isnan(x) ( (x) != (x) )

#define isinf(x) (isnum((x)) && (((x) == SYSTEM_TYPE_INFINITY) || ((x) == -SYSTEM_TYPE_INFINITY)))

#define isProbablyWallMounted(O) (O.pixel_x > 20 || O.pixel_x < -20 || O.pixel_y > 20 || O.pixel_y < -20)

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) )

#define iscash(A) (istype(A, /obj/item/coin) || istype(A, /obj/item/stack/spacecash) || istype(A, /obj/item/holochip))

// Jobs
#define is_job(job_type)  (istype(job_type, /datum/job))
#define is_assistant_job(job_type) (istype(job_type, /datum/job/assistant))
#define is_bartender_job(job_type) (istype(job_type, /datum/job/bartender))
#define is_captain_job(job_type) (istype(job_type, /datum/job/captain))
#define is_chaplain_job(job_type) (istype(job_type, /datum/job/chaplain))
#define is_clown_job(job_type) (istype(job_type, /datum/job/clown))
#define is_detective_job(job_type) (istype(job_type, /datum/job/detective))
#define is_scientist_job(job_type) (istype(job_type, /datum/job/scientist))
#define is_security_officer_job(job_type) (istype(job_type, /datum/job/security_officer))
#define is_research_director_job(job_type) (istype(job_type, /datum/job/research_director))
#define is_unassigned_job(job_type) (istype(job_type, /datum/job/unassigned))
