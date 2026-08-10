/// Normalización para las búsquedas locales del mostrador.
///
/// SQLite no trae `unaccent` ni una collation que ignore tildes, así que la
/// normalización se hace en Dart y se guarda ya normalizada en una columna
/// aparte: quien escribe "perez" con prisa tiene que encontrar a "Pérez".
library;

const Map<String, String> _foldings = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n', 'ç': 'c',
};

/// Minúsculas, sin acentos y con los espacios colapsados.
String normalizeForSearch(String value) {
  final buffer = StringBuffer();
  for (final character in value.toLowerCase().split('')) {
    buffer.write(_foldings[character] ?? character);
  }
  return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Índice de búsqueda de un cliente: nombre y teléfono en un solo campo, para
/// que una sola consulta `LIKE` cubra las dos formas en que se le busca.
String customerSearchIndex({required String fullName, String? phone}) {
  final digits = (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return normalizeForSearch('$fullName $digits').trim();
}
