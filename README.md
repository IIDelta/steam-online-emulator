![Retro Patcher Banner](https://github.com/IIDelta/steam-online-emulator/blob/main/assets/banner.jpg)

# Auto-Patcher v3.0

=========================================

PRE-REQUISITES:

Ensure the game folder contains the steam_api.dll (preferably, the original, uncracked).

IF NOT: locate it in the game folder (may have been renamed by the crack) or online.

Game folder: steam_api.dll is often renamed appending '_o' or '.bak'

Online: Search for the file corresponding specifically to your game version. **Warning:** Generic DLL download sites often provide mismatched versions that will crash the game. Ensure the file version matches your game build.

INSTRUCTIONS:
1. Locate your game folder (the one containing the .exe and steam_api.dll).
2. **Run the Patcher:**
    * **Executable (.exe):** Drag and Drop that ENTIRE FOLDER onto **'Goldberg_Auto_Patcher.exe'** (the new, robust tool).
    * **Source Code (.py):** If you have Python installed, drag the game folder onto the **'setup_goldberg.py'** file, or run it from the command line: `python setup_goldberg.py "path\to\game\folder"`
3. Follow the guided, interactive setup to enter the Steam AppID (e.g., 10680 for AvP).
4. Done!

GLOBAL NETWORK CONFIG (Do this once per PC):
1. Go to %AppData%\Goldberg SteamEmu Saves\settings
2. Create 'listen_interface.txt' with YOUR Tailscale IP inside.
3. Create 'custom_broadcasts.txt' with your friends' Tailscale IPs inside.

TROUBLESHOOTING:
- "Tool not found": Make sure you kept the folder structure correct.
- Game crashes: You likely patched a pre-cracked game. Restore original files and try again.
- Interface Generation is stuck: This is fixed in v3.0, but if it happens, try deleting the existing `steam_interfaces.txt` and run the patcher again.