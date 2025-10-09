import csv

# Nome del file di input e output
input_file = "tum_03102025.csv"
output_file = "tum_03102025.csv"

def normalize_stamp(stamp):
    s = str(stamp)
    if '.' in s:
        integer, decimal = s.split('.')
        # Conta quante cifre ci sono dopo il punto
        num_decimals = len(decimal)
        if num_decimals < 9:
            # Aggiungi zeri subito dopo il punto, prima della parte decimale
            zeros_needed = 9 - num_decimals
            new_decimal = '0' * zeros_needed + decimal
        else:
            new_decimal = decimal[:9]
        return f"{integer}.{new_decimal}"
    else:
        # Se non c'è punto decimale, aggiungilo con 9 zeri
        return f"{s}.000000000"

with open(input_file, newline='') as csvfile:
    reader = csv.reader(csvfile)
    rows = list(reader)

# Trova l'indice della colonna 'stamp'
header = rows[0]
stamp_index = header.index('stamp')

# Correggi i valori nella colonna stamp
for i in range(1, len(rows)):
    rows[i][stamp_index] = normalize_stamp(rows[i][stamp_index])

# Scrivi il nuovo CSV
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(rows)

print(f"✅ File salvato come '{output_file}' con zeri aggiunti subito dopo il punto.")