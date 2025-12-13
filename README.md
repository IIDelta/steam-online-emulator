![Retro Patcher Banner](https://github.com/IIDelta/steam-online-emulator/blob/main/assets/banner.jpg)

# Delta's Auto-Patcher v3.0

=========================================
INSTRUCTIONS:
1. Locate your game folder (the one containing the .exe and steam_api.dll).
2. **Run the Patcher:**
    * **Executable (.exe):** Run the exe and follow the cmd line instructions.
    * **Source Code (.py):** If you have Python installed, drag the game folder onto the **'Deltas_Patcher.py'** file, or run it from the command line: `python Deltas_Patcher.py "path\to\game\folder"`
3. Follow the guided, interactive setup to enter the Steam AppID (e.g., 10680 for AvP).
4. Done!

GLOBAL CONFIGURATION (Do this once per PC):
1. Navigate to `%AppData%\Goldberg SteamEmu Saves\settings`
2. **Set Username:** Open `account_name.txt`. Replace "Goldberg" with your desired nickname. (Crucial for identifying players in-game!).
3. **Network Setup (Tailscale/VPN):**
    - Create `listen_interface.txt` with YOUR Tailscale IP inside.
    - Create `custom_broadcasts.txt` with your friends' Tailscale IPs inside.