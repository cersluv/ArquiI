import re
import matplotlib.pyplot as plt

def cleanHexText(text):
    """
    Limpia el texto hexadecimal eliminando caracteres innecesarios como \\x00
    y convierte los números en formato hexadecimal a sus valores numéricos.
    """
    # Elimina \\x00 al final del texto
    text = re.sub(r'(\\x00)+$', '', text)

    # Encuentra la última aparición de \\x00\\x00 y elimina todo lo anterior
    pos = text.rfind('\\x00\\x00')
    if pos != -1:
        text = text[pos+4:]

    # Elimina todos los \\x00 en medio de las palabras
    text = text.replace('\\x00', '')

    # Convierte secuencias \\xXX a su valor numérico en ASCII
    return re.sub(r'\\x([0-9a-fA-F]{2})', lambda match: str(int(match.group(1), 16)), text)

def createWordCountDictionary(text):
    """
    Crea un diccionario a partir del texto, donde las claves son palabras y los valores son sus conteos.
    """
    # Encuentra todas las palabras seguidas de números (palabras repetidas)
    pattern = r'([a-zA-Z]+)(\d+)'  # Grupo 1: palabra, Grupo 2: número
    matches = re.findall(pattern, text)

    # Crea el diccionario de palabras y sus contadores
    wordCountDictionary = {word: int(count) for word, count in matches}

    # Imprime cada palabra y su contador mientras se construye el diccionario
    for word, count in wordCountDictionary.items():
        print(f"Palabra: {word}, Repeticiones: {count}")

    # Retorna el diccionario ordenado de mayor a menor por el número de repeticiones
    return dict(sorted(wordCountDictionary.items(), key=lambda item: item[1], reverse=True))

def plotTop10Words(wordCountDictionary):
    """
    Genera un histograma de las 10 palabras más frecuentes a partir de un diccionario de palabras.
    """
    # Obtiene las 10 palabras más frecuentes
    top10Words = list(wordCountDictionary.keys())[:10]
    top10Counts = list(wordCountDictionary.values())[:10]

    # Configuración visual del histograma
    plt.figure(figsize=(10, 6))  # Ajusta el tamaño de la gráfica
    plt.bar(top10Words, top10Counts, color='skyblue')

    # Etiquetas y título del gráfico
    plt.xlabel('Palabras', fontsize=12)
    plt.ylabel('Repeticiones', fontsize=12)
    plt.title('Top 10 Palabras por Frecuencia', fontsize=14)
    plt.xticks(rotation=45, fontsize=10)
    plt.yticks(fontsize=10)

    # Ajuste final para que todo se muestre correctamente
    plt.tight_layout()

    # Muestra el gráfico
    plt.show()

def convertHexToAscii(inputFile):
    """
    Lee un archivo hexadecimal, lo convierte a ASCII, elimina secuencias no deseadas,
    y luego genera un histograma con las palabras más frecuentes.
    """
    try:
        # Leer el archivo en modo binario
        with open(inputFile, 'rb') as file:
            content = file.read()

        # Convierte cada byte a ASCII o lo deja en hexadecimal si no es imprimible
        asciiContent = "".join(chr(byte) if 32 <= byte <= 126 else f'\\x{byte:02x}' for byte in content)

        # Limpia el texto eliminando basura y convierte números en el formato correcto
        cleanedText = cleanHexText(asciiContent)

        # Crea un diccionario con las palabras y sus conteos
        wordCountDictionary = createWordCountDictionary(cleanedText)

        # Genera un histograma de las 10 palabras más comunes
        plotTop10Words(wordCountDictionary)

    except FileNotFoundError:
        print(f"Error: No se pudo encontrar el archivo {inputFile}")

# Especifica el archivo de entrada
inputFile = 'texto_procesado.txt'

# Ejecuta la función principal
convertHexToAscii(inputFile)
