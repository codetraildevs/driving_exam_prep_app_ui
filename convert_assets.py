import os
from PIL import Image

def convert_to_webp(directory):
    print(f"Starting conversion in {directory}...")
    files = [f for f in os.listdir(directory) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
    
    converted_count = 0
    total_reduction = 0

    for filename in files:
        base_name = os.path.splitext(filename)[0]
        ext = os.path.splitext(filename)[1].lower()
        
        filepath = os.path.join(directory, filename)
        webp_path = os.path.join(directory, f"{base_name}.webp")
        
        try:
            with Image.open(filepath) as img:
                original_size = os.path.getsize(filepath)
                # Save as WebP with 80% quality (best balance)
                img.save(webp_path, "WEBP", quality=80)
                new_size = os.path.getsize(webp_path)
                
                reduction = original_size - new_size
                total_reduction += reduction
                
                print(f"Converted: {filename} -> {base_name}.webp (Reduced by {reduction/1024:.1f} KB)")
                
                # Delete original
                os.remove(filepath)
                converted_count += 1
        except Exception as e:
            print(f"Error converting {filename}: {e}")

    print("-" * 30)
    print(f"Finished! Converted {converted_count} files.")
    print(f"Total Disk Space Saved: {total_reduction/1024/1024:.2f} MB")

if __name__ == "__main__":
    target_dir = os.path.join("assets", "images")
    if os.path.exists(target_dir):
        convert_to_webp(target_dir)
    else:
        print(f"Directory {target_dir} not found. Please run from project root.")
