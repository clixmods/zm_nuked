#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

// Nuketown map features
#using scripts\zm\zm_nuked_perks; 
#using scripts\zm\classic_features\clock_nuked; 
#using scripts\zm\classic_features\mannequins; 
#using scripts\zm\classic_features\ee_music; 
#using scripts\zm\classic_features\nuketown_panneau;
#using scripts\zm\classic_features\vox_transmission; 
#using scripts\zm\classic_features\pack_a_punch_from_the_sky; 
#using scripts\zm\zm_nuketown_hd_amb;

// Nuketown weapons
#using scripts\zm\_hb21_zm_weap_galvaknuckles;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	zm_usermap::main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func = &usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
}

function usermap_test_zone_init()
{
	// Start zone
	zm_zonemgr::add_adjacent_zone( "start_zone", "house1_zone", "enter_house1" );
	zm_zonemgr::add_adjacent_zone( "start_zone", "house2_zone", "enter_house2" );
    
	// X House
	zm_zonemgr::add_adjacent_zone( "house1_zone", "house1_out_zone", "enter_house1_out" );
	zm_zonemgr::add_adjacent_zone( "house1_zone", "house1_out_zone", "enter_etage_house1" );
    zm_zonemgr::add_adjacent_zone( "house1_out_zone", "etage_house1_zone", "enter_etage_house1" );
	zm_zonemgr::add_adjacent_zone( "house1_zone", "etage_house1_zone", "enter_etage_house1" );

	// X House
	zm_zonemgr::add_adjacent_zone( "house2_zone", "house2_out_zone", "enter_out_house2" );
	zm_zonemgr::add_adjacent_zone( "house2_zone", "house2_out_zone", "enter_etage_house2" );
	zm_zonemgr::add_adjacent_zone( "house2_zone", "etage_house2_zone", "enter_etage_house2" );
    zm_zonemgr::add_adjacent_zone( "house2_out_zone", "etage_house2_zone", "enter_etage_house2" );

	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}



