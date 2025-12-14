import os
import shutil
import glob
import sys
import re

# --- CONFIGURATION FIX ---

# Determine the correct base path for bundled resources.
# If running as a bundled executable, sys._MEIPASS is the temporary path.
# Otherwise (if running as a .py script), use os.path.dirname(__file__).
if getattr(sys, 'frozen', False):
    # Running as executable (use temp folder)
    BASE_DIR = sys._MEIPASS
else:
    # Running as script (use script's folder)
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

TOOLS_DIR = os.path.join(BASE_DIR, "tools")
EMU_X86 = os.path.join(BASE_DIR, "emu_x86", "steam_api.dll")
EMU_X64 = os.path.join(BASE_DIR, "emu_x64", "steam_api64.dll")

# Fallback interfaces (Standard Goldberg Default)
DEFAULT_INTERFACES = """SteamClient015
SteamGameServer012
SteamGameServerStats001
SteamUser017
SteamFriends014
SteamUtils007
SteamMatchMaking009
SteamMatchMakingServers002
STEAMUSERSTATS_INTERFACE_VERSION011
STEAMAPPS_INTERFACE_VERSION006
SteamNetworking005
STEAMREMOTESTORAGE_INTERFACE_VERSION012
STEAMSCREENSHOTS_INTERFACE_VERSION002
STEAMHTTP_INTERFACE_VERSION002
STEAMUNIFIEDMESSAGES_INTERFACE_VERSION001
STEAMCONTROLLER_INTERFACE_VERSION
STEAMUGC_INTERFACE_VERSION002
STEAMAPPLIST_INTERFACE_VERSION001
STEAMMUSIC_INTERFACE_VERSION001
STEAMMUSICREMOTE_INTERFACE_VERSION001
"""

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_game_folder():
    if len(sys.argv) > 1 and os.path.isdir(sys.argv[1]):
        return sys.argv[1]
    
    print("Drag and drop the game folder onto this window and press Enter:")
    path = input("> ").strip().strip('"')
    if os.path.isdir(path):
        return path
    print("[ERROR] Invalid folder.")
    sys.exit(1)

def find_steam_dll(folder):
    x64 = glob.glob(os.path.join(folder, "**", "steam_api64.dll"), recursive=True)
    if x64: return x64[0], True
    x86 = glob.glob(os.path.join(folder, "**", "steam_api.dll"), recursive=True)
    if x86: return x86[0], False
    return None, None

def extract_interfaces_from_bytes(data):
    """
    Scans bytes for Steam interfaces using Regex (ASCII and UTF-16LE).
    """
    # Regex for ASCII/UTF-8
    pattern_ascii = re.compile(b'(Steam[a-zA-Z]+[0-9]{3}|STEAM[A-Z0-9_]+_VERSION[_0-9]*[0-9]|STEAM[A-Z0-9_]+_V[0-9]+)')
    
    matches = []
    
    # 1. Scan ASCII
    for m in pattern_ascii.findall(data):
        try: matches.append(m.decode('utf-8')) 
        except: pass

    # 2. Scan UTF-16LE (Wide Char)
    try:
        # Decode broadly, then apply regex to the string
        text_wide = data.decode('utf-16-le', errors='ignore')
        # We need a string regex now, not bytes
        pattern_str = re.compile(r'(Steam[a-zA-Z]+[0-9]{3}|STEAM[A-Z0-9_]+_VERSION[_0-9]*[0-9]|STEAM[A-Z0-9_]+_V[0-9]+)')
        matches.extend(pattern_str.findall(text_wide))
    except:
        pass

    # Deduplicate and Filter (Must be > 10 chars to avoid noise)
    unique = sorted(list(set([m for m in matches if len(m) > 10])))
    return unique

def generate_interfaces_file(target_dll, output_path):
    print(f"Scanning {os.path.basename(target_dll)}...")
    try:
        with open(target_dll, 'rb') as f:
            raw_data = f.read()
            
        interfaces = extract_interfaces_from_bytes(raw_data)
        
        if not interfaces:
            return False, 0
            
        with open(output_path, 'w') as f:
            f.write('\n'.join(interfaces))
            
        return True, len(interfaces)

    except Exception as e:
        print(f"[Debug] Read failed: {e}")
        return False, 0

def main():
    clear_screen()
    print("=== GOLDBERG EMULATOR AUTO-SETUP (FINAL) ===\n")
    
    game_dir = get_game_folder()
    print(f"Target: {game_dir}")
    
    original_dll_path, is_64bit = find_steam_dll(game_dir)
    
    if not original_dll_path:
        print("[ERROR] No steam_api.dll or steam_api64.dll found!")
        input("Press Enter to exit...")
        return

    dll_dir = os.path.dirname(original_dll_path)
    dll_name = os.path.basename(original_dll_path)
    backup_path = os.path.join(dll_dir, f"{dll_name}.bak")
    
    # 1. BACKUP
    if not os.path.exists(backup_path):
        print(f"[INFO] Backing up original DLL to {os.path.basename(backup_path)}...")
        shutil.copy2(original_dll_path, backup_path)
    else:
        print("[INFO] Backup already exists.")

    # 2. APPID
    appid_path = os.path.join(dll_dir, "steam_appid.txt")
    if not os.path.exists(appid_path):
        print("\n[INPUT] Enter the Steam AppID:")
        appid = input("AppID > ").strip()
        with open(appid_path, "w") as f:
            f.write(appid)
        print("[INFO] steam_appid.txt created.")
    
    # 3. APPLY EMULATOR
    print(f"\n[INFO] Applying Goldberg Emulator ({'64-bit' if is_64bit else '32-bit'})...")
    emu_source = EMU_X64 if is_64bit else EMU_X86
    try:
        shutil.copy2(emu_source, original_dll_path)
    except PermissionError:
        print("[ERROR] File locked. Close the game and try again.")
        input("Press Enter to exit...")
        return
    
    # 4. FIRST RUN TEST
    print("\n" + "="*40)
    print("STEP 1 DONE. Try running the game now.")
    print("="*40)
    if input("Did it work? (y/n) > ").lower() == 'y':
        print("\n[SUCCESS] Have fun!")
        return

    # 5. SMART INTERFACE GENERATION
    print("\n[INFO] Game failed. searching for interfaces...")
    interfaces_path = os.path.join(dll_dir, "steam_interfaces.txt")
    
    # Collect all potential DLLs (backups, originals, renamed ones)
    candidates = glob.glob(os.path.join(game_dir, "**", "*steam*.dll"), recursive=True)
    # Ensure our backup is in the list
    if backup_path not in candidates and os.path.exists(backup_path):
        candidates.insert(0, backup_path)

    valid_results = []
    
    for cand in candidates:
        # Skip the currently active Goldberg DLL (it has no interfaces)
        if os.path.abspath(cand) == os.path.abspath(original_dll_path):
            continue
            
        # Temp file name
        temp_out = os.path.join(dll_dir, f"temp_{os.path.basename(cand)}.txt")
        success, count = generate_interfaces_file(cand, temp_out)
        
        if success:
            print(f"  -> Found {count} interfaces in {os.path.basename(cand)}")
            valid_results.append(temp_out)
        else:
            if os.path.exists(temp_out): os.remove(temp_out)

    # SMART DECISION LOGIC
    if len(valid_results) == 0:
        print("\n[FAIL] No interfaces found in any local DLLs.")
        print("[INFO] Creating default brute-force list.")
        with open(interfaces_path, "w") as f:
            f.write(DEFAULT_INTERFACES)
            
    elif len(valid_results) == 1:
        print("\n[SUCCESS] Only one valid source found. Applying automatically.")
        if os.path.exists(interfaces_path): os.remove(interfaces_path)
        os.rename(valid_results[0], interfaces_path)
        print(f"Saved to: {interfaces_path}")
        
    else:
        print(f"\n[WARNING] Found {len(valid_results)} different valid interface lists.")
        print("I have saved them as 'temp_...' in the game folder.")
        print("Please rename the correct one to 'steam_interfaces.txt'.")

    print("\nSetup Complete. Try running the game again.")
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()