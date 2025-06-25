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

#using scripts\zm\nuked_utility;

function init()
{
    level thread sndgameend(); // LAST UPDATe
    level thread sndmusiceastereggs(); // LAST UPDATE
}

function sndmusiceastereggs()
{
    level.can_play_music_biatch = true; // ADD CONDITION
    level.music_override = 0;
    level thread sndmusegg1();
    level thread sndmusegg2();
    level thread sndmusegg3_counter();
    level thread sndmusegg4(); //zmb_nuked_song_4
}

function sndgameend()
{
    level waittill( "intermission" );
    playsoundatposition( "zmb_endgame", ( 0, 1, 0 ) );
}

function sndmusegg1()
{
    level waittill( "nuke_clock_moved" );
    level waittill( "magic_door_power_up_grabbed" );
    min_hand_model = getent( "clock_min_hand", "targetname" );

    IPrintLnBold("pop count : "+level.population_count);

    if ( level.population_count == 15 && level.music_override == 0 && level.can_play_music_biatch == true ) // ADD CONDITION
    {
        if(level flag::get("quest_perk_enable"))
        {
            increase_perk_purchase_limit();
        }

         IPrintLnBold("BITE");
        
        level thread sndmuseggplay( spawn( "script_origin", ( 0, 1, 0 ) ), "zmb_nuked_song_1", 88 );
    }
    else if ( level.population_count == 15 && level.can_play_music_biatch == false && level flag::get("quest_perk_enable") )
    {
        increase_perk_purchase_limit();
    }
}

function increase_perk_purchase_limit()
{
    level.perk_purchase_limit++;
    IPrintLnBold("Perk purchase limit increased to " + level.perk_purchase_limit);
}

function sndmusegg2()
{
    bear_trig = GetEntArray( "bear_trig", "targetname" );


    level.meteor_counter = 0;
    level.music_override = 0;
    //i = 0;
    for(i = 0; i < bear_trig.size; i++)
    {
        bear_trig[i] thread sndmusegg2_wait();
    }
}

function sndmusegg2_wait()
{
    tamere = spawn( "script_model", self.origin);
    tamere SetModel( "tag_origin" );    
    tamere PlayLoopSound( "zmb_meteor_loop" ,  0.1 );
    self waittill( "trigger", player );
    tamere StopLoopSound( 1 );
    player PlaySound( "zmb_meteor_activate" );
    level.meteor_counter++;
    if ( level.meteor_counter == 3 && level.can_play_music_biatch == true ) // ADD CONDITION
    {
        //IPrintLnBold( "le son zm_nuked 2 se lance"  );
        level thread sndmuseggplay( self, "zmb_nuked_song_2", 60 );
    }
    else
    {
        wait 1.5;
        self Delete();
    }
}

function sndmusegg2_override()
{
    if ( isDefined( level.music_override ) && level.music_override )
    {
        return 0;
    }
    return 1;
}

function sndmusegg3_counter( destructible_event, attacker )
{


    if ( level.mannequin_count <= 0 )
    {
        return;
    }
 
   // IPrintLnBold( "CAYERS: " + level.mannequin_count );  // POUR OREL

    level.mannequin_count--;

    if ( level.mannequin_count <= 0 )
    {
        while ( isdefined( level.music_override ) && level.music_override )
        {
            wait 5;
        }
        if(level.debug_nuked == true)
        {
        IPrintLnBold( "le son zm_nuked 3 se lance"  );
        }
        level thread sndmuseggplay( Spawn( "script_origin", ( 0, 1, 0 ) ), "zmb_nuked_song_3", 80 );
    }
  
}

function sndmuseggplay( ent, alias, time )
{
    level.music_override = 1;
    level.can_play_music_biatch = false;
    wait 1;
    ent PlaySound( alias );
    level thread sndeggmusicwait( time );
    self util::waittill_either( "end_game", "sndSongDone" );
    ent StopSounds();
    wait 0.05;
    ent Delete();
    level.music_override = 0;
}

function sndeggmusicwait( time )
{
    level endon( "end_game" );
    wait time;
    level notify( "sndSongDone" );
}

function sndmusegg4()
{
    bear_trig = GetEntArray( "bear_2_trig", "targetname" );


    level.meteor_2_counter = 0;
    //level.music_override = 0;
    //i = 0;
    for(i = 0; i < bear_trig.size; i++)
    {
        bear_trig[i] thread sndmusegg4_wait();
    }
}

function sndmusegg4_wait()
{
    tamere = spawn( "script_model", self.origin);
    tamere SetModel( "tag_origin" );    
    tamere PlayLoopSound( "zmb_meteor_loop" ,  0.1 );
    self waittill( "trigger", player );
    tamere StopLoopSound( 1 );
    player PlaySound( "zmb_meteor_activate" );
    level.meteor_2_counter++;
    if ( level.meteor_2_counter == 3 ) 
    {
        level thread sndmuseggplay( self, "zmb_nuked_song_4", 200 );
    }
    else
    {
        wait 1.5;
        self Delete();
    }
}