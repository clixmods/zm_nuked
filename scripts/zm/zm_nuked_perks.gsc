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
#using scripts\shared\trigger_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\zombie_shared;
#using scripts\shared\system_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_perks;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\duplicaterender.gsh;


#using scripts\zm\_util;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_net;
#using scripts\shared\ai\zombie_death;
#using scripts\zm\_zm_pack_a_punch_util;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
// #using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\nuked_utility;

// Hold feature used for Nuketown quest
//#using scripts\zm\ee\ee_tv_code;

#namespace zm_nuked_perks;

#define TRIGGER_OFF_OFFSET_VECTOR (0, 0, -10000)

#precache("model","specialty_quickrevive");
#precache("model","p7_fxanim_zm_bow_rune_prison_mod");

#define TRAIL_PERK  "dlc5/moon/fx_meteor_trail"
#precache( "fx", TRAIL_PERK );

function autoexec __init__sytem__()
{
    system::register("nuked_perks", &__init__,undefined, undefined);
}

function __init__()
{
	clientfield::register( "scriptmover", "clientfield_perk_intro_fx", VERSION_SHIP, 1, "int" );	

	level flag::init("perks_cycle_defined");

	level.perk_arrival_vehicle = GetEnt( "perk_arrival_vehicle", "targetname" );
	level.perk_arrival_vehicle SetModel( "tag_origin" );
	flag::init( "perk_vehicle_bringing_in_perk" );
	structs = struct::get_array( "zm_perk_machine", "targetname" );
	i = 0;
	while ( i < structs.size )
	{
		structs Delete();
		structs[ i ] struct::delete();
		i++;
	}

	level.nuked_perks = [];
	level.nuked_perks[ 0 ] = SpawnStruct();
	level.nuked_perks[ 0 ].model = "p7_zm_vending_revive";
	level.nuked_perks[ 0 ].script_noteworthy = "specialty_quickrevive";
	level.nuked_perks[ 0 ].turn_on_notify = "revive_on";
	level.nuked_perks[ 1 ] = SpawnStruct();
	level.nuked_perks[ 1 ].model = "p7_zm_vending_sleight";
	level.nuked_perks[ 1 ].script_noteworthy = "specialty_fastreload";
	level.nuked_perks[ 1 ].turn_on_notify = "sleight_on";
	level.nuked_perks[ 2 ] = SpawnStruct();
	level.nuked_perks[ 2 ].model = "p7_zm_vending_doubletap2";
	level.nuked_perks[ 2 ].script_noteworthy = "specialty_doubletap2";
	level.nuked_perks[ 2 ].turn_on_notify = "doubletap_on";
	level.nuked_perks[ 3 ] = SpawnStruct();
	level.nuked_perks[ 3 ].model = "p7_zm_vending_jugg";
	level.nuked_perks[ 3 ].script_noteworthy = "specialty_armorvest";
	level.nuked_perks[ 3 ].turn_on_notify = "juggernog_on";
	//level.nuked_perks[ 4 ] = spawnstruct();
	//level.nuked_perks[ 4 ].model = "p6_anim_zm_buildable_pap";
	//level.nuked_perks[ 4 ].script_noteworthy = "specialty_weapupgrade";
	//level.nuked_perks[ 4 ].turn_on_notify = "Pack_A_Punch_on";

	level.nuked_perks[ 4 ] = SpawnStruct();
	level.nuked_perks[ 4 ].model = "p7_zm_vending_marathon";
	level.nuked_perks[ 4 ].script_noteworthy = "specialty_staminup";
	level.nuked_perks[ 4 ].turn_on_notify = "specialty_staminup_power_on";

	level.nuked_perks[ 5 ] = SpawnStruct();
	level.nuked_perks[ 5 ].model = "p7_zm_vending_deadshot";
	level.nuked_perks[ 5 ].script_noteworthy = "specialty_deadshot";
	level.nuked_perks[ 5 ].turn_on_notify = "specialty_deadshot_power_on";
		
	level.nuked_perks[ 6 ] = SpawnStruct();
	level.nuked_perks[ 6 ].model = "p7_zm_vending_three_gun";
	level.nuked_perks[ 6 ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.nuked_perks[ 6 ].turn_on_notify = "specialty_additionalprimaryweapon_power_on";
		
	level.nuked_perks[ 7 ] = SpawnStruct();
	level.nuked_perks[ 7 ].model = "p7_zm_vending_widows_wine";
	level.nuked_perks[ 7 ].script_noteworthy = "specialty_widowswine";
	level.nuked_perks[ 7 ].turn_on_notify = "specialty_widowswine_power_on";
		
	players = GetNumExpectedPlayers();
	if ( players == 1 )
	{
		level.nuked_perks_first_revive = true;
		// PACK A PUNCH
		perk_structs_pap = struct::get_array( "zm_random_machine", "script_noteworthy" );
		slot = RandomIntRange(0,perk_structs_pap.size);
		level.pap_pos_struct = perk_structs_pap[slot];
		perk_structs_pap[slot] Delete();
		perk_structs_pap[slot] struct::delete();
		level notify("pap_have_a_position");

		level.override_perk_targetname = "zm_perk_machine_override";
		level.revive_struct_roof = struct::get_array( "solo_revive", "targetname" );
		i = 0;
		while ( i < level.revive_struct_roof.size )
		{
			random_revive_structs[ i ] = struct::get( level.revive_struct_roof[ i ].target, "targetname" );
			random_revive_structs[ i ].cequejeveux = level.revive_struct_roof[ i ];
			random_revive_structs[ i ].script_int = level.revive_struct_roof[ i ].script_int;
			i++;
		}

		level.random_revive_structs = zombie_death::randomize_array( random_revive_structs );
		level.random_revive_structs[ 0 ].targetname = "zm_perk_machine_override";
		level.random_revive_structs[ 0 ].model = level.nuked_perks[ 0 ].model;
		level.random_revive_structs[ 0 ].blocker_model = getent( level.random_revive_structs[ 0 ].target, "targetname" );
		level.random_revive_structs[ 0 ].script_noteworthy = level.nuked_perks[ 0 ].script_noteworthy;
		level.random_revive_structs[ 0 ].turn_on_notify = level.nuked_perks[ 0 ].turn_on_notify;
		if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
		{
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
		}
		level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_revive_structs[ 0 ];


		
		random_perk_structs = [];
		perk_structs = struct::get_array( "zm_random_machine", "script_noteworthy" );
		perk_structs = array::exclude( perk_structs, level.random_revive_structs[ 0 ].cequejeveux );
		i = 0;
		while ( i < perk_structs.size )
		{
			random_perk_structs[ i ] = struct::get( perk_structs[ i ].target, "targetname" );
			random_perk_structs[ i ].script_int = perk_structs[ i ].script_int;
			i++;
		}

		level.random_perk_structs = zombie_death::randomize_array( random_perk_structs );
		i = 1;

		while ( i < 8 )
		{
			level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
			level.random_perk_structs[ i ].model = level.nuked_perks[ i ].model;
			level.random_perk_structs[ i ].blocker_model = getent( level.random_perk_structs[ i ].target, "targetname" );
			level.random_perk_structs[ i ].script_noteworthy = level.nuked_perks[ i ].script_noteworthy;
			level.random_perk_structs[ i ].turn_on_notify = level.nuked_perks[ i ].turn_on_notify;

			if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
			{
				level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
			}
			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
			i++;
		}
	}
	else 
	{
		// PACK A PUNCH
		perk_structs_pap = struct::get_array( "zm_random_machine", "script_noteworthy" );
		slot = RandomIntRange(0,perk_structs_pap.size);
		level.pap_pos_struct = perk_structs_pap[slot];
		perk_structs_pap[slot] Delete();
		perk_structs_pap[slot] struct::delete();

		level notify("pap_have_a_position");

		level.override_perk_targetname = "zm_perk_machine_override";
		random_perk_structs = [];
		perk_structs = struct::get_array( "zm_random_machine", "script_noteworthy" );

		i = 0;

		while ( i < perk_structs.size )
		{
			random_perk_structs[ i ] = struct::get( perk_structs[ i ].target, "targetname" );
			random_perk_structs[ i ].script_int = perk_structs[ i ].script_int;
			i++;
		}

		level.random_perk_structs = zombie_death::randomize_array( random_perk_structs );
		i = 0;

		while ( i < 8 )
		{
			level.random_perk_structs[ i ].targetname = "zm_perk_machine_override";
			level.random_perk_structs[ i ].model = level.nuked_perks[ i ].model;
			level.random_perk_structs[ i ].blocker_model = getent( level.random_perk_structs[ i ].target, "targetname" );
			level.random_perk_structs[ i ].script_noteworthy = level.nuked_perks[ i ].script_noteworthy;
			level.random_perk_structs[ i ].turn_on_notify = level.nuked_perks[ i ].turn_on_notify;
			
			if ( !isDefined( level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] ) )
			{
				level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ] = [];
			}

			level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ][ level.struct_class_names[ "targetname" ][ "zm_perk_machine_override" ].size ] = level.random_perk_structs[ i ];
			i++;
		}
 	}
}


function bring_random_perk( machines, machine_triggers )
{
	count = machines.size;

	if ( count <= 0 )
	{
		return;
	}
	
	index = zombie_death::randomize_array( count );
	bring_perk( machines[ index ], machine_triggers[ index ] );
	arrayremoveindex( machines, index );
	arrayremoveindex( machine_triggers, index );
}

function bring_perk( machine, trigger )
{
	players = GetPlayers();
	is_doubletap = 0;
	is_sleight = 0;
	is_revive = 0;
	is_jugger = 0;
	is_staminup = 0;
	is_deadshot = 0;
	is_additionalprimaryweapon = 0;
	is_widowswine = 0;
	level flag::wait_till_clear( "perk_vehicle_bringing_in_perk" );
	PlaySoundAtPosition( "zmb_perks_incoming_quad_front", ( 0, -1, 0 ) );
	PlaySoundAtPosition( "zmb_perks_incoming_alarm", ( -2198, 486, 327 ) );
	machine clientfield::set( "clientfield_perk_intro_fx", 1 );
	machine thread perk_incoming_sound();
	machine LinkTo( level.perk_arrival_vehicle, "tag_origin", ( 0, -1, 0 ), ( 0, -1, 0 ) );
	i = RandomIntRange(0,3);

	if(isdefined(level.perks_omega) && i >= 1)
	{
		a = RandomIntRange(0,2);
		if(a != 1)
		{
			start_node = GetVehicleNode( "perk_arrival_path_" + machine.script_int + "_omega_bis", "targetname" );
			if(isdefined(start_node))
				machine.omega_loc_bis = true;
		}
		else if(a == 1)
		{
			start_node = GetVehicleNode( "perk_arrival_path_" + machine.script_int + "_omega", "targetname" );
			machine.omega_loc = true;
		}
		
		if(!isdefined(start_node))
		{
			start_node = GetVehicleNode( "perk_arrival_path_" + machine.script_int + "_omega", "targetname" );
			machine.omega_loc = true;
		}		

	}
	else
	{
		start_node = GetVehicleNode( "perk_arrival_path_" + machine.script_int, "targetname" );
	}

	level.perk_arrival_vehicle perk_follow_path( start_node );
	machine Unlink();
	offset = ( 0, -1, 0 );
	if ( issubstr( machine.targetname, "doubletap" ) )
	{
		machine.spec = "specialty_doubletap2";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		is_doubletap = 1;
	}
	else if ( issubstr( machine.targetname, "sleight" ) )
	{
		machine.spec = "specialty_fastreload";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		is_sleight = 1;
	}
	else if ( issubstr( machine.targetname, "revive" ) )
	{
		machine.spec = "specialty_quickrevive";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model Hide();
		is_revive = 1;
	}

	else if ( issubstr( machine.targetname, "vending_deadshot" ) )
	{
		machine.spec = "specialty_deadshot";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model Hide();
		is_deadshot = 1;
	}

	else if ( issubstr( machine.targetname, "additionalprimaryweapon" ) )
	{
		machine.spec = "specialty_additionalprimaryweapon";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model Hide();
		is_additionalprimaryweapon = 1;
	}

	else if ( issubstr( machine.targetname, "vending_marathon" ) )
	{
		machine.spec = "specialty_staminup";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model Hide();
		is_staminup = 1;
	}

	else if ( issubstr( machine.targetname, "widowswine" ) )
	{
		machine.spec = "specialty_widowswine";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		trigger.blocker_model Hide();
		is_widowswine = 1;
	}
	else if ( issubstr( machine.targetname, "vending_jugg" ) )
	{
		machine.spec = "specialty_armorvest";
		forward_dir = anglesToForward( machine.original_angles + vectorScale( ( 0, -1, 0 ), 90 ) );
		offset = vectorScale( forward_dir * -1, 10 );
		is_jugger = 1;
	}
		
	if ( !is_revive )
	{
		trigger.blocker_model Delete();
	}
	if(machine.omega_loc == true)
	{
		hab = 0;
		new_locs = struct::get_array("zm_random_machine_omega" , "script_noteworthy");
		while ( hab < new_locs.size )
		{
			loc[ hab ] = struct::get( new_locs[ hab ].target, "targetname" );
			//loc[ hab ].cequejeveux = level.revive_struct_roof[ i ];
			loc[ hab ].script_int = new_locs[ hab ].script_int;
			if(loc[ hab ].script_int == machine.script_int)
			{
				chose_pos = loc[ hab ];
			}
			hab++;
		}
		
		machine.origin = chose_pos.origin;
		machine.angles = chose_pos.angles;
		trigger.origin = chose_pos.origin;
		trigger.angles = chose_pos.angles;
		//perk = self.script_noteworthy;
		//perk = vending_triggers[nearest].script_noteworthy;
		vending_triggers = GetEntArray( "zombie_vending", "targetname" );
		for ( i = 0; i < vending_triggers.size; i++ )
		{
			IPrintLnBold("vending_triggers[i].script_noteworthy :"+vending_triggers[i].script_noteworthy);
			if ( vending_triggers[i].script_noteworthy == machine.spec )
			{
				IPrintLn("atout origin avant"+vending_triggers[i].origin);
				trigger_pos = Spawn("script_model", machine.origin + (0, 0, 60), 0, 40, 80);
				trigger_pos SetModel("tag_origin");

				vending_triggers[i] EnableLinkTo();
				vending_triggers[i] LinkTo( trigger_pos , "tag_origin", (0, 0, -30));

				IPrintLn("atout origin apre"+vending_triggers[i].origin);
			}
		}
	}

	else if(machine.omega_loc_bis == true)
	{
		hab = 0;
		new_locs = struct::get_array("zm_random_machine_omega_bis" , "script_noteworthy");
		while ( hab < new_locs.size )
		{
			loc[ hab ] = struct::get( new_locs[ hab ].target, "targetname" );
			//loc[ hab ].cequejeveux = level.revive_struct_roof[ i ];
			loc[ hab ].script_int = new_locs[ hab ].script_int;
			if(loc[ hab ].script_int == machine.script_int)
			{
				chose_pos = loc[ hab ];
			}
			hab++;
		}
		
		machine.origin = chose_pos.origin;
		machine.angles = chose_pos.angles;
		trigger.origin = chose_pos.origin;
		trigger.angles = chose_pos.angles;
		//perk = self.script_noteworthy;
		//perk = vending_triggers[nearest].script_noteworthy;
		vending_triggers = GetEntArray( "zombie_vending", "targetname" );
		for ( i = 0; i < vending_triggers.size; i++ )
		{
			IPrintLnBold("vending_triggers[i].script_noteworthy :"+vending_triggers[i].script_noteworthy);
			if ( vending_triggers[i].script_noteworthy == machine.spec )
			{
				IPrintLn("atout origin avant"+vending_triggers[i].origin);
				trigger_pos = Spawn("script_model", machine.origin + (0, 0, 60), 0, 40, 80);
				trigger_pos SetModel("tag_origin");

				vending_triggers[i] EnableLinkTo();
				vending_triggers[i] LinkTo( trigger_pos , "tag_origin", (0, 0, -30));

				IPrintLn("atout origin apre"+vending_triggers[i].origin);
			}
		}
	}

	else
	{	
		machine.original_pos += ( offset[ 0 ], offset[ 1 ], 0 );
		machine.origin = machine.original_pos;
		machine.angles = machine.original_angles;
	}

	if ( is_revive )
	{
		level.quick_revive_final_pos = machine.origin;
		level.quick_revive_final_angles = machine.angles;
	}
	machine.fx StopLoopSound( 0.5 );
	machine clientfield::set( "clientfield_perk_intro_fx", 0 );
	PlaySoundAtPosition( "zmb_perks_incoming_land", machine.origin );
	trigger trigger_on();
	machine thread bring_perk_landing_damage();
    
	machine.fx Unlink();
	machine.fx Delete();
	machine notify( machine.turn_on_notify );
	level notify( machine.turn_on_notify );
	machine Vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
	machine PlaySound( "zmb_perks_power_on" );
	machine zm_perks::perk_fx( undefined, 1 );
	if ( is_revive )
	{
		level.revive_machine_spawned = 1;
		machine thread zm_perks::perk_fx( "revive_light" );

	}
	else if ( is_jugger )
	{
		machine thread zm_perks::perk_fx( "jugger_light" );
	}
	else if ( is_doubletap )
	{
		machine thread zm_perks::perk_fx( "doubletap2_light" );

	}
	else if ( is_staminup )
	{
		machine thread zm_perks::perk_fx( "marathon_light" );
	}
	else if ( is_deadshot )
	{
		machine thread zm_perks::perk_fx( "deadshot_light" );
	}
	else if ( is_additionalprimaryweapon )
	{
		machine thread zm_perks::perk_fx( "additionalprimaryweapon_light" );
	}
	else if ( is_widowswine )
	{
		machine thread zm_perks::perk_fx( "widow_light" );
	}
	else
	{
		if ( is_sleight )
		{
			machine thread zm_perks::perk_fx( "sleight_light" );
		}
	}
}

function perk_incoming_sound()
{
	self endon( "death" );
	wait 10;
	self playsound( "zmb_perks_incoming" );
}

//"Name: blocker_delete"
//"Type: PERK"
//"Summary: Fait disparaitre les blocker des atouts
//"Suggestion : - A déplacer dans zm_nuked_perk
//              - "
//
function blocker_delete(id, omega_block, omega_block_bis)
{ 
    if(omega_block == true)
    {
        blocker = GetEntArray("explo_blocker_trig_"+id+"_omega", "targetname");
    }
	else if (omega_block_bis == true)
		blocker = GetEntArray("explo_blocker_trig_"+id+"_omega_bis", "targetname");

    else
        blocker = GetEntArray("explo_blocker_trig_"+id, "targetname");
    
    foreach(ent in blocker)
    {
        ent Hide();
        ent Delete();   
    }
   


    if(omega_block == true)
    {
        exploder::exploder("blocker_fx_"+id+"_omega");
    }
    else
        exploder::exploder("blocker_fx_"+id);   
}


function bring_perk_landing_damage()
{
	player_prone_damage_radius = 300;
	Earthquake( 0.7, 2.5, self.origin, 1000 );
	RadiusDamage( self.origin, player_prone_damage_radius, 10, 5, undefined, "MOD_EXPLOSIVE" );
	//IPrintLnBold("self.script_int correspond à " +self.script_int);
	blocker_delete(self.script_int, self.omega_loc );
	players = GetPlayers();
	i = 0;
	while ( i < players.size )
	{
		if ( DistanceSquared( players[ i ].origin, self.origin ) <= ( player_prone_damage_radius * player_prone_damage_radius ) )
		{
			players[ i ] SetStance( "prone" );
			players[ i ] ShellShock( "default", 1.5 );
			RadiusDamage( players[ i ].origin, player_prone_damage_radius / 2, 10, 5, undefined, "MOD_EXPLOSIVE" );
			level notify("player_shocked", players[i]);
		}
		i++;
	}
	// castle method
	a_ai_enemies = Array::get_all_closest(self.origin, GetAITeamArray(level.zombie_team), undefined, 40, 100);
	foreach(ai_zombie in a_ai_enemies)
	{
		ai_zombie DoDamage(ai_zombie.health + 100, ai_zombie.origin + VectorScale((0, 1, 0), 100));
	}
	/*
	zombies = GetAIArray( level.zombie_team );
	i = 0;
	while ( i < zombies.size )
	{
		zombie = zombies[ i ];
		if ( !isdefined( zombie ) || !IsAlive( zombie ) )
		{
			i++;
			continue;
		}
		else
		{
			if ( DistanceSquared( zombie.origin, self.origin ) > 250000 )
			{
				i++;
				continue;
			}
			else
			{
				zombie thread perk_machine_knockdown_zombie( self.origin );
			}
		}
		i++;
	}
	*/
}

function perk_machine_knockdown_zombie( origin )
{
	if(level.debug_nuked == true)
    {
		IPrintLnBold( "perk_machine_knockdown_zombie"  );
	}
	self.a.gib_ref = array::random( array( "guts", "right_arm", "left_arm" ) );
	self thread zombie_death::do_gib();
	level.zombie_total++;
	level.zombie_total_subtract++;
	self dodamage( self.health + 100, origin );
}

function perk_follow_path( node )
{
	//IPrintLnBold( "perk_follow_path"  );
	self flag::set( "perk_vehicle_bringing_in_perk" );
	self notify( "newpath" );
	if ( isdefined( node ) )
	{
		self.attachedpath = node;
	}
	pathstart = self.attachedpath;
	self.currentnode = self.attachedpath;
	if ( !isdefined( pathstart ) )
	{
		return;
	}
	self AttachPath( pathstart );
	self StartPath();
	self waittill( "reached_end_node" );
	flag::clear( "perk_vehicle_bringing_in_perk" );
}


function turn_perks_on()
{
	//wait 3;
	//zm_power::turn_power_on_and_open_doors();
	//level notify("Pack_A_Punch_off");
	zm_perks::perk_unpause(PERK_STAMINUP);
 		level notify("marathon_on");
  		wait(.1);
  		level notify("specialty_staminup_power_on"); 

  	zm_perks::perk_unpause(PERK_ADDITIONAL_PRIMARY_WEAPON);
        level notify("additionalprimaryweapon_on");
  		wait(.1);
  		level notify("specialty_additionalprimaryweapon_power_on"); 

  	zm_perks::perk_unpause(PERK_DOUBLETAP2);
        level notify("doubletap_on");
  		wait(.1);
  		level notify("specialty_doubletap2_power_on"); 

  	zm_perks::perk_unpause(PERK_JUGGERNOG);
        level notify("juggernog_on");
  		wait(.1);
  		level notify("specialty_armorvest_power_on"); 

  	zm_perks::perk_unpause(PERK_SLEIGHT_OF_HAND);
        level notify("sleight_on");
  		wait(.1);
  		level notify("specialty_fastreload_power_on"); 

  	zm_perks::perk_unpause(PERK_DEAD_SHOT);
        level notify("deadshot_on");
  		wait(.1);
  		level notify("specialty_deadshot_power_on"); 

  		        
    zm_perks::perk_unpause(PERK_WIDOWS_WINE);
        level notify("widows_wine_on");
  		wait(.1);
  		level notify("specialty_widowswine_power_on"); 

  	zm_perks::perk_unpause(PERK_QUICK_REVIVE);
        level notify( "revive_on" );
  		wait(.1);
        level notify( "specialty_quickrevive_power_on" );
        

}


function perks_from_the_sky() // CLASSIC, HARD, REALIST
{
	if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines[ 0 ] ) )
	{
		return;
	}

	machine_triggers[ 0 ] = GetEnt( "vending_revive", "target" );
	machine_number[0] = 0; // MARS 2019
	move_perk( machines[ 0 ], top_height, 5, 0.001 );
	machine_triggers[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );
	machine_number[1] = 1; // MARS 2019
	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	machine_number[2] = 2; // MARS 2019
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	machine_number[3] = 3; // MARS 2019
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();

	machines[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers[ 4 ] = GetEnt( "vending_marathon", "target" );
	machine_number[4] = 4; // MARS 2019
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();

	machines[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers[ 5 ] = GetEnt( "vending_deadshot", "target" );
	machine_number[5] = 5; // MARS 2019
	move_perk( machines[ 5 ], top_height, 5, 0.001 );
	machine_triggers[ 5 ] trigger_off();

	machines[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	machine_number[6] = 6; // MARS 2019
	move_perk( machines[ 6 ], top_height, 5, 0.001 );
	machine_triggers[ 6 ] trigger_off();

	machines[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers[ 7 ] = GetEnt( "vending_widowswine", "target" );
	machine_number[7] = 7; // MARS 2019
	move_perk( machines[ 7 ], top_height, 5, 0.001 );
	machine_triggers[ 7 ] trigger_off();

	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );
	players = GetPlayers();
	
	if ( level.nuked_perks_first_revive  == 1 )
	{
		wait 4;
		index = 0;
		bring_perk( machines[ index ], machine_triggers[ index ] ); // TV CODE
		level.codeA = machine_number[ index ];// TV CODE
		if(level.debug_nuked == true)
		{
			IPrintLnBold(level.codeA);// TV CODE
		}
		ArrayRemoveIndex( machines, index );
		ArrayRemoveIndex( machine_triggers, index );
		ArrayRemoveIndex( machine_number, index ); // TV CODE
		if(level.debug_nuked == true)
		{
			IPrintLnBold(level.codeA);// TV CODE
		}

	//i = RandomIntRange(machines.size);
	}
 	
	level notify("pap_can_chose_position");
	nuked_utility::wait_for_round_range_random( 3, 5 );
	wait RandomIntRange( 30, 60 );
	j = RandomInt( machines.size );
	bring_perk( machines[ j  ], machine_triggers[ j  ]); // TV CODE
	if(isdefined(level.codeA))
		{
			level.codeB = machine_number[ j ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeB); // TV CODE
			}
		}	
	else
		{
			level.codeA = machine_number[ j ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeA); // TV CODE
			}
		}			
	ArrayRemoveIndex( machines, j  );
	ArrayRemoveIndex( machine_triggers, j  );
	ArrayRemoveIndex( machine_number, j ); // TV CODE

	nuked_utility::wait_for_round_range_random( 6, 7 );
	wait RandomIntRange( 30, 60 );
	h = RandomInt( machines.size );
	bring_perk( machines[ h ], machine_triggers[ h  ] ); // TV CODE

	if(isdefined(level.codeB))
		{
			level.codeC = machine_number[ h ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeC); // TV CODE
			}
		}	
	else
		{
			level.codeB = machine_number[ h ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeB); // TV CODE
			}
		}		

	ArrayRemoveIndex( machines, h  );
	ArrayRemoveIndex( machine_triggers, h );
	ArrayRemoveIndex( machine_number, h );// TV CODE


	nuked_utility::wait_for_round_range_random( 8, 10 );
	wait RandomIntRange( 60, 120 );
	k = RandomInt( machines.size );
	bring_perk( machines[ k ], machine_triggers[ k  ] );// TV CODE
	if(isdefined(level.codeC))
		{
			level.codeD = machine_number[ k ]; // TV CODE
			//level thread ee_tv_code::add_code_to_tv(level.codeA,level.codeB,level.codeC,level.codeD,undefined,"drop_gersh");
			//level thread ee_tv_code::add_code_to_tv(level.codeD,level.codeC,level.codeB,level.codeA,undefined,"drop_wavegun");
			
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeD); // TV CODE
			}
		}	
	else
		{
			level.codeC = machine_number[ k ]; // TV CODE
			
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeC); // TV CODE
			}
		}	

	ArrayRemoveIndex( machines, k  );
	ArrayRemoveIndex( machine_triggers, k );
	ArrayRemoveIndex( machine_number, k );// TV CODE

	nuked_utility::wait_for_round_range_random( 11, 13 );
	wait RandomIntRange( 60, 120 );
	l = RandomInt( machines.size );
	bring_perk( machines[ l ], machine_triggers[ l  ] );
	if(!isdefined(level.codeD))
		{
			level.codeD = machine_number[ l ]; // TV CODE
			//level thread ee_tv_code::add_code_to_tv(level.codeA,level.codeB,level.codeC,level.codeD,undefined,"drop_gersh");
			//level thread ee_tv_code::add_code_to_tv(level.codeD,level.codeC,level.codeB,level.codeA,undefined,"drop_wavegun");
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeD); // TV CODE
			}
		}	
	ArrayRemoveIndex( machines, l  );
	ArrayRemoveIndex( machine_triggers, l );

	nuked_utility::wait_for_round_range_random( 14, 16 );
	wait RandomIntRange( 60, 120 );
	m = RandomInt( machines.size );
	bring_perk( machines[ m ], machine_triggers[ m  ] );
	ArrayRemoveIndex( machines, m  );
	ArrayRemoveIndex( machine_triggers, m );

	nuked_utility::wait_for_round_range_random( 17, 19 );
	wait RandomIntRange( 60, 120 );
	n = RandomInt( machines.size );
	bring_perk( machines[ n ], machine_triggers[ n  ] );
	ArrayRemoveIndex( machines, n  );
	ArrayRemoveIndex( machine_triggers, n );


	nuked_utility::wait_for_round_range_random( 20, 22 );
	wait RandomIntRange( 60, 120 );
	o = RandomInt( machines.size );
	bring_perk( machines[ o ], machine_triggers[ o  ] );
	ArrayRemoveIndex( machines, o  );
	ArrayRemoveIndex( machine_triggers, o );

	nuked_utility::wait_for_round_range_random( 23, 25 );
	wait RandomIntRange( 60, 120 );
	p = RandomInt( machines.size );
	bring_perk( machines[ p ], machine_triggers[ p  ] );
	ArrayRemoveIndex( machines, p  );
	ArrayRemoveIndex( machine_triggers, p );

}

function perks_from_the_sky_onelife() // CLASSIC, HARD, REALIST
{
		if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines_nop[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines_nop[ 0 ] ) )
	{
		return;
	}
	machine_triggers_nop[ 0 ] = GetEnt( "vending_revive", "target" );
	machine_number_nop[0] = 0; // MARS 2019
	move_perk( machines_nop[ 0 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );
	machine_number[1] = 1; // MARS 2019
	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	machine_number[2] = 2; // MARS 2019
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	machine_number[3] = 3; // MARS 2019
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();

	machines[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers[ 4 ] = GetEnt( "vending_marathon", "target" );
	machine_number[4] = 4; // MARS 2019
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();

	machines[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers[ 5 ] = GetEnt( "vending_deadshot", "target" );
	machine_number[5] = 5; // MARS 2019
	move_perk( machines[ 5 ], top_height, 5, 0.001 );
	machine_triggers[ 5 ] trigger_off();

	machines[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	machine_number[6] = 6; // MARS 2019
	move_perk( machines[ 6 ], top_height, 5, 0.001 );
	machine_triggers[ 6 ] trigger_off();

	machines[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers[ 7 ] = GetEnt( "vending_widowswine", "target" );
	machine_number[7] = 7; // MARS 2019
	move_perk( machines[ 7 ], top_height, 5, 0.001 );
	machine_triggers[ 7 ] trigger_off();
	//machine_triggers[ 4 ] = getent( "specialty_weapupgrade", "script_noteworthy" );
	//machines[ 4 ] = getent( machine_triggers[ 4 ].target, "targetname" );
	//move_perk( machines[ 4 ], top_height, 5, 0.001 );
	//machine_triggers[ 4 ] trigger_off();

	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );
	players = GetPlayers();
	if ( players.size == 1 )
	{
	wait 4;
		index = 1;
		bring_perk( machines[ index ], machine_triggers[ index ] ); // TV CODE
		level.codeA = machine_number[ index ];// TV CODE
		if(level.debug_nuked == true)
		{
			IPrintLnBold(level.codeA);// TV CODE
		}
		ArrayRemoveIndex( machines, index );
		ArrayRemoveIndex( machine_triggers, index );
		ArrayRemoveIndex( machine_number, index ); // TV CODE
		if(level.debug_nuked == true)
		{
			IPrintLnBold(level.codeA);// TV CODE
		}

	//i = RandomIntRange(machines.size);
	}
	nuked_utility::wait_for_round_range_random( 3, 5 );
	wait RandomIntRange( 30, 60 );
	j = RandomInt( machines.size );
	bring_perk( machines[ j  ], machine_triggers[ j  ]); // TV CODE
	if(isdefined(level.codeA))
		{
			level.codeB = machine_number[ j ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeB); // TV CODE
			}
		}	
	else
		{
			level.codeA = machine_number[ j ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeA); // TV CODE
			}
		}			
	ArrayRemoveIndex( machines, j  );
	ArrayRemoveIndex( machine_triggers, j  );
	ArrayRemoveIndex( machine_number, j ); // TV CODE

	nuked_utility::wait_for_round_range_random( 6, 7 );
	wait RandomIntRange( 30, 60 );
	h = RandomInt( machines.size );
	bring_perk( machines[ h ], machine_triggers[ h  ] ); // TV CODE

	if(isdefined(level.codeB))
		{
			level.codeC = machine_number[ h ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeC); // TV CODE
			}
		}	
	else
		{
			level.codeB = machine_number[ h ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeB); // TV CODE
			}
		}		

	ArrayRemoveIndex( machines, h  );
	ArrayRemoveIndex( machine_triggers, h );
	ArrayRemoveIndex( machine_number, h );// TV CODE


	nuked_utility::wait_for_round_range_random( 8, 10 );
	wait RandomIntRange( 60, 120 );
	k = RandomInt( machines.size );
	bring_perk( machines[ k ], machine_triggers[ k  ] );// TV CODE
	if(isdefined(level.codeC))
		{
			level.codeD = machine_number[ k ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeD); // TV CODE
			}
		}	
	else
		{
			level.codeC = machine_number[ k ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeC); // TV CODE
			}
		}	

	ArrayRemoveIndex( machines, k  );
	ArrayRemoveIndex( machine_triggers, k );
	ArrayRemoveIndex( machine_number, k );// TV CODE

	nuked_utility::wait_for_round_range_random( 11, 13 );
	wait RandomIntRange( 60, 120 );
	l = RandomInt( machines.size );
	bring_perk( machines[ l ], machine_triggers[ l  ] );
	if(!isdefined(level.codeD))
		{
			level.codeD = machine_number[ l ]; // TV CODE
			if(level.debug_nuked == true)
			{
				IPrintLnBold(level.codeD); // TV CODE
			}
		}	
	ArrayRemoveIndex( machines, l  );
	ArrayRemoveIndex( machine_triggers, l );

	nuked_utility::wait_for_round_range_random( 14, 16 );
	wait RandomIntRange( 60, 120 );
	m = RandomInt( machines.size );
	bring_perk( machines[ m ], machine_triggers[ m  ] );
	ArrayRemoveIndex( machines, m  );
	ArrayRemoveIndex( machine_triggers, m );

	nuked_utility::wait_for_round_range_random( 17, 19 );
	wait RandomIntRange( 60, 120 );
	n = RandomInt( machines.size );
	bring_perk( machines[ n ], machine_triggers[ n  ] );
	ArrayRemoveIndex( machines, n  );
	ArrayRemoveIndex( machine_triggers, n );


	nuked_utility::wait_for_round_range_random( 20, 22 );
	wait RandomIntRange( 60, 120 );
	o = RandomInt( machines.size );
	bring_perk( machines[ o ], machine_triggers[ o  ] );
	ArrayRemoveIndex( machines, o  );
	ArrayRemoveIndex( machine_triggers, o );

	nuked_utility::wait_for_round_range_random( 23, 25 );
	wait RandomIntRange( 60, 120 );
	p = RandomInt( machines.size );
	bring_perk( machines[ p ], machine_triggers[ p  ] );
	ArrayRemoveIndex( machines, p  );
	ArrayRemoveIndex( machine_triggers, p );

}

function perks_from_the_sky_no_ee() // easy, gungame 
{
		if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines[ 0 ] ) )
	{
		return;
	}
	machine_triggers[ 0 ] = GetEnt( "vending_revive", "target" );

	move_perk( machines[ 0 ], top_height, 5, 0.001 );
	machine_triggers[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );

	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();

	machines[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers[ 4 ] = GetEnt( "vending_marathon", "target" );
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();

	machines[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers[ 5 ] = GetEnt( "vending_deadshot", "target" );
	move_perk( machines[ 5 ], top_height, 5, 0.001 );
	machine_triggers[ 5 ] trigger_off();

	machines[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	move_perk( machines[ 6 ], top_height, 5, 0.001 );
	machine_triggers[ 6 ] trigger_off();

	machines[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers[ 7 ] = GetEnt( "vending_widowswine", "target" );
	move_perk( machines[ 7 ], top_height, 5, 0.001 );
	machine_triggers[ 7 ] trigger_off();

	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );
	players = GetPlayers();
	if ( players.size == 1 )
	{
	wait 4;
		index = 0;
		bring_perk( machines[ index ], machine_triggers[ index ] ); // TV CODE
		ArrayRemoveIndex( machines, index );
		ArrayRemoveIndex( machine_triggers, index );

	//i = RandomIntRange(machines.size);
	}

	nuked_utility::wait_for_round_range_random( 3, 5 );
	wait RandomIntRange( 30, 60 );
	j = RandomInt( machines.size );
	bring_perk( machines[ j  ], machine_triggers[ j  ]);
		
	ArrayRemoveIndex( machines, j  );
	ArrayRemoveIndex( machine_triggers, j  );

	nuked_utility::wait_for_round_range_random( 6, 7 );
	wait RandomIntRange( 30, 60 );
	h = RandomInt( machines.size );
	bring_perk( machines[ h ], machine_triggers[ h  ] ); // TV CODE

	ArrayRemoveIndex( machines, h  );
	ArrayRemoveIndex( machine_triggers, h );

	nuked_utility::wait_for_round_range_random( 8, 10 );
	wait RandomIntRange( 60, 120 );
	k = RandomInt( machines.size );
	bring_perk( machines[ k ], machine_triggers[ k  ] );// TV CODE

	ArrayRemoveIndex( machines, k  );
	ArrayRemoveIndex( machine_triggers, k );

	nuked_utility::wait_for_round_range_random( 11, 13 );
	wait RandomIntRange( 60, 120 );
	l = RandomInt( machines.size );
	bring_perk( machines[ l ], machine_triggers[ l  ] );
	ArrayRemoveIndex( machines, l  );
	ArrayRemoveIndex( machine_triggers, l );

	nuked_utility::wait_for_round_range_random( 14, 16 );
	wait RandomIntRange( 60, 120 );
	m = RandomInt( machines.size );
	bring_perk( machines[ m ], machine_triggers[ m  ] );
	ArrayRemoveIndex( machines, m  );
	ArrayRemoveIndex( machine_triggers, m );

	nuked_utility::wait_for_round_range_random( 17, 19 );
	wait RandomIntRange( 60, 120 );
	n = RandomInt( machines.size );
	bring_perk( machines[ n ], machine_triggers[ n  ] );
	ArrayRemoveIndex( machines, n  );
	ArrayRemoveIndex( machine_triggers, n );


	nuked_utility::wait_for_round_range_random( 20, 22 );
	wait RandomIntRange( 60, 120 );
	o = RandomInt( machines.size );
	bring_perk( machines[ o ], machine_triggers[ o  ] );
	ArrayRemoveIndex( machines, o  );
	ArrayRemoveIndex( machine_triggers, o );

	nuked_utility::wait_for_round_range_random( 23, 25 );
	wait RandomIntRange( 60, 120 );
	p = RandomInt( machines.size );
	bring_perk( machines[ p ], machine_triggers[ p  ] );
	ArrayRemoveIndex( machines, p  );
	ArrayRemoveIndex( machine_triggers, p );

}

function perks_from_the_sky_no_chronicles() // a rendre compatible pour la quete
{
	if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines[ 0 ] ) )
	{
		return;
	}
	machine_triggers[ 0 ] = GetEnt( "vending_revive", "target" );
	move_perk( machines[ 0 ], top_height, 5, 0.001 );
	machine_triggers[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );
	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();


	machines_nop[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers_nop[ 4 ] = GetEnt( "vending_marathon", "target" );
	move_perk( machines_nop[ 4 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 4 ] trigger_off();

	machines_nop[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers_nop[ 5 ] = GetEnt( "vending_deadshot", "target" );
	move_perk( machines_nop[ 5 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 5 ] trigger_off();

	machines_nop[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers_nop[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	move_perk( machines_nop[ 6 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 6 ] trigger_off();

	machines_nop[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers_nop[ 7 ] = GetEnt( "vending_widowswine", "target" );
	move_perk( machines_nop[ 7 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 7 ] trigger_off();


	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );
	players = GetPlayers();


	if ( level.nuked_perks_first_revive  == 1 )
	{
		wait 4;
		index = 0;
		bring_perk( machines[ index ], machine_triggers[ index ] ); // TV CODE
		ArrayRemoveIndex( machines, index );
		ArrayRemoveIndex( machine_triggers, index );

	}
 	
	level notify("pap_can_chose_position");
	nuked_utility::wait_for_round_range_random( 3, 5 );
	wait RandomIntRange( 30, 60 );
	j = RandomInt( machines.size );
	bring_perk( machines[ j  ], machine_triggers[ j  ]);		
	ArrayRemoveIndex( machines, j  );
	ArrayRemoveIndex( machine_triggers, j  );

	nuked_utility::wait_for_round_range_random( 6, 9 );
	wait RandomIntRange( 30, 60 );
	h = RandomInt( machines.size );
	bring_perk( machines[ h ], machine_triggers[ h  ] ); // TV CODE
	ArrayRemoveIndex( machines, h  );
	ArrayRemoveIndex( machine_triggers, h );

	nuked_utility::wait_for_round_range_random( 10, 14 );
	wait RandomIntRange( 60, 120 );
	k = RandomInt( machines.size );
	bring_perk( machines[ k ], machine_triggers[ k  ] );// TV CODE
	ArrayRemoveIndex( machines, k  );
	ArrayRemoveIndex( machine_triggers, k );

	nuked_utility::wait_for_round_range_random( 15, 19 );
	wait RandomIntRange( 60, 120 );
	l = RandomInt( machines.size );
	bring_perk( machines[ l ], machine_triggers[ l  ] );
	ArrayRemoveIndex( machines, l  );
	ArrayRemoveIndex( machine_triggers, l );


}

function perks_from_the_sky_gungame() // easy, gungame 
{
		if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines_nop[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines_nop[ 0 ] ) )
	{
		return;
	}
	machine_triggers_nop[ 0 ] = GetEnt( "vending_revive", "target" );

	move_perk( machines_nop[ 0 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );

	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();

	machines[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers[ 4 ] = GetEnt( "vending_marathon", "target" );
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();

	machines[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers[ 5 ] = GetEnt( "vending_deadshot", "target" );
	move_perk( machines[ 5 ], top_height, 5, 0.001 );
	machine_triggers[ 5 ] trigger_off();

	machines_nop[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers_nop[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	move_perk( machines_nop[ 6 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 6 ] trigger_off();

	machines_nop[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers_nop[ 7 ] = GetEnt( "vending_widowswine", "target" );
	move_perk( machines_nop[ 7 ], top_height, 5, 0.001 );
	machine_triggers_nop[ 7 ] trigger_off();
	//machine_triggers[ 4 ] = getent( "specialty_weapupgrade", "script_noteworthy" );
	//machines[ 4 ] = getent( machine_triggers[ 4 ].target, "targetname" );
	//move_perk( machines[ 4 ], top_height, 5, 0.001 );
	//machine_triggers[ 4 ] trigger_off();

	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );
	players = GetPlayers();
	if ( players.size == 1 )
	{
	wait 4;
		index = 0;
		bring_perk( machines[ index ], machine_triggers[ index ] ); // TV CODE


		ArrayRemoveIndex( machines, index );
		ArrayRemoveIndex( machine_triggers, index );

	//i = RandomIntRange(machines.size);
	}
	nuked_utility::wait_for_round_range_random( 3, 5 );
	wait RandomIntRange( 30, 60 );
	j = RandomInt( machines.size );
	bring_perk( machines[ j  ], machine_triggers[ j  ]);
		
	ArrayRemoveIndex( machines, j  );
	ArrayRemoveIndex( machine_triggers, j  );

	nuked_utility::wait_for_round_range_random( 6, 7 );
	wait RandomIntRange( 30, 60 );
	h = RandomInt( machines.size );
	bring_perk( machines[ h ], machine_triggers[ h  ] ); // TV CODE

	ArrayRemoveIndex( machines, h  );
	ArrayRemoveIndex( machine_triggers, h );

	nuked_utility::wait_for_round_range_random( 8, 10 );
	wait RandomIntRange( 60, 120 );
	k = RandomInt( machines.size );
	bring_perk( machines[ k ], machine_triggers[ k  ] );// TV CODE

	ArrayRemoveIndex( machines, k  );
	ArrayRemoveIndex( machine_triggers, k );

	nuked_utility::wait_for_round_range_random( 11, 13 );
	wait RandomIntRange( 60, 120 );
	l = RandomInt( machines.size );
	bring_perk( machines[ l ], machine_triggers[ l  ] );
	ArrayRemoveIndex( machines, l  );
	ArrayRemoveIndex( machine_triggers, l );

	nuked_utility::wait_for_round_range_random( 14, 16 );
	wait RandomIntRange( 60, 120 );
	m = RandomInt( machines.size );
	bring_perk( machines[ m ], machine_triggers[ m  ] );
	ArrayRemoveIndex( machines, m  );
	ArrayRemoveIndex( machine_triggers, m );

	nuked_utility::wait_for_round_range_random( 17, 19 );
	wait RandomIntRange( 60, 120 );
	n = RandomInt( machines.size );
	bring_perk( machines[ n ], machine_triggers[ n  ] );
	ArrayRemoveIndex( machines, n  );
	ArrayRemoveIndex( machine_triggers, n );


	nuked_utility::wait_for_round_range_random( 20, 22 );
	wait RandomIntRange( 60, 120 );
	o = RandomInt( machines.size );
	bring_perk( machines[ o ], machine_triggers[ o  ] );
	ArrayRemoveIndex( machines, o  );
	ArrayRemoveIndex( machine_triggers, o );

	nuked_utility::wait_for_round_range_random( 23, 25 );
	wait RandomIntRange( 60, 120 );
	p = RandomInt( machines.size );
	bring_perk( machines[ p ], machine_triggers[ p  ] );
	ArrayRemoveIndex( machines, p  );
	ArrayRemoveIndex( machine_triggers, p );

}

function PerksFromSky_Gauntlet1() // easy, gungame 
{
	if(level flag::get("perks_cycle_defined"))
		return;

	level flag::set("perks_cycle_defined");
	
	level thread turn_perks_on();
	top_height = 20000;
	machines = [];
	machine_triggers = [];
	machines[ 0 ] = GetEnt( "vending_revive", "targetname" );
	if ( !isDefined( machines[ 0 ] ) )
	{
		return;
	}
	machine_triggers[ 0 ] = GetEnt( "vending_revive", "target" );
	move_perk( machines[ 0 ], top_height, 5, 0.001 );
	machine_triggers[ 0 ] trigger_off();

	machines[ 1 ] = GetEnt( "vending_doubletap", "targetname" );
	machine_triggers[ 1 ] = GetEnt( "vending_doubletap", "target" );
	move_perk( machines[ 1 ], top_height, 5, 0.001 );
	machine_triggers[ 1 ] trigger_off();

	machines[ 2 ] = GetEnt( "vending_sleight", "targetname" );
	machine_triggers[ 2 ] = GetEnt( "vending_sleight", "target" );
	move_perk( machines[ 2 ], top_height, 5, 0.001 );
	machine_triggers[ 2 ] trigger_off();

	machines[ 3 ] = GetEnt( "vending_jugg", "targetname" );
	machine_triggers[ 3 ] = GetEnt( "vending_jugg", "target" );
	move_perk( machines[ 3 ], top_height, 5, 0.001 );
	machine_triggers[ 3 ] trigger_off();

	machines[ 4 ] = GetEnt( "vending_marathon", "targetname" ); 
	machine_triggers[ 4 ] = GetEnt( "vending_marathon", "target" );
	move_perk( machines[ 4 ], top_height, 5, 0.001 );
	machine_triggers[ 4 ] trigger_off();

	machines[ 5 ] = GetEnt( "vending_deadshot", "targetname" );
	machine_triggers[ 5 ] = GetEnt( "vending_deadshot", "target" );
	move_perk( machines[ 5 ], top_height, 5, 0.001 );
	machine_triggers[ 5 ] trigger_off();

	machines[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "targetname" );
	machine_triggers[ 6 ] = GetEnt( "vending_additionalprimaryweapon", "target" );
	move_perk( machines[ 6 ], top_height, 5, 0.001 );
	machine_triggers[ 6 ] trigger_off();

	machines[ 7 ] = GetEnt( "vending_widowswine", "targetname" );
	machine_triggers[ 7 ] = GetEnt( "vending_widowswine", "target" );
	move_perk( machines[ 7 ], top_height, 5, 0.001 );
	machine_triggers[ 7 ] trigger_off();

	flag::wait_till( "initial_blackscreen_passed" );
	wait RandomFloatRange( 5, 15 );

	while ( level.round_number < 2 ) wait 1;
    
	wait RandomIntRange( 30, 60 );
	bring_perk( machines[ 5 ], machine_triggers[ 5 ]);
		

	while ( level.round_number < 5 ) wait 1;
	wait RandomIntRange( 30, 60 );
	bring_perk( machines[ 2 ], machine_triggers[ 2 ] ); 


	while ( level.round_number < 7 ) wait 1;
	wait RandomIntRange( 60, 120 );
	bring_perk( machines[ 6 ], machine_triggers[ 6  ] );


	while ( level.round_number < 9 ) wait 1;
	wait RandomIntRange( 60, 120 );
	bring_perk( machines[ 7 ], machine_triggers[ 7  ] );


	while ( level.round_number < 11 ) wait 1;
	wait RandomIntRange( 60, 120 );
	bring_perk( machines[ 3 ], machine_triggers[ 3  ] );


	while ( level.round_number < 13 ) wait 1;
	wait RandomIntRange( 60, 120 );
	bring_perk( machines[ 1 ], machine_triggers[ 1  ] );



	while ( level.round_number < 15 ) wait 1;
	wait RandomIntRange( 60, 120 );
	bring_perk( machines[ 4 ], machine_triggers[ 4  ] );

}

function move_perk( ent, dist, time, accel )
{
	ent.original_pos = ent.origin;
	ent.original_angles = ent.angles;
	pos = ( ent.origin[ 0 ], ent.origin[ 1 ], ent.origin[ 2 ] + dist );
	ent moveto( pos, time, accel, accel );
}

function trigger_off()
{
	if(isdefined(self._wardog_old_origin))
		return;

	self._wardog_old_origin = self.origin;
	self.origin += TRIGGER_OFF_OFFSET_VECTOR;

	self notify("trigger_off");
}

function trigger_on()
{
	if(!isdefined(self._wardog_old_origin))
		return;

	self.origin = self._wardog_old_origin;
	self._wardog_old_origin = undefined;

	self notify("trigger_on");
}