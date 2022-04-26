//Xenoartifact defines
//Activator modifiers. Used in context of the difficulty of a task.
#define EASY 1
#define NORMAL 1.8
#define HARD 2.4
#define COMBAT 2.8 //Players who engage in combat are given an extra reward for the consequences of doing so.

//Material defines. Used for characteristic generation.
#define BLUESPACE "#1e7cff" //Silly toys
#define PLASMA "#ff00c8" //Associated weapons
#define URANIUM "#00ff0d" //Broken Enigmas
#define BANANIUM "#ffd900" //Wildcard, may god have mercy. Was originally called BANANIUM, changed for localisation.
#define DEBUGIUM "#ff4800"

//Technically not materials, still used for xenoartifact related content
#define XENOSELLERNAMES list("Borov", "Ivantsov", "Petrenko", "Voronin", "Kitsenko", "Plichko", "Sergei", "Kruglov", "Sakharov", "Kalugin", "Semenov", "Vasiliev", "Pavlik", "Tolik", "Kuznetsov", "Sidorovich", "Strelok")
#define XENOSELLERDIAL list("Hello, Commrade. I think I have something that might interest you.","Hello, Friend. I think I have something you might be interested in.","Commrade, I can offer you only this.","For you, my Friend, I offer this.", "Commrade, this thing killed my Babushka, take it.","Friend, you want?","My buddy thinks I could sell this.","I'm pretty sure this took several years off my life, take it.","This was hard to find, but you can have it.","I found this one deep in the zone, it was a risk to get.")

//Also not materials but also related
#define LIT 1
#define TICK 2

/*
    It's signals, there here. These must all be ordered the same way, I think? The existing signals aren't all concreate.
    We use different types, that do the same thing, so activators can just define what types they want and avoid coding anything else.
*/
#define XENOA_INTERACT "xenoa_interact" //This goes for all (item, user, target)
#define XENOA_THROW_IMPACT "xenoa_interact"
#define XENOA_ATTACK "xenoa_attack"
#define XENOA_SIGNAL "xenoa_signal"
#define XENOA_ATTACKBY "xenoa_attackby" //defining my own so I dont fuck anything up with COMSIG_PARENT_ATTACKBY
