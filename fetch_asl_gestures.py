import os
import urllib.request
import ssl
import time

def setup_directories():
    base_dir = "ASL_Gestures"
    alphabets_dir = os.path.join(base_dir, "Alphabets")
    numbers_dir = os.path.join(base_dir, "Numbers")
    os.makedirs(alphabets_dir, exist_ok=True)
    os.makedirs(numbers_dir, exist_ok=True)
    return alphabets_dir, numbers_dir

def download_image(url, save_path):
    try:
        context = ssl._create_unverified_context()
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, context=context, timeout=10) as response:
            with open(save_path, 'wb') as f:
                f.write(response.read())
        return True
    except Exception as e:
        return False

def main():
    print("🚀 Finalizing ASL Gesture Downloads...")
    alpha_path, num_path = setup_directories()
    
    # --- ALPHABETS (A-Z) ---
    # Already successful, but checking if any are missing
    print("📦 Checking Alphabets...")
    base_alpha_url = "https://raw.githubusercontent.com/Arfa-Ahsan/ASL_Image_Classification/main/Images/"
    for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        save_path = os.path.join(alpha_path, f"{letter}.jpg")
        if not os.path.exists(save_path):
            if download_image(f"{base_alpha_url}{letter}.jpg", save_path):
                print(f"  ✅ {letter} downloaded")
        else:
            print(f"  ✅ {letter} exists")

    # --- NUMBERS (1-10) ---
    print("\n📦 Downloading Missing Numbers...")
    
    # Verified Filenames for Numbers 1-9
    num_map = {
        1: "IMG_1119.JPG",
        2: "IMG_1118.JPG",
        3: "IMG_1121.JPG",
        4: "IMG_1122.JPG",
        5: "IMG_1123.JPG",
        6: "IMG_1124.JPG",
        7: "IMG_1125.JPG",
        8: "IMG_1126.JPG",
        9: "IMG_1127.JPG"
    }
    
    for n, filename in num_map.items():
        save_path = os.path.join(num_path, f"{n}.jpg")
        url = f"https://raw.githubusercontent.com/ardamavi/Sign-Language-Digits-Dataset/master/Dataset/{n}/{filename}"
        if not os.path.exists(save_path) or os.path.getsize(save_path) == 0:
            if download_image(url, save_path):
                print(f"  ✅ {n} downloaded")
            else:
                print(f"  ❌ {n} failed")
        else:
            print(f"  ✅ {n} exists")

    # Number 10
    save_10 = os.path.join(num_path, "10.jpg")
    url_10 = "https://raw.githubusercontent.com/EvilPort2/Sign-Language/master/gestures/10/1.jpg"
    if not os.path.exists(save_10):
        if download_image(url_10, save_10):
            print("  ✅ 10 downloaded")
        else:
            print("  ❌ 10 failed")

    print(f"\n✨ All images have been organized in: {os.path.abspath('ASL_Gestures')}")

if __name__ == "__main__":
    main()
