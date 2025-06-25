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

function init()
{
    level.population_count = 0;
    level thread nuked_population_sign_think();
}

function nuked_population_sign_think()
{
    tens_model = getent( "counter_tens", "targetname" );
    ones_model = getent( "counter_ones", "targetname" );
    step = 36;
    ones = 0;
    tens = 0;
    local_zombies_killed = 0;
    tens_model RotateRoll( step, 0.05 );
    ones_model RotateRoll( step, 0.05 );
    while ( 1 )
    {
        if ( local_zombies_killed < ( level.total_zombies_killed - level.zombie_total_subtract ))
        {
            ones--;

            time = 1;
            if ( ones < 0 )
            {
                ones = 9;
                tens_model RotateRoll( 0 - step, time );
                tens_model PlaySound( "zmb_counter_flip" );
                tens--;

            }
            if ( tens < 0 )
            {
                tens = 9;
            }
            ones_model rotateroll( 0 - step, time );
            ones_model PlaySound( "zmb_counter_flip" );
            ones_model waittill( "rotatedone" );
            level.population_count = ones + ( tens * 10 );
            
            if ( level.population_count == 33 || level.population_count == 66 || level.population_count == 99 )
                level notify("update_doomsday_clock");

            local_zombies_killed++;
        }
       
        wait 0.05;
    }
}
