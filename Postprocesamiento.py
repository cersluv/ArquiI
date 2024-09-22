import string
import unicodedata

def procesar_texto(archivo_entrada, archivo_salida):
    # Definir los caracteres de puntuación que queremos eliminar
    signos_puntuacion = string.punctuation
    
    # Abrir el archivo original para lectura
    with open(archivo_entrada, 'r', encoding='utf-8') as archivo:
        contenido = archivo.read()
    
    # Convertir todo el texto a minúsculas
    contenido = contenido.lower()
    
    # Eliminar signos de puntuación
    for signo in signos_puntuacion:
        contenido = contenido.replace(signo, "")
    
    # Eliminar tildes (acentos diacríticos)
    contenido = unicodedata.normalize('NFKD', contenido).encode('ASCII', 'ignore').decode('utf-8')
    
    # Eliminar saltos de línea y asegurarnos que las palabras estén separadas por espacios
    contenido = contenido.replace("\n", " ").replace("\r", " ")
    
    # Guardar el contenido preprocesado en el archivo de salida
    with open(archivo_salida, 'w', encoding='utf-8') as archivo:
        archivo.write(contenido)

# Usar la función con los nombres de archivo especificados
procesar_texto('texto_original.txt', 'texto_preprocesado.txt')


