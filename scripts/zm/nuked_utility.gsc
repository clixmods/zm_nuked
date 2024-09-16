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

#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_net;

#using scripts\zm\_zm; // pour les respawn

// keep perk
#using scripts\zm\_zm_perks;
#insert scripts\zm\_zm_perks.gsh;

#insert scripts\zm\nuked_utility.gsh;

#namespace nuked_utility;


function main()
{
	level.debug_nuked = DEBUG_NUKED;
    level thread clean_useless_wallbuy_chalks();
    level thread respawn_player_when_i_want();
    level thread disable_trig_fire_dog();
}

function is_omega()
{
    mapname = GetDvarString("mapname");

    if(mapname == "zm_nuked")
    {
        return false;
    }
    else
    {
        return true;
    }
}


function disable_trig_fire_dog()
{
    trigs = GetEntArray("trig_fire","targetname");
    clips = GetEntArray("clip_dogs","targetname");
    foreach(trig in trigs) 
    {
        trig Hide();
    }
    foreach(clip in clips) 
    {
        clip Hide();
    }

    level waittill("trig_fire_go");
    level thread traversals_delete();
    exploder::exploder("dog_round");
    //level flag::set("dog_round");
    foreach(trig in trigs) 
    {
        trig Show();
    }
    foreach(clip in clips) 
    {
        clip Show();
    }
    level waittill("trig_fire_stop");
    exploder::stop_exploder("dog_round");
    //level flag::clear("dog_round");
    foreach(trig in trigs) 
    {
        trig Hide();
    }
    foreach(clip in clips) 
    {
        clip Hide();
    }
}


function traversals_delete()
{

    begin_nodes = GetNodeArray("node_dog","targetname");

    //level waittill("spawn_rush_complete");

    foreach(node in begin_nodes)
    {
        if(level.debug_nuked == true)
            IPrintLnBold("node found");
        
        UnlinkTraversal( node );
    }
    level waittill("trig_fire_stop");
    foreach(node in begin_nodes)
    {
        if(level.debug_nuked == true)
            IPrintLnBold("node found");
        
        LinkTraversal( node );
    }
} 


function respawn_player_when_i_want()
{
    
    while(1)
    {
        level waittill("can_respawn_players");
        players = GetPlayers();
		for( i = 0; i < players.size; i++ )
		{
			e_player = players[i];
			e_player zm::spectator_respawn_player();
		}
    }
}

function playsound_to_players(sound) // Joue un son local au player, a utilisé partout 
{
    players = GetPlayers(); 
    foreach( player in players )
        player PlayLocalSound( sound );

}



function register_cf_pop_func(clientfield , multi)
{
    if ( !isdefined( level.elem_pop ) ) // Crée l'array si elle n'est pas défini
    {
        level.elem_pop = [];
    }
    if ( !isdefined(multi) )
    {
        multi = false;
    }
    array::add( level.elem_pop, clientfield, multi );
    level notify ( "tcheck_pop" );
}

function register_cf_pop_styl_treyarch_func(clientfield , multi)
{
    if ( !isdefined( level.elem_pop_treyarch ) ) // Crée l'array si elle n'est pas défini
    {
        level.elem_pop_treyarch = [];
    }
    if ( !isdefined(multi) )
    {
        multi = false;
    }
    array::add( level.elem_pop_treyarch, clientfield, multi );
    level notify ( "tcheck_pop_treyarch" );
}

//
//"Name: tcheck_if_blackop2_is_on"
//"Type: MOD"
//"Summary: Garde/enleve les wallbuy en fonction du mod 
//"Suggestion : - Fait il crasher avec la transparence sans tri ?  
////              - Parfait maybe 
//
function clean_useless_wallbuy_chalks()
{
    chalk_remove = GetEntArray("bo1_weapon","script_noteworthy");
    chalk_remove = ArrayCombine(chalk_remove, GetEntArray("bo4_weapon", "script_noteworthy"), true, false);
    chalk_remove = ArrayCombine(chalk_remove, GetEntArray("waw_weapon", "script_noteworthy"), true, false);
    chalk_remove = ArrayCombine(chalk_remove, GetEntArray("bo2_bo1_weapon", "script_noteworthy"), true, false);
    chalk_remove = ArrayCombine(chalk_remove, GetEntArray("ww2_weapon", "script_noteworthy"), true, false);
    foreach ( chalk in chalk_remove )
        chalk Delete();
      
}


function random_team()  //NEXT UPDATE
{
    if ( level.i_player_switch_team == 0 )
    {   
       // IPrintLnBold("level.i_player_switch_team = " +level.i_player_switch_team);
    }
    else
    {
        level.charindexarray_switch_0 = 0   ;// - Dempsey )
        level.charindexarray_switch_1 = 1  ;// - Nikolai )
        level.charindexarray_switch_2 = 2   ;// - Richtofen )
        level.charindexarray_switch_3 = 3  ;// - Takeo 

    }
}

function wait_for_round_range (round_number)
{
    while(1)
    {
        if(level.round_number >= round_number)
        {
            //IPrintLnBold("On joue le son  à la manche "+ level.round_number + " Manche Définie"+round_number);
            break;
            return true;
        }
        wait(0.05);
    }
}

function wait_for_round_range_random( start_round, end_round )
{
    round_to_spawn = RandomIntRange( start_round, end_round );
    
    while ( level.round_number < round_to_spawn )
    {
        wait 1;
    }
}


//
//"Name: gift_powerup_drop"
//"Type: Récompense"
//"Summary: Fait apparaitre un power up à l'endroit indiqué 
//"Suggestion : - Aucune
//              - "
//
function gift_powerup_drop( powerup_name, drop_spot, powerup_team, powerup_location ) 
{
    powerup_gift = zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + vectorScale( ( 0, 1, 0 ), 40 ) );
    level notify( "powerup_dropped" );
    if ( isDefined( powerup_gift ) )
    {

        powerup_gift zm_powerups::powerup_setup( powerup_name, powerup_team, powerup_location );
        powerup_gift thread zm_powerups::powerup_wobble();
        powerup_gift thread zm_powerups::powerup_grab( powerup_team );
        powerup_gift thread zm_powerups::powerup_move();

    }
}

//
//"Name: wait_for_next_round"
//"Type: Utility"
//"Summary: Comme indiquer, il attend le prochain round
//"Suggestion : - Aucune
//              - "
//
function wait_for_next_round( current_round ) //NEXT UPDATE
{
    while ( level.round_number <= current_round )
    {
        wait 1;
    }
}

function keep_perk_after_ee()
{ 
        self waittill( "player_revived" );
        
        self zm_perks::give_perk( PERK_JUGGERNOG );
        wait 0.1;
        self zm_perks::give_perk( PERK_SLEIGHT_OF_HAND );
        wait 0.1;
        self zm_perks::give_perk( PERK_DOUBLETAP2 );
        wait 0.1;
        if(level.perk_purchase_limit >= 4)
            self zm_perks::give_perk( PERK_STAMINUP );
        wait 0.1;
        if(level.perk_purchase_limit >= 5)
            self zm_perks::give_perk( PERK_DEAD_SHOT );
        wait 0.1;
        if(level.perk_purchase_limit >= 6)
            self zm_perks::give_perk( PERK_ADDITIONAL_PRIMARY_WEAPON );
        wait 0.1;
        if(level.perk_purchase_limit >= 7)
            self zm_perks::give_perk( PERK_ELECTRIC_CHERRY );
        wait 0.1;
        if(level.perk_purchase_limit >= 8)
            self zm_perks::give_perk( PERK_WIDOWS_WINE );
}
