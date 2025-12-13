![Retro Patcher Banner](https://github.com/IIDelta/steam-online-emulator/blob/main/assets/banner.jpg)

# Delta's Auto-Patcher v3.0

=========================================

INSTRUCTIONS:
1. Locate your game folder (the one containing the .exe and steam_api.dll).
2. **Run the Patcher:**
    * **Executable (.exe):** Drag and Drop that ENTIRE FOLDER onto **'Deltas_Patcher.exe'** (the new, robust tool).
    * **Source Code (.py):** If you have Python installed, drag the game folder onto the **'Deltas_Patcher.py'** file, or run it from the command line: `python Deltas_Patcher.py "path\to\game\folder"`
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