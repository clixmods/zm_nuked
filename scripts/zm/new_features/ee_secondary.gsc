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

#define OUTLET_SHOOTED_FX "electric/fx_elec_spark_loop_sm" 
#precache( "fx", OUTLET_SHOOTED_FX ); 

#precache( "model", "p7_conduit_metal_1_outlet_plug_e_burnt" );
#precache( "model", "p7_zm_teddybear_sitting_shootable" );


function init()
{
    level thread outlet_shootable(); 
   
    level thread phd_song();   
    
    level thread teddy_shootable();
}


function teddy_shootable() 
{
    level.teddy_count = 0;
    gift_teddy_drop = struct::get( "zm_nuked_teddy_shootable_gift", "script_noteworthy" );
    teddy_shoot_trig = struct::get_array("teddy_shoot","targetname");

    while( teddy_shoot_trig.size != 3) 
    {
        index = RandomInt( teddy_shoot_trig.size );
        teddy_shoot_trig[index] Delete();        
        
        ArrayRemoveIndex( teddy_shoot_trig, index  );
       
        wait 1;
    }

    for(i = 0; i < teddy_shoot_trig.size; i++)
    {
        teddy_shoot_trig[i] thread teddy_triggered();
    }

    while(1)
    {
        level waittill("teddy_shotted");

        if ( level.teddy_count == teddy_shoot_trig.size ) // Objectif
        {
            increase_perk_purchase_limit();
            level.teddy_count--;
            break;
        }

        wait 0.5;
    
    }
}

function teddy_triggered()
{ 
    self.teddy = util::spawn_model("p7_zm_teddybear_sitting_shootable", self.origin, self.angles);
    self.teddy SetCanDamage(1);
    self.teddy waittill( "damage", amount, attacker, dir, org, mod );
    level.teddy_count++;
 
    self.teddy Delete();    
    self Delete();
    level notify("teddy_shotted");   
}

function outlet_shootable() 
{
    level.prise_count = 0; 
    prise_shoot_trig = GetEntArray( "prise_shootable", "targetname" );

    for(i = 0; i < prise_shoot_trig.size; i++)
    {
        prise_shoot_trig[i] thread prise_add();
    }

    while(true)
    {
        level waittill("prise_shooted");

        if ( level.prise_count == prise_shoot_trig.size ) // Objectif
        {
            increase_perk_purchase_limit();
            break;
        }

        wait 0.5;
    }
}

function increase_perk_purchase_limit()
{
    level.perk_purchase_limit++;
    IPrintLnBold("Perk purchase limit increased to " + level.perk_purchase_limit);
}

function prise_add() 
{
    self SetCanDamage(1);
    self waittill( "damage", amount, attacker, dir, org, mod );
    self SetCanDamage(0);
    PlayFX( OUTLET_SHOOTED_FX , self.origin);
    level.prise_count++;
    self SetModel("p7_conduit_metal_1_outlet_plug_e_burnt");
    level notify("prise_shooted");
}

function phd_song()
{
    trig = GetEnt("phd_trig","targetname");
    trig waittill("trigger",grenade, weapon, player);
    PlaySoundAtPosition("mus_perks_phdflopper_jingle", trig.origin);
}