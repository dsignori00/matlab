#!/usr/bin/env python3
"""
Rinomina ricorsivamente i file in una cartella e nelle sue sottocartelle:
- Prima lettera del nome in maiuscolo
- Rimuove tutti gli underscore, rendendo maiuscola la lettera successiva

Esempio:
    my_file_name.txt  ->  MyFileName.txt
"""

import os
import sys
import re
from pathlib import Path

# ─── Funzione di trasformazione ────────────────────────────────────────────────
def camel_case(name: str) -> str:
    """
    Converte 'nome_file' in 'NomeFile', mantenendo inalterata l'estensione.
    """
    base, ext = os.path.splitext(name)
    new_base = re.sub(r'(?:^|_)(\w)', lambda m: m.group(1).upper(), base)
    return new_base + ext

# ─── Funzione principale ───────────────────────────────────────────────────────
def rename_files_recursively(folder: Path) -> None:
    if not folder.is_dir():
        sys.exit(f"Errore: {folder} non è una cartella valida.")

    for file_path in folder.rglob('*'):
        if file_path.is_file():
            new_name = camel_case(file_path.name)
            if new_name != file_path.name:
                new_path = file_path.with_name(new_name)

                # Evita conflitti con file già esistenti
                counter = 1
                while new_path.exists():
                    new_stem = f"{Path(new_name).stem}_{counter}"
                    new_path = file_path.with_name(new_stem + file_path.suffix)
                    counter += 1

                file_path.rename(new_path)
                print(f"{file_path.relative_to(folder)}  ->  {new_path.relative_to(folder)}")

# ─── Avvio ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    # Usa la cartella passata come argomento, altrimenti la cartella corrente
    directory = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    rename_files_recursively(directory)
