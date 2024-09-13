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
#using scripts\shared\vehicle_shared;

#using scripts\shared\system_shared;

#using scripts\zm\_zm_power;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "model", "p7_zm_vending_packapunch_on" );

function autoexec __init__sytem__()
{
	system::register("zm_nuked_pap", &__init__,undefined, undefined);
}

function __init__()
{

	clientfield::register( "scriptmover", "fx_trail_clientfield", 12000, 1, "int" );	
	clientfield::register( "toplayer", "fx_trail_clientfield_toplayer", VERSION_SHIP, 1, "int" );	

	level.pack_a_punch.custom_power_think = &s_pap_tp_fc;

	wait 55;

	pap_arrival(level.pap_pos_struct);
}

function init()
{


	
}

function blocker_delete(id, omega_block)
{ 
    if(omega_block == true)
    {
        blocker = GetEntArray("explo_blocker_trig_"+id+"_omega", "targetname");
    }
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

function s_pap_tp_fc()
{
	level.pap_machine = self;
	self.zbarrier _zm_pack_a_punch::set_state_hidden();

	new_origin = struct::get(level.pap_pos_struct.target,"targetname");
	self.zbarrier Show();

	self.zbarrier _zm_pack_a_punch::set_state_initial();
	self.zbarrier _zm_pack_a_punch::set_state_power_on();
	level waittill("Pack_A_Punch_on");

	pap_fx = undefined;
	pap_fx_model = undefined;
	self.origin = new_origin.origin + (0,0,7);
	self.angles = new_origin.angles;
	self.zbarrier.origin = new_origin.origin + (0,0,7);
	self.zbarrier.angles = new_origin.angles;

	level.pap_machine.origin = new_origin.origin+ (0,0,7);
	level.pap_machine.angles = new_origin.angles;
	level.pap_machine.zbarrier.origin = new_origin.origin+ (0,0,7);
	level.pap_machine.zbarrier.angles = new_origin.angles;

	collision = Spawn("script_model", new_origin.origin, 1);
	collision.angles = new_origin.angles;
	collision SetModel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision DisconnectPaths();

	trigger = level.pack_a_punch.triggers[0];
	triggera = level.pack_a_punch.triggers;

	trigger.origin = trigger.origin + (0, 0, level.pack_a_punch.interaction_height); 

}


function pap_arrival(emplacement)
{ 
    round_to_spawn = RandomIntRange( 6, 25 );

    while ( level.round_number < round_to_spawn && !level flag::get("pack_a_punch_is_needed"))
    {
		//IPrintLn("pack_a_punch tombera manche" +round_to_spawn);

        wait 1;
    }

	wait RandomIntRange( 30, 60 );

    if(level.debug_nuked == true)
    {
	   IPrintLnBold("pap_arrival a été thread");
	}

    PlaySoundAtPosition( "zmb_perks_incoming_quad_front", ( 0, -1, 0 ) );
	PlaySoundAtPosition( "zmb_perks_incoming_alarm", ( -2198, 486, 327 ) );
	vehicle = GetEnt("pap_veh","targetname");
    vehicle.fx = Spawn( "script_model", vehicle.origin );
    vehicle.fx thread perk_incoming_sound();
    vehicle.fx.angles = vehicle.angles;
    vehicle.fx SetModel( "p7_zm_vending_packapunch_on" );
    
	vehicle.fx clientfield::set( "clientfield_perk_intro_fx", 1 );
  
    vehicle.fx LinkTo( vehicle );


    n_path_start = GetVehicleNode( "perk_arrival_path_" + emplacement.script_int, "targetname" );

    vehicle LinkTo( n_path_start, "tag_origin", ( 0, -1, 0 ), ( 0, -1, 0 ) );
    vehicle AttachPath( n_path_start );
    vehicle StartPath();


	new_origin = struct::get(emplacement.target,"targetname");

    vehicle waittill( "reached_end_node" );

    /*
    for(i=0;i<plr.size;i++)
	{
		plr[i] clientfield::set_to_player( "fx_trail_clientfield_toplayer", 0 ); 
	}
    vehicle.fx clientfield::set( "fx_trail_clientfield", 0);
    */

    vehicle.fx clientfield::set( "clientfield_perk_intro_fx", 0 );

    PlaySoundAtPosition( "zmb_perks_incoming_land", vehicle.origin );
    level notify("Pack_A_Punch_on");
    vehicle PlaySound( "zmb_perks_power_on" );
    zm_power::turn_power_on_and_open_doors();
    emplacement thread bring_perk_landing_damage();
    vehicle.fx Unlink();
	vehicle.fx Delete();

}

function perk_incoming_sound()
{
	self endon( "death" );
	wait 10;
	self PlaySound( "zmb_perks_incoming" );
}

function bring_perk_landing_damage()
{
	player_prone_damage_radius = 300;
	Earthquake( 0.5, 0.75, self.origin, 1000 );
	RadiusDamage( self.origin, player_prone_damage_radius, 10, 5, undefined, "MOD_EXPLOSIVE" );
	blocker_delete(self.script_int);
	
	players = GetPlayers();
	i = 0;
	while ( i < players.size )
	{
		if ( DistanceSquared( players[ i ].origin, self.origin ) <= ( player_prone_damage_radius * player_prone_damage_radius ) )
		{
			players[ i ] SetStance( "prone" );
			players[ i ] ShellShock( "default", 1.5 );
			RadiusDamage( players[ i ].origin, player_prone_damage_radius / 2, 10, 5, undefined, "MOD_EXPLOSIVE" );
		}
		i++;
	}
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
				//zombie thread perk_machine_knockdown_zombie( self.origin );
			}
		}
		i++;
	}
}