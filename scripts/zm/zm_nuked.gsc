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
#using scripts\zm\_zm_perks; // Spare change
#insert scripts\zm\_zm_perks.gsh; // Allow custom fx for perks

#using scripts\zm\classic_features\clock_nuked; 
#using scripts\zm\classic_features\mannequins; 
#using scripts\zm\classic_features\ee_music; 
#using scripts\zm\classic_features\nuketown_panneau;
#using scripts\zm\classic_features\vox_transmission; 
#using scripts\zm\classic_features\pack_a_punch_from_the_sky; 
#using scripts\zm\zm_nuketown_hd_amb;

// Secondary EE
#using scripts\zm\new_features\ee_secondary;
#using scripts\zm\new_features\ee_tv_code;

// Utility
#using scripts\zm_exp\zm_subtitle;
#using scripts\zm\_zm_net;

// Nuketown weapons
#using scripts\zm\_hb21_zm_weap_galvaknuckles;

// Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

// Gameover cinematic
#precache( "model", "p6_zm_nuked_rocket_cam_hd" ); 
#precache( "model", "p7_lotus_ground_clouds_01" ); 
#precache( "model", "p7_inf_bas_fallaway_clouds_01_single" ); 
#precache( "model", "p7_inf_bas_fallaway_clouds_01" ); 
#precache( "model", "p7_fxp_vista_nuked_endgame" ); 
#define ROCKET_GAMEOVER_ENGINE  "dlc1/castle/fx_ee_moon_rockets_exhaust"
#precache( "fx", ROCKET_GAMEOVER_ENGINE );
#define ROCKET_GAMEOVER_FRONT  "dlc4/genesis/fx_apothint_wind_exhale_loop"
#precache( "fx", ROCKET_GAMEOVER_FRONT );

// Cinematic Moon rocket
#define NUKE_SHOCK_EXPLOSION           "dlc1/castle/fx_exp_moon_castle"
#precache( "fx", NUKE_SHOCK_EXPLOSION );
#define NUKE_EXPLOSION            "dlc5/moon/fx_exp_nuke"
#precache( "fx", NUKE_EXPLOSION );
#define NUKE_EXPLOSION_LIGHT "clix/nuketown/explosion_earth_lightblue"
#precache( "fx", NUKE_EXPLOSION_LIGHT );
#define TRAIL_ROCKET  "clix/fx_rocket_clix"
#precache( "fx", TRAIL_ROCKET );
#define TRAIL_ROCKET_OTHER  "clix/fx_rocket_clix_other"
#precache( "fx", TRAIL_ROCKET_OTHER );

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	// Set cheat to 1 to enable cheats
	setdvar("sv_cheats", 1);

    // Register clientfield 
    clientfield::register("world", "change_fog", VERSION_SHIP, 4, "int" );
    clientfield::register("world", "change_zombie_eye_color", VERSION_SHIP, 1, "int");
    clientfield::register("world", "change_exposure_to_2", VERSION_SHIP, 1, "int"); 
    clientfield::register("world", "change_exposure_to_1", VERSION_SHIP, 1, "int");

    // Need to be executed before zm_usermap
    level.dog_rounds_allowed = false; // No dog round

	// Init base feature for zombies
	zm_usermap::main();

    // Setup some rules for the map
    level.random_pandora_box_start = true;
    zm_perks::spare_change(); // Add points under each perk
    level._zombiemode_custom_box_move_logic = &nuked_box_move_logic;
	level._zombie_custom_add_weapons =&custom_add_weapons;
    level.custom_zombie_powerup_drop = &custom_zombie_powerup_drop_nuked;
    level util::set_lighting_state( 0 ); // Set the lighting state to base one.
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func = &usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	// Init Nuketown features
    level thread play_music("project_skadi_classified");
    level thread init_nuked_audio();
    level thread zm_nuked_perks::perks_from_the_sky();
    level thread vox_transmission::init();
    level thread ee_music::init();
    level thread bus_random_horn();
    level thread cardboard_dyn();
    level thread pack_a_punch_hide_model();

    // Init new features
    level thread ee_secondary::init();
    level thread ee_tv_code::init();


    // Setup gameover cinematic
    rocket = GetEnt( "intermission_rocket", "targetname" );
    rocket Hide();

    // Keep the base intermission to restore it if the secret cinematic was enabled
    level.old_custom_intermission   = level.custom_intermission;
    level.custom_intermission       = &nuked_standard_intermission; 
    level.custom_player_fake_death  = &player_fake_death;

    // Flags initialization
    level flag::init( "moon_transmission_over" );

    // Pack-a-Punch Camo
    level.pack_a_punch_camo_index = 128;
    level.pack_a_punch_camo_index_number_variants = 3;

    //level thread ee_secondary::init();

	// Clean residual elements
    level thread survival_omega_clean_up();
    level thread clean_quest();

    // Init Nuketown secret features
	level thread earth_blowup();
}

#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5
function init_nuked_audio()
{
    if(!level flag::get("no_round_sound"))
    {    
        zm_audio::musicState_Create("round_start", PLAYTYPE_ROUND, "roundstart1");
        zm_audio::musicState_Create("round_start_short", PLAYTYPE_ROUND,  "roundstart1" );
        zm_audio::musicState_Create("round_start_first", PLAYTYPE_ROUND, "roundstart_first" );
        zm_audio::musicState_Create("round_end", PLAYTYPE_ROUND, "roundend1" );
    }
    
    zm_audio::musicState_Create("game_over", PLAYTYPE_GAMEEND, "gameover" );
    zm_audio::musicState_Create("dog_start", PLAYTYPE_ROUND, "dogstart1" );
    zm_audio::musicState_Create("dog_end", PLAYTYPE_ROUND, "dogend1" );
    zm_audio::musicState_Create("timer", PLAYTYPE_ROUND, "timer" );
    zm_audio::musicState_Create("power_on", PLAYTYPE_QUEUE, "poweron" );
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

function bus_random_horn()
{
    horn_struct = struct::get( "bus_horn_struct", "targetname" );

    while(1)
    {
        to_round = level.round_number + RandomIntRange( 5, 10 );
        if(level.debug_nuked == true)
        {
            IPrintLnBold("le round du klaxon sera :"+to_round);
        }
          
        level waittill("between_round_over");
        PlaySoundAtPosition( "horn_leave", horn_struct.origin );
    }
}

function cardboard_dyn()
{
    trig_box = GetEnt("trig_box","targetname");
    clip_box = GetEnt( trig_box.target ,"targetname");
    box = GetEnt("box_model_taser","targetname");

    while(1)
    {
        trig_box waittill("trigger", player);
        clip_box Hide();
        PlayFX("destruct/fx_dest_paper", trig_box.origin);
        box Hide();
        break;
    }
}

function pack_a_punch_hide_model()
{
    models = GetEntArray("pap_model_add","targetname");
    
    foreach(model in models)
    {
        model Hide();
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

function nuked_box_move_logic()
{
    // Check to see if there's a chest selection we should use for this move
    // This is indicated by a script_noteworthy of "moveX*"
    //  (e.g. move1_chest0, move1_chest1)  We will randomly choose between 
    //      one of those two chests for that move number only.
    index = -1;
    
    for ( i=0; i<level.chests.size; i++ )
    {
        // Check to see if there is something that we have a choice to move to for this move number
        if ( IsSubStr( level.chests[i].script_noteworthy, ("move"+(level.chest_moves+1)) ) &&
             i != level.chest_index )
        {
            index = i;
            break;
        }
    }

    if ( index != -1 )
    {
        level.chest_index = index;
        
    }
    else
    {
        level.chest_index++;
    }

    if (level.chest_index >= level.chests.size)
    {
        //PI CHANGE - this way the chests won't move in the same order the second time around
        temp_chest_name = level.chests[level.chest_index - 1].script_noteworthy;
        level.chest_index = 0;
        level.chests = array::randomize(level.chests);
        //in case it happens to randomize in such a way that the chest_index now points to the same location
        // JMA - want to avoid an infinite loop, so we use an if statement
        if (temp_chest_name == level.chests[level.chest_index].script_noteworthy)
        {
            level.chest_index++;
        }
        
        //END PI CHANGE
    }
    while(IsSubStr( level.chests[level.chest_index].script_noteworthy, "restricted" )
        || (isdefined(temp_chest_name) && temp_chest_name == level.chests[level.chest_index].script_noteworthy)
        || level.chest_index >= level.chests.size)
        {
            if(level.debug_nuked == true)
                IPrintLnBold("besoin de mélanger car "+level.chests[level.chest_index].script_noteworthy);

            if(level.chest_index >= level.chests.size)
            {
                if(level.debug_nuked == true)
                    IPrintLnBold("besoin de mélanger depasser limite atteint");
                
                level.chest_index = -1;
            }
            
            level.chest_index++;

            if(level.debug_nuked == true)
                IPrintLn("resultat du melange "+level.chests[level.chest_index].script_noteworthy);
        }
    if(level.debug_nuked == true)
        IPrintLnBold("celui qui a été choisi :"+level.chests[level.chest_index].script_noteworthy);
}

function custom_zombie_powerup_drop_nuked(drop_point)
{
    powerup = zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + (0,0,40));
    can_drop = powerup zm_zonemgr::entity_in_active_zone();
    powerup Delete();
    
    if(IS_TRUE( can_drop ))
    {
        return false;
    }
    
    return true;
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

    weapon_rack_wavegun = GetEnt("weapon_rack","targetname");
    weapon_rack_wavegun Hide();

    wavegun_ice_model = GetEnt("wavegun_ice","targetname");
    wavegun_ice_model Hide();

    wavegun_fire_model = GetEnt("wavegun_fire","targetname");
    wavegun_fire_model Hide();

    wavegun_wind_model = GetEnt("wavegun_wind","targetname");
    wavegun_wind_model Hide();

    wavegun_electric_model = GetEnt("wavegun_electric","targetname");
    wavegun_electric_model Hide();

    structs = struct::get_array("struct_wavegun","targetname");
    foreach (struct in structs)
    {
        struct hide();
    }    
}

function earth_blowup()
{
    moon_tranmission_struct = struct::get( "moon_transmission_struct","targetname" );
    nuke_shock = struct::get( "fx_nukeshock_position", "targetname" );
    nuke = struct::get( "fx_nuke", "targetname" );
    nuke_light = struct::get( "fx_nuke_light", "targetname" );

    wait 15;

    while ( level.round_number < 30)
    {
        wait 1;
    }

    wait 30;

    //
    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_0", 11, moon_tranmission_struct.origin, "vox_xcomp_quest_step6_14"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(11);
    wait 20;

    // Maxis take controls of the station
    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_1", 13, moon_tranmission_struct.origin, "vox_xcomp_quest_step7_5"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(13);

    SetDvar("ai_disableSpawn", 1);

    // Remove the nuked intermission and restore the base one
    // Because rockets is going to be launched, so we don't want see them in the intermission
    level.custom_intermission = level.old_custom_intermission;

    wait 54;
  
    // Maxis has finished calculations, Launch in 5 seconds
    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_2", 10, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_4"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(10);

    wait 20;

    level clientfield::set( "change_exposure_to_2", 1 );
    foreach(player in level.players)
    {
       player PlaySoundToPlayer("earth_blow_music", player);
       player PlaySoundToPlayer("earth_blow_music_no_music", player);
    }

    level flag::set( "call_rocket_alternate_ending" );

    level thread move_rocket_vehicle_alternate_ending();
    level thread move_rocket_vehicle_other_alternate_ending("veh_rocket_2", "start_fx_rocket_2"); 
    level thread move_rocket_vehicle_other_alternate_ending("veh_rocket_3", "start_fx_rocket_3");

    wait 23;

    // Maxis says 30 seconds to impact
    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_3", 3, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_5"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(3);

    wait 30.5;

    // TODO : Find a way to optimize this part, because the game is going to freeze for some seconds
    // Not hard crash, but freeze, I don't know if that can crash the game with multiple players
    PlayFx( NUKE_SHOCK_EXPLOSION , nuke_shock.origin);
    wait 3;
    player StartFadingBlur( 7, 3 );
    wait 1;
    level clientfield::set( "setup_skybox", 2 );
    level notify("skybox_moon");
    PlayFx( NUKE_EXPLOSION_LIGHT , nuke_light.origin);
    wait 2;

    PlaySoundAtPosition( "vox_xcomp_laugh", (0,0,0) );
    level util::set_lighting_state( 1 );
    
    earthquake( 0.6, 8, player.origin, 1000000 );
    model = util::spawn_model( "tag_origin", nuke.origin, nuke.angles );

    exploder::exploder("nuke_fx");

    wait 15;
    SetDvar("ai_disableSpawn", 0);

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_4", 5, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_6"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(5);
    wait 8;

    zm_sub::register_subtitle_func(&"NUKED_STRING_MAXIS_DIALOG_5", 6, moon_tranmission_struct.origin, "vox_xcomp_quest_step8_8"); //textLine, duration, origin, sound, duration_begin, to_player)
    level thread vox_transmission::set_tv_on_during(6);
    level flag::set( "spawn_zombies" );
    level flag::set( "rocket_is_fall" );
    level flag::set( "aftermath" );
    //PlaySoundAtPosition( "sam_moon_mus", moon_tranmission_struct.origin );

    level thread vox_transmission::richtofen_quote_random_ee();
}

function move_rocket_vehicle_alternate_ending() 
{
    vh_rocket_alt = GetEnt( "veh_rocket", "targetname" );  
    vh_rocket_alt.fx = Spawn( "script_model", vh_rocket_alt.origin );
    vh_rocket_alt.fx.angles = vh_rocket_alt.angles;
    vh_rocket_alt.fx SetModel( "tag_origin" );
    PlayFXOnTag(TRAIL_ROCKET ,vh_rocket_alt.fx,"tag_origin");
    vh_rocket_alt.fx LinkTo( vh_rocket_alt );
    n_path_start = GetVehicleNode( "start_fx_rocket", "targetname" );
    vh_rocket_alt LinkTo( n_path_start, "tag_origin", ( 0, -1, 0 ), ( 0, -1, 0 ) );
    vh_rocket_alt AttachPath( n_path_start );
    vh_rocket_alt StartPath();

    vh_rocket_alt waittill( "reached_end_node" );
    vh_rocket_alt.fx Unlink();
    vh_rocket_alt.fx Delete();

}

function move_rocket_vehicle_other_alternate_ending(veh, node) 
{
    vh_rocket_alt = GetEnt( veh, "targetname" );  
    vh_rocket_alt.fx = Spawn( "script_model", vh_rocket_alt.origin );
    vh_rocket_alt.fx.angles = vh_rocket_alt.angles;
    vh_rocket_alt.fx SetModel( "tag_origin" );
    PlayFXOnTag(TRAIL_ROCKET_OTHER ,vh_rocket_alt.fx,"tag_origin");
    vh_rocket_alt.fx LinkTo( vh_rocket_alt );
    n_path_start = GetVehicleNode( node, "targetname" );
    vh_rocket_alt LinkTo( n_path_start, "tag_origin", ( 0, -1, 0 ), ( 0, -1, 0 ) );
    vh_rocket_alt AttachPath( n_path_start );
    vh_rocket_alt StartPath();
    vh_rocket_alt waittill( "reached_end_node" );
    vh_rocket_alt.fx Unlink();
    vh_rocket_alt.fx Delete();
}


function nuked_standard_intermission()
{
    self CloseInGameMenu();
    self CloseMenu( "StartMenu_Main" );
    self notify("player_intermission");
    self endon("player_intermission");
    level endon( "stop_intermission" );
    self endon("disconnect");
    self endon("death");
    self notify( "_zombie_game_over" ); // ww: notify so hud elements know when to leave

    //Show total gained point for end scoreboard and lobby
    self.score = self.score_total;  

    self.game_over_bg = NewClientHudElem( self );
    self.game_over_bg.x = 0;
    self.game_over_bg.y = 0;
    self.game_over_bg.horzalign = "fullscreen";
    self.game_over_bg.vertalign = "fullscreen";
    self.game_over_bg.foreground = 1;
    self.game_over_bg.sort = 1;
    self.game_over_bg setshader( "black", 640, 480 );
    self.game_over_bg.alpha = 1;

    if(self IsHost())
        level thread moon_rocket_follow_path();
    
    wait 0.1;
    self.game_over_bg fadeovertime( 1 );
    self.game_over_bg.alpha = 0;
    level flag::wait_till( "rocket_hit_nuketown" );
    self.game_over_bg fadeovertime( 1 );
    self.game_over_bg.alpha = 1;
}

function player_fake_death()
{
    self.ignoreme = true;
    self EnableInvulnerability();
}

function moon_rocket_follow_path()
{

    level clientfield::set( "setup_skybox", 5 );
    

    rocket_start_struct = struct::get( "inertmission_rocket_start", "targetname" );
    rocket_end_struct = struct::get( "inertmission_rocket_end", "targetname" );
    rocket_cam_start_struct = struct::get( "intermission_rocket_cam_start", "targetname" );
    rocket_cam_end_struct = struct::get( "intermission_rocket_cam_end", "targetname" );
    
    cloud_1 = Spawn( "script_model", rocket_start_struct.origin );
    cloud_1 MoveZ(-2000,0.1);
    cloud_2 = Spawn( "script_model", rocket_start_struct.origin );
    cloud_2 MoveZ(-6000,0.1);
    cloud_3 = Spawn( "script_model", rocket_start_struct.origin );
    cloud_3 MoveZ(-12000,0.1);
    cloud_4 = Spawn( "script_model", rocket_start_struct.origin );
    cloud_4 MoveZ(-15000,0.1);

    cloud_1 SetModel("p7_inf_bas_fallaway_clouds_01");
    cloud_2 SetModel("p7_inf_bas_fallaway_clouds_01");
    cloud_3 SetModel("p7_lotus_ground_clouds_01");
    cloud_4 SetModel("p7_lotus_ground_clouds_01");
    
    fog = Spawn( "script_model", (170297,857,6853) );
    fog SetModel("p7_fxp_vista_nuked_endgame");
    fog.angles = (0,90,0);
    
    fog SetScale(10000);

    fog_1 = Spawn( "script_model", (0,0,0) );
    fog_1.origin = (62000,857,2875);
    fog_1 SetModel("p7_fxp_vista_nuked_endgame");
    fog_1.angles = (0,90,0);
    
    fog_1 SetScale(4000);

    fog_2 = Spawn( "script_model", (56427,845,2924) );
    fog_2 SetModel("p7_fxp_vista_nuked_endgame");
    fog_2.angles = (0,90,0);
    
    fog_2 SetScale(3000);

    rocket_camera_ent = Spawn( "script_model", rocket_cam_start_struct.origin );
    rocket_camera_ent.angles = rocket_cam_start_struct.angles;
    rocket = GetEnt( "intermission_rocket", "targetname" );
    rocket Show();
     modelss = GetEntArray("endgame_models","targetname");
    foreach(e in modelss)
        e Show();
    rocket.origin = rocket_start_struct.origin;
    camera = Spawn( "script_model", rocket_cam_start_struct.origin );
    camera.angles = rocket_cam_start_struct.angles;
    camera SetModel( "tag_origin" );
    exploder::exploder( "endgame" );
    players = GetPlayers();
    level.camera_rocket = camera;
    for(i=0; i < players.size ; i++)
    {
        players[i] FreezeControls (true);
        players[i] SetClientUIVisibilityFlag( "weapon_hud_visible", 1 );
        players[i] HideViewModel();
        players[i] SetInvisibleToAll();
        players[i] SetClientUIVisibilityFlag( "hud_visible", 1 );
        players[i] thread player_rocket_rumble();
        players[i] thread intermission_rocket_blur();
        players[i] SetDepthOfField( 0, 128, 7000, 10000, 6, 1.8 );
        players[i] LinkTo(camera);
        players[i] GiveWeapon( "ar_standard");
        players[i] SwitchToWeapon("ar_standard");

    }

    rocket MoveTo( rocket_end_struct.origin, 9 );
    rocket RotateTo( rocket_end_struct.angles, 11 );
    camera MoveTo( rocket_cam_end_struct.origin, 9 );
    camera RotateTo( rocket_cam_end_struct.angles, 8 );
    PlayFXOnTag( ROCKET_GAMEOVER_FRONT, rocket, "tag_cam" );
    wait 8;
    level flag::set( "rocket_hit_nuketown" );
}

function player_to_rocket()
{
    while(1)
    {
        self SetOrigin( level.camera_rocket.origin );
        self SetPlayerAngles( level.camera_rocket.angles );
        wait 0.05;
    }
}

function intermission_rocket_blur()
{
    while ( !level flag::get( "rocket_hit_nuketown" ) )
    {
        blur = RandomFloatRange( 1, 5 );
        self SetBlur( blur, 0.1 );
        wait RandomIntRange( 1, 3 );
    }
}

function inermission_rocket_init()
{
    rocket = GetEnt( "intermission_rocket", "targetname" );
    rockets = GetEnt( "endgame_models", "targetname" );
    rockets Hide();
    models = GetEntArray("endgame_models","targetname");
    foreach(e in models)
        e Hide();

    rocket Hide();
}

function player_rocket_rumble()
{
    while ( !level flag::get( "rocket_hit_nuketown" ) )
    {
        self PlayRumbleOnEntity( "damage_light" );
        Earthquake( 0.15, 0.25, self.origin, 100 );
        wait 0.5;
    }
}
