#define STARTING_PAYCHECKS 5

//Current Paycheck values. Altering these changes both the cost of items meant for each paygrade, as well as the passive/starting income of each job.
///Default paygrade for the Unassigned Job/Unpaid job assignments.
#define PAYCHECK_ZERO 0
///Paygrade for Prisoners and Assistants.
#define PAYCHECK_LOWER 20
///Paygrade for all regular crew not belonging to PAYGRADE_LOWER or PAYGRADE_COMMAND.
#define PAYCHECK_CREW 40

// given from nanotrasen to heads
#define PAYCHECK_COMMAND_NT 10
// given from department budget
#define PAYCHECK_COMMAND_DEPT 70
///Paygrade for Heads of Staff.
#define PAYCHECK_COMMAND 80


#define PAYCHECK_VIP 1000
/*	Note: The current intention for crazy amount of money to VIP is that they can be a rich shitter
			or be targeted by antags for their money - oh, my, being rich isn't always good.
			The first buff to their money was to 2,000 credits. Nerf is fine if you think it's necessary,
			but if you decrease their payment too much, they'll be no longer interested.
			I recommend to nerf their gimmick spawn chance instead. */


#define PAYCHECK_WELFARE 10 //NEETbucks

// Standardized price multipliers for vending machines and economy
//Extremely cheap, worth very little
#define MULTIPLIER_ULTRA_LOW 0.4
/// Very cheap, e.g. basic snacks, low-tier items
#define MULTIPLIER_VERY_LOW 0.5
/// Discounted
#define MULTIPLIER_LOW 0.7
/// Slightly more affordable
#define MULTIPLIER_SUBSTANDARD 0.85
/// Normal price
#define MULTIPLIER_STANDARD 1
/// Slightly expensive
#define MULTIPLIER_HIGH 1.2
/// Premium items
#define MULTIPLIER_PREMIUM 1.5
/// Luxury/rare items
#define MULTIPLIER_LUXURY 3
/// Very rare, exclusive, or high-value items
#define MULTIPLIER_EXCLUSIVE 4.5
/// Big
#define MULTIPLIER_COMMAND 6


#define EXPORT_PRICE_WEAPON_TRIVIAL CARGO_CRATE_VALUE * 0.10
#define EXPORT_PRICE_WEAPON_LOW CARGO_CRATE_VALUE * 0.5
#define EXPORT_PRICE_WEAPON_STANDARD CARGO_CRATE_VALUE
#define EXPORT_PRICE_WEAPON_HIGH CARGO_CRATE_VALUE * 1.5


// Usage example:
// extra_price = PAYCHECK_COMMAND * MULTIPLIER_LOW
// default_price = PAYCHECK_CREW * MULTIPLIER_STANDARD
// extra_price = PAYCHECK_COMMAND * MULTIPLIER_PREMIUM

/// NT's Tax rate - Currently applies to vending machine sales
#define TAX_RATE 0.5

/// Economy multiplier. This controls (or hopefully will control) the whole economy as a whole
#define ECONOMY_MULTIPLIER 1	// Currently applies to automatic item pricing

/// This markup is applied to vendor prices and vendor prices only (DOES NOT APPLY TO PREMIUM PRICE)
#define PRICE_MARKUP 2

/// Defines an Item that is contraband
#define TRADE_CONTRABAND (1 << 0)
/// Defines Items that can not be sold
#define TRADE_NOT_SELLABLE (1 << 1)
/// Defines items that, if unsold will be deleted instead of being returned
#define TRADE_DELETE_UNSOLD (1 << 2)

#define NON_STATION_BUDGET_BASE rand(8888888, 11111111)
#define BUDGET_RATIO_TYPE_SINGLE 1 // For Service & Civilian budget
#define BUDGET_RATIO_TYPE_DOUBLE 2 // and for the rest

#define ACCOUNT_CIV_ID "Civilian"
#define ACCOUNT_CIV_NAME "Civil Budget"
#define ACCOUNT_SRV_ID "Service"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR_ID "Cargo"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SCI_ID "Science"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_ENG_ID "Engineering"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_MED_ID "Medical"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SEC_ID "Security"
#define ACCOUNT_SEC_NAME "Defense Budget"
#define ACCOUNT_COM_ID "Command"
#define ACCOUNT_COM_NAME "Nanotrasen Commands' Quality ＆ Appearance Maintenance Budget"
#define ACCOUNT_VIP_ID "VIP"
#define ACCOUNT_VIP_NAME "Nanotrasen VIP Expense Account Budget"
#define ACCOUNT_NEET_ID "Welfare"
#define ACCOUNT_NEET_NAME "Space Nations Welfare"
#define ACCOUNT_GOLEM_ID "Golem"
#define ACCOUNT_GOLEM_NAME "Shared Mining Account"


#define ACCOUNT_ALL_NAME "United Station Budget" // for negative station trait - united budget

// If a vending machine matches its department flag with your bank account's, it gets free.
#define ACCOUNT_COM_BITFLAG (1<<0) // for Commander only vendor items (i.e. HoP cartridge vendor)
#define ACCOUNT_CIV_BITFLAG (1<<1)
#define ACCOUNT_SRV_BITFLAG (1<<2)
#define ACCOUNT_CAR_BITFLAG (1<<3)
#define ACCOUNT_SCI_BITFLAG (1<<4)
#define ACCOUNT_ENG_BITFLAG (1<<5)
#define ACCOUNT_MED_BITFLAG (1<<6)
#define ACCOUNT_SEC_BITFLAG (1<<7)
#define ACCOUNT_VIP_BITFLAG (1<<8) // for VIP only vendor items. currently not used.
// this should use the same bitflag values in `\_DEFINES\jobs.dm` to match.
// It's true that bitflags shouldn't be separated in two DEFINES if these are same, but just in case the system can be devided, it's remained separated.

/// How much mail the Economy SS can create per minute, regardless of firing time.
#define MAX_MAIL_PER_MINUTE 1
/// Probability of using letters of envelope sprites on all letters.
#define FULL_CRATE_LETTER_ODDS 70
/// Max amount of mail that can be queued
#define MAX_MAIL_LIMIT 12
/// Amount of mail required before a mail crate spawns
#define MAIL_REQUIRED_BEFORE_SPAWN 6

/// used for custom_currency
#define ACCOUNT_CURRENCY_MINING "mining points"
#define ACCOUNT_CURRENCY_EXPLO "exploration points"

//These defines are to be used to with the payment component, determines which lines will be used during a transaction. If in doubt, go with clinical.
#define PAYMENT_CLINICAL "clinical"
#define PAYMENT_FRIENDLY "friendly"
#define PAYMENT_ANGRY "angry"
