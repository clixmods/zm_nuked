#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_widows_wine;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

// Nuketown map features
#using scripts\zm\zm_nuked_perks; 
#using scripts\zm\classic_features\pack_a_punch_from_the_sky; 
#using scripts\zm\zm_nuketown_hd_amb;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#define ORANGE_EYE_FX    "frost_iceforge/orange_zombie_eyes"
#define BLUE_EYE_FX    "frost_iceforge/blue_zombie_eyes"
#precache( "client_fx", ORANGE_EYE_FX );
#precache( "client_fx", BLUE_EYE_FX );

function main()
{
	// Register clientfields
	clientfield::register( "world", "change_fog", VERSION_SHIP, 4, "int", &change_fog, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register("world", "change_eye_color", VERSION_SHIP, 1, "int", &setEyeClientField, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("world", "change_exposure_to_2", VERSION_SHIP, 1, "int", &SetExposureActive, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
	clientfield::register("world", "change_exposure_to_1", VERSION_SHIP, 1, "int", &SetExposureDisable, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);

	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function change_fog(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if ( newVal == 1 ) // normal
	{
		SetLitFogBank( localClientNum, -1, 0, -1 ); 
		SetWorldFogActiveBank( localClientNum, 1 ); 
	}
	if ( newVal == 2 ) // aftermath
	{
		SetLitFogBank( localClientNum, -1, 1, -1 ); 
		SetWorldFogActiveBank( localClientNum, 2 ); 
	}
	if ( newVal == 3 ) // dog
	{
		SetLitFogBank( localClientNum, -1, 2, -1 ); 
		SetWorldFogActiveBank( localClientNum, 4 ); 
	}
	if ( newVal == 4 ) // omega
	{
		SetLitFogBank( localClientNum, -1, 3, -1 ); 
		SetWorldFogActiveBank( localClientNum, 8 ); 
	}
}

function setEyeClientField( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if(newval==1)
    {
        set_eye_color();
    }
}

function set_eye_color()
{
    level._override_eye_fx = BLUE_EYE_FX; //Change "BLUE" to any of the other colors.
    level.zombie_eyeball_color_override = 2;
}

function SetExposureActive( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if(newval==1)
    {
        exposure_nuke();
    }
}

function SetExposureDisable( localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwasdemojump )
{
    if(newval==1)
    {
        exposure_nuke_disable();
    }
}

function exposure_nuke( localclientnum, newval )
{
     SetExposureActiveBank( localClientNum, 2 ); 
}

function exposure_nuke_disable( localclientnum, newval )
{
     SetExposureActiveBank( localClientNum, 1 ); 
}

