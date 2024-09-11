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

#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;


function autoexec init()
{
    level thread nuked_doomsday_clock_think();
    level thread perks_behind_door();
}


function nuked_doomsday_clock_think()
{
    level flag::wait_till( "initial_blackscreen_passed" ); // nécessaire pour le linkto
    min_hand_model = GetEnt( "clock_min_hand", "targetname" );

    min_hand_model LinkTo(GetEnt("clock_tower_round", "targetname" ),"mp_nuked_doomsday_clock");

    min_hand_model.position = 0;
    while ( 1 )
    {
        level waittill( "update_doomsday_clock" );
        level thread update_doomsday_clock( min_hand_model );
    }
}

function update_doomsday_clock( min_hand_model )
{
    if ( min_hand_model.position == 0 )
    {
        min_hand_model.position = 3;
        min_hand_model RotatePitch( -90, 1 );
        min_hand_model PlaySound( "zmb_clock_hand" );
        wait 1;
        min_hand_model PlaySound( "zmb_clock_chime" );
    }
    else
    {
        min_hand_model.position--;

        min_hand_model RotatePitch( 30, 1 );
        min_hand_model PlaySound( "zmb_clock_hand" );
        min_hand_model waittill( "rotatedone" );
    }
    level notify( "nuke_clock_moved" );
}

function perks_behind_door()
{
    level endon( "magic_door_power_up_grabbed" );
    level flag::wait_till( "initial_blackscreen_passed" );
    door_perk_drop_list = [];
    door_perk_drop_list[ 0 ] = "nuke";
    door_perk_drop_list[ 1 ] = "double_points";
    door_perk_drop_list[ 2 ] = "insta_kill";
    door_perk_drop_list[ 3 ] = "fire_sale";
    door_perk_drop_list[ 4 ] = "full_ammo";
    index = 0;
    ammodrop = struct::get( "zm_nuked_ammo_drop", "script_noteworthy" );
    perk_type = door_perk_drop_list[ index ];
    index++;
    door_powerup_drop( perk_type, ammodrop.origin );
    while ( 1 )
    {
        level waittill( "nuke_clock_moved" );
        if ( index == door_perk_drop_list.size )
        {
            index = 0;
        }
        perk_type = door_perk_drop_list[ index ];
        index++;
        door_powerup_drop( perk_type, ammodrop.origin );
    }

}

function door_powerup_drop( powerup_name, drop_spot, powerup_team, powerup_location )
{
    if ( isDefined( level.door_powerup ) )
    {
        level.door_powerup Delete();
    }
    powerup = zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + vectorScale( ( 0, 1, 0 ), 40 ) );
    level notify( "powerup_dropped" );
    if ( isDefined( powerup ) )
    {
        powerup.grabbed_level_notify = "magic_door_power_up_grabbed";
        powerup zm_powerups::powerup_setup( powerup_name, powerup_team, powerup_location );
        powerup thread zm_powerups::powerup_wobble();
        powerup thread zm_powerups::powerup_grab( powerup_team );
        powerup thread zm_powerups::powerup_move();
        level.door_powerup = powerup;
    }
}