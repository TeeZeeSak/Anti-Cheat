#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fun>

#define PLUGIN "Anticheat beta"
#define VERSION "1.1b"
#define AUTHOR "chick & TeeZ0"
//Variables----

//Bool if detected hack!
new bool:g_bIsUserHacking [ 33 ];

//Frames
new g_iFrames [ 33 ];

//Detecting FOG1 & FOG2
#define MAXPERFECT 12
#define MAXSEMIPERFECT 17

//Total bhops
new g_iTotalBhops [ 33 ];

//Fog1 & Fog2 for count
new g_iPerfectBhop [ 33 ]; 			//Fog1
new g_iSemiPerfectBhop [ 33 ]; 		//Fog2

//Fog1 & Fog2 for ratio
new g_iRatioPerfectBhop [ 33 ];		//Fog1
new g_iRatioSemiPerfectBhop [ 33 ];	//Fog2

//Punish slay or kick ( 1 or 2 )
new ac_punish;

//Chat and log messages
new g_iLastChatMessage [ 33 ];
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
	//End
	ac_punish = register_cvar( "ac_punish" , "1" ); //Slay - 1 || Kick - 2 || Default is 1
}

public client_disconnect ( id )
{
	if ( g_iMotdTotalBhops [ id ] != 0 ) g_iMotdTotalBhops [ id ] = 0;
	if ( g_iMotdTotalBhops [ id ] != 0 ) g_iMotdPerfectBhops [ id ] = 0;
	if ( g_iMotdTotalBhops [ id ] != 0 ) g_iMotdSemiPerfectBhops [ id ] = 0;
}

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

	for ( new i; i < playercount; i++ )
		{
			//Create ratio!
			new Float:flRatio = ( float (g_iMotdPerfectBhops [ id ]) + float (g_iMotdSemiPerfectBhops [ id ]) ) / float(g_iTotalBhops [ id ]) * 100;
			//End & Continue
			new szName [ 32 ] , szSteamId [ 32 ];
			PlayerID = players [ i ];
			get_user_name ( PlayerID , szName , charsmax(szName) );
			get_user_authid ( PlayerID , szSteamId , charsmax(szSteamId) );
			len += format ( motd [ len ] , 2047-len , "<tr><td>%s</td><td>%s</td><td>%i</td><td>%i</td><td>%i</td><td>%.2f%</td></tr>" , szName , szSteamId , g_iMotdPerfectBhops [ id ] , \
			g_iMotdSemiPerfectBhops [ id ] , g_iMotdTotalBhops [ id ] , flRatio );
		}
	len += format ( motd [ len ] , 2047-len , "</table></body></html>" );

	show_motd ( id , motd , "Anticheat" );
}

public client_PreThink ( id )
{
	new button = pev ( id , pev_button );
	new oldbuttons = pev ( id , pev_oldbuttons );
	//Frame on ground
	if ( pev ( id , pev_flags ) & FL_ONGROUND )
		g_iFrames [ id ]++;
	else
		g_iFrames [ id ] = 0;
	//End

	//Player speed
	new Float:flVelocity [ 3 ] , Float:flPlayerSpeed;
	pev ( id , pev_velocity , flVelocity );
	flPlayerSpeed = floatsqroot ( flVelocity [ 0 ] * flVelocity [ 0 ] + flVelocity [ 1 ] * flVelocity [ 1 ] );
	//End

	//Detecting if player is bhoping
	if ( flPlayerSpeed > 50.0 && g_iFrames [ id ] <= 6 && button & IN_JUMP && ~oldbuttons & IN_JUMP && pev ( id , pev_flags ) & FL_ONGROUND )
		{
			//Count total bhops!
			g_iTotalBhops [ id ]++;
			//Too for MOTD
			g_iMotdTotalBhops [ id ]++;
			//End

			//Detecting perfect bhops & semi-perfect bhops
			if ( g_iFrames [ id ] == 1 && flPlayerSpeed < 400.0 )
				{
					g_iPerfectBhop [ id ]++;
					g_iRatioPerfectBhop [ id ]++;
					g_iSemiPerfectBhop [ id ] = 0;
					g_iMotdPerfectBhops [ id ]++;
				}
			else if ( g_iFrames [ id ] == 2 && flPlayerSpeed < 400.0 )
				{
					g_iSemiPerfectBhop [ id ]++;
					g_iRatioSemiPerfectBhop [ id ]++;
					g_iPerfectBhop [ id ] = 0;
					g_iMotdSemiPerfectBhops [ id ]++;
				}
			else
				{
					g_iPerfectBhop [ id ] = 0;
					g_iSemiPerfectBhop [ id ] = 0;
				}
			//End

			//Detecting high ratio perfect bhops & semi-perfect bhops of 60 bhops ( (Perfect bhops+Semiperfect bhops)/Total bhops*100  ) - 57/60 ( 95% ) is hacked.
			if ( g_iTotalBhops [ id ] >= 60 )
				{
					new Float:flRatio = ( float(g_iRatioPerfectBhop[ id ]) + float(g_iRatioSemiPerfectBhop [ id ]) ) / float(g_iTotalBhops [ id ]) * 100;
					if ( flRatio >= 95.0 )
						{
							if ( !g_bIsUserHacking [ id ] ) g_bIsUserHacking [ id ] = true;
							//Log
							if ( g_iLastLogMessage [ id ]+60 >= get_systime() )
							{
								new szName [ 32 ] , szSteamId [ 32 ];
								get_user_name ( id , szName , charsmax(szName) );
								get_user_authid ( id , szSteamId , charsmax(szSteamId) );
								log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack. (Big ratio of perfect/semi-perfect bhops = %.2f)" , szName , szSteamId , flRatio );
								g_iLastLogMessage [ id ] = get_systime ();
							}
						}
					g_iTotalBhops [ id ] = 0;
				}
			//End

			//Detect if player reached MAXPERFECT ( 12 ) perfect bhops.
			if ( g_iPerfectBhop [ id ] >= MAXPERFECT )
				{
					if ( !g_bIsUserHacking [ id ] ) g_bIsUserHacking [ id ] = true;
					if ( g_iLastLogMessage [id]+300 <= get_systime() )
						{
							new szName [ 32 ] , szSteamId [ 32 ];
							get_user_name ( id , szName , charsmax(szName) );
							get_user_authid ( id , szSteamId , charsmax(szSteamId) );
							log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack. (Perfect bhop)" , szName , szSteamId );
							g_iLastChatMessage [ id ] = get_systime ();
						}
				}
			//Detect if player reached MAXSEMIPERFECT ( 17 ) perfect bhops.
			if ( g_iSemiPerfectBhop [ id ] >= MAXSEMIPERFECT )
				{
					if ( !g_bIsUserHacking [ id ] ) g_bIsUserHacking [ id ] = true;
					if ( g_iLastLogMessage [id]+300 <= get_systime() )
					{
						new szName [ 32 ] , szSteamId [ 32 ];
						get_user_name ( id , szName , charsmax(szName) );
						get_user_authid ( id , szSteamId , charsmax(szSteamId) );
						log_to_file( "anticheat_log.log" , "[Anticheat] Player %s (%s) used bhop hack." , szName , szSteamId );
						g_iLastChatMessage [ id ] = get_systime ();
					}
				}
			//End detecting

			//Punish if bool hacking is true
			if ( g_bIsUserHacking [ id ] )
				{
					new szName [ 32 ] , szSteamId [ 32 ];
					get_user_name ( id , szName , charsmax(szName) );
					get_user_authid ( id , szSteamId , charsmax(szSteamId) );

					if ( get_pcvar_num (ac_punish) == 1 )
					{
						server_cmd ( "amx_slay %s" , szSteamId );
						ColorChat( 0 , "^1[^4Anti-cheat^1] Player ^4%s^1 (^4%s^1) is using bhop hack! Slaying.." , szName , szSteamId );
					}
					if ( get_pcvar_num (ac_punish) == 2 )
					{
						server_cmd ( "amx_kick %s" , szSteamId );
						ColorChat( 0 , "^1[^4Anti-cheat^1] Player ^4%s^1 (^4%s^1) is using bhop hack! Slaying.." , szName , szSteamId );
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
