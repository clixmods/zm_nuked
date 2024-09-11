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
#using scripts\zm_exp\zm_subtitle; // zm_sub::register_subtitle_func(textLine, duration, origin, sound);

#define ZOMBIE_RICH_ANNOUNCER_PREFIX "zmba_rich" 

function init()
{
    level thread marlton_vo_inside_bunker(); 
    level thread moon_tranmission_vo(); 
    level thread richtofen_quote_random(); // Pour boss
}


//
//"Name: marlton_vo_inside_bunker"
//"Type: Main Quest"
//"Summary: Voix de Marlton au pif quand on cut le trigger
//"Suggestion : - A test
//              - Demander à Symbo de faire la VF et VO"
//

function marlton_vo_inside_bunker() 
{
    level.marlton_ee = 0;
    marlton_bunker_trig = GetEnt( "marlton_bunker_trig", "targetname" );
    marlton_sound_pos = marlton_bunker_trig.origin;
    marlton_vo = [];
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_pap_wait_0"; //_7c3962dd
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_pap_wait2_0"; // _8c7496ba
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_pap_wait2_2"; // _7591283d
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_avogadro_attack_1"; //_9ab76748
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_avogadro_attack_2"; //_3d1d3753
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_build_add_1"; //_bdeed332
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_build_pck_bjetgun_0"; //_ffb6980a
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_bus_zom_chase_1"; //_d9874b65
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_bus_zom_roof_4"; // _578982b2
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_cough_0"; // _4fbe4b
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_map_in_fog_0"; // _25c0141c
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_map_in_fog_1"; // _9aa87058
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_map_in_fog_2"; // _a449aa74
    marlton_vo[ marlton_vo.size ] = "vox_plr_3_oh_shit_0_alt01"; //_3b23c8e
    
    // while (level flag::get("quest_enable"))
    // {
    //     if(level.marlton_ee <= 5)
    //     {
    //              marlton_bunker_trig waittill( "trigger" );
    //              //
    //              zm_sub::register_subtitle_func(&"NUKED_STRING_MARLTON_DIALOG_1", 10, marlton_sound_pos, "marlton_line_01");

    //              level.marlton_ee++;
    //              nuked_utility::wait_for_next_round( level.round_number );

    //              marlton_bunker_trig waittill( "trigger" );
    //              zm_sub::register_subtitle_func(&"NUKED_STRING_MARLTON_DIALOG_2", 10, marlton_sound_pos, "marlton_line_02");
    //              level.marlton_ee++;
    //              nuked_utility::wait_for_next_round( level.round_number );

    //              marlton_bunker_trig waittill( "trigger" );
    //             zm_sub::register_subtitle_func(&"NUKED_STRING_MARLTON_DIALOG_3", 10, marlton_sound_pos, "marlton_line_03");
    //              level.marlton_ee++;
    //              nuked_utility::wait_for_next_round( level.round_number );

    //              marlton_bunker_trig waittill( "trigger" );
    //              zm_sub::register_subtitle_func(&"NUKED_STRING_MARLTON_DIALOG_4", 10, marlton_sound_pos, "marlton_line_04");
    //              level.marlton_ee++;
    //              nuked_utility::wait_for_next_round( level.round_number );

    //              marlton_bunker_trig waittill( "trigger" );
    //              zm_sub::register_subtitle_func(&"NUKED_STRING_MARLTON_DIALOG_5", 10, marlton_sound_pos, "marlton_line_05");
    //              wait 8;
    //              zm_sub::register_subtitle_func(&"NUKED_STRING_IEM_DIALOG_2", 10, marlton_sound_pos, "generateur_no_security");
    //              level.marlton_ee++;
 
    //              level thread ee_step_generator::generateur_step();
    //             level.emp_gen = false;
    //             level notify("emp_gen_off");

                
    //                 if(level.debug_nuked == true)
    //                 {
    //                     IPrintLnBold("marlton a demandé de detruire les generateurs"+level.marlton_ee); //debug
    //                 }
               
    //              level.marlton_ee++;
    //              nuked_utility::wait_for_next_round( level.round_number );

    //     }
    //     if(level.marlton_ee >= 5)
    //     {   
    //             marlton_bunker_trig waittill( "trigger" );
    //             PlaySoundAtPosition( marlton_vo[ RandomIntRange( 0, marlton_vo.size ) ], marlton_sound_pos );
             
    //             level.marlton_ee++;      
    //             nuked_utility::wait_for_next_round( level.round_number );
    //     }

    // }

}

function tv_allumer(waiting)
{
    if(level.tv_code_is_on != true )
    {
        level.tv SetModel("tv_nuked_on");
        
        wait(waiting);

        level.tv SetModel("tv_nuked");
    }
}

function moon_tranmission_vo()
{
    moon_tranmission_struct = struct::get( "moon_transmission_struct","targetname" );
    nuked_utility::wait_for_round_range( 2 );

    level waittill("between_round_over");
    //PlaySoundAtPosition( "vox_nuked_tbase_transmission_0", moon_tranmission_struct.origin );
    zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_DIALOG_1", 8, moon_tranmission_struct.origin, "vox_nuked_tbase_transmission_0",6); // textLine, duration, origin, sound, duration_begin, to_player)
    level thread tv_allumer(14);
    if(level.debug_nuked == true)
    {
    IPrintLn("vox_nuked_tbase_transmission_0"); // debug, remove if ya wanna
    }
    nuked_utility::wait_for_round_range( randomintrange( 4, 5 ));
    level waittill("between_round_over");
    zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_DIALOG_2", 9, moon_tranmission_struct.origin, "vox_nuked_tbase_transmission_1",5);
    level thread tv_allumer(10);
        if(level.debug_nuked == true)
        {
            IPrintLn("vox_nuked_tbase_transmission_1"); // debug, remove if ya wanna
        }

        nuked_utility::wait_for_round_range( randomintrange( 7, 11 ));
        
    if(level.code_go_23 != true)
    {
        level waittill("between_round_over");
        zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_DIALOG_4", 8, moon_tranmission_struct.origin, "vox_nuked_tbase_transmission_2",4);
        level thread tv_allumer(12);
        if(level.debug_nuked == true)
        {
         IPrintLn("vox_nuked_tbase_transmission_2"); // debug, remove if ya wanna
        }
        nuked_utility::wait_for_round_range( randomintrange( 13, 15 ));
        level waittill("between_round_over");
        zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_DIALOG_3", 9, moon_tranmission_struct.origin, "vox_nuked_tbase_transmission_3",8);
        level thread tv_allumer(17);
        if(level.debug_nuked == true)
        {   
            IPrintLn("vox_nuked_tbase_transmission_3"); // debug, remove if ya wanna
        }
    }
    nuked_utility::wait_for_round_range( 25 );
    level waittill("between_round_over");
    zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_DIALOG_5", 12, moon_tranmission_struct.origin, "vox_nuked_tbase_transmission_4",8);
    level thread tv_allumer(20);
    if(level.debug_nuked == true)
    {
     IPrintLn("vox_nuked_tbase_transmission_4"); // debug, remove if ya wanna
    }
    level clientfield::set( "change_eye_color", 1 );
    level.player_4_vox_override = true;
    //level.zombie_eyeball_color_override = 2;
    level.zmAnnouncerPrefix = "vox_"+ZOMBIE_RICH_ANNOUNCER_PREFIX+"_";
    level flag::set( "moon_transmission_over" );
    

}

//
//"Name: richtofen_quote_random_ee"
//"Type: Main quete"
//"Summary: Cette function gère les voix de richtofen qui apparaissent aléatoirement apres la chute de la fusée "
//"Suggestion : - A test
//              - 
//"
//
function richtofen_quote_random_ee() 
{
    richtofen_quote_ee = [];
    richtofen_quote_ee_sub = [];
    richtofen_quote_ee[ 1 ] = "vox_richtofen_random_1"; //
    richtofen_quote_ee_sub[ 1 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_1"; //
    richtofen_quote_ee[ 2 ] = "vox_richtofen_random_2"; // 
    richtofen_quote_ee_sub[ 2 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_2"; //
    richtofen_quote_ee[ 3 ] = "vox_richtofen_random_3"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_ee_sub[ 3 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_3"; //
    richtofen_quote_ee[ 4 ] = "vox_richtofen_random_4"; //
    richtofen_quote_ee_sub[ 4 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_4"; //
    richtofen_quote_ee[ 5 ] = "vox_richtofen_random_5"; 
    richtofen_quote_ee_sub[ 5 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_5"; //
    richtofen_quote_ee[ 6 ] = "vox_richtofen_random_6"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_ee_sub[ 6 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_6"; //
    richtofen_quote_ee[ 7 ] = "vox_richtofen_random_7"; //
    richtofen_quote_ee_sub[ 7 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_7"; //
    richtofen_quote_ee[ 8 ] = "vox_richtofen_random_8"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_ee_sub[ 8 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_8"; //
    richtofen_quote_ee[ 9 ] = "vox_richtofen_random_9"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_ee_sub[ 9 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_9"; //
    richtofen_quote_ee[ 10 ] = "vox_richtofen_random_10"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_ee_sub[ 10 ] = &"NUKED_STRING_RICHTOFEN_RANDOM_10"; //

    while(richtofen_quote_ee.size > 0 && level.boss_battle != true) // boucle jusqu'a que richtofen_quote_ee.size soit vide
    {      
        round = level.round_number + 1;
        if(level.debug_nuked == true)
        {
            IPrintLn("prochain round ou rich parle"+round); // debug
        }
        
        nuked_utility::wait_for_round_range( round );
        level waittill("between_round_over");
        wait( RandomIntRange(30,50) );
        quote = RandomInt( richtofen_quote_ee.size );
        //nuked_utility::playsound_to_players(richtofen_quote_ee[quote]);
        zm_sub::register_subtitle_func(richtofen_quote_ee_sub[quote], 8, undefined, richtofen_quote_ee[quote], undefined, true ); //textLine, duration, origin, sound, duration_begin, to_player)
        if(level.debug_nuked == true)
        {
            IPrintLn("normalement a été remove"+richtofen_quote_ee[quote]); // debug
            IPrintLn("normalement a été remove"+richtofen_quote_ee_sub[quote]);

        }
        ArrayRemoveIndex( richtofen_quote_ee, quote  );  // enleve la quote du richtofen_quote_ee.size
        ArrayRemoveIndex( richtofen_quote_ee_sub, quote  );  // enleve la quote du richtofen_quote_ee.size
    }
    wait (0.5);
}


function richtofen_quote_random() // CLIX ADD // Cette function gère les voix de richtofen qui apparaissent aléatoirement durant le combat
{
    level waittill("final_step_triggered");
    wait 3;
    zm_sub::register_subtitle_func(&"NUKED_STRING_RICHTOFEN_RANDOM_13", 8, undefined, "vox_richtofen_random_13", undefined, true );   

    richtofen_quote = [];
    richtofen_quote_sub = [];
    richtofen_quote[ 1 ] = "vox_richtofen_random_1"; //
    richtofen_quote_sub[ 1 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_1"; //
    richtofen_quote[ 2 ] = "vox_richtofen_random_2"; // 
    richtofen_quote_sub[ 2 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_2"; //
    richtofen_quote[ 3 ] = "vox_richtofen_random_3"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_sub[ 3 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_3"; //
    richtofen_quote[ 4 ] = "vox_richtofen_random_4"; //
    richtofen_quote_sub[ 4 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_4"; //
    richtofen_quote[ 5 ] = "vox_richtofen_random_5"; 
    richtofen_quote_sub[ 5 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_5"; //
    richtofen_quote[ 6 ] = "vox_richtofen_random_7"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_sub[ 6 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_7"; //
    richtofen_quote[ 7 ] = "vox_richtofen_random_10"; //
    richtofen_quote_sub[ 7 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_10"; //
    richtofen_quote[ 8 ] = "vox_richtofen_random_11"; //
    richtofen_quote_sub[ 8 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_11"; //
    richtofen_quote[ 9 ] = "vox_richtofen_random_12"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_sub[ 9 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_12"; //
    richtofen_quote[ 10 ] = "vox_richtofen_random_14"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_sub[ 10 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_14"; // 
    richtofen_quote[ 11 ] = "vox_richtofen_random_15"; // Vide pour eviter quil parle tout le temps
    richtofen_quote_sub[ 11 ]= &"NUKED_STRING_RICHTOFEN_RANDOM_15"; //

    while(richtofen_quote.size > 0) // boucle jusqu'a que richtofen_quote.size soit vide
    {
        wait( RandomIntRange(30,50) );
        quote = RandomInt( richtofen_quote.size );
        //playsound_to_players(richtofen_quote[quote]);
        zm_sub::register_subtitle_func(richtofen_quote_sub[quote], 8, undefined, richtofen_quote[quote], undefined, true );  //textLine, duration, origin, sound, duration_begin, to_player)
        if(level.debug_nuked == true)
        {  
            IPrintLn("normalement a été remove"+richtofen_quote[quote]);
        }
        ArrayRemoveIndex( richtofen_quote, quote  );  // enleve la quote du richtofen_quote.size
        ArrayRemoveIndex( richtofen_quote_sub, quote  );  // enleve la quote du richtofen_quote_ee.size
    }
    wait (0.5);
}