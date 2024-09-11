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
#using scripts\zm\classic_features\ee_music;


#precache( "model", "dest_zm_nuked_female_01_head_hd" ); //NEXT UPDATE
#precache( "model", "dest_zm_nuked_female_02_head_hd" ); //NEXT UPDATE
#precache( "model", "dest_zm_nuked_female_03_head_hd" ); //NEXT UPDATE
#precache( "model", "dest_zm_nuked_male_01_head_hd_bo4" ); //NEXT UPDATE
#precache( "model", "dest_zm_nuked_male_02_head_hd_bo4" ); //NEXT UPDATE
#precache( "model", "dest_zm_nuked_male_03_head_hd_bo4" ); //NEXT UPDATE



function autoexec init()
{
	level thread nuked_mannequin_init(); 

}


function man_add() // LAST UPDATE
{
    level waittill("mannequins_ready");
    self.head SetCanDamage(1);
    self.head waittill( "damage", amount, attacker, dir, org, mod );
    level.trig_man_count++;

    if(level.debug_nuked == true)
    {
        IPrintLnBold("Mannequin shooté ="+level.trigger_mannequins+"sur"+level.trig_man_count); 
    }
    self.head Delete();

    if ( level.trig_man_count == 28 )
    {
        if(level flag::get("quest_perk_enable"))
        {
            level.perk_purchase_limit++;
        }
        
        if( level.can_play_music_biatch == true)
        {
            level thread ee_music::sndmuseggplay( Spawn( "script_origin", ( 0, 1, 0 ) ), "zmb_nuked_song_3", 80 );
        }
       
    }
   
}

//
//"Name: nuked_mannequin_init"
//"Type: Classic feature"
//"Summary: Cette function choisi et delete aleatoirement les mannequins pour en garder 28 "
//"Suggestion : - Attention defois le compteur de mannequins indiqué 29 au lieu de 28 faut trouver l'erreur
//              - Trouver un moyen de faire apparaitre le clip
//"
//
function nuked_mannequin_init() // LAST UPDATE
{   

    keep_count = 28;
    level.mannequin_count = 0;
    destructibles = GetEntArray( "destructible", "targetname" );
    mannequins = nuked_mannequin_filter( destructibles );

    if ( mannequins.size <= 0 )
    {
        return;
    }

    remove_count = mannequins.size - keep_count;
    remove_count = math::clamp( remove_count, 0, remove_count );
    mannequins = array::randomize( mannequins );
    head = [];  

    j = 0;

    while(j < mannequins.size)
    {
        origin = mannequins[j] GetTagOrigin( "tag_base_d1_head" );
        angles = mannequins[j] GetTagAngles( "tag_base_d1_head" ); 
        
        if(IsSubStr (mannequins[j].model, "_female" ))
        {
            mannequins[j].head = util::spawn_model("dest_zm_nuked_female_0"+RandomIntRange(1,3)+"_head_hd_bo4", (0,0,0), (0,0,0));
        }
        else
        { 
            mannequins[j].head = util::spawn_model("dest_zm_nuked_male_0"+RandomIntRange(1,4)+"_head_hd_bo4", (0,0,0), (0,0,0));     
        }
        mannequins[j].head.origin = origin;
        mannequins[j].head.angles = angles;
        mannequins[j].head LinkTo(mannequins[j],"tag_base_d1_head");          
        j++;    
    }

    i = 0;
    while ( i < remove_count )
    {
        clip = getent(mannequins[ i ].script_noteworthy, "targetname");    
        clip Delete();
        mannequins[ i ].head Delete();
        mannequins[ i ] delete();
        ArrayRemoveIndex(mannequins, i);
        level.mannequin_count--;
        i++;
    }

    level waittill( "prematch_over" );

    level.mannequin_time = getTime();

    for(i = 0; i < mannequins.size; i++)
    {
        mannequins[i] thread man_add();
    }

    level.trig_man_count = 0;
    level.trigger_mannequins = level.mannequin_count;
    level notify("mannequins_ready");

}

//
//"Name: nuked_mannequin_filter"
//"Type: Classic feature"
//"Summary: Cette function filtre le nombre de mannequins présent sur la map "
//"Suggestion : - Attention defois le compteur de mannequins indiqué 29 au lieu de 28 faut trouver l'erreur
//              - 
//"
//
function nuked_mannequin_filter( destructibles )
{
    mannequins = [];
    i = 0;
    while ( i < destructibles.size )
    {
        destructible = destructibles[ i ];

        if ( IsSubStr( destructible.destructibledef, "male" ) )
        {
            mannequins[ mannequins.size ] = destructible;

            level.mannequin_count++;
        }
        i++;
    }
    return mannequins;
}