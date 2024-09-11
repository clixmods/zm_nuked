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
#using scripts\zm\_zm_perk_widows_wine;

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

// Utility
#using scripts\zm_exp\zm_subtitle;

// Nuketown weapons
#using scripts\zm\_hb21_zm_weap_galvaknuckles;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;



// Cinematic Moon rocket
#define NUKE_SHOCK_EXPLOSION           "dlc1/castle/fx_exp_moon_castle"
#precache( "fx", NUKE_SHOCK_EXPLOSION );

#define NUKE_EXPLOSION            "dlc5/moon/fx_exp_nuke"
#precache( "fx", NUKE_EXPLOSION );

#define NUKE_EXPLOSION_LIGHT "clix/nuketown/explosion_earth_lightblue"
#precache( "fx", NUKE_EXPLOSION_LIGHT );

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	// Init base feature for zombies
	zm_usermap::main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func = &usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	// Init Nuketown features
    level thread play_music("project_skadi_classified");
    level thread zm_nuked_perks::perks_from_the_sky();
    level thread vox_transmission::init();
    level thread ee_music::init();
    //level thread ee_secondary::init();

	// Clean residual elements
    level thread survival_omega_clean_up();
    level thread clean_quest();

    // Init Nuketown secret features
	level thread earth_blowup();
}

// This function will init each zones (adjacent and not adjacent).
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

function play_music(music = "project_skadi_classified")
{
	level.origin_bg_mus = Spawn("script_model", (0,0,0));
	level.origin_bg_mus SetModel("tag_origin");

	while(1)
	{
		level waittill("play_bg_music");
		level.origin_bg_mus PlayLoopSound(music, 1);
	}
}

// Remove all elements related to Omega version of the map.
function survival_omega_clean_up()
{
    level._zombiemode_check_firesale_loc_valid_func = &check_firesale_loc_valid_func;

	// Hide wallbuys in outside zone
    wallbuy = GetEntArray("wallbuy_omega","targetname");
    foreach(ent in wallbuy)
    {
		ent hide();
	}    

    doors = GetEntArray("floating_debris","targetname");
    for(i=0;i<doors.size;i++)
    {
        doors[i] Hide();
		trigger = GetEntArray(doors[i].target,"targetname");

		foreach(ent in trigger)
		{
			if(ent.classname == "trigger_use")
			{
				ent Hide();
			}	
		}
    }

    i=0;
    while(i != 20)
    {
        blocker = GetEntArray("explo_blocker_trig_"+i+"_omega", "targetname");
        foreach(ent in blocker)
        {
            ent Hide();
            ent Delete();   
        }

        i++;
    }

    level flag::wait_till( "rocket_is_fall" ); 
    for(i=0;i<doors.size;i++)
    {
        if(doors[i].script_noteworthy != "door_moon_destroy")
        {
            doors[i] Show();

            trigger = GetEnt(doors[i].target,"targetname");
            trigger Show();
        }
    }
}

// Supposed to not use omega mystery box when Firesale is on.
function check_firesale_loc_valid_func()
{
    if( IsSubStr( self.script_noteworthy, "restricted") )
    {
		return false;
	}   
    else
	{
		return true;
	}
}

// Remove all elements related to the quest, sorry guys ...
function clean_quest()
{
	level flag::clear("quest_enable");

    ents = GetEntArray("dirts","script_noteworthy");
    foreach( ent in ents)
    {
		ent delete();
	}    

    blocker_wavegun = getent("explo_blocker_trig_pap","targetname");
    blocker_wavegun hide();

    marlton_bunker_trig = GetEnt( "marlton_bunker_trig", "targetname" );
    marlton_bunker_trig hide();

    //paper_perk_code
    autel = GetEnt("autel", "targetname");
    autel_book = GetEnt("autel_book", "targetname");
    autel_clip = GetEnt("autel_clip", "targetname");
    boss_clip_player = GetEntArray("clip_boss_begin","targetname");
    autel_item = GetEntArray("autel_boss_items","targetname");
    foreach (ent in autel_item)
    {   
        ent hide();
    }

    foreach (ent in boss_clip_player)
    {   
        ent hide();
    }
    autel hide();
    autel_book hide();
    autel_clip hide();

    perk_code = GetEntArray("paper_perk_code", "targetname");
    foreach (ent in perk_code)
    {
        ent hide();
    }

    number_pop_all = GetEntArray("number_pop_all", "script_noteworthy");
    foreach (ent in number_pop_all)
    {
        ent hide();
    }

    texture_chalk_tv = GetEnt("chalk_tv_code", "targetname");
    texture_chalk_tv hide();

    ritual_model = GetEntArray("struct_attackable","targetname");
   	foreach(model in ritual_model)
   	{
        model hide();
   	}

    ritual_item = GetEntArray("item_ritual","targetname");
    foreach(item in ritual_item)
   	{
        item hide();
   	}	

    gersh_model = GetEntArray("gersh_model_array","script_noteworthy");
    foreach(model in gersh_model)
   	{
        model hide();
   	}

    triggers_soul = GetEntArray("activate_growsoul","targetname");
    foreach (trig in triggers_soul)
    {
        trig hide();
    }

    book = GetEntArray("book_emplacement_apres_gersh","targetname");
    foreach(ent in book)
    {
        ent hide();
    }

    book_emplacement_1 = GetEnt("book_emplacement_1", "targetname");
    book_emplacement_2 = GetEnt("book_emplacement_2", "targetname");
    book_emplacement_1 hide();
    book_emplacement_2 hide();

    key_ritual = GetEntArray("key_ritual_1","targetname");
    key_ritual = ArrayCombine(key_ritual, GetEntArray("key_ritual_2", "targetname"), true, false);
    key_ritual = ArrayCombine(key_ritual, GetEntArray("key_ritual_3", "targetname"), true, false);
    key_ritual = ArrayCombine(key_ritual, GetEntArray("key_ritual_4", "targetname"), true, false);
    foreach(key in key_ritual)
    {
        key Hide();
    }

    candy = GetEntArray("candy", "script_noteworthy");
    foreach ( ent in candy )
    {
        ent hide();
    }
}

function earth_blowup()
{
    moon_tranmission_struct = struct::get( "moon_transmission_struct","targetname" );
    nuke_shock = struct::get( "fx_nukeshock_position", "targetname" );
    nuke = struct::get( "fx_nuke", "targetname" );
    nuke_light = struct::get( "fx_nuke_light", "targetname" );

    wait 15;

    while ( level.round_number <= 30)
    {
        wait 1;
    }

    wait 30;

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_0", 11, moon_tranmission_struct.origin, "vox_xcomp_quest_step6_14"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(11);
    wait 20;

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_1", 13, moon_tranmission_struct.origin, "vox_xcomp_quest_step7_5"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(13);

    wait 54;
  
    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_2", 10, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_4"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(10);

    SetDvar("ai_disableSpawn", 1);
    wait 20;

    level clientfield::set( "change_exposure_to_2", 1 );
    foreach(player in level.players)
    {
       player PlaySoundToPlayer("earth_blow_music", player);
       player PlaySoundToPlayer("earth_blow_music_no_music", player);
    }

    level flag::set( "call_rocket_alternate_ending" );

    wait 23;

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_3", 3, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_5"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(3);

    wait 30.5;

    PlayFx( NUKE_SHOCK_EXPLOSION , nuke_shock.origin);

    wait 3;
    level clientfield::set( "setup_skybox", 2 );
    level notify("skybox_moon");
    PlayFx( NUKE_EXPLOSION_LIGHT , nuke_light.origin);
    player StartFadingBlur( 15, 5 );
    wait 2;

    PlaySoundAtPosition( "vox_xcomp_laugh", (0,0,0) );
    level util::set_lighting_state( 1 );
    
    earthquake( 0.6, 8, player.origin, 1000000 );
    model = util::spawn_model( "tag_origin", nuke.origin, nuke.angles );

    exploder::exploder("nuke_fx");

    wait 15;
    SetDvar("ai_disableSpawn", 0);

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_4", 5, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_6"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(5);
    wait 8;

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_5", 6, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_8"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::tv_allumer(6);
    level flag::set( "spawn_zombies" );
    level flag::set( "rocket_is_fall" );
    level flag::set( "aftermath" );
    PlaySoundAtPosition( "sam_moon_mus", moon_tranmission_struct.origin );

    level thread vox_transmission::richtofen_quote_random_ee();
}


