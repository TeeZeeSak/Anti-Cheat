/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <engine>

#define PLUGIN "Anticheat Bhop/Ground strafe"
#define VERSION "1.0"
#define AUTHOR "chick"

new g_iFrames [ 33 ];

//Fog1 Fog2 detecting ( 12+ Fog1 / 17+ Fog2 - bhop hack )
new g_iBhopFog1 [ 33 ];
new g_iBhopFog2 [ 33 ];

new m_iBhopFog1 [ 33 ];
new m_iBhopFog2 [ 33 ];

// Gstrafe Fog
new g_iGstrafeFog1 [ 33 ];
new g_iGstrafeFog2 [ 33 ];


//Detecting by ratio
new g_iBhopRatioFog1 [ 33 ];
new g_iBhopRatioFog2 [ 33 ];
new g_iBhopRatioFog3 [ 33 ];
new g_iBhopRatio [ 33 ];
new Float:m_iBhopRatio [ 33 ];

//Detecting by ratio
new g_iGstrafeRatioFog1 [ 33 ];
new g_iGstrafeRatioFog2 [ 33 ];
new g_iGstrafeRatioFog3 [ 33 ];
new g_iGstrafeRatio [ 33 ];

//Detecting strafe hack
new Float:flSideMove[33]
new Float:flForwardMove[33]

new Float:g_Result

new g_iDetections[33]
new g_iLastMessage[33]

//Punishment cvar
new amxac_punish;


public plugin_init ( )
{
	register_plugin( PLUGIN , VERSION , AUTHOR );
		
	register_clcmd ( "say /anticheat", "shmotd" );

	register_forward(FM_CmdStart, "client_CmdStart")

	amxac_punish = register_cvar("amxac_punish", "1");// 1 = slay; 2 = kick
}

public client_connect(id){
	m_iBhopFog1[id] = 0;
	m_iBhopFog2[id] = 0;
	m_iBhopRatio[id] = 0.0;
	g_iDetections[id] = 0;
	g_iLastMessage[id] = 0;
}

public shmotd ( id )
{
	new motd [ 2048 ], len;
	len = format ( motd, 2047, "<html><head><meta charset='UTF-8'><h1 style='color: white;'>Anticheat sumarry</h1><style>body{font-family: 'Calibri';background-color:rgba(21,21,21,255);width:auto; }\
	td {border-bottom: 1px #bbb solid;background-color: rgba(255,255,255,0.8);text-align: center; width:auto;}tr:nth-child(1){background-color: rgba(150,0,0,0.8);}tr:nth-child(even)\
	{background-color: rgba(25,25,25,0.1);}table{border-spacing: 0;}</style></head><body><table style=^"width:100&#37;^">" );
	len += format ( motd [len], 2047-len, "<tr><th>Nickname</th><th>SteamID</th><th>Perfect Hops</th><th>Semi-perfect Hops</th><th>Ratio</th><th>Detections</th></tr>" );
	
	for(new i = 1; i <= 32; i++){
		if(!is_user_connected(i) || is_user_bot(i))
			continue;
		new name[33], steamid[65];
		get_user_name(id, name, sizeof(name) - 1);
		get_user_authid(id, steamid, sizeof(steamid) - 1);
		len += format ( motd [len], 2047-len, "<tr><td>%s</td><td>%s</td><td>%i</td><td>%i</td><td>%.1f%</td><td>%i</td></tr>", name, steamid, m_iBhopFog1[i], m_iBhopFog2[i], m_iBhopRatio[i], g_iDetections[i]);
	}
	len += format ( motd [len], 2047-len, "</table></body></html>" );
	
	show_motd ( id, motd, "Cheaters" );
}


public client_CmdStart(id, uc)
{
	if( is_user_alive(id) ){
		
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		
		if( velocity[2] != 0 )
			velocity[2]-=velocity[2];
		
		new Float:flSpeed = vector_length(velocity);
		
		get_uc(uc, UC_ForwardMove, flForwardMove[id])
		
		get_uc(uc, UC_SideMove, flSideMove[id])
		
		new Float:playerSpeed = get_user_maxspeed(id);
		
		checkFastRun(id, playerSpeed, flSpeed);
		
		checkStrafeHack(id, playerSpeed, flSpeed);
		
	}
} 


public checkStrafeHack(id, Float:playerSpeed, Float:flSpeed){
	if(!(get_entity_flags(id) & FL_ONGROUND)){
		if(flSideMove[id] * 1 > playerSpeed){
			if((flForwardMove[id] * 1) < 100){
				new szUserName[65], szSteamId[33];
				get_user_name(id, szUserName, sizeof(szUserName) - 1)
				
				get_user_authid(id, szSteamId, sizeof(szSteamId) - 1)
				
				
				if(get_pcvar_num(amxac_punish) == 1){
					server_cmd("amx_slay %s", szSteamId);
				}else if(get_pcvar_num(amxac_punish) == 2){
					server_cmd("amx_kick %s ^"Cheat detected!^"", szSteamId);
				}
				
				if(g_iLastMessage[id] + 60 <= get_systime()){
					
					ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using strafehack!", szUserName, szSteamId);
					g_iLastMessage[id] = get_systime();
				}
				g_iDetections[id]++;
			}
		}
	}
}

public checkFastRun(id, Float:playerSpeed, Float:flSpeed){
	if(get_entity_flags(id) & FL_ONGROUND){
		if(flForwardMove[id] * 1 > playerSpeed + 20 && flSpeed >= playerSpeed + 25 && flSpeed <= playerSpeed + 50){
			new szUserName[65], szSteamId[33];
			get_user_name(id, szUserName, sizeof(szUserName) - 1)
			
			get_user_authid(id, szSteamId, sizeof(szSteamId) - 1)
			
			
			
			if(get_pcvar_num(amxac_punish) == 1){
					server_cmd("amx_slay %s", szSteamId);
			}else if(get_pcvar_num(amxac_punish) == 2){
					server_cmd("amx_kick %s ^"Cheat detected!^"", szSteamId);
			}
			
			if(g_iLastMessage[id] + 60 <= get_systime()){
				
				ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using fastrun hack!", szUserName, szSteamId);
				g_iLastMessage[id] = get_systime();

			}
			g_iDetections[id]++;
		}
	}	
}

public client_PreThink ( id )
{
	if( pev( id , pev_flags ) & FL_ONGROUND )
		g_iFrames[ id ]++;
	else
		g_iFrames[ id ] = 0;

	new button = pev( id , pev_button );
	new oldbutton = pev( id , pev_oldbuttons );	
		
	new Float:velocity[ 3 ];
	pev ( id , pev_velocity , velocity );

	new Float:speed = floatsqroot( velocity[ 0 ] * velocity[ 0 ] + velocity[ 1 ] * velocity[ 1 ] );
	/*static Float:prevSpeed;*/
	
	//Detecting by FOG1 ( perfect bhop ) and FOG2
	if( speed > 50.0 && g_iFrames[ id ] < 6 && button & IN_JUMP && ~oldbutton & IN_JUMP  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
			if( ( g_iFrames[ id ] == 1 && speed < 400.0 ) /*|| ( g_iFrames[ id ] >= 2 && speed < 400.0 < prevSpeed )*/ )
			{
				g_iBhopFog2 [ id ] = 0;
				g_iBhopFog1 [ id ]++;
				m_iBhopFog1 [ id ]++;

			} else if ( ( g_iFrames[ id ] == 2 && speed < 400.0 ) )
			{
				g_iBhopFog1 [ id ] = 0;
				g_iBhopFog2 [ id ]++;
				m_iBhopFog2 [ id ]++;

			} else
			{
				g_iBhopFog1 [ id ] = 0;
				g_iBhopFog2 [ id ] = 0;
			}
			
			//If perfect bhops are equal or more than 12 - result is probably bhop hack. At 15 Fog1 ( perfect bhops ) is 99,98% hack.
			if (  g_iBhopFog1 [ id ] >= 12 || g_iBhopFog2 [ id ] >=17 ) {
				new name [ 64 ], steamid [ 64 ];
				get_user_name ( id, name, charsmax(name) );
				get_user_authid ( id, steamid, charsmax(steamid) );
				
				if ( g_iBhopFog1 [ id ] >= 12 || g_iBhopFog2 [ id ] >= 12){
					if(get_cvar_num("amxac_punish") == 1){
					server_cmd("amx_slay %s", steamid);
					}else if(get_pcvar_num(amxac_punish) == 2){
						server_cmd("amx_kick %s ^"Cheat detected!^"", steamid);
					}
				
					if(g_iLastMessage[id] + 60 <= get_systime()){
						ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using bhop hack!", name, steamid);
						g_iLastMessage[id] = get_systime();

					}
					g_iDetections[id]++;
				}

			}
		}
	//---------------------------
	
	//-------------------------------------------------------------------------------------------------------------------------------------------
	
	//Detecting by fog1+fog2 check ratio
	if( speed > 50.0 && g_iFrames[ id ] < 6 && button & IN_JUMP && ~oldbutton & IN_JUMP  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
			if ( g_iFrames [ id ] == 1 && speed < 400.0 )
				g_iBhopRatioFog1 [ id ]++;
			if ( g_iFrames [ id ] == 2 && speed < 400.0 )
				g_iBhopRatioFog2 [ id ]++;
			if ( g_iFrames [ id ] > 2 && speed < 400.0 )
				g_iBhopRatioFog3 [ id ]++;
			
			g_iBhopRatio [ id ] = g_iBhopRatioFog1 [ id ] + g_iBhopRatioFog2 [ id ] + g_iBhopRatioFog3 [ id ];
			
			if ( g_iBhopRatio [ id ] == 60 ) {
				g_Result = ( g_iBhopRatioFog1 [ id ] + g_iBhopRatioFog2  [ id ] ) / float( g_iBhopRatio [ id ] ) * 100;
				m_iBhopRatio[id] = g_Result;
				if ( g_Result >= 95 ) {
					new name [ 32 ], steamid [ 32 ], ip [ 32 ];
					get_user_name ( id, name, charsmax(name) );
					get_user_authid ( id, steamid, charsmax(steamid) );
					get_user_ip ( id, ip, charsmax(ip), 0 );
					if(get_pcvar_num(amxac_punish) == 1){
					server_cmd("amx_slay %s", steamid);
					}else if(get_cvar_num("amxac_punish") == 2){
						server_cmd("amx_kick %s ^"Cheat detected!^"", steamid);
					}
				
					if(g_iLastMessage[id] + 60 <= get_systime()){
						g_iLastMessage[id] = get_systime();
						ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using bhop hack!", name, steamid);
					}
					g_iDetections[id]++;


				}
				g_iBhopRatioFog1 [ id ] = 0;
				g_iBhopRatioFog2 [ id ] = 0;
				g_iBhopRatioFog3 [ id ] = 0;
			}
		}
	//---------------------------
	
	//-------------------------------------------------------------------------------------------------------------------------------------------
	
	//Detecting GS by FOG 1 & FOG 2
	if( speed > 50.0 && g_iFrames[ id ] < 6 && button & IN_DUCK && ~oldbutton & IN_DUCK  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
		if( ( g_iFrames[ id ] == 1 && speed < 400.0 ) /*|| ( g_iFrames[ id ] >= 2 && speed < 400.0 < prevSpeed )*/ )
		{
			g_iGstrafeFog2 [ id ] = 0;
			g_iGstrafeFog1 [ id ]++;
		} else if ( ( g_iFrames[ id ] == 2 && speed < 400.0 ) )
		{
			g_iGstrafeFog1 [ id ] = 0;
			g_iGstrafeFog2 [ id ]++;
		} else
		{
			g_iGstrafeFog1 [ id ] = 0;
			g_iGstrafeFog2 [ id ] = 0;
		}
			
		if (  g_iGstrafeFog1 [ id ] >= 12 || g_iGstrafeFog2 [ id ] >=17 ) {
			new name [ 64 ], steamid [ 64 ];
			get_user_name ( id, name, charsmax(name) );
			get_user_authid ( id, steamid, charsmax(steamid) );
			
			if ( g_iGstrafeFog1 [ id ] >= 12 || g_iGstrafeFog2 [ id ] >= 12){
				if(get_cvar_num("amxac_punish") == 1){
					server_cmd("amx_slay %s", steamid);
				}else if(get_pcvar_num(amxac_punish) == 2){
					server_cmd("amx_kick %s ^"Cheat detected!^"", steamid);
				}
				if(g_iLastMessage[id] + 60 <= get_systime()){
					ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using groundstrafe hack!", name, steamid);
				}
				g_iDetections[id]++;
				g_iLastMessage[id] = get_systime();

			}
					
			
		}
	}
	
	// Detecting GS by Ratio
	if( speed > 50.0 && g_iFrames[ id ] < 6 && button & IN_DUCK && ~oldbutton & IN_DUCK  && pev( id, pev_flags ) & FL_ONGROUND  )
		{
		if ( g_iFrames [ id ] == 1 && speed < 400.0 )
			g_iGstrafeRatioFog1 [ id ]++;
		if ( g_iFrames [ id ] == 2 && speed < 400.0 )
			g_iGstrafeRatioFog2 [ id ]++;
		if ( g_iFrames [ id ] > 2 && speed < 400.0 )
			g_iGstrafeRatioFog3 [ id ]++;
		
		g_iGstrafeRatio [ id ] = g_iGstrafeRatioFog1 [ id ] + g_iGstrafeRatioFog2 [ id ] + g_iGstrafeRatioFog3 [ id ];
			
		if ( g_iGstrafeRatio [ id ] == 60 ) {
			g_Result = ( g_iGstrafeRatioFog1 [ id ] + g_iGstrafeRatioFog2  [ id ] ) / float( g_iGstrafeRatio [ id ] ) * 100;
				
			if ( g_Result >= 95 ) {
				new name [ 32 ], steamid [ 32 ], ip [ 32 ];
				get_user_name ( id, name, charsmax(name) );
				get_user_authid ( id, steamid, charsmax(steamid) );
				get_user_ip ( id, ip, charsmax(ip), 0 );
				if(get_cvar_num("amxac_punish") == 1){
					server_cmd("amx_slay %s", steamid);
				}else if(get_pcvar_num(amxac_punish) == 2){
					server_cmd("amx_kick %s ^"Cheat detected!^"", steamid);
				}
				if(g_iLastMessage[id] + 60 <= get_systime()){
					ColorChat(0, "^3[^4Anti-Cheat^3]^1 %s (^4%s^1) is using groundstrafe hack!", name, steamid);
					g_iLastMessage[id] = get_systime();
				}
				g_iDetections[id]++;


			}
			g_iGstrafeRatioFog1 [ id ] = 0;
			g_iGstrafeRatioFog2 [ id ] = 0;
			g_iGstrafeRatioFog3 [ id ] = 0;
		}
	}
}

stock ColorChat(const id, const input[], any:...) 
{ 
    new count = 1, players[32] 
    static msg[ 191 ] 
    vformat(msg, 190, input, 3) 
     
    replace_all(msg, 190, "^x01" , "^1") 
    replace_all(msg, 190, "^x03" , "^3") 
    replace_all(msg, 190, "^x04" , "^4")  
     
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