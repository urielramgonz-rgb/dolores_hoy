import 'package:dolores_hoy/datos/config_claves.dart';
import 'package:dolores_hoy/datos/servicios.dart';
import 'package:dolores_hoy/dominio/excepciones.dart';
import 'package:dolores_hoy/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

void main() {
  // API 1 · Clima (Open-Meteo)
  group('API 1 · Clima (Open-Meteo)', () {
    test('convierte la respuesta en Clima', () async {
      final s = ServicioClima(seguro((req) async {
        expect(req.url.host, 'api.open-meteo.com');
        expect(req.url.queryParameters['latitude'], '21.1561');
        return jsonOk(jsonClima);
      }));

      final c = await s.actual();

      expect(c.temperatura, 24.3);
      expect(c.humedad, 41);
      expect(c.codigo, 1);
    });

    test('rechaza coordenadas fuera de rango', () {
      final s = ServicioClima(
        seguro((_) async => jsonOk(jsonClima)),
      );

      expect(
        s.actual(lat: 200),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });

    test('si falta el bloque current lanza RespuestaInvalida', () {
      final s = ServicioClima(
        seguro((_) async => jsonOk({'otra': 1})),
      );

      expect(
        s.actual(),
        throwsA(isA<RespuestaInvalidaException>()),
      );
    });

    test('describirClima traduce códigos', () {
      expect(describirClima(0).$2, 'Despejado');
      expect(describirClima(63).$2, 'Lluvia');
      expect(describirClima(95).$2, 'Tormenta');
    });
  });

  // API 2 · Tipo de cambio (Frankfurter)
  group('API 2 · Tipo de cambio (Frankfurter)', () {
    test('calcula pesos por dólar invirtiendo la tasa', () async {
      final s = ServicioCambio(
        seguro((_) async => jsonOk({
          'base': 'MXN',
          'date': '2026-10-28',
          'rates': {
            'USD': 0.05,
            'EUR': 0.04,
          },
        })),
      );

      final t = await s.deMxn();

      expect(t.pesosPorUnidad('USD'), closeTo(20.0, 0.0001));
      expect(t.pesosPorUnidad('EUR'), closeTo(25.0, 0.0001));
    });
  });

  // API 3 · Festivos (Nager.Date)
  group('API 3 · Festivos (Nager.Date)', () {
    test('devuelve solo los próximos, en orden', () async {
      final s = ServicioFestivos(seguro((req) async {
        expect(req.url.path, '/api/v3/PublicHolidays/2026/MX');
        return jsonOk(jsonFestivos);
      }));

      final r = await s.proximos(
        hoy: DateTime(2026, 10, 29),
        cuantos: 2,
      );

      expect(
        r.map((f) => f.nombre),
        ['Día de la Revolución', 'Navidad'],
      );
    });

    test('incluye el festivo de hoy mismo', () async {
      final s = ServicioFestivos(
        seguro((_) async => jsonOk(jsonFestivos)),
      );

      final r = await s.proximos(
        hoy: DateTime(2026, 12, 25),
        cuantos: 5,
      );

      expect(r.single.nombre, 'Navidad');
    });

    test('rechaza años absurdos', () {
      final s = ServicioFestivos(
        seguro((_) async => jsonOk(jsonFestivos)),
      );

      expect(
        s.proximos(anio: 3000),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });
  });


}

