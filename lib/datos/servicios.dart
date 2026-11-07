
import '../dominio/excepciones.dart';
import '../dominio/modelos.dart';
import 'cliente_seguro.dart';
import 'config_claves.dart';

/// API 1 · Open-Meteo (clima, sin clave)
class ServicioClima {
  final ClienteSeguro _c;

  ServicioClima(this._c);

  // Dolores Hidalgo C.I.N.: 21.1561, -100.9319
  Future<Clima> actual({
    double lat = 21.1561,
    double lon = -100.9319,
  }) async {
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      throw const EntradaInvalidaException(
        'coordenadas fuera de rango',
      );
    }

    final json = await _c.obtenerJson(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'timezone': 'America/Mexico_City',
      }),
    );

    return convertir(
      () => Clima.desdeJson(json as Map<String, dynamic>),
    );
  }
}

/// API 2 · Frankfurter (tipo de cambio, sin clave)
class ServicioCambio {
  final ClienteSeguro _c;

  ServicioCambio(this._c);

  Future<TipoCambio> deMxn() async {
    final json = await _c.obtenerJson(
      Uri.https('api.frankfurter.dev', '/v1/latest', {
        'base': 'MXN',
        'symbols': 'USD,EUR',
      }),
    );

    return convertir(
      () => TipoCambio.desdeJson(json as Map<String, dynamic>),
    );
  }
}

/// API 3 · Nager.Date (días festivos de México, sin clave)
class ServicioFestivos {
  final ClienteSeguro _c;

  ServicioFestivos(this._c);

  /// [hoy] se puede inyectar: así la prueba no depende del calendario real.
  Future<List<Festivo>> proximos({
    int? anio,
    DateTime? hoy,
    int cuantos = 3,
  }) async {
    final ahora = hoy ?? DateTime.now();
    final a = anio ?? ahora.year;

    if (a < 2000 || a > 2100) {
      throw const EntradaInvalidaException('año fuera de rango');
    }

    final json = await _c.obtenerJson(
      Uri.https(
        'date.nager.at',
        '/api/v3/PublicHolidays/$a/MX',
      ),
    );

    final todos = convertir(
      () => (json as List)
          .map(
            (e) => Festivo.desdeJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

    final dia = DateTime(ahora.year, ahora.month, ahora.day);

    final futuros = todos
        .where((f) => !f.fecha.isBefore(dia))
        .toList()
      ..sort((x, y) => x.fecha.compareTo(y.fecha));

    return futuros.take(cuantos).toList();
  }
}
