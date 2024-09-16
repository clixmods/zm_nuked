#using scripts\codescripts\struct;

#using scripts\shared\aat_shared;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\shared\aat_zm.gsh;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_ai_dogs_nuked.gsh;

#precache( "fx", DOG_DEFAULT_SPAWN_FX );
#precache( "fx", DOG_DEFAULT_EYE_FX );
#precache( "fx", DOG_DEFAULT_GIB_FX );
#precache( "fx", DOG_DEFAULT_TRAIL_FX );

#precache( "fx", DOG_ELECTRIC_SPAWN_FX );
#precache( "fx", DOG_ELECTRIC_EYE_FX );
#precache( "fx", DOG_ELECTRIC_GIB_FX );
#precache( "fx", DOG_ELECTRIC_DEATH_RADIUS_FX );
#precache( "fx", DOG_ELECTRIC_TRAIL_FX );

#precache( "fx", DOG_NOVA_SPAWN_FX );
#precache( "fx", DOG_NOVA_EYE_FX );
#precache( "fx", DOG_NOVA_GIB_FX );
#precache( "fx", DOG_NOVA_TRAIL_FX );

#define ZM_DOGS_HERO_WEAPON_KILL_POWER 2

#namespace zm_ai_dogs_nuked;

REGISTER_SYSTEM( "zm_ai_dogs_nuked", &__init__, "aat" )
	
function __init__()
{
	clientfield::register( "actor", "dog_nuked_fx", VERSION_SHIP, 4, "int" );
	level flag::init("zombie_dog_default"); 
	level flag::init("zombie_dog_elec");
	level flag::init("zombie_dog_nova");
	init_dog_fx();
	init();
}

function init()
{
	level.dog_round_track_override_nuked =&dog_round_tracker;

	level.dogs_round_callbyscript = &round_dog_by_script;
	level.dogs_nuked_enabled = true;
	level.dog_nuked_rounds_enabled = false;
	level.dog_nuked_round_count = 1;

	level.dog_nuked_spawners = [];

	//utility::flag_init( "dog_round" );
	level flag::init( "dog_clips" );

	if ( GetDvarString( "zombie_dog_animset" ) == "" )
	{
		SetDvar( "zombie_dog_animset", "zombie" );
	}

	if ( GetDvarString( "scr_dog_health_walk_multiplier" ) == "" )
	{
		SetDvar( "scr_dog_health_walk_multiplier", "4.0" );
	}

	if ( GetDvarString( "scr_dog_run_distance" ) == "" )
	{
		SetDvar( "scr_dog_run_distance", "500" );
	}

	level.melee_range_sav  = GetDvarString( "ai_meleeRange" );
	level.melee_width_sav = GetDvarString( "ai_meleeWidth" );
	level.melee_height_sav  = GetDvarString( "ai_meleeHeight" );

	zombie_utility::set_zombie_var( "dog_fire_trail_percent", 50 );

	// AAT IMMUNITIES
	level thread aat::register_immunity( ZM_AAT_BLAST_FURNACE_NAME, ARCHETYPE_ZOMBIE_DOG, false, true, true );
	level thread aat::register_immunity( ZM_AAT_DEAD_WIRE_NAME, ARCHETYPE_ZOMBIE_DOG, false, true, true );
	level thread aat::register_immunity( ZM_AAT_FIRE_WORKS_NAME, ARCHETYPE_ZOMBIE_DOG, true, true, true );
	level thread aat::register_immunity( ZM_AAT_THUNDER_WALL_NAME, ARCHETYPE_ZOMBIE_DOG, false, false, true );
	level thread aat::register_immunity( ZM_AAT_TURNED_NAME, ARCHETYPE_ZOMBIE_DOG, true, true, true );
	
	// Init dog targets - mainly for testing purposes.
	//	If you spawn a dog without having a dog round, you'll get SREs on hunted_by.
	dog_spawner_init();

	level thread dog_clip_monitor();
}

function init_dog_fx()
{
	level._effect[ "lightning_dog_nuked_spawn" ]	= DOG_DEFAULT_SPAWN_FX;
	level._effect[ "dog_nuked_eye_glow" ]			= DOG_DEFAULT_EYE_FX;
	level._effect[ "dog_nuked_gib" ]				= DOG_DEFAULT_GIB_FX;
	level._effect[ "dog_nuked_trail_fire" ]		= DOG_DEFAULT_TRAIL_FX;

	level._effect[ "lightning_dog_nuked_electric_spawn" ]	= DOG_ELECTRIC_SPAWN_FX;
	level._effect[ "dog_nuked_electric_eye_glow" ]			= DOG_ELECTRIC_EYE_FX;
	level._effect[ "dog_nuked_electric_gib" ]				= DOG_ELECTRIC_GIB_FX;
	level._effect[ "dog_nuked_electric_death" ]				= DOG_ELECTRIC_DEATH_RADIUS_FX;
	level._effect[ "dog_nuked_electric_trail_fire" ]		= DOG_ELECTRIC_TRAIL_FX;

	level._effect[ "lightning_dog_nuked_nova_spawn" ]	= DOG_NOVA_SPAWN_FX;
	level._effect[ "dog_nuked_nova_eye_glow" ]			= DOG_NOVA_EYE_FX;
	level._effect[ "dog_nuked_nova_gib" ]				= DOG_NOVA_GIB_FX;
	level._effect[ "dog_nuked_nova_trail_fire" ]		= DOG_NOVA_TRAIL_FX;
}

//
//	If you want to enable dog rounds, then call this.
//	Specify an override func if needed.
function enable_dog_rounds()
{
	level.dog_nuked_rounds_enabled = true;

	if( !isdefined( level.dog_round_track_override_nuked ) )
	{
		level.dog_round_track_override_nuked =&dog_round_tracker;
	}

	level thread [[level.dog_round_track_override_nuked]]();
}


function dog_spawner_init()
{
	level.dog_nuked_spawners = getEntArray( "zombie_dog_spawner", "script_noteworthy" ); 
	later_dogs = getentarray("later_round_dog_spawners", "script_noteworthy" );
	level.dog_nuked_spawners = ArrayCombine( level.dog_nuked_spawners, later_dogs, true, false );
	
	if( level.dog_nuked_spawners.size == 0 )
	{
		return;
	}
	
	for( i = 0; i < level.dog_nuked_spawners.size; i++ )
	{
		if ( zm_spawner::is_spawner_targeted_by_blocker( level.dog_nuked_spawners[i] ) )
		{
			level.dog_nuked_spawners[i].is_enabled = false;
		}
		else
		{
			level.dog_nuked_spawners[i].is_enabled = true;
			level.dog_nuked_spawners[i].script_forcespawn = true;
		}
	}

	assert( level.dog_nuked_spawners.size > 0 );
	level.dog_health = 100;

	array::thread_all( level.dog_nuked_spawners,&spawner::add_spawn_function,&dog_init );
}


function dog_round_spawning()
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	
	level.dog_targets = getplayers();
	for( i = 0 ; i < level.dog_targets.size; i++ )
	{
		level.dog_targets[i].hunted_by = 0;
	}

	level endon( "kill_round" );

	if( level.intermission )
	{
		return;
	}

	level.dog_intermission = true;
	level thread dog_round_aftermath();
	players = GetPlayers();
	array::thread_all( players,&play_dog_round );	
	wait(1);
	level thread zm_audio::sndAnnouncerPlayVox("dogstart");
	wait(6);
	
	if( level.dog_nuked_round_count < 3 )
	{
		max = players.size * 12;
	}
	else
	{
		max = players.size * 24;
	}

	level.zombie_total = max;
	dog_health_increase();



	count = 0; 
	while( true )
	{
		// added ability to pause spawning
		level flag::wait_till( "spawn_zombies" );
		
		while( zombie_utility::get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
		{
			wait 0.1;
		}

		num_player_valid = zm_utility::get_number_of_valid_players();
	
		while( zombie_utility::get_current_zombie_count() >= num_player_valid * 6 ) // number dogs
		{
			wait( 2 );
			num_player_valid = zm_utility::get_number_of_valid_players();
		}
		
		//update the player array.
		players = GetPlayers();
		favorite_enemy = get_favorite_enemy();

		if ( isdefined( level.dog_spawn_func ) )
		{
			spawn_loc = [[level.dog_spawn_func]]( level.dog_nuked_spawners, favorite_enemy );

			ai = zombie_utility::spawn_zombie( level.dog_nuked_spawners[0] );
			if( isdefined( ai ) ) 	
			{
				ai thread define_dog_type();
				IPrintLnBold("Un chien de type" +self.type_dog+ "à spawn");
				ai.favoriteenemy = favorite_enemy;
				spawn_loc thread dog_spawn_fx( ai, spawn_loc );
				level.zombie_total--;
				count++;
				level flag::set( "dog_clips" );
			}
		}
		else
		{
			// Default method
			spawn_point = dog_spawn_factory_logic( favorite_enemy );
			ai = zombie_utility::spawn_zombie( level.dog_nuked_spawners[0] );

			if( isdefined( ai ) ) 	
			{
				ai thread define_dog_type();
				IPrintLnBold("Un chien de type" +self.type_dog+ "à spawn");
				ai.favoriteenemy = favorite_enemy;
				spawn_point thread dog_spawn_fx( ai, spawn_point );
				level.zombie_total--;
				count++;
				level flag::set( "dog_clips" );
			}
		}

		if(isdefined(level.special_wait_next_dog_spawn))
		{
			[[level.special_wait_next_dog_spawn]](count, max);
		}
		else	
			waiting_for_next_dog_spawn( count, max );
	}
}

function waiting_for_next_dog_spawn( count, max )
{
	default_wait = 0.5 ;

	if( level.dog_nuked_round_count == 1)
	{
		default_wait = 3;
	}
	else if( level.dog_nuked_round_count == 2)
	{
		default_wait = 2.5;
	}
	else if( level.dog_nuked_round_count == 3)
	{
		default_wait = 2;
	}
	else 
	{
		default_wait = 1.5;
	}

	default_wait = default_wait - ( count / max );
	
	default_wait = max( default_wait, 0.05 ); 

	wait( 1 );
}

function dog_round_aftermath()
{
	level waittill( "last_ai_down", e_last );

	level thread zm_audio::sndMusicSystem_PlayState( "dog_end" );
	
	power_up_origin = level.last_dog_origin;
	if ( isdefined(e_last) )
	{
		power_up_origin = e_last.origin;
	}

	if( isdefined( power_up_origin ) )
	{
		level thread zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );
	}
	
	wait(2);
	util::clientNotify( "dog_stop" );
	wait(6);
	level.dog_intermission = false;

	//level thread dog_round_aftermath();

}


//
//	In Factory, there's a single spawner and the struct is passed in as the second argument.
function dog_spawn_fx( ai, ent )
{
	ai endon( "death" );
	
	/*if ( !IsDefined(ent) )
	{
		ent = struct::get( self.target, "targetname" );
	}*/

	ai SetFreeCameraLockOnAllowed( false );
//	if ( isdefined( ent ) )
	{
		if(ai.type_dog == "default")
		{
			IPrintLnBold("dog_spawn_fx default");
			Playfx( level._effect["lightning_dog_nuked_spawn"], ent.origin );
			playsoundatposition( "zmb_hellhound_prespawn", ent.origin );
			wait( 1.5 );
			playsoundatposition( "zmb_hellhound_bolt", ent.origin );

			Earthquake( 0.5, 0.75, ent.origin, 1000);
		//PlayRumbleOnPosition("explosion_generic", ent.origin);
			playsoundatposition( "zmb_hellhound_spawn", ent.origin );
		}
		else if(ai.type_dog == "elec")
		{
			IPrintLnBold("dog_spawn_fx elec");
			Playfx( level._effect["lightning_dog_nuked_electric_spawn"], ent.origin );
			playsoundatposition( "zmb_hellhound_prespawn", ent.origin );
			wait( 1.5 );
			playsoundatposition( "zmb_hellhound_bolt", ent.origin );

			Earthquake( 0.5, 0.75, ent.origin, 1000);
		//PlayRumbleOnPosition("explosion_generic", ent.origin);
			playsoundatposition( "zmb_hellhound_spawn", ent.origin );
		}
		else if(ai.type_dog == "nova")
		{
			IPrintLnBold("dog_spawn_fx nova");
			Playfx( level._effect["lightning_dog_nuked_nova_spawn"], ent.origin );
			playsoundatposition( "zmb_hellhound_prespawn", ent.origin );
			wait( 1.5 );
			playsoundatposition( "zmb_hellhound_bolt", ent.origin );

			Earthquake( 0.5, 0.75, ent.origin, 1000);
		//PlayRumbleOnPosition("explosion_generic", ent.origin);
			playsoundatposition( "zmb_hellhound_spawn", ent.origin );
		}
		else 
		{
			Playfx( level._effect["lightning_dog_nuked_spawn"], ent.origin );
			playsoundatposition( "zmb_hellhound_prespawn", ent.origin );
			wait( 1.5 );
			playsoundatposition( "zmb_hellhound_bolt", ent.origin );

			Earthquake( 0.5, 0.75, ent.origin, 1000);
		//PlayRumbleOnPosition("explosion_generic", ent.origin);
			playsoundatposition( "zmb_hellhound_spawn", ent.origin );
		}




		// face the enemy
		if ( IsDefined( ai.favoriteenemy ) )
		{
			angle = VectorToAngles( ai.favoriteenemy.origin - ent.origin );
			angles = ( ai.angles[0], angle[1], ai.angles[2] );
		}
		else
		{
			angles = ent.angles;
		}
		ai ForceTeleport( ent.origin, angles );
	}

	assert( isdefined( ai ), "Ent isn't defined." );
	assert( IsAlive( ai ), "Ent is dead." );
	assert( ai.isdog, "Ent isn't a dog;" );
	assert( zm_utility::is_magic_bullet_shield_enabled( ai ), "Ent doesn't have a magic bullet shield." );

	ai zombie_setup_attack_properties_dog();
	ai util::stop_magic_bullet_shield();

	wait( 0.1 ); // dog should come out running after this wait
	ai show();
	ai SetFreeCameraLockOnAllowed( true );
	ai.ignoreme = false; // don't let attack dogs give chase until the wolf is visible
	ai notify( "visible" );
}


//
//	Dog spawning logic for Factory.  
//	Makes use of the _zm_zone_manager and specially named structs for each zone to
//	indicate dog spawn locations instead of constantly using ents.
//	
function dog_spawn_factory_logic( favorite_enemy)
{
	dog_locs = array::randomize( level.zm_loc_types[ "dog_location" ] );
	//assert( dog_locs.size > 0, "Dog Spawner locs array is empty." );

	for( i = 0; i < dog_locs.size; i++ )
	{
		if( isdefined( level.old_dog_spawn ) && level.old_dog_spawn == dog_locs[i] )
		{
			continue;
		}

		if( !isdefined( favorite_enemy ) )
		{
			continue;	
		}
		
		dist_squared = DistanceSquared( dog_locs[i].origin, favorite_enemy.origin );
		if(  dist_squared > ( 400 * 400 ) && dist_squared < ( 1000 * 1000 ) )
		{
			level.old_dog_spawn = dog_locs[i];
			return dog_locs[i];
		}	
	}

	return dog_locs[0];
}


function get_favorite_enemy()
{
	dog_targets = getplayers();
	least_hunted = dog_targets[0];
	for( i = 0; i < dog_targets.size; i++ )
	{
		if ( !isdefined( dog_targets[i].hunted_by ) )
		{
			dog_targets[i].hunted_by = 0;
		}

		if( !zm_utility::is_player_valid( dog_targets[i] ) )
		{
			continue;
		}

		if( !zm_utility::is_player_valid( least_hunted ) )
		{
			least_hunted = dog_targets[i];
		}
			
		if( dog_targets[i].hunted_by < least_hunted.hunted_by )
		{
			least_hunted = dog_targets[i];
		}

	}
	// do not return the default first player if he is invalid
	if( !zm_utility::is_player_valid( least_hunted ) )
	{
		return undefined;
	}
	else
	{
		least_hunted.hunted_by += 1;

		return least_hunted;
	}

}


function dog_health_increase()
{
	players = getplayers();

	if( level.dog_nuked_round_count == 1 )
	{
		level.dog_health = 400;
	}
	else if( level.dog_nuked_round_count == 2 )
	{
		level.dog_health = 900;
	}
	else if( level.dog_nuked_round_count == 3 )
	{
		level.dog_health = 1300;
	}
	else if( level.dog_nuked_round_count == 4 )
	{
		level.dog_health = 1600;
	}

	if( level.dog_health > 1600 )
	{
		level.dog_health = 1600;
	}
}

function dog_round_wait_func()
{
	if( level flag::get("dog_round" ) )
	{
		wait(7);
		while( level.dog_intermission )
		{
			wait(0.5);
		}	
		zm::increment_dog_round_stat("finished");	
	}
	
	level.sndMusicSpecialRound = false;
}

function dog_round_tracker()
{	
	level.dog_nuked_round_count = 1;
	
	// PI_CHANGE_BEGIN - JMA - making dog rounds random between round 5 thru 7
	// NOTE:  RandomIntRange returns a random integer r, where min <= r < max
	
	level.next_dog_round = level.round_number + randomintrange( 4, 7 );	
	// PI_CHANGE_END
	IPrintLnBold("1");
	old_spawn_func = level.round_spawn_func;
	old_wait_func  = level.round_wait_func;

	while ( 1 )
	{
		level waittill ( "between_round_over" );
		IPrintLnBold("2");
		if ( level.round_number == level.next_dog_round && !IsSubStr(level.ZombieGameType,"gauntlet"))
		{
			IPrintLnBold("3");
			level.sndMusicSpecialRound = true;
			old_spawn_func = level.round_spawn_func;
			old_wait_func  = level.round_wait_func;
			dog_round_start();
			level.round_spawn_func = &dog_round_spawning;
			level.round_wait_func = &dog_round_wait_func;
			level thread change_fog();
			level.next_dog_round = level.round_number + randomintrange( 4, 6 );
		}

		else if ( level.round_number == level.next_dog_round && IsSubStr(level.ZombieGameType,"gauntlet"))
		{
			IPrintLnBold("gauntlet dog track");
			level.sndMusicSpecialRound = true;
			old_spawn_func = level.round_spawn_func;
			old_wait_func  = level.round_wait_func;
			dog_round_start();
			level.round_spawn_func = &dog_round_spawning;
			level.round_wait_func = &dog_round_wait_func;
			level thread change_fog();
			old_next_dog_round = level.next_dog_round;
			level.next_dog_round = 999999; 
			level thread wait_gauntlet_challenge(old_next_dog_round);

		}
		else if ( level flag::get( "dog_round" ) )
		{
			IPrintLnBold("4");
			dog_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func  = old_wait_func;
			level.dog_nuked_round_count += 1;
			
		}
	}	
}

function wait_gauntlet_challenge(old_next_dog_round)
{ 
	level endon("challenge_succesfull");
	level waittill("challenge_failed");
	level.next_dog_round = old_next_dog_round;    
	
}
function round_dog_by_script()
{	

	old_spawn_func = level.round_spawn_func;
	old_wait_func  = level.round_wait_func;

		level.sndMusicSpecialRound = true;
		old_spawn_func = level.round_spawn_func;
		old_wait_func  = level.round_wait_func;
		dog_round_start();
		level.round_spawn_func = &dog_round_spawning;
		level.round_wait_func = &dog_round_wait_func;
		level thread change_fog();

		level waittill("end_of_round");
			IPrintLnBold("4");
		dog_round_stop();
		level.round_spawn_func = old_spawn_func;
			level.round_wait_func  = old_wait_func;
			level.dog_nuked_round_count += 1;
		

}

function change_fog()
{
	//level.perks_omega = true;
            //level flag::set( "rocket_is_fall" ); // door trinity_to_hatchkey
			IPrintLnBold("5");
	level clientfield::set("change_fog",3);

	level waittill( "dog_round_ending" );
	if(level.perks_omega == true && !level flag::get( "aftermath" )) // back to omega 
	{
		level clientfield::set("change_fog",4);
	}
	else if(level.perks_omega != true && !level flag::get( "aftermath" )) // back to nz 
	{
		level clientfield::set("change_fog",1);
	}
	else if(level flag::get( "aftermath" )) // back to aftermath
	{
		level clientfield::set("change_fog",2);
	}

}

function dog_round_start()
{
	level flag::set( "dog_round" );
	level flag::set( "special_round" );
	level flag::set( "dog_clips" );
	
	level notify( "dog_round_starting" );
	level thread zm_audio::sndMusicSystem_PlayState( "dog_start" );
	util::clientNotify( "dog_start" );

	if(isdefined(level.dog_melee_range))
	{
	 	SetDvar( "ai_meleeRange", level.dog_melee_range ); 
	}
	else
	{
	 	SetDvar( "ai_meleeRange", 100 ); 
	}
}


function dog_round_stop()
{
	level flag::clear( "dog_round" );
	level flag::clear( "special_round" );
	level flag::clear( "dog_clips" );
	
	level notify( "dog_round_ending" );
	util::clientNotify( "dog_stop" );
	
 	SetDvar( "ai_meleeRange", level.melee_range_sav ); 
 	SetDvar( "ai_meleeWidth", level.melee_width_sav );
 	SetDvar( "ai_meleeHeight", level.melee_height_sav );
}


function play_dog_round()
{
	self playlocalsound( "zmb_dog_round_start" );
	variation_count =5;
	
	wait(4.5);

	players = getplayers();
	num = randomintrange(0,players.size);
	players[num] zm_audio::create_and_play_dialog( "general", "dog_spawn" );
}


function dog_init()
{

	self.targetname = "zombie_dog";
	self.script_noteworthy = undefined;
	self.animname = "zombie_dog"; 		
	self.ignoreall = true; 
	self.ignoreme = true; // don't let attack dogs give chase until the wolf is visible
	self.allowdeath = true; 			// allows death during animscripted calls
	self.allowpain = false;
	self.force_gib = true; 		// needed to make sure this guy does gibs
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	// out both legs and then the only allowed stance should be prone.
	self.gibbed = false; 
	self.head_gibbed = false;
	self.default_goalheight = 40;
	self.ignore_inert = true;	
	
	self.holdfire			= true;

	//	self.disableArrivals = true; 
	//	self.disableExits = true; 
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;

	self.badplaceawareness = 0;
	self.chatInitialized = false;

	self.team = level.zombie_team;
	self.heroweapon_kill_power = ZM_DOGS_HERO_WEAPON_KILL_POWER;

	self AllowPitchAngle( 1 );
	self setPitchOrient();
	self setAvoidanceMask( "avoid none" );

	self PushActors( true );

	health_multiplier = 1.0;
	if ( GetDvarString( "scr_dog_health_walk_multiplier" ) != "" )
	{
		health_multiplier = GetDvarFloat( "scr_dog_health_walk_multiplier" );
	}

	self.maxhealth = int( level.dog_health * health_multiplier );
	self.health = int( level.dog_health * health_multiplier );

	self.freezegun_damage = 0;
	
	self.zombie_move_speed = "sprint";
	self.a.nodeath = true;//Always explode on death




	self thread dog_run_think(); //clix : on change le type de chien ici
	self thread dog_stalk_audio();

	self thread zombie_utility::round_spawn_failsafe();
	self ghost();
	self thread util::magic_bullet_shield();

	self thread dog_death(); //clix : on change le type de chien ici
	
	level thread zm_spawner::zombie_death_event( self ); 
	self thread zm_spawner::enemy_death_detection();
	self thread zm_audio::zmbAIVox_NotifyConvert();

	self.a.disablePain = true;
	self zm_utility::disable_react(); // SUMEET - zombies dont use react feature.
	self ClearGoalVolume();

	self.flame_damage_time = 0;
	self.meleeDamage = 40;

	self.thundergun_knockdown_func =&dog_thundergun_knockdown;

	self zm_spawner::zombie_history( "zombie_dog_spawn_init -> Spawned = " + self.origin );
	
	if ( isdefined(level.achievement_monitor_func) )
	{
		self [[level.achievement_monitor_func]]();
	}
}

function dog_death() //clix : on change le type de chien ici
{
	self waittill( "death" );

	if( zombie_utility::get_current_zombie_count() == 0 && level.zombie_total == 0 )
	{

		level.last_dog_origin = self.origin;
		level notify( "last_ai_down", self );

	}

	// score
	if( IsPlayer( self.attacker ) )
	{
		event = "death";
		if ( self.damageweapon.isBallisticKnife )
		{
			event = "ballistic_knife_death";
		}	
		
		if ( !IS_TRUE( self.deathpoints_already_given ) )
		{
			self.attacker zm_score::player_add_points( event, self.damagemod, self.damagelocation, true );
		}
		
		if( isdefined(level.hero_power_update))
		{
			[[level.hero_power_update]]( self.attacker, self );
		}		
	    
	    if( RandomIntRange(0,100) >= 80 )
	    {
	        self.attacker zm_audio::create_and_play_dialog( "kill", "hellhound" );
	    }
	    
	    //stats
		self.attacker zm_stats::increment_client_stat( "zdogs_killed" );
		self.attacker zm_stats::increment_player_stat( "zdogs_killed" );
	}

	// switch to inflictor when SP DoDamage supports it
	if( isdefined( self.attacker ) && isai( self.attacker ) )
	{
		self.attacker notify( "killed", self );
	}

	// sound
	self stoploopsound();

	// just explode if we died on an incline greater than 10 degrees
	if ( !IS_TRUE( self.a.nodeath ) )
	{
		trace = GroundTrace( self.origin + ( 0, 0, 10 ), self.origin - ( 0, 0, 30 ), false, self );
		if ( trace["fraction"] < 1 )
		{
			pitch = Acos( VectorDot( trace["normal"], ( 0, 0, 1 ) ) );
			if ( pitch > 10 )
			{
				self.a.nodeath = true;
			}
		}
	}

	if ( isdefined( self.a.nodeath ) )
	{
		level thread dog_explode_fx( self );
		if(self.type_dog == "nova")
			self thread dog_gas_explo_death();
		
		if(self.type_dog == "elec")
			self thread dog_elec_explo_death();


		self delete();
	}
	else
	{
	    self notify( "bhtn_action_notify", "death" );
	}
}














//DOG ELECTRICT DEATH
function dog_elec_explo_death()
{

	self thread dog_elec_explo(self.origin);	
	level thread dog_elec_area_of_effect(self.origin);
}
function dog_elec_explo(origin)
{
	PlaySoundAtPosition("zmb_quad_explo", origin);
	players = GetPlayers();
	zombies = GetAITeamArray(level.zombie_team);
	for(i = 0; i < players.size; i++)
	{
		if(Distance(origin, players[i].origin) <= DOG_NOVA_DEATH_EXPLO_RADIUS_PLR)
		{
			is_immune = 0;
			if(isdefined(level.dog_gas_immune_func))
			{
				is_immune = players[i] thread [[level.dog_gas_immune_func]]();
			}
			if(!is_immune)
			{
				players[i] ShellShock("explosion", 2.5);
				players[i] SetElectrified( 3 );
				players[i] thread zm_perks::lose_random_perk();
				RadiusDamage(origin, DOG_NOVA_DEATH_EXPLO_RADIUS_ZOMB, level.zombie_health, level.zombie_health, undefined, "MOD_EXPLOSIVE");			
			}
		}
	}
	self.exploded = 1;
	//self RadiusDamage(origin, DOG_NOVA_DEATH_EXPLO_RADIUS_ZOMB, level.zombie_health, level.zombie_health, self, "MOD_EXPLOSIVE");
}
function dog_elec_area_of_effect(origin)
{
	IPrintLn("^1 GAS EFFECT");
	effectArea = Spawn("trigger_radius", origin, 0, DOG_NOVA_DEATH_GAS_RADIUS, 100);
	PlayFX(level._effect["dog_nuked_electric_death"], origin);
	for(gas_time = 0; gas_time < DOG_NOVA_DEATH_GAS_TIME;  gas_time++)
	{
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			is_immune = 0;
			if(isdefined(level.dog_gas_immune_func))
			{
				is_immune = players[i] thread [[level.dog_gas_immune_func]]();
			}
			if(players[i] IsTouching(effectArea) && !is_immune)
			{
				IPrintLn("^1 elec TO PLAYER EFFECT");
				//players[i] SetBlur(15,1);
				players[i] SetElectrified( 1 );
				//continue;
			}
			players[i] SetBlur(0,1);
			//visionset_mgr::deactivate("overlay", "zm_ai_quad_blur", players[i]);
			
		}
		//wait(1);
	}
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] SetBlur(0,1);
	}
	effectArea Delete();
}






























//DOG GAZ DEATH
function dog_gas_explo_death()
{
	origin = self.origin;
	self thread dog_death_explo(origin);	
	level thread dog_gas_area_of_effect(origin);
}
function dog_death_explo(origin)
{
	PlaySoundAtPosition("zmb_quad_explo", origin);
	players = GetPlayers();
	zombies = GetAITeamArray(level.zombie_team);
	for(i = 0; i < players.size; i++)
	{
		if(Distance(origin, players[i].origin) <= DOG_NOVA_DEATH_EXPLO_RADIUS_PLR)
		{
			is_immune = 0;
			if(isdefined(level.dog_gas_immune_func))
			{
				is_immune = players[i] thread [[level.dog_gas_immune_func]]();
			}
			if(!is_immune)
			{
				players[i] ShellShock("explosion", 2.5);
				RadiusDamage(origin, DOG_NOVA_DEATH_EXPLO_RADIUS_ZOMB, level.zombie_health, level.zombie_health, undefined, "MOD_EXPLOSIVE");
			}
		}
	}
	
	self.exploded = 1;
	
}
function dog_gas_area_of_effect(origin)
{
	IPrintLn("^1 GAS EFFECT");
	effectArea = Spawn("trigger_radius", origin, 0, DOG_NOVA_DEATH_GAS_RADIUS, 100);
	PlayFX(level._effect["quad_explo_gas"], origin);
	
	for(gas_time = 0; gas_time < DOG_NOVA_DEATH_GAS_TIME;  gas_time++)
	{
		
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			is_immune = 0;
			if(isdefined(level.dog_gas_immune_func))
			{
				is_immune = players[i] thread [[level.dog_gas_immune_func]]();
			}
			if(players[i] IsTouching(effectArea) && !is_immune)
			{
				IPrintLn("^1 BLUR TO PLAYER EFFECT");
				players[i] SetBlur(15,1);
				//continue;
			}
			else
				players[i] SetBlur(0,1);
			//visionset_mgr::deactivate("overlay", "zm_ai_quad_blur", players[i]);
			
		}
		
		//wait(1);
	}
	
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] SetBlur(0,1);
	}
	effectArea Delete();
}































function dog_explode_fx( dog )
{
	if(dog.type_dog == "default")
	{
		PlayFX( level._effect["dog_nuked_gib"], dog.origin );
		PlaySoundAtPosition( DOG_DEFAULT_DEATH_ALIAS, dog.origin );
	}
	if(dog.type_dog == "elec")
	{
		PlayFX( level._effect["dog_nuked_electric_gib"], dog.origin );
		PlaySoundAtPosition( DOG_ELECTRIC_DEATH_ALIAS, dog.origin );
	}
	if(dog.type_dog == "nova")
	{
		PlayFX( level._effect["dog_nuked_nova_gib"], dog.origin );
		PlaySoundAtPosition( DOG_NOVA_DEATH_ALIAS, dog.origin );
	}
}


// this is where zombies go into attack mode, and need different attributes set up
function zombie_setup_attack_properties_dog()
{
	self zm_spawner::zombie_history( "zombie_setup_attack_properties()" );
	
	self thread dog_behind_audio();

	// allows zombie to attack again
	self.ignoreall = false; 

	//self.pathEnemyFightDist = 64;
	self.meleeAttackDist = 64;

	// turn off transition anims
	self.disableArrivals = true; 
	self.disableExits = true; 

	if ( isdefined( level.dog_setup_func ) )
	{
		self [[level.dog_setup_func]]();
	}
}


//COLLIN'S Audio Scripts
function stop_dog_sound_on_death()
{
	self waittill("death");
	self stopsounds();
}

function dog_behind_audio()
{
	self thread stop_dog_sound_on_death();

	self endon("death");
	self util::waittill_any( "dog_running", "dog_combat" );
	
	self notify( "bhtn_action_notify", "close" );
	wait( 3 );

	while(1)
	{
		players = GetPlayers();
		for(i=0;i<players.size;i++)
		{
			dogAngle = AngleClamp180( vectorToAngles( self.origin - players[i].origin )[1] - players[i].angles[1] );
		
			if(isAlive(players[i]) && !isdefined(players[i].revivetrigger))
			{
				if ((abs(dogAngle) > 90) && distance2d(self.origin,players[i].origin) > 100)
				{
					self notify( "bhtn_action_notify", "close" );
					wait( 3 );
				}
			}
		}
		
		wait(.75);
	}
}


//
//	Keeps dog_clips up if there is a dog running around in the level.
function dog_clip_monitor()
{
	clips_on = false;
	level.dog_clips = GetEntArray( "dog_clips", "targetname" );
	while (1)
	{
		for ( i=0; i<level.dog_clips.size; i++ )
		{
	//		level.dog_clips[i] TriggerEnable( false );
			level.dog_clips[i] ConnectPaths();
		}

		level flag::wait_till( "dog_clips" );
		
		if(isdefined(level.no_dog_clip) && level.no_dog_clip == true)
		{
			return;
		}
		
		for ( i=0; i<level.dog_clips.size; i++ )
		{
	//		level.dog_clips[i] TriggerEnable( true );
			level.dog_clips[i] DisconnectPaths();
			util::wait_network_frame();
		}

		dog_is_alive = true;
		while ( dog_is_alive || level flag::get( "dog_round" ) )
		{
			dog_is_alive = false;
			dogs = GetEntArray( "zombie_dog", "targetname" );
			for ( i=0; i<dogs.size; i++ )
			{
				if ( IsAlive(dogs[i]) )
				{
					dog_is_alive = true;
				}
			}
			wait( 1 );
		}

		level flag::clear( "dog_clips" );
		wait(1);
	}
}

//
//	Allows dogs to be spawned independent of the round spawning
function special_dog_spawn( num_to_spawn, spawners, spawn_point )
{
	dogs = GetAISpeciesArray( "all", "zombie_dog" );

	if ( isdefined( dogs ) && dogs.size >= 9 )
	{
		return false;
	}
	
	if ( !isdefined(num_to_spawn) )
	{
		num_to_spawn = 1;
	}

	spawn_point = undefined;
	count = 0;
	while ( count < num_to_spawn )
	{
		//update the player array.
		players = GetPlayers();
		favorite_enemy = get_favorite_enemy();

		if ( isdefined( spawners ) )
		{
			if ( !isdefined( spawn_point ) )
			{
				spawn_point = spawners[ RandomInt(spawners.size) ];
			}
			ai = zombie_utility::spawn_zombie( spawn_point );

			if( isdefined( ai ) ) 	
			{
				ai thread define_dog_type();
				IPrintLnBold("Un chien de type" +self.type_dog+ "à spawn");
				ai.favoriteenemy = favorite_enemy;
				spawn_point thread dog_spawn_fx( ai );
				count++;
				level flag::set( "dog_clips" );
			}
		}
		else
		{
			if ( isdefined( level.dog_spawn_func ) )
			{
				spawn_loc = [[level.dog_spawn_func]]( level.dog_nuked_spawners, favorite_enemy );

				ai = zombie_utility::spawn_zombie( level.dog_nuked_spawners[0] );
				if( isdefined( ai ) ) 	
				{
					ai thread define_dog_type();
					IPrintLnBold("Un chien de type" +self.type_dog+ "à spawn");
					ai.favoriteenemy = favorite_enemy;
					spawn_loc thread dog_spawn_fx( ai, spawn_loc );
					count++;
					level flag::set( "dog_clips" );
				}
			}
			else
			{
				// Default method
				spawn_point = dog_spawn_factory_logic( favorite_enemy );
				ai = zombie_utility::spawn_zombie( level.dog_nuked_spawners[0] );

				if( isdefined( ai ) ) 	
				{
					ai thread define_dog_type();
					IPrintLnBold("Un chien de type" +self.type_dog+ "à spawn");
					ai.favoriteenemy = favorite_enemy;
					spawn_point thread dog_spawn_fx( ai, spawn_point );
					count++;
					level flag::set( "dog_clips" );
				}
			}
		}

		if(isdefined(level.special_wait_next_dog_spawn))
		{
			[[level.special_wait_next_dog_spawn]](count, num_to_spawn);
		}
		else	
			waiting_for_next_dog_spawn( count, num_to_spawn );
	}

	return true;
}

function define_dog_type()
{
	type = [];
	if(level flag::get("zombie_dog_default"))
	{
		type[type.size] = "default";
	}	
	if(level flag::get("zombie_dog_elec"))
	{
		type[type.size] = "elec";
	}
	if(level flag::get("zombie_dog_nova"))
	{
		type[type.size] = "nova";
	}
	type = array::randomize(type);

	self.type_dog = type[0];
}

function setAnimRate()
{
	if(self.type_dog == "default")
	{
		if(level.gamemode_menu["difficulty_setting"].setting == "easy")  
			self ASMSetAnimationRate( DOG_DEFAULT_MOVE_SPEED_EASY );
        else if(level.gamemode_menu["difficulty_setting"].setting == "normal" )    
			self ASMSetAnimationRate( DOG_DEFAULT_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "hard" )    
			self ASMSetAnimationRate( DOG_DEFAULT_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "realist" )    
			self ASMSetAnimationRate( DOG_DEFAULT_MOVE_SPEED );
	}
	if(self.type_dog == "elec")
	{
		if(level.gamemode_menu["difficulty_setting"].setting == "easy")  
			self ASMSetAnimationRate( DOG_ELECTRIC_MOVE_SPEED_EASY );
        else if(level.gamemode_menu["difficulty_setting"].setting == "normal" )    
			self ASMSetAnimationRate( DOG_ELECTRIC_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "hard" )    
			self ASMSetAnimationRate( DOG_ELECTRIC_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "realist" )    
			self ASMSetAnimationRate( DOG_ELECTRIC_MOVE_SPEED );
	}
	if(self.type_dog == "nova")
	{
		
		if(level.gamemode_menu["difficulty_setting"].setting == "easy")  
			self ASMSetAnimationRate( DOG_NOVA_MOVE_SPEED_EASY );
        else if(level.gamemode_menu["difficulty_setting"].setting == "normal" )    
			self ASMSetAnimationRate( DOG_NOVA_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "hard" )    
			self ASMSetAnimationRate( DOG_NOVA_MOVE_SPEED );

        else if(level.gamemode_menu["difficulty_setting"].setting == "realist" )    
			self ASMSetAnimationRate( DOG_NOVA_MOVE_SPEED );
	}
}

function dog_run_think() //clix : on change le type de chien ici
{
	self endon( "death" );

	
	// these should go back in when the stalking stuff is put back in, the visible check will do for now
	//self util::waittill_any( "dog_running", "dog_combat" );
	//self playsound( "zdog_close" );
	self waittill( "visible" );
	
	// decrease health
	if ( self.health > level.dog_health )
	{
		self.maxhealth = level.dog_health;
		self.health = level.dog_health;
	}
	IPrintLnBold("OUI");
	self thread setAnimRate();
	if(self.type_dog == "default")
	{
		// start glowing eyes & fire trail
		
		self clientfield::set( "dog_nuked_fx", 1 );
		self playloopsound( DOG_DEFAULT_LOOP_ALIAS );
	}
	if(self.type_dog == "elec")
	{
		// start glowing eyes & fire trail
		//self SetEntityAnimRate( 0.3 );
		
		self clientfield::set( "dog_nuked_fx", 2 );
		self playloopsound( DOG_ELECTRIC_LOOP_ALIAS );
	}
	if(self.type_dog == "nova")
	{
		// start glowing eyes & fire trail
		self clientfield::set( "dog_nuked_fx", 3 );
		self playloopsound( DOG_NOVA_LOOP_ALIAS );
	}
	

	//Check to see if the enemy is not valid anymore
	while( true )
	{
		if( !zm_utility::is_player_valid(self.favoriteenemy) )
		{
			//We are targetting an invalid player - select another one
			self.favoriteenemy = get_favorite_enemy();
		}
		if( isdefined( level.custom_dog_target_validity_check ) )
		{
			self [[ level.custom_dog_target_validity_check ]]();
		} 
		wait( 0.2 );
	
	}
}

function dog_stalk_audio()
{
	self endon( "death" );
	self endon( "dog_running" );
	self endon( "dog_combat" );
	
	while(1)
	{
		self notify( "bhtn_action_notify", "ambient" );
		wait randomfloatrange(2,4);		
	}
}

function dog_thundergun_knockdown( player, gib )
{
	self endon( "death" );

	damage = int( self.maxhealth * 0.5 );
	self DoDamage( damage, player.origin, player );
}
