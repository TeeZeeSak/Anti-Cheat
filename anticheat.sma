#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <dhudmessage>

#define PLUGIN "Anticheat beta"
#define VERSION "1.2b"
#define AUTHOR "chick & TeeZ0"
//Variables----

//Bool if detected hack!
new bool:g_bIsUserHacking [ 33 ][ 1 ];
#define CHEAT_BHOP 0
/*MUST REPAIR
new Float:flSideMove[33] , Float:flForwardMove[33];
*/
//Frames
new g_iFrames [ 33 ];
new g_iFramesInAir [33];

//Total bhops
new g_iTotalBhops [ 33 ];

//Fog1 & Fog2 for count
new g_iPerfectBhop [ 33 ]; 			//Fog1
new g_iSemiPerfectBhop [ 33 ]; 		//Fog2

#define MAXPERFECT 12
#define MAXSEMIPERFECT 17

//Fog1 & Fog2 for ratio
new g_iRatioPerfectBhop [ 33 ];		//Fog1
new g_iRatioSemiPerfectBhop [ 33 ];	//Fog2
new g_iRatioTotalBhops [ 33 ];

//Punish slay or kick ( 1 or 2 )
new ac_punish;

//Chat and log messages
/*new g_iLastChatMessage [ 33 ];*/
new g_iLastLogMessage [ 33 ];

//Motd
new g_iMotdPerfectBhops [ 33 ];
new g_iMotdSemiPerfectBhops [ 33 ];
new g_iMotdTotalBhops [ 33 ];
//End----------

public plugin_init()
{
	register_plugin( PLUGIN , VERSION , AUTHOR );

	//MOTD for ADMIN_BAN
	register_clcmd ( "say /anticheat" , "fwMotd" , ADMIN_BAN );
	
	ac_punish = register_cvar( "ac_punish" , "1" ); //Slay - 1 || Kick - 2 || Default is 1

	//RegisterHam ( Ham_Spawn , "player" , "client_spawn" , 1 );
	//register_forward( FM_CmdStart , "fw_CmdStart" );
}
/* MUST REPAIR
public fw_CmdStart ( id , uc_handle )
{
	new Float:flMaxSpeed;
	pev ( id , pev_maxspeed , flMaxSpeed );
	get_uc ( uc_handle , UC_SideMove , flSideMove[id] );
	get_uc ( uc_handle , UC_ForwardMove , flForwardMove[id] );

	new button = pev ( id , pev_button );
	new oldbuttons = pev ( id , pev_oldbuttons );

	set_dhudmessage( 250 , 0 , 0 , -1.0 , 0.25 , 0 , 0.2 , 0.4 , 0.1 , 0.1 );
	show_dhudmessage( id , "Maxspeed & Sidemove & Forwardmove:^n%.2f   %.2f   %.2f" , flMaxSpeed , flSideMove[id] , flForwardMove[id] );

	if ( button & IN_MOVELEFT && oldbuttons & IN_MOVELEFT )
			client_print ( id , print_chat , "Your sidemove: %.2f" , flSideMove[id] )

	if ( g_iFramesInAir[id] > 20 && is_user_alive(id) && is_user_connected(id) )
	{
		if ( button & IN_MOVELEFT && oldbuttons & IN_MOVELEFT || button & IN_MOVERIGHT && oldbuttons & IN_MOVERIGHT )
			{
				new Float:absflSideMove = floatabs ( flSideMove[id] );
				if ( absflSideMove != flMaxSpeed )
					{
						new szName [32] , szSteamId [32];
						get_user_name ( id , szName , charsmax(szName) );
						get_user_authid ( id , szSteamId , charsmax(szSteamId) );
						ColorChat ( 0 , "^1[^4Anti-cheat^1] Player %s(^4%s^1) is using strafe helper!" , szName , szSteamId );
					}
			}
		if ( button & IN_FORWARD && oldbuttons & IN_FORWARD || button & IN_BACK && oldbuttons & IN_BACK )
			{
				new Float:absflForwardMove = floatabs ( flForwardMove[id] );
				if ( absflForwardMove != flMaxSpeed )
					{
							new szName [32] , szSteamId [32];
							get_user_name ( id , szName , charsmax(szName) );
							get_user_authid ( id , szSteamId , charsmax(szSteamId) );
							ColorChat ( 0 , "^1[^4Anti-cheat^1] Player %s(^4%s^1) is using strafe helper!" , szName , szSteamId );
					}
			}
	}
}
*/
public client_connect ( id )
{
	if ( g_iMotdTotalBhops [id] != 0 ) g_iMotdTotalBhops [id] = 0;
	if ( g_iMotdTotalBhops [id] != 0 ) g_iMotdPerfectBhops [id] = 0;
	if ( g_iMotdTotalBhops [id] != 0 ) g_iMotdSemiPerfectBhops [id] = 0;
}

/*public client_spawn ( id )
{
	
}*/

public fwMotd ( id , level , cid )
{
	if ( !cmd_access ( id , level , cid , 2 ) )
		return;

	new motd [ 2048 ] , len;
	len = format ( motd , 2047 , "<html><head><meta charset='UTF-8'><h1 style='color: white;'>Anticheat sumarry</h1><style>body{font-family: 'Calibri';background-color:rgba(21,21,21,255);width:auto; }\
	td {border-bottom: 1px #bbb solid;background-color: rgba(255,255,255,0.8);text-align: center; width:auto;}tr:nth-child(1){background-color: rgba(150,0,0,0.8);}tr:nth-child(even)\
	{background-color: rgba(25,25,25,0.1);}table{border-spacing: 0;}</style></head><body><table style=^"width:100&#37;^">" );
	len += format ( motd [ len ] , 2047-len , "<tr><th>Nickname</th><th>SteamID</th><th>Perfect Bhops</th><th>Semi-perfect Bhops</th><th>Total Bhops</th><th>Ratio</th></tr>" );

	new players [ 32 ] , playercount , PlayerID;
	get_players ( players , playercount );

	for ( new i = 0; i < playercount; i++ )
		{
			PlayerID = players [ i ];
			//Create ratio!
			new Float:flRatio = ( float (g_iMotdPerfectBhops [PlayerID]) + float (g_iMotdSemiPerfectBhops [PlayerID]) ) / float(g_iTotalBhops [PlayerID]) * 100;
			//End & Continue
			new szName [ 32 ] , szSteamId [ 32 ];
			get_user_name ( PlayerID , szName , charsmax(szName) );
			get_user_authid ( PlayerID , szSteamId , charsmax(szSteamId) );
			len += format ( motd [ len ] , 2047-len , "<tr><td>%s</td><td>%s</td><td>%i</td><td>%i</td><td>%i</td><td>%.2f%</td></tr>" , szName , szSteamId , g_iMotdPerfectBhops [PlayerID] , \
			g_iMotdSemiPerfectBhops [PlayerID] , g_iMotdTotalBhops [PlayerID] , flRatio );
		}
	len += format ( motd [ len ] , 2047-len , "</table></body></html>" );

	show_motd ( id , motd , "Anticheat" );
}

public client_PreThink ( id )
{
	new button = pev ( id , pev_button );
	new oldbuttons = pev ( id , pev_oldbuttons );
	new IsPlayerOnGround = pev ( id , pev_flags ) & FL_ONGROUND;
	//Frame on ground
	if ( IsPlayerOnGround )
		g_iFrames [id]++;
	else
		g_iFrames [id] = 0;
	//End

	if ( !IsPlayerOnGround && !is_user_bot(id) && is_user_alive(id) && is_user_connected(id) )
		g_iFramesInAir [id]++;
	else
		g_iFramesInAir [id] = 0;
	
	//Player speed
	new Float:flVelocity [ 3 ] , Float:flPlayerSpeed;
	pev ( id , pev_velocity , flVelocity );
	flPlayerSpeed = floatsqroot ( flVelocity [ 0 ] * flVelocity [ 0 ] + flVelocity [ 1 ] * flVelocity [ 1 ] );
	//End

	//Detecting if player is bhoping & BHOP HACK DETECTING
	if ( flPlayerSpeed > 50.0 && g_iFrames [id] <= 6 && button & IN_JUMP && ~oldbuttons & IN_JUMP && pev ( id , pev_flags ) & FL_ONGROUND )
		{
			g_iTotalBhops [id]++;		//Count total bhops
			g_iMotdTotalBhops [id]++;	//Too for MOTD
			g_iRatioTotalBhops [id]++;	//And for ratio

			//Detecting perfect bhops & semi-perfect bhops
			if ( g_iFrames [id] == 1 && flPlayerSpeed < 400.0 )
				{
					g_iPerfectBhop [id]++;
					g_iRatioPerfectBhop [id]++;
					g_iSemiPerfectBhop [id] = 0;
					g_iMotdPerfectBhops [id]++;
				}
			else if ( g_iFrames [id] == 2 && flPlayerSpeed < 400.0 )
				{
					g_iSemiPerfectBhop [id]++;
					g_iRatioSemiPerfectBhop [id]++;
					g_iPerfectBhop [id] = 0;
					g_iMotdSemiPerfectBhops [id]++;
				}
			else
				{
					g_iPerfectBhop [id] = 0;
					g_iSemiPerfectBhop [id] = 0;
				}
			//End

			//Detecting high ratio perfect bhops & semi-perfect bhops of 60 bhops ( (Perfect bhops+Semiperfect bhops)/Total bhops*100  ) - 57/60 ( 95% ) is hacked.
			if ( g_iRatioTotalBhops [id] >= 60 )
				{
					new Float:flRatio = ( float(g_iRatioPerfectBhop[id]) + float(g_iRatioSemiPerfectBhop [id]) ) / float(g_iTotalBhops [id]) * 100;
					if ( flRatio >= 95.0 )
					{
						if ( !g_bIsUserHacking [id][CHEAT_BHOP] ) g_bIsUserHacking [id][CHEAT_BHOP] = true;
						//Log
						if ( g_iLastLogMessage [id]+60 >= get_systime() )
						{
							new szName [ 32 ] , szSteamId [ 32 ];
							get_user_name ( id , szName , charsmax(szName) );
							get_user_authid ( id , szSteamId , charsmax(szSteamId) );
							log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack. (Big ratio of perfect/semi-perfect bhops = %.2f)" , szName , szSteamId , flRatio );
							g_iLastLogMessage [id] = get_systime ();
						}
					}
					g_iRatioTotalBhops [id] = 0;
				}
			//End

			//Detect if player reached MAXPERFECT ( 12 ) perfect bhops.
			if ( g_iPerfectBhop [id] >= MAXPERFECT )
				{
					if ( !g_bIsUserHacking [id][CHEAT_BHOP] ) g_bIsUserHacking [id][CHEAT_BHOP] = true;
					if ( g_iLastLogMessage [id]+300 <= get_systime() )
						{
							new szName [ 32 ] , szSteamId [ 32 ];
							get_user_name ( id , szName , charsmax(szName) );
							get_user_authid ( id , szSteamId , charsmax(szSteamId) );
							log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack. (Perfect bhop)" , szName , szSteamId );
							g_iLastLogMessage [id] = get_systime ();
						}
				}
			//Detect if player reached MAXSEMIPERFECT ( 17 ) perfect bhops.
			if ( g_iSemiPerfectBhop [id] >= MAXSEMIPERFECT )
				{
					if ( !g_bIsUserHacking [id][CHEAT_BHOP] ) g_bIsUserHacking [id][CHEAT_BHOP] = true;
					if ( g_iLastLogMessage [id]+300 <= get_systime() )
					{
						new szName [ 32 ] , szSteamId [ 32 ];
						get_user_name ( id , szName , charsmax(szName) );
						get_user_authid ( id , szSteamId , charsmax(szSteamId) );
						log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack." , szName , szSteamId );
						g_iLastLogMessage [id] = get_systime ();
					}
				}
			//End detecting
		}
	//Punish
	fw_Punish (id);
}

public fw_Punish ( id )
{
	new szName [ 32 ] , szSteamId [ 32 ];
	get_user_name ( id , szName , charsmax(szName) );
	get_user_authid ( id , szSteamId , charsmax(szSteamId) );

	if ( g_bIsUserHacking [id][CHEAT_BHOP] )
	{
		if ( is_user_connected(id) && is_user_alive(id) )
		{
			if ( get_pcvar_num (ac_punish) == 1 )
				{
					server_cmd ( "amx_slay ^"%s^"" , szSteamId );
					if ( g_bIsUserHacking [id][CHEAT_BHOP] )
							ColorChat( 0 , "^1[^4Anti-cheat^1] Player ^4%s^1 (^4%s^1) is using bhop hack! Slaying.." , szName , szSteamId  );
				}
		}
	}
}

stock ColorChat(const id, const input[], any:...) 
{ 
    new count = 1, players[32] 
    static msg[ 191 ] 
    vformat(msg, 190, input, 3) 
     
    replace_all(msg, 190, "^x01" , "^1") //white
    replace_all(msg, 190, "^x03" , "^3") //team
    replace_all(msg, 190, "^x04" , "^4") //green
     
    if (id) players[0] = id; else get_players(players , count , "ch") 
    { 
    for (new i = 0; i < count; i++) 
    { 
            if (is_user_connected(players[i])) 
            { 
                message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("SayText"), _, players[i]) 
                write_byte(players[i]); 
                write_string(msg); 
                message_end(); 
            } 
        } 
    } 
} 
