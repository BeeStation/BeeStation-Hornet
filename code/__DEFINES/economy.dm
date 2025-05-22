/// Number of paychecks jobs start with at the creation of a new bank account for a player (So at shift-start or game join, but not a blank new account.)
#define STARTING_PAYCHECKS 5

//Current Paycheck values. Altering these changes both the cost of items meant for each paygrade, as well as the passive/starting income of each job.
///Default paygrade for the Unassigned Job/Unpaid job assignments.
#define PAYCHECK_ZERO 0
///Paygrade for Prisoners and Assistants.
#define PAYCHECK_LOWER 25
///Paygrade for all regular crew not belonging to PAYGRADE_LOWER or PAYGRADE_COMMAND.
#define PAYCHECK_CREW 50
///Paygrade for Heads of Staff.
#define PAYCHECK_COMMAND 100

// given from nanotrasen to heads
#define PAYCHECK_COMMAND_NT PAYCHECK_COMMAND * 0.2
// given from department budget to heads
#define PAYCHECK_COMMAND_DEPT PAYCHECK_COMMAND * 0.8

/**
  * Note: The current intention for crazy amount of money to VIP is that they can be a rich shitter
  * or be targeted by antags for their money - oh, my, being rich isn't always good.
  * The first buff to their money was to 2,000 credits. Nerf is fine if you think it's necessary,
  * but if you decrease their payment too much, they'll be no longer interested.
  * I recommend to nerf their gimmick spawn chance instead.
***/
#define PAYCHECK_VIP 2000

//How many credits a player is charged if they print something from a departmental lathe they shouldn't have access to.
//#define LATHE_TAX 10
//How much POWER a borg's cell is taxed if they print something from a departmental lathe.
//#define SILICON_LATHE_TAX 2000

#define STATION_TARGET_BUFFER 25

#define PAYCHECK_WELFARE 5 //NEETbucks


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
#define NO_FREEBIES 0 // used for a vendor selling nothing for free

//Defines that set what kind of civilian bounties should be applied mid-round.
#define CIV_JOB_BASIC 1
#define CIV_JOB_ROBO 2
#define CIV_JOB_CHEF 3
#define CIV_JOB_SEC 4
#define CIV_JOB_DRINK 5
#define CIV_JOB_CHEM 6
#define CIV_JOB_VIRO 7
#define CIV_JOB_SCI 8
#define CIV_JOB_ENG 9
#define CIV_JOB_MINE 10
#define CIV_JOB_MED 11
#define CIV_JOB_GROW 12
#define CIV_JOB_ATMOS 13
#define CIV_JOB_RANDOM 14

//By how much should the station's inflation value be multiplied by when dividing the civilian bounty's reward?
#define BOUNTY_MULTIPLIER 10

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

/// How much mail the Economy SS will create per minute, regardless of firing time.
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
