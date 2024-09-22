import matplotlib.pyplot as plt
import re



# def graficacion():
#     # Datos de ejemplo (rellenar con los tiempos obtenidos)
#     hilos = [2, 3, 4, 5]
#     tiempos2 = (8.28 + 9.07 + 8.67 + 8.43 + 8.82) / 5
#     tiempos3 = (9.78 + 10.15 + 9.34 + 9.45 + 9.84) / 5
#     tiempos4 = (10.09 + 10.15 + 10.04 + 10.02 + 10.06) / 5
#     tiempos5 = (10.61 + 11.38 + 10.59 + 10.78 + 10.90) / 5
#     tiempos = [tiempos2, tiempos3, tiempos4, tiempos5]  # Reemplaza con los tiempos reales obtenidos
#
#     tiempos2 = round(tiempos2, 2)
#     tiempos3 = round(tiempos3, 2)
#     tiempos4 = round(tiempos4, 2)
#     tiempos5 = round(tiempos5, 2)
#
#     print(f'Tiempo 2 hilos: {tiempos2}')
#     print(f'Tiempo 3 hilos: {tiempos3}')
#     print(f'Tiempo 4 hilos: {tiempos4}')
#     print(f'Tiempo 5 hilos: {tiempos5}')
#
#     plt.plot(hilos, tiempos, marker='o')
#     plt.xlabel('Número de Hilos')
#     plt.ylabel('Tiempo de Ejecución (ms)')
#     plt.title('Número de Hilos vs Tiempo de Ejecución')
#     plt.grid(True)
#     plt.show()

def limpiar_texto(texto):
    # Diccionario para reemplazar letras con tilde por letras sin tilde
    reemplazos = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
        'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
        'ñ': 'n', 'Ñ': 'n'
    }

    # Convertir todo a minúsculas
    texto = texto.lower()

    # Reemplazar letras tildadas
    for letra_tildada, letra_normal in reemplazos.items():
        texto = texto.replace(letra_tildada, letra_normal)

    # Reemplazar números y caracteres especiales por un espacio
    texto = re.sub(r'[^a-z\s]', ' ', texto)

    # Eliminar saltos de línea
    texto = texto.replace('\n', ' ')

    # Reemplazar múltiples espacios por un solo espacio
    texto = re.sub(r'\s+', ' ', texto)

    # Eliminar espacios al inicio y al final
    texto = texto.strip()

    return texto

def procesar_archivo(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        contenido = f.read()

    # Limpiar el contenido y asegurarse de que todo quede en una sola línea
    texto_limpio = limpiar_texto(contenido)

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(texto_limpio)

def texto_a_hexadecimal(input_file, output_file):
    # Abrir archivo de entrada en modo lectura
    with open(input_file, 'r', encoding='utf-8') as infile:
        # Leer todo el contenido del archivo
        contenido = infile.read()

    # Abrir archivo de salida en modo escritura
    with open(output_file, 'w', encoding='utf-8') as outfile:
        # Recorrer cada carácter en el contenido
        for char in contenido:
            if char == ' ':
                # Si es un espacio, escribir "00"
                outfile.write('00\n')
            else:
                # Convertir cada carácter a hexadecimal y escribirlo en una nueva línea
                outfile.write(f'{ord(char):02x}\n')

# Rutas de archivo
input_file = "C:\\Users\\crseg\\OneDrive\\Escritorio\\Proyecto_Arqui\\elQuijote.txt"
output_file = "C:\\Users\\crseg\\OneDrive\\Escritorio\\Proyecto_Arqui\\elQuijoteEDITADA.txt"

# Especifica los archivos de entrada y salida
archivo_entrada = output_file
archivo_salida = 'C:\\Users\\crseg\\OneDrive\\Escritorio\\Proyecto_Arqui\\elQuijoteHEXA.txt'

procesar_archivo(input_file, output_file)
texto_a_hexadecimal(archivo_entrada, archivo_salida)
# Ejecutar la función de procesamiento

#graficacion()

