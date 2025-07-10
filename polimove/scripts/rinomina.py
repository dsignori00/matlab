#!/usr/bin/env python3
"""
Rinomina ricorsivamente i file in una cartella e sottocartelle:
- Converte i nomi CamelCase a snake_case
- Mantiene gli acronimi (lettere maiuscole consecutive) in maiuscolo
- Estensione invariata
"""

import os
import sys
import re
from pathlib import Path

def to_snake_case(name: str) -> str:
    """
    Converte 'CamelCase' in 'snake_case', mantenendo gli acronimi in MAIUSCOLO.
    """
    base, ext = os.path.splitext(name)

    # Step 1: separa sequenze tipo JSONParser -> JSON_Parser
    base = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1_\2', base)

    # Step 2: separa tipo myParser -> my_Parser
    base = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', base)

    # Step 3: per ogni parola, mantieni MAIUSCOLE quelle già tutte maiuscole (acronimi),
    # e rendi minuscole le altre
    parts = base.split('_')
    converted = [
        part if part.isupper() else part.lower()
        for part in parts
    ]

    return '_'.join(converted) + ext

def rename_files_recursively(folder: Path) -> None:
    if not folder.is_dir():
        sys.exit(f"Errore: {folder} non è una cartella valida.")

    for file_path in folder.rglob('*'):
        if file_path.is_file():
            new_name = to_snake_case(file_path.name)
            if new_name != file_path.name:
                new_path = file_path.with_name(new_name)

                # Evita conflitti
                counter = 1
                while new_path.exists():
                    new_stem = f"{Path(new_name).stem}_{counter}"
                    new_path = file_path.with_name(new_stem + file_path.suffix)
                    counter += 1

                file_path.rename(new_path)
                print(f"{file_path.relative_to(folder)}  ->  {new_path.relative_to(folder)}")

if __name__ == "__main__":
    directory = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    rename_files_recursively(directory)
