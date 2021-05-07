#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <geoip>
#include <files>
#pragma newdecls required
#pragma semicolon 1

char g_sFilePath[PLATFORM_MAX_PATH];
char g_sConnectionState[32];
char g_sFormatedTime[64];

Handle g_hFile;

public Plugin myinfo =
{
	name = "Info Tracker",
	author = "Kyli3_Boi",
	description = "",
	version = "1.0",
	url = "https://github.com/Kyli3Boi/InfoTracker"
};


public void OnPluginStart()
{
	BuildPath(Path_SM, g_sFilePath, sizeof(g_sFilePath), "data/InfoTracker/");

	if (!DirExists(g_sFilePath))
	{
		CreateDirectory(g_sFilePath, 3);
	}
}

public void OnMapStart()
{
	int currentTime = GetTime();
	char currentMap[128];
	
	GetCurrentMap(currentMap, sizeof(currentMap));
	FormatTime(g_sFormatedTime, 100, "%d/%m/%y %R", currentTime);

	BuildPath(Path_SM, g_sFilePath, sizeof(g_sFilePath), "data/InfoTracker/PlayerInfo.txt");
	
	g_hFile = OpenFile(g_sFilePath, "a");
	
	WriteFileLine(g_hFile, "%s | --------------------------- Map changed to %s ---------------------------", g_sFormatedTime, currentMap);

	CloseHandle(g_hFile);
}

public void OnClientPostAdminCheck(int client)
{
	int currentTime = GetTime();
	g_sConnectionState = "Connected";
	
	SavePlayerInfo(client, currentTime);
}

public void OnClientDisconnect(int client)
{
	int currentTime = GetTime();
	g_sConnectionState = "Disconnected";

	SavePlayerInfo(client, currentTime);
}

public void SavePlayerInfo(int client, int currentTime)
{
	if (!IsFakeClient(client))
	{
		char name[MAX_NAME_LENGTH];
		char IPAddress[64];
		char steamId[64];
		char country[64];

		g_hFile = OpenFile(g_sFilePath, "a");

		FormatTime(g_sFormatedTime, 100, "%d/%m/%y %R", currentTime);

		GetClientName(client, name, sizeof(name));
		GetClientIP(client, IPAddress, sizeof(IPAddress));
		GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
		
		//GeoipCountry(IPAddress, country, 45);
		if (!GeoipCountry(IPAddress, country, 45))
		{
			Format(country, 64, "Another Planet");
		}
		
		WriteFileLine(g_hFile, "%s | %s %s from %s: IP: %s | SteamID: %s", g_sFormatedTime, name, g_sConnectionState, country, IPAddress, steamId);

		CloseHandle(g_hFile);
	}
}

public void OnMapEnd()
{
	g_hFile = OpenFile(g_sFilePath, "a");
	
	WriteFileLine(g_hFile, "%s | --------------------------- Map Ended ---------------------------", g_sFormatedTime);

	CloseHandle(g_hFile);
}