#define SUCCESSFUL_SPAWN 2
#define NOT_ENOUGH_PLAYERS 3
#define MAP_ERROR 4
#define WAITING_FOR_SOMETHING 5

#define EVENT_CANT_RUN 0
#define EVENT_READY 1
#define EVENT_CANCELLED 2
#define EVENT_INTERRUPTED 3

///Events that mess with or create artificial intelligences, such as vending machines and the AI itself
#define EVENT_CATEGORY_AI "AI issues"
///Events that spawn anomalies, which might be the source of anomaly cores
#define EVENT_CATEGORY_ANOMALIES "Anomalies"
///Events pertaining cargo, messages incoming to the station and job slots
#define EVENT_CATEGORY_BUREAUCRATIC "Bureaucratic"
///Events that cause breakages and malfunctions that could be fixed by engineers
#define EVENT_CATEGORY_ENGINEERING "Engineering"
///Events that spawn creatures with simple desires, such as to hunt
#define EVENT_CATEGORY_ENTITIES "Entities"
///Events that should have no harmful effects, and might be useful to the crew
#define EVENT_CATEGORY_FRIENDLY "Friendly"
///Events that affect the body and mind
#define EVENT_CATEGORY_HEALTH "Health"
///Events reserved for special occassions
#define EVENT_CATEGORY_HOLIDAY "Holiday"
///Events with enemy groups with a more complex plan
#define EVENT_CATEGORY_INVASION "Invasion"
///Events that summon meteors and other debris, and stationwide waves of harmful space weather
#define EVENT_CATEGORY_SPACE "Space Threats"
///Events summoned by a wizard
#define EVENT_CATEGORY_WIZARD "Wizard"
