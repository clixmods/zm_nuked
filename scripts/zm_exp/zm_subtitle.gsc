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

function register_subtitle_func(textLine, duration, origin, sound, duration_begin, to_player)
{
    // Old logic about subtitle was remove for mod compatibility

    // I let these lines to avoid editing all files using this function, maybe find a better function name later
    if(isdefined(origin) && isdefined(sound))
        PlaySoundAtPosition( sound, origin );

    if(IS_TRUE(to_player) && isdefined(sound))
    {
        players = GetPlayers(); 
        foreach( player in players )
        {
            player PlayLocalSound( sound );
        }    
    }

    // If your mod has custom subtitle logic, you can implement it here
}
