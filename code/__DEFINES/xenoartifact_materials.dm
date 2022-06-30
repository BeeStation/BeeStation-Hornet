//Xenoartifact defines
//Material defines. Used for characteristic generation
///Silly toys
#define XENOA_BLUESPACE "#1e7cff"
///Associated weapons
#define XENOA_PLASMA "#ff00c8"
///Broken Enigmas
#define XENOA_URANIUM "#00ff0d"
///Wildcard, may god have mercy
#define XENOA_BANANIUM "#ffd900"
#define XENOA_DEBUGIUM "#ff4800"

//Technically not materials, still used for xenoartifact related content
#define XENOA_SELLER_NAMES list("Borov", "Ivantsov", "Petrenko", "Voronin", "Kitsenko", "Plichko", "Sergei", "Kruglov", "Sakharov", "Kalugin", "Semenov", "Vasiliev", "Pavlik", "Tolik", "Kuznetsov", "Sidorovich", "Strelok")
#define XENOA_SELLER_DIAL list("Hello, Commrade. I think I have something that might interest you.","Hello, Friend. I think I have something you might be interested in.","Commrade, I can offer you only this.","For you, my Friend, I offer this.", "Commrade, this thing killed my Babushka, take it.","Friend, you want?","My buddy thinks I could sell this.","I'm pretty sure this took several years off my life, take it.","This was hard to find, but you can have it.","I found this one deep in the zone, it was a risk to get.")

//Also not materials but also related
///Process type on burn
#define PROCESS_TYPE_LIT "is_lit"
///Process type on ticking
#define PROCESS_TYPE_TICK "is_tick"

///Discovery point reward
#define XENOA_DP 200

///Max vendors / buyers in each catergory
#define XENOA_MAX_VENDORS 8

///traits types, referenced for generation
#define XENOA_ACTIVATORS compile_artifact_weights(/datum/xenoartifact_trait/activator)
#define XENOA_MINORS compile_artifact_weights(/datum/xenoartifact_trait/minor)
#define XENOA_MAJORS compile_artifact_weights(/datum/xenoartifact_trait/major)
#define XENOA_MALFS compile_artifact_weights(/datum/xenoartifact_trait/malfunction)

//Specific trait defines
///Bear limit
#define XENOA_MAX_BEARS 3
///Max targets on expansive
#define XENOA_MAX_TARGETS 10
///Tick chance to untick
#define XENOA_TICK_CANCEL_PROB 13

///Chance to avoid target if wearing bomb suit
#define XENOA_DEFLECT_CHANCE 45
