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

#using scripts\shared\hud_shared;
#using scripts\shared\hud_util_shared;

///////////////////////////////////////PRECACHE SUBTITLE LOCALIZED/////////////////////////////////////////////////////
#precache("string", "NUKED_STRING_ANNOUNCER_DIALOG_1");
#precache("string", "NUKED_STRING_ANNOUNCER_DIALOG_2");

#precache("string", "NUKED_STRING_IEM_DIALOG_1");
#precache("string", "NUKED_STRING_IEM_DIALOG_2");

#precache("string", "NUKED_STRING_MARLTON_DIALOG_1");
#precache("string", "NUKED_STRING_MARLTON_DIALOG_2");
#precache("string", "NUKED_STRING_MARLTON_DIALOG_3");
#precache("string", "NUKED_STRING_MARLTON_DIALOG_4");
#precache("string", "NUKED_STRING_MARLTON_DIALOG_5");
#precache("string", "NUKED_STRING_MARLTON_DIALOG_6");

#precache("string", "NUKED_STRING_RICHTOFEN_DIALOG_1");
#precache("string", "NUKED_STRING_RICHTOFEN_DIALOG_2");
#precache("string", "NUKED_STRING_RICHTOFEN_DIALOG_3");
#precache("string", "NUKED_STRING_RICHTOFEN_DIALOG_4");
#precache("string", "NUKED_STRING_RICHTOFEN_DIALOG_5");

#precache("string", "NUKED_STRING_MAXIS_DIALOG_0");
#precache("string", "NUKED_STRING_MAXIS_DIALOG_1");
#precache("string", "NUKED_STRING_MAXIS_DIALOG_2");
#precache("string", "NUKED_STRING_MAXIS_DIALOG_3");
#precache("string", "NUKED_STRING_MAXIS_DIALOG_4");
#precache("string", "NUKED_STRING_MAXIS_DIALOG_5");

#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_1");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_2");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_3");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_4");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_5");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_6");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_7");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_8");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_9");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_10");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_11");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_12");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_13");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_14");
#precache("string", "NUKED_STRING_RICHTOFEN_RANDOM_15");

///////////////////////////////////////////////////////////////////////////////////////////////////////////

#namespace zm_sub;

function autoexec init() // Cette function permet d'afficher des popup, array::add( level.elem_pop, clientfield, true );
{
    subtitle = NewHudElem();
               subtitle.horzAlign = "center";
            subtitle.vertAlign = "bottom";
            subtitle.alignX = "center";
            subtitle.alignY = "bottom";
           // subtitle hud::setPoint( "CENTER", "bottom", 0, 0 );
            subtitle.x = 0;
            subtitle.y = -80;
            subtitle.sort = 1001;
            subtitle.foreground = false;
            subtitle.hidewheninmenu = true;
            subtitle.fontscale = 1.5;

    while(1)
    {
        level waittill( "tcheck_subtitle" );
        while(level.subtitle_pop.size > 0 )
        {
            line1_to_show = GetFirstArrayKey( level.subtitle_pop );
            duration_to_show = GetFirstArrayKey( level.subtitle_duration );
            duration_to_begin = GetFirstArrayKey( level.subtitle_duration_begin );
         
            text_to_show = level.subtitle_pop[ line1_to_show ];
            text_wait_begin = level.subtitle_duration_begin[ duration_to_begin ];

            if(isdefined(duration_to_begin))
                wait(level.subtitle_duration_begin[ duration_to_begin ]);

            subtitle SetText( text_to_show );
            subtitle.alpha = 0;
            subtitle FadeOverTime( 0.5 );
            subtitle.alpha = 1;

            if(isdefined(duration_to_show))
                wait(level.subtitle_duration[ duration_to_show ]);

            else
                wait 5;


            ArrayRemoveIndex( level.subtitle_pop, line1_to_show  );
            subtitle FadeOverTime( 0.5 );
            subtitle.alpha = 0;

            if(isdefined(duration_to_show))
                ArrayRemoveIndex( level.subtitle_duration, duration_to_show  );

            if(isdefined(duration_to_begin))
                ArrayRemoveIndex( level.subtitle_duration_begin, duration_to_begin  );
              

           
            level notify ( "tcheck_subtitle" );
        }

    }
}


function register_subtitle_func(textLine, duration, origin, sound, duration_begin, to_player)
{
    if ( !isdefined( level.subtitle_pop ) ) // Crée l'array si elle n'est pas défini
    {
        level.subtitle_pop = [];

        level.subtitle_duration = [];

        level.subtitle_duration_begin = [];
    }
    multi = true; // distinction entre deux meme valeur

    if(isdefined(textLine))
    array::add( level.subtitle_pop, textLine,multi );

    if(isdefined(duration))
    array::add( level.subtitle_duration, duration,multi );

    if(isdefined(duration_begin))
    array::add( level.subtitle_duration_begin, duration_begin,multi );

    if(isdefined(origin) && isdefined(sound))
        PlaySoundAtPosition( sound, origin );

    if(IS_TRUE(to_player) && isdefined(sound))
        {
            players = GetPlayers(); 
            foreach( player in players )
                player PlayLocalSound( sound );
        }

    level notify ( "tcheck_subtitle" );
}
