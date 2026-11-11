import 'package:dolores_hoy/datos/cliente_seguro.dart';
import 'package:dolores_hoy/datos/config_claves.dart';
import 'package:dolores_hoy/datos/servicios.dart';
import 'package:dolores_hoy/presentacion/tablero_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'ayudas.dart';

TableroViewModel crear(Future<http.Response> Function(http.Request) h) {
  final cliente = ClienteSeguro(
    MockClient(h),
    espera: const Duration(seconds: 2),
  );

  return TableroViewModel(
    clima: ServicioClima(cliente),
    cambio: ServicioCambio(cliente),
    festivos: ServicioFestivos(cliente),
    wikipedia: ServicioWikipedia(cliente),
    nasa: ServicioNasa(cliente, const ConfigClaves(nasa: 'K')),
  );
}

void main() {
  test('carga todas las APIs y guarda cada tarjeta', () async {
    final vm = crear((req) async {
      switch (req.url.host) {
        case 'api.open-meteo.com':
          return jsonOk(jsonClima);
        case 'api.frankfurter.dev':
          return jsonOk(jsonCambio);
        case 'date.nager.at':
          return jsonOk(jsonFestivos);
        case 'es.wikipedia.org':
          return jsonOk({
            'title': 'Dolores Hidalgo',
            'extract': 'Ciudad histórica.',
            'thumbnail': {'source': 'https://example.com/mini.jpg'},
          });
        case 'api.nasa.gov':
          return jsonOk(jsonNasa);
        default:
          return http.Response('', 404);
      }
    });

    await vm.cargarTodo();

    expect(vm.clima.estado, Estado.listo);
    expect(vm.cambio.estado, Estado.listo);
    expect(vm.festivos.estado, Estado.listo);
    expect(vm.wiki.estado, Estado.listo);
    expect(vm.nasa.estado, Estado.listo);
  });

  test('si una API falla, el resto sigue funcionando', () async {
    final vm = crear((req) async {
      switch (req.url.host) {
        case 'api.open-meteo.com':
          return jsonOk(jsonClima);
        case 'api.frankfurter.dev':
          return jsonOk(jsonCambio);
        case 'date.nager.at':
          return jsonOk(jsonFestivos);
        case 'es.wikipedia.org':
          return jsonOk({
            'title': 'Dolores Hidalgo',
            'extract': 'Ciudad histórica.',
            'thumbnail': {'source': 'https://example.com/mini.jpg'},
          });
        case 'api.nasa.gov':
          return http.Response('', 403);
        default:
          return http.Response('', 404);
      }
    });

    await vm.cargarTodo();

    expect(vm.clima.estado, Estado.listo);
    expect(vm.cambio.estado, Estado.listo);
    expect(vm.festivos.estado, Estado.listo);
    expect(vm.wiki.estado, Estado.listo);
    expect(vm.nasa.estado, Estado.error);
  });
}
