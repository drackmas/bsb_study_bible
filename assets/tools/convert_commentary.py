#!/usr/bin/env python3
"""
Commentary JSON Converter

Converts commentary JSON files from SWORD/zCom format to BSB-compatible format.

SWORD format keys look like: MAT.1.1, 1CO.5.20, 2PE.3.15
BSB format keys look like: Matthew 1:1, I Corinthians 5:20, II Peter 3:15

Usage:
    python3 convert_commentary.py --input commentary.json --output output_bsb.json

The script:
1. Reads the source JSON file
2. Maps SWORD abbreviations to BSB book names
3. Converts all commentary keys
4. Preserves all text exactly as-is
5. Outputs a valid JSON file with BSB-compatible keys
"""

import json
import argparse
import sys


# BSB book name mapping from SWORD abbreviations
# This mapping covers all 27 New Testament books
BSB_BOOK_MAPPING = {
    "MAT": "Matthew",
    "MRK": "Mark",
    "LUK": "Luke",
    "JHN": "John",
    "ACT": "Acts",
    "ROM": "Romans",
    "1CO": "I Corinthians",
    "2CO": "II Corinthians",
    "GAL": "Galatians",
    "EPH": "Ephesians",
    "PHP": "Philippians",
    "COL": "Colossians",
    "1TH": "I Thessalonians",
    "2TH": "II Thessalonians",
    "1TI": "I Timothy",
    "2TI": "II Timothy",
    "TIT": "Titus",
    "PHM": "Philemon",
    "HEB": "Hebrews",
    "JAS": "James",
    "1PE": "I Peter",
    "2PE": "II Peter",
    "1JN": "I John",
    "2JN": "II John",
    "3JN": "III John",
    "JUD": "Jude",
    "REV": "Revelation of John",
}


def convert_commentary(input_path, output_path):
    """
    Convert a commentary JSON file from SWORD format to BSB-compatible format.
    
    Args:
        input_path: Path to the source JSON file
        output_path: Path to write the converted JSON file
    """
    # Load source file
    print(f"Reading source file: {input_path}")
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if 'commentary' not in data:
        print("ERROR: No 'commentary' key found in source JSON")
        sys.exit(1)
    
    original_commentary = data['commentary']
    entry_count = len(original_commentary)
    print(f"Found {entry_count} commentary entries")
    
    # Convert keys
    converted_commentary = {}
    unmapped_keys = []
    
    for old_key, value in original_commentary.items():
        parts = old_key.split('.')
        if len(parts) < 2:
            print(f"WARNING: Unexpected key format: {old_key}")
            unmapped_keys.append(old_key)
            continue
        
        sword_abbrev = parts[0].upper()
        book_name = BSB_BOOK_MAPPING.get(sword_abbrev)
        
        if book_name is None:
            print(f"WARNING: Unmapped SWORD abbreviation: {sword_abbrev} in key {old_key}")
            unmapped_keys.append(old_key)
            continue
        
        # Rebuild key with BSB book name
        new_key = f"{book_name} {parts[1]}:{parts[2]}"
        converted_commentary[new_key] = value
    
    # Sort by book name, then chapter, then verse
    sorted_commentary = dict(sorted(converted_commentary.items()))
    
    # Update the data structure
    data['commentary'] = sorted_commentary
    data['format'] = 'bsb-compatible'
    
    # Write output
    print(f"Writing output file: {output_path}")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    # Validation
    print("\n=== Validation ===")
    print(f"Original entries: {entry_count}")
    print(f"Converted entries: {len(converted_commentary)}")
    print(f"Unmapped keys: {len(unmapped_keys)}")
    
    if len(converted_commentary) != entry_count:
        print(f"WARNING: Entry count mismatch! Lost {entry_count - len(converted_commentary)} entries")
    else:
        print("All entries preserved successfully")
    
    if unmapped_keys:
        print(f"\nUnmapped keys:")
        for key in unmapped_keys:
            print(f"  {key}")
    
    # Show book summary
    books = set()
    for key in converted_commentary.keys():
        book = key.split(' ')[0]
        books.add(book)
    
    print(f"\nBooks covered ({len(books)}):")
    for book in sorted(books):
        count = sum(1 for k in converted_commentary.keys() if k.startswith(book + ' '))
        print(f"  {book}: {count} entries")
    
    print("\nConversion complete!")


def main():
    parser = argparse.ArgumentParser(
        description='Convert commentary JSON from SWORD format to BSB-compatible format'
    )
    parser.add_argument(
        '--input', '-i',
        required=True,
        help='Path to the source commentary JSON file'
    )
    parser.add_argument(
        '--output', '-o',
        required=True,
        help='Path to write the converted JSON file'
    )
    
    args = parser.parse_args()
    convert_commentary(args.input, args.output)


if __name__ == '__main__':
    main()