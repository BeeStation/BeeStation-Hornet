// /obj/item signals for economy
///called before an item is sold by the exports system.
#define COMSIG_ITEM_PRE_EXPORT "item_pre_sold"
	/// Stops the export from calling sell_object() on the item, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT (1<<0)
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_EXPORTED "item_sold"
	/// Stops the export from adding the export information to the report, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT_REPORT (1<<0)
///called when a wrapped up item is opened by hand
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"

///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
