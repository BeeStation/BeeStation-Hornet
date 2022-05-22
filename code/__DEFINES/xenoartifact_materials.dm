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
#define PROCESS_TYPE_LIT "is_lit" //Process type
#define PROCESS_TYPE_TICK "is_tick"

#define XENOA_DP 120 //Discovery point reward

#define XENOA_MAX_VENDORS 8 //Max vendors / buyers in each catergory

#define XENOA_ACTIVATORS subtypesof(/datum/xenoartifact_trait/activator) //traits types, referenced for generation
#define XENOA_MINORS subtypesof(/datum/xenoartifact_trait/minor)
#define XENOA_MAJORS subtypesof(/datum/xenoartifact_trait/major)
#define XENOA_MALFS subtypesof(/datum/xenoartifact_trait/malfunction)
