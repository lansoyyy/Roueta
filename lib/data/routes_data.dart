import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bus_route.dart';

typedef _StopDef = ({String name, double lat, double lng});

class RoutesData {
  static List<BusRoute> get routes => [
    _r102(),
    _r103(),
    _r402(),
    _r403(),
    _r503(),
    _r603(),
    _r763(),
    _r783(),
    _r793(),
  ];

  // Coordinates were provided under a "LONGITUDE, LATITUDE" heading,
  // but the numeric values themselves clearly follow latitude, longitude.

  static BusStop _s(
    String routeId,
    String variantId,
    int idx,
    String name,
    double lat,
    double lng,
  ) => BusStop(
    id: '${routeId}_${variantId}_$idx',
    name: name,
    position: LatLng(lat, lng),
    estimatedMinutesFromStart: idx * 3,
  );

  static List<BusStop> _stops(
    String routeId,
    String variantId,
    List<_StopDef> defs,
  ) => [
    for (int index = 0; index < defs.length; index++)
      _s(
        routeId,
        variantId,
        index + 1,
        defs[index].name,
        defs[index].lat,
        defs[index].lng,
      ),
  ];

  static RouteVariant _v({
    required String routeId,
    required String variantId,
    required String label,
    required RouteShift shift,
    required RouteDirection direction,
    required List<_StopDef> defs,
  }) {
    final stops = _stops(routeId, variantId, defs);
    return RouteVariant(
      id: variantId,
      label: label,
      shift: shift,
      direction: direction,
      stops: stops,
      polylinePoints: stops.map((stop) => stop.position).toList(growable: false),
    );
  }

  static BusRoute _build({
    required String id,
    required String code,
    required String name,
    required String origin,
    required String destination,
    required RouteVariant amOut,
    required RouteVariant amIn,
    required RouteVariant pmOut,
    required RouteVariant pmIn,
  }) => BusRoute(
    id: id,
    code: code,
    name: name,
    origin: origin,
    destination: destination,
    amStartTime: '6:00 AM',
    amEndTime: '10:00 AM',
    pmStartTime: '4:00 PM',
    pmEndTime: '9:00 PM',
    variants: {amOut.id: amOut, amIn.id: amIn, pmOut.id: pmOut, pmIn.id: pmIn},
    defaultVariantId: 'am_out',
  );

  static BusRoute _route({
    required String id,
    required String code,
    required String name,
    required String origin,
    required String destination,
    required List<_StopDef> amOutStops,
    required List<_StopDef> amInStops,
    required List<_StopDef> pmOutStops,
    required List<_StopDef> pmInStops,
  }) => _build(
    id: id,
    code: code,
    name: name,
    origin: origin,
    destination: destination,
    amOut: _v(
      routeId: id,
      variantId: 'am_out',
      label: 'AM Outbound',
      shift: RouteShift.am,
      direction: RouteDirection.outbound,
      defs: amOutStops,
    ),
    amIn: _v(
      routeId: id,
      variantId: 'am_in',
      label: 'AM Inbound',
      shift: RouteShift.am,
      direction: RouteDirection.inbound,
      defs: amInStops,
    ),
    pmOut: _v(
      routeId: id,
      variantId: 'pm_out',
      label: 'PM Outbound',
      shift: RouteShift.pm,
      direction: RouteDirection.outbound,
      defs: pmOutStops,
    ),
    pmIn: _v(
      routeId: id,
      variantId: 'pm_in',
      label: 'PM Inbound',
      shift: RouteShift.pm,
      direction: RouteDirection.inbound,
      defs: pmInStops,
    ),
  );

  static BusRoute _r102() => _route(
    id: 'r102',
    code: 'R102',
    name: 'Toril - GE Torres Route',
    origin: 'Toril',
    destination: 'GE Torres',
    amOutStops: [
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
      (name: 'Fusion GTH', lat: 7.025698892542236, lng: 125.50453761754194),
      (
        name: 'Pepsi Dumoy',
        lat: 7.031020317008934,
        lng: 125.51234608938083,
      ),
      (
        name: 'Bago Aplaya Crossing',
        lat: 7.042824130139026,
        lng: 125.52971547482498,
      ),
      (
        name: 'Gulf View',
        lat: 7.046178796107667,
        lng: 125.53453721069407,
      ),
      (
        name: 'Jollibee Puan',
        lat: 7.051585874043629,
        lng: 125.54229109431324,
      ),
      (
        name: 'Coke Ulas',
        lat: 7.053474931980843,
        lng: 125.54436359895027,
      ),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.0582621410071225,
        lng: 125.56973946675656,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055776928386809,
        lng: 125.5754344886606,
      ),
      (
        name: 'DGT',
        lat: 7.0583486850000705,
        lng: 125.58039900394762,
      ),
      (
        name: 'Water District Matina',
        lat: 7.061004064760845,
        lng: 125.5900226852448,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Ateneo Matina',
        lat: 7.062759783034674,
        lng: 125.59743867572544,
      ),
      (
        name: 'GE Torres (Sandawa near Palawan Pawnshop)',
        lat: 7.061446545475992,
        lng: 125.60122807516602,
      ),
    ],
    amInStops: [
      (
        name: 'GE Torres (Sandawa near Palawan Pawnshop)',
        lat: 7.061446545475992,
        lng: 125.60122807516602,
      ),
      (
        name: 'Yellow Fin Quimpo',
        lat: 7.055577448020908,
        lng: 125.59961250780894,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.0452226579005295,
        lng: 125.5915562689465,
      ),
      (
        name: 'Shell Bago Aplaya',
        lat: 7.042438125328425,
        lng: 125.52897452339809,
      ),
      (
        name: 'IWHA Station',
        lat: 7.031834894392899,
        lng: 125.51331936427333,
      ),
      (name: 'GTH', lat: 7.025812548407179, lng: 125.50437733730142),
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
    ],
    pmOutStops: [
      (
        name: 'Ecoland Terminal',
        lat: 7.055079609013119,
        lng: 125.59968205747072,
      ),
      (
        name: 'GE Torres (Sandawa near Panadero)',
        lat: 7.060628314955491,
        lng: 125.60147769085005,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061492938569922,
        lng: 125.59127098528911,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057825343273126,
        lng: 125.5794216899317,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059221779362475,
        lng: 125.56786435434049,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.061171351857061,
        lng: 125.56320239004123,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061408837537958,
        lng: 125.55969246138575,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.060517756202169,
        lng: 125.55430401623474,
      ),
      (
        name: 'Coke Ulas',
        lat: 7.053537102889695,
        lng: 125.54428506667371,
      ),
      (
        name: 'Mercury Puan',
        lat: 7.052293002313232,
        lng: 125.54295148303915,
      ),
      (
        name: 'Apo Golf',
        lat: 7.046005722211973,
        lng: 125.53412415123428,
      ),
      (
        name: 'Shell Bago Aplaya',
        lat: 7.0380889488090945,
        lng: 125.52252973548912,
      ),
      (name: 'IWHA', lat: 7.031834894392899, lng: 125.51331936427333),
      (
        name: 'GTH',
        lat: 7.025864011282817,
        lng: 125.50450361517382,
      ),
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
    ],
    pmInStops: [
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
      (
        name: 'Fusion GTH',
        lat: 7.025864011282817,
        lng: 125.50450361517382,
      ),
      (
        name: 'Pepsi Dumoy',
        lat: 7.031020317008934,
        lng: 125.51234608938083,
      ),
      (
        name: 'Bago Aplaya Crossing',
        lat: 7.042824130139026,
        lng: 125.52971547482498,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.045246390453188,
        lng: 125.59163249336244,
      ),
      (
        name: 'Ecoland Terminal',
        lat: 7.055079609013119,
        lng: 125.59968205747072,
      ),
    ],
  );

  static BusRoute _r103() => _route(
    id: 'r103',
    code: 'R103',
    name: 'Toril - Roxas Route',
    origin: 'Toril',
    destination: 'Roxas',
    amOutStops: [
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
      (name: 'Fusion GTH', lat: 7.025698892542236, lng: 125.50453761754194),
      (
        name: 'Pepsi Dumoy',
        lat: 7.031020317008934,
        lng: 125.51234608938083,
      ),
      (
        name: 'Bago Aplaya Crossing',
        lat: 7.042824130139026,
        lng: 125.52971547482498,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.0452226579005295,
        lng: 125.5915562689465,
      ),
      (
        name: 'Ecoland Terminal',
        lat: 7.055079609013119,
        lng: 125.59968205747072,
      ),
      (
        name: 'Felcris Centrale',
        lat: 7.059924682953355,
        lng: 125.60870525952208,
      ),
      (
        name: 'Davao City Police Office',
        lat: 7.063287884164293,
        lng: 125.61090525863925,
      ),
      (
        name: 'CM Recto (LBC Recto Branch)',
        lat: 7.067109827662894,
        lng: 125.61072031272349,
      ),
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
    ],
    amInStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
      (
        name: 'Artiaga Boulevard',
        lat: 7.064608654855327,
        lng: 125.6140988492206,
      ),
      (
        name: 'Felcris Centrale',
        lat: 7.060605155427315,
        lng: 125.60918109028236,
      ),
      (
        name: 'Yellow Fin Quimpo',
        lat: 7.0554988138005905,
        lng: 125.59965853842085,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.045539221894273,
        lng: 125.59156133829786,
      ),
      (
        name: 'Shell Bago Aplaya',
        lat: 7.042438125328425,
        lng: 125.52897452339809,
      ),
      (name: 'IWHA', lat: 7.031834894392899, lng: 125.51331936427333),
      (name: 'GTH', lat: 7.025992277751492, lng: 125.50457434043632),
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
    ],
    pmOutStops: [
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
      (
        name: 'UM Bolton',
        lat: 7.067117153656241,
        lng: 125.60980822842654,
      ),
      (
        name: 'Felcris Centrale',
        lat: 7.060605155427315,
        lng: 125.60918109028236,
      ),
      (
        name: 'Yellow Fin Quimpo',
        lat: 7.0554988138005905,
        lng: 125.59965853842085,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.0452226579005295,
        lng: 125.5915562689465,
      ),
      (
        name: 'Shell Bago Aplaya',
        lat: 7.042438125328425,
        lng: 125.52897452339809,
      ),
      (name: 'IWHA', lat: 7.031834894392899, lng: 125.51331936427333),
      (name: 'GTH', lat: 7.025992277751492, lng: 125.50457434043632),
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
    ],
    pmInStops: [
      (
        name: 'Toril District Hall',
        lat: 7.01857530967576,
        lng: 125.49752945160083,
      ),
      (name: 'Fusion GTH', lat: 7.025698892542236, lng: 125.50453761754194),
      (
        name: 'Pepsi Dumoy',
        lat: 7.031020317008934,
        lng: 125.51234608938083,
      ),
      (
        name: 'Bago Aplaya Crossing',
        lat: 7.042824130139026,
        lng: 125.52971547482498,
      ),
      (
        name: 'Coastal Rd. Times Beach',
        lat: 7.0452226579005295,
        lng: 125.5915562689465,
      ),
      (
        name: 'Ecoland Terminal',
        lat: 7.055079609013119,
        lng: 125.59968205747072,
      ),
      (
        name: 'Felcris Centrale',
        lat: 7.059924682953355,
        lng: 125.60870525952208,
      ),
      (
        name: 'Davao City Police Office',
        lat: 7.063287884164293,
        lng: 125.61090525863925,
      ),
      (
        name: 'CM Recto Ave. (LBC Recto Branch)',
        lat: 7.067109827662894,
        lng: 125.61072031272349,
      ),
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
    ],
  );

  static BusRoute _r402() => _route(
    id: 'r402',
    code: 'R402',
    name: 'Mintal - GE Torres Route',
    origin: 'Mintal',
    destination: 'GE Torres',
    amOutStops: [
      (name: 'Mintal Palengke', lat: 7.0916813, lng: 125.5029771),
      (name: 'Sto Nino Mintal', lat: 7.0856891, lng: 125.5082963),
      (name: 'Green Meadows', lat: 7.0802349, lng: 125.5131001),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.0741641,
        lng: 125.5186047,
      ),
      (name: 'Wellspring Village', lat: 7.0695275, lng: 125.5246370),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.058252,
        lng: 125.569758,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055776928386809,
        lng: 125.5754344886606,
      ),
      (
        name: 'DGT',
        lat: 7.058353611624336,
        lng: 125.58039303376741,
      ),
      (
        name: 'Water District Matina',
        lat: 7.061017302356448,
        lng: 125.59001891248525,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Ateneo Matina',
        lat: 7.062768817010731,
        lng: 125.59761977749405,
      ),
      (
        name: 'GE Torres (Sandawa near Palawan Pawnshop)',
        lat: 7.0614109,
        lng: 125.6012486,
      ),
    ],
    amInStops: [
      (
        name: 'GE Torres (Sandawa near Palawan Pawnshop)',
        lat: 7.0614109,
        lng: 125.6012486,
      ),
      (name: 'Yellow Fin Quimpo', lat: 7.0554287, lng: 125.5996255),
      (name: 'PWC Quimpo', lat: 7.0528969, lng: 125.5945749),
      (name: 'LTO Ecoland', lat: 7.0509340, lng: 125.5878979),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.0591393,
        lng: 125.5680469,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.061171351857061,
        lng: 125.56320239004123,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061408837537958,
        lng: 125.55969246138575,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.060517756202169,
        lng: 125.55430401623474,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069983054087357,
        lng: 125.52423877988046,
      ),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.074403636117461,
        lng: 125.51845189215015,
      ),
      (
        name: 'Gaisano Capital',
        lat: 7.080844033463694,
        lng: 125.51271444213823,
      ),
      (name: 'Vista Mall', lat: 7.08642393577315, lng: 125.50780692265114),
      (name: 'Mintal Palengke', lat: 7.091678, lng: 125.502941),
    ],
    pmOutStops: [
      (
        name: 'Ecoland Terminal',
        lat: 7.055079609013119,
        lng: 125.59968205747072,
      ),
      (
        name: 'GE Torres (Sandawa)',
        lat: 7.0606257088610445,
        lng: 125.60146662185548,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061492938569922,
        lng: 125.59127098528911,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057825343273126,
        lng: 125.5794216899317,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059221779362475,
        lng: 125.56786435434049,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.061171351857061,
        lng: 125.56320239004123,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061408837537958,
        lng: 125.55969246138575,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.060517756202169,
        lng: 125.55430401623474,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069983054087357,
        lng: 125.52423877988046,
      ),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.074403636117461,
        lng: 125.51845189215015,
      ),
      (
        name: 'Gaisano Capital',
        lat: 7.080844033463694,
        lng: 125.51271444213823,
      ),
      (name: 'Vista Mall', lat: 7.08642393577315, lng: 125.50780692265114),
      (name: 'Mintal Palengke', lat: 7.091678, lng: 125.502941),
    ],
    pmInStops: [
      (name: 'Mintal Palengke', lat: 7.0916813, lng: 125.5029771),
      (name: 'Sto Nino Mintal', lat: 7.0856891, lng: 125.5082963),
      (name: 'Green Meadows', lat: 7.0802349, lng: 125.5131001),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.0741641,
        lng: 125.5186047,
      ),
      (name: 'Wellspring Village', lat: 7.0695275, lng: 125.5246370),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.058252,
        lng: 125.569758,
      ),
      (name: 'Kawayan Drive', lat: 7.055756, lng: 125.575448),
      (name: 'SM Ecoland', lat: 7.050676, lng: 125.588039),
      (name: 'PWC Quimpo', lat: 7.052837, lng: 125.594654),
      (name: 'Ecoland Terminal', lat: 7.055034, lng: 125.599672),
    ],
  );

  static BusRoute _r403() => _route(
    id: 'r403',
    code: 'R403',
    name: 'Mintal - Roxas Route',
    origin: 'Mintal',
    destination: 'Roxas',
    amOutStops: [
      (name: 'Mintal Palengke', lat: 7.0916813, lng: 125.5029771),
      (name: 'Sto Nino Mintal', lat: 7.0856891, lng: 125.5082963),
      (name: 'Green Meadows', lat: 7.0802349, lng: 125.5131001),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.0741641,
        lng: 125.5186047,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069623172646326,
        lng: 125.52453175532172,
      ),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.0582621410071225,
        lng: 125.56973946675656,
      ),
      (name: 'Kawayan Drive', lat: 7.055756, lng: 125.575448),
      (
        name: 'DGT',
        lat: 7.058353611624336,
        lng: 125.58039303376741,
      ),
      (
        name: 'Water Dist. Matina',
        lat: 7.061017302356448,
        lng: 125.59001891248525,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Grand Mensang Hotel',
        lat: 7.064698731709079,
        lng: 125.60657110786875,
      ),
      (
        name: 'CM Recto Ave. (LBC Recto Branch)',
        lat: 7.066659879284418,
        lng: 125.6106318195824,
      ),
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
    ],
    amInStops: [
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
      (
        name: 'San Pedro St. near Watsons Pharmacy',
        lat: 7.06565726850648,
        lng: 125.60779199919283,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061492938569922,
        lng: 125.59127098528911,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057825343273126,
        lng: 125.5794216899317,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059221779362475,
        lng: 125.56786435434049,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.061171351857061,
        lng: 125.56320239004123,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061408837537958,
        lng: 125.55969246138575,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.060517756202169,
        lng: 125.55430401623474,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069983054087357,
        lng: 125.52423877988046,
      ),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.074403636117461,
        lng: 125.51845189215015,
      ),
      (
        name: 'Gaisano Capital',
        lat: 7.080844033463694,
        lng: 125.51271444213823,
      ),
      (name: 'Vista Mall', lat: 7.08642393577315, lng: 125.50780692265114),
      (name: 'Mintal Palengke', lat: 7.091678, lng: 125.502941),
    ],
    pmOutStops: [
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
      (
        name: 'San Pedro St. near Watsons Pharmacy',
        lat: 7.06565726850648,
        lng: 125.60779199919283,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061492938569922,
        lng: 125.59127098528911,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057825343273126,
        lng: 125.5794216899317,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059221779362475,
        lng: 125.56786435434049,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.061171351857061,
        lng: 125.56320239004123,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061408837537958,
        lng: 125.55969246138575,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.060517756202169,
        lng: 125.55430401623474,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069983054087357,
        lng: 125.52423877988046,
      ),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.074403636117461,
        lng: 125.51845189215015,
      ),
      (
        name: 'Gaisano Capital',
        lat: 7.080844033463694,
        lng: 125.51271444213823,
      ),
      (name: 'Vista Mall', lat: 7.08642393577315, lng: 125.50780692265114),
      (name: 'Mintal Palengke', lat: 7.091678, lng: 125.502941),
    ],
    pmInStops: [
      (name: 'Mintal Palengke', lat: 7.0916813, lng: 125.5029771),
      (name: 'Sto Nino Mintal', lat: 7.0856891, lng: 125.5082963),
      (name: 'Green Meadows', lat: 7.0802349, lng: 125.5131001),
      (
        name: 'Catalunan Pequeno near footbridge',
        lat: 7.0741641,
        lng: 125.5186047,
      ),
      (
        name: 'Wellspring Village',
        lat: 7.069623172646326,
        lng: 125.52453175532172,
      ),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.058252,
        lng: 125.569758,
      ),
      (name: 'Kawayan Drive', lat: 7.055756, lng: 125.575448),
      (
        name: 'DGT',
        lat: 7.058353611624336,
        lng: 125.58039303376741,
      ),
      (
        name: 'Water Dist. Matina',
        lat: 7.061017302356448,
        lng: 125.59001891248525,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Grand Mensang Hotel',
        lat: 7.064698731709079,
        lng: 125.60657110786875,
      ),
      (
        name: 'CM Recto Ave. (LBC Recto Branch)',
        lat: 7.066659879284418,
        lng: 125.6106318195824,
      ),
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
    ],
  );

  static BusRoute _r503() => _route(
    id: 'r503',
    code: 'R503',
    name: 'Bangkal - Roxas Route',
    origin: 'Bangkal',
    destination: 'Roxas',
    amOutStops: [
      (
        name: 'Hope Ave. Bangkal',
        lat: 7.06094175665836,
        lng: 125.55394071328725,
      ),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (name: 'SPED Bangkal', lat: 7.061315, lng: 125.559738),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.0582621410071225,
        lng: 125.56973946675656,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055776928386809,
        lng: 125.5754344886606,
      ),
      (
        name: 'DGT',
        lat: 7.0583486850000705,
        lng: 125.58039900394762,
      ),
      (
        name: 'Water Dist. Matina',
        lat: 7.061004064760845,
        lng: 125.5900226852448,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Ateneo Matina',
        lat: 7.062768817010731,
        lng: 125.59761977749405,
      ),
      (
        name: 'Pichon St. cor. Quirino Ave. near OroDERM Hotel',
        lat: 7.067718663619696,
        lng: 125.60328826830126,
      ),
      (
        name: 'Grand Menseng Hotel',
        lat: 7.064698731709079,
        lng: 125.60657110786875,
      ),
      (
        name: 'CM Recto Ave. (LBC Recto Branch)',
        lat: 7.067109827662894,
        lng: 125.61072031272349,
      ),
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
    ],
    amInStops: [
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
      (
        name: 'San Pedro St. near Watsons Pharmacy',
        lat: 7.065645056433382,
        lng: 125.60778417590222,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061561287026659,
        lng: 125.59156077173391,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057729814938764,
        lng: 125.57929008714297,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055776928386809,
        lng: 125.5754344886606,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059158718303413,
        lng: 125.56810660127924,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.0611689325111975,
        lng: 125.56320740006322,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061423234933985,
        lng: 125.55971753566475,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.0607059589260865,
        lng: 125.55529899846877,
      ),
      (
        name: 'Hope Ave. Bangkal',
        lat: 7.06094175665836,
        lng: 125.55394071328725,
      ),
    ],
    pmOutStops: [
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
      (
        name: 'San Pedro St. near Watsons Pharmacy',
        lat: 7.065645056433382,
        lng: 125.60778417590222,
      ),
      (
        name: 'UM Matina',
        lat: 7.0631411341208565,
        lng: 125.59817587877563,
      ),
      (
        name: 'Alorica Davao',
        lat: 7.061561287026659,
        lng: 125.59156077173391,
      ),
      (
        name: 'Shrine Hills Matina',
        lat: 7.057729814938764,
        lng: 125.57929008714297,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055890402091169,
        lng: 125.57563883607156,
      ),
      (
        name: 'Matina Crossing near DCPO Police Station 3 - Talomo',
        lat: 7.059158718303413,
        lng: 125.56810660127924,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.0611689325111975,
        lng: 125.56320740006322,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061423234933985,
        lng: 125.55971753566475,
      ),
      (
        name: 'Shell Bangkal',
        lat: 7.0607059589260865,
        lng: 125.55529899846877,
      ),
      (
        name: 'Hope Ave. Bangkal',
        lat: 7.06094175665836,
        lng: 125.55394071328725,
      ),
    ],
    pmInStops: [
      (
        name: 'Hope Ave. Bangkal',
        lat: 7.06094175665836,
        lng: 125.55394071328725,
      ),
      (
        name: 'Ateneo Senior High',
        lat: 7.060864554604337,
        lng: 125.55678299327847,
      ),
      (
        name: 'SPED Bangkal',
        lat: 7.061305555555556,
        lng: 125.55975,
      ),
      (
        name: 'Tahimik Ave. Matina',
        lat: 7.060860106129967,
        lng: 125.56368857654391,
      ),
      (
        name: 'Matina Crossing near Central Convenience Store',
        lat: 7.0582621410071225,
        lng: 125.56973946675656,
      ),
      (
        name: 'Kawayan Drive',
        lat: 7.055776928386809,
        lng: 125.5754344886606,
      ),
      (
        name: 'DGT',
        lat: 7.058353611624336,
        lng: 125.58039303376741,
      ),
      (
        name: 'Water Dist. Matina',
        lat: 7.061004064760845,
        lng: 125.5900226852448,
      ),
      (
        name: 'NCCC Maa',
        lat: 7.0619110502556826,
        lng: 125.59385166012267,
      ),
      (
        name: 'Ateneo Matina',
        lat: 7.062768817010731,
        lng: 125.59761977749405,
      ),
      (
        name: 'Pichon St. cor. Quirino Ave. near OroDERM Hotel',
        lat: 7.067718663619696,
        lng: 125.60328826830126,
      ),
      (
        name: 'Grand Menseng Hotel',
        lat: 7.064698731709079,
        lng: 125.60657110786875,
      ),
      (
        name: 'CM Recto Ave. (LBC Recto Branch)',
        lat: 7.066659879284418,
        lng: 125.6106318195824,
      ),
      (
        name: 'Davao Light (C. Bangoy St.)',
        lat: 7.072781016890752,
        lng: 125.61067229677701,
      ),
    ],
  );

  static BusRoute _r603() => _route(
    id: 'r603',
    code: 'R603',
    name: 'Buhangin - Roxas Route',
    origin: 'Buhangin',
    destination: 'Roxas',
    amOutStops: [
      (name: 'Citymall Northtown', lat: 7.14211, lng: 125.60020),
      (
        name: 'Jollibee Cabantian',
        lat: 7.127485580429315,
        lng: 125.61997126182304,
      ),
      (name: 'Buhangin NHA', lat: 7.11549, lng: 125.62413),
      (
        name: 'Buhangin Gym',
        lat: 7.115436096443829,
        lng: 125.62419332955305,
      ),
      (
        name: 'Ladislawa',
        lat: 7.0991250748399946,
        lng: 125.61475564421224,
      ),
      (name: 'Abreeza Mall', lat: 7.09227, lng: 125.61062),
      (
        name: 'NCCC Mall VP',
        lat: 7.085066134760534,
        lng: 125.61153590506359,
      ),
      (
        name: 'Red Cross Roxas',
        lat: 7.072527777777778,
        lng: 125.61155555555556,
      ),
    ],
    amInStops: [
      (name: 'Citymall Northtown', lat: 7.14211, lng: 125.60020),
      (
        name: 'Jollibee Cabantian',
        lat: 7.127706877855715,
        lng: 125.61990918017105,
      ),
      (
        name: 'Holy Child Cabantian',
        lat: 7.119214642355623,
        lng: 125.62093799262627,
      ),
      (
        name: 'Ladislawa',
        lat: 7.098968235764844,
        lng: 125.61487946716696,
      ),
      (
        name: 'JP Laurel Flyover',
        lat: 7.094919190434544,
        lng: 125.61500215550664,
      ),
      (name: 'Abreeza Mall', lat: 7.09144, lng: 125.61020),
      (
        name: 'NCCC Mall VP',
        lat: 7.0858498613307495,
        lng: 125.61123357754279,
      ),
      (
        name: 'Davao Mental Hospital',
        lat: 7.0760341991753775,
        lng: 125.61325843489129,
      ),
      (name: 'Red Cross Roxas', lat: 7.07254, lng: 125.61155),
    ],
    pmOutStops: [
      (name: 'Red Cross Roxas', lat: 7.07254, lng: 125.61155),
      (
        name: 'Davao Mental Hospital',
        lat: 7.0760341991753775,
        lng: 125.61325843489129,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.0858498613307495,
        lng: 125.61123357754279,
      ),
      (name: 'Abreeza Mall', lat: 7.09144, lng: 125.61020),
      (
        name: 'JP Laurel Flyover',
        lat: 7.094919190434544,
        lng: 125.61500215550664,
      ),
      (
        name: 'Ladislawa',
        lat: 7.098968235764844,
        lng: 125.61487946716696,
      ),
      (name: 'Citygate Buhangin', lat: 7.10959, lng: 125.61297),
    ],
    pmInStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072527777777778,
        lng: 125.61155555555556,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.085066134760534,
        lng: 125.61153590506359,
      ),
      (name: 'Abreeza Mall', lat: 7.09227, lng: 125.61062),
      (
        name: 'Ladislawa',
        lat: 7.0991250748399946,
        lng: 125.61475564421224,
      ),
      (name: 'Citygate Buhangin', lat: 7.10959, lng: 125.61297),
    ],
  );

  static BusRoute _r763() => _route(
    id: 'r763',
    code: 'R763',
    name: 'Panacan (via Buhangin) - Roxas Route',
    origin: 'Panacan',
    destination: 'Roxas',
    amOutStops: [
      (
        name: 'Panacan Depot',
        lat: 7.1483802243673145,
        lng: 125.65936831386026,
      ),
      (
        name: 'Panacan Bypass Rd.',
        lat: 7.143770140614087,
        lng: 125.65441917006825,
      ),
      (
        name: 'LPU Davao',
        lat: 7.136791751687799,
        lng: 125.64708078981438,
      ),
      (
        name: 'Sta. Lucia Mall',
        lat: 7.132858865728123,
        lng: 125.64292420752054,
      ),
      (
        name: 'MCDO Pagibig',
        lat: 7.126136844157472,
        lng: 125.63398832776832,
      ),
      (
        name: 'NHA Buhangin',
        lat: 7.114784094334299,
        lng: 125.62337880872832,
      ),
      (
        name: 'Buhangin Gym',
        lat: 7.10958724320657,
        lng: 125.61577966794478,
      ),
      (
        name: 'Ladislawa',
        lat: 7.099105274822992,
        lng: 125.61474136029946,
      ),
      (
        name: 'Abreeza Mall',
        lat: 7.090488911765794,
        lng: 125.6098514669913,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.08500747306239,
        lng: 125.61158161952932,
      ),
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
    ],
    amInStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
      (
        name: 'Davao Mental Hospital',
        lat: 7.076141316149247,
        lng: 125.61328735437344,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.085832087865023,
        lng: 125.61122741373902,
      ),
      (
        name: 'Abreeza Mall',
        lat: 7.090293042067523,
        lng: 125.61002514411945,
      ),
      (
        name: 'JP Laurel Flyover',
        lat: 7.094932811177917,
        lng: 125.61507660602784,
      ),
      (
        name: 'Ladislawa',
        lat: 7.098993086513025,
        lng: 125.61488357323728,
      ),
      (
        name: 'Milan Buhangin',
        lat: 7.108787771004994,
        lng: 125.6139568515754,
      ),
      (
        name: 'NHA Buhangin',
        lat: 7.1143317219048,
        lng: 125.62297245583643,
      ),
      (
        name: 'Laverna',
        lat: 7.126913915173767,
        lng: 125.6355141723046,
      ),
      (
        name: 'Jose Maria College',
        lat: 7.134279475205123,
        lng: 125.64471170882811,
      ),
      (
        name: 'Landmark',
        lat: 7.138371248580803,
        lng: 125.64891657559151,
      ),
      (
        name: 'Panacan Ave.',
        lat: 7.143269083693995,
        lng: 125.65403708357618,
      ),
      (
        name: 'DavSam Ferry Terminal',
        lat: 7.14610995558344,
        lng: 125.66128424997011,
      ),
      (
        name: 'Panacan Depot',
        lat: 7.1483802243673145,
        lng: 125.65936831386026,
      ),
    ],
    pmOutStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
      (
        name: 'Davao Mental Hospital',
        lat: 7.076141316149247,
        lng: 125.61328735437344,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.085832087865023,
        lng: 125.61122741373902,
      ),
      (
        name: 'Abreeza Mall',
        lat: 7.090293042067523,
        lng: 125.61002514411945,
      ),
      (
        name: 'JP Laurel Flyover',
        lat: 7.094932811177917,
        lng: 125.61507660602784,
      ),
      (
        name: 'Ladislawa',
        lat: 7.098993086513025,
        lng: 125.61488357323728,
      ),
      (
        name: 'Milan Buhangin',
        lat: 7.108787771004994,
        lng: 125.6139568515754,
      ),
      (
        name: 'NHA Buhangin',
        lat: 7.1143317219048,
        lng: 125.62297245583643,
      ),
      (
        name: 'Laverna',
        lat: 7.126913915173767,
        lng: 125.6355141723046,
      ),
      (
        name: 'Jose Maria College',
        lat: 7.134279475205123,
        lng: 125.64471170882811,
      ),
      (
        name: 'Landmark',
        lat: 7.138371248580803,
        lng: 125.64891657559151,
      ),
      (
        name: 'Panacan Ave',
        lat: 7.143269083693995,
        lng: 125.65403708357618,
      ),
      (
        name: 'DavSam Ferry Terminal',
        lat: 7.14610995558344,
        lng: 125.66128424997011,
      ),
      (
        name: 'Panacan Depot',
        lat: 7.1483802243673145,
        lng: 125.65936831386026,
      ),
    ],
    pmInStops: [
      (
        name: 'Panacan Depot',
        lat: 7.1483802243673145,
        lng: 125.65936831386026,
      ),
      (
        name: 'Panacan Bypass Rd',
        lat: 7.143770140614087,
        lng: 125.65441917006825,
      ),
      (
        name: 'LPU Davao',
        lat: 7.136791751687799,
        lng: 125.64708078981438,
      ),
      (
        name: 'Sta. Lucia Mall',
        lat: 7.132858865728123,
        lng: 125.64292420752054,
      ),
      (
        name: 'McDo Pag ibig',
        lat: 7.126136844157472,
        lng: 125.63398832776832,
      ),
      (
        name: 'NHA Buhangin',
        lat: 7.114784094334299,
        lng: 125.62337880872832,
      ),
      (
        name: 'Buhangin Gym',
        lat: 7.10958724320657,
        lng: 125.61577966794478,
      ),
      (
        name: 'Ladislawa',
        lat: 7.099105274822992,
        lng: 125.61474136029946,
      ),
      (
        name: 'Abreeza Mall',
        lat: 7.090488911765794,
        lng: 125.6098514669913,
      ),
      (
        name: 'NCCC Mall VP',
        lat: 7.08500747306239,
        lng: 125.61158161952932,
      ),
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
    ],
  );

  static BusRoute _r783() => _route(
    id: 'r783',
    code: 'R783',
    name: 'Panacan (via Angliongto) - Roxas Route',
    origin: 'Panacan',
    destination: 'Roxas',
    amOutStops: [
      (name: 'Panacan Depot', lat: 7.148351, lng: 125.659342),
      (name: 'Panacan Bypass Rd.', lat: 7.122030, lng: 125.632913),
      (name: 'LPU Davao', lat: 7.136741, lng: 125.647065),
      (name: 'Sta. Lucia Mall', lat: 7.132763, lng: 125.642831),
      (name: 'Mcdo Pagibig', lat: 7.125792, lng: 125.633892),
      (name: 'Punad Bypass', lat: 7.122047, lng: 125.632929),
      (name: 'Angliongto Arcade', lat: 7.108705, lng: 125.632331),
      (name: 'Phil. Nikkei Jin Kai', lat: 7.102758, lng: 125.632766),
      (name: 'SM Lanang', lat: 7.100564, lng: 125.630351),
      (name: 'Carmelite Lanang', lat: 7.099727, lng: 125.627344),
      (name: 'Merco Cabaguio', lat: 7.096429, lng: 125.620606),
      (name: 'Assumption College', lat: 7.086990, lng: 125.623866),
      (name: 'Agdao Flyover', lat: 7.080859, lng: 125.624626),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076942, lng: 125.619280),
      (name: 'Red Cross Roxas', lat: 7.072698, lng: 125.611480),
    ],
    amInStops: [
      (name: 'Red Cross Roxas', lat: 7.072698, lng: 125.611480),
      (name: 'Davao Mental Hospital', lat: 7.076234, lng: 125.613292),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076877, lng: 125.619345),
      (name: 'Agdao Flyover', lat: 7.080869, lng: 125.624780),
      (name: 'Holy Cross R. Castillo', lat: 7.087379, lng: 125.629481),
      (name: 'Jerome R. Castillo', lat: 7.096886, lng: 125.638286),
      (name: 'Nova Tierra', lat: 7.110840, lng: 125.649694),
      (name: 'Dona Pilar', lat: 7.114650, lng: 125.652805),
      (name: 'Old Airport', lat: 7.117241, lng: 125.654859),
      (name: 'Shell Dona Salud', lat: 7.121625, lng: 125.658373),
      (name: 'Philippine Ports Authority', lat: 7.127041, lng: 125.661821),
      (name: 'Sasa Palengke', lat: 7.134615, lng: 125.661623),
      (
        name: 'DavSam Ferry Terminal',
        lat: 7.14610995558344,
        lng: 125.66128424997011,
      ),
      (name: 'Panacan Depot', lat: 7.148351, lng: 125.659342),
    ],
    pmOutStops: [
      (name: 'Red Cross Roxas', lat: 7.072698, lng: 125.611480),
      (name: 'Davao Mental Hospital', lat: 7.076234, lng: 125.613292),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076899, lng: 125.619284),
      (name: 'Agdao Flyover', lat: 7.080869, lng: 125.624780),
      (name: 'Holy Cross R. Castillo', lat: 7.087379, lng: 125.629481),
      (name: 'Jerome R. Castillo', lat: 7.096886, lng: 125.638286),
      (name: 'Nova Tierra', lat: 7.110840, lng: 125.649694),
      (name: 'Dona Pilar', lat: 7.114650, lng: 125.652805),
      (name: 'Old Airport', lat: 7.117241, lng: 125.654859),
      (name: 'Shell Dona Salud', lat: 7.121625, lng: 125.658373),
      (name: 'Philippine Ports Authority', lat: 7.127041, lng: 125.661821),
      (name: 'Sasa Palengke', lat: 7.134615, lng: 125.661623),
      (
        name: 'DavSam Ferry Terminal',
        lat: 7.14610995558344,
        lng: 125.66128424997011,
      ),
      (name: 'Panacan Depot', lat: 7.148351, lng: 125.659342),
    ],
    pmInStops: [
      (name: 'Panacan Depot', lat: 7.148351, lng: 125.659342),
      (name: 'Panacan Bypass Rd', lat: 7.143647, lng: 125.654327),
      (name: 'LPU Davao', lat: 7.136741, lng: 125.647065),
      (name: 'Sta. Lucia Mall', lat: 7.132763, lng: 125.642831),
      (name: 'Mcdo Pagibig', lat: 7.125792, lng: 125.633892),
      (name: 'Punad Bypass', lat: 7.122030, lng: 125.632913),
      (name: 'Angliongto Arcade', lat: 7.108705, lng: 125.632331),
      (name: 'Phil. Nikkei Jin Kai', lat: 7.102758, lng: 125.632766),
      (name: 'SM Lanang', lat: 7.100564, lng: 125.630351),
      (name: 'Carmelite Lanang', lat: 7.099727, lng: 125.627344),
      (name: 'Merco Cabaguio', lat: 7.096429, lng: 125.620606),
      (name: 'Assumption College', lat: 7.086990, lng: 125.623866),
      (name: 'Agdao Flyover', lat: 7.080859, lng: 125.624626),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076942, lng: 125.619280),
      (name: 'Red Cross Roxas', lat: 7.072698, lng: 125.611480),
    ],
  );

  static BusRoute _r793() => _route(
    id: 'r793',
    code: 'R793',
    name: 'Panacan (via R. Castillo) - Roxas Route',
    origin: 'Panacan',
    destination: 'Roxas',
    amOutStops: [
      (
        name: 'NCCC Panacan',
        lat: 7.143951693564209,
        lng: 125.66121195588696,
      ),
      (name: 'Sasa Palengke', lat: 7.135255, lng: 125.661507),
      (
        name: 'Sulpicio Rd. Sasa',
        lat: 7.127609335602626,
        lng: 125.661675557983,
      ),
      (
        name: 'Dona Salud',
        lat: 7.1222935776519956,
        lng: 125.65875558521984,
      ),
      (
        name: 'Old Airport',
        lat: 7.117205884351722,
        lng: 125.65467495284958,
      ),
      (
        name: 'Petron Dona Pilar',
        lat: 7.114635002992314,
        lng: 125.65254134647583,
      ),
      (
        name: 'Nova Tierra',
        lat: 7.110980064704668,
        lng: 125.64954814880186,
      ),
      (
        name: 'Jerome R. Castillo',
        lat: 7.09665698474913,
        lng: 125.63786641688755,
      ),
      (
        name: 'Holy Cross R. Castillo',
        lat: 7.08721563127331,
        lng: 125.62900799073341,
      ),
      (
        name: 'Agdao Flyover',
        lat: 7.080935317784382,
        lng: 125.62460530324813,
      ),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076969, lng: 125.619016),
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
    ],
    amInStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
      (
        name: 'Davao Mental Hospital',
        lat: 7.076141316149247,
        lng: 125.61328735437344,
      ),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076969, lng: 125.619016),
      (
        name: 'Agdao Flyover',
        lat: 7.080935317784382,
        lng: 125.62460530324813,
      ),
      (
        name: 'Assumption College',
        lat: 7.087771291866992,
        lng: 125.62378192592959,
      ),
      (
        name: 'Shell SPMC',
        lat: 7.097941897318523,
        lng: 125.62173814746481,
      ),
      (
        name: 'Tebow Hospital Lanang',
        lat: 7.099321509512396,
        lng: 125.62655759530764,
      ),
      (
        name: 'SM Lanang',
        lat: 7.100130578006676,
        lng: 125.62942516123555,
      ),
      (
        name: 'Starbucks Damosa',
        lat: 7.103273421001684,
        lng: 125.63283102307423,
      ),
      (
        name: 'Angliongto Arcade',
        lat: 7.109179284811052,
        lng: 125.63240016549021,
      ),
      (
        name: 'Punad Bypass',
        lat: 7.121548534303242,
        lng: 125.63333729997544,
      ),
      (
        name: 'Laverna',
        lat: 7.126913915173767,
        lng: 125.6355141723046,
      ),
      (
        name: 'Jose Maria College',
        lat: 7.134279475205123,
        lng: 125.64471170882811,
      ),
      (
        name: 'Landmark',
        lat: 7.138371248580803,
        lng: 125.64891657559151,
      ),
      (
        name: 'Panacan Ave.',
        lat: 7.143269083693995,
        lng: 125.65403708357618,
      ),
      (
        name: 'NCCC Panacan',
        lat: 7.143951693564209,
        lng: 125.66121195588696,
      ),
    ],
    pmOutStops: [
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
      (
        name: 'Davao Mental Hospital',
        lat: 7.076141316149247,
        lng: 125.61328735437344,
      ),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076969, lng: 125.619016),
      (
        name: 'Agdao Flyover',
        lat: 7.080935317784382,
        lng: 125.62460530324813,
      ),
      (
        name: 'Assumption College',
        lat: 7.087771291866992,
        lng: 125.62378192592959,
      ),
      (
        name: 'Shell SPMC',
        lat: 7.097941897318523,
        lng: 125.62173814746481,
      ),
      (
        name: 'Tebow Hospital Lanang',
        lat: 7.099321509512396,
        lng: 125.62655759530764,
      ),
      (
        name: 'SM Lanang',
        lat: 7.100130578006676,
        lng: 125.62942516123555,
      ),
      (
        name: 'Starbucks Damosa',
        lat: 7.103273421001684,
        lng: 125.63283102307423,
      ),
      (
        name: 'Angliongto Arcade',
        lat: 7.109179284811052,
        lng: 125.63240016549021,
      ),
      (
        name: 'Punad Bypass',
        lat: 7.121548534303242,
        lng: 125.63333729997544,
      ),
      (
        name: 'Laverna',
        lat: 7.126913915173767,
        lng: 125.6355141723046,
      ),
      (
        name: 'Jose Maria College',
        lat: 7.134279475205123,
        lng: 125.64471170882811,
      ),
      (
        name: 'Landmark',
        lat: 7.138371248580803,
        lng: 125.64891657559151,
      ),
      (
        name: 'Panacan Ave.',
        lat: 7.143269083693995,
        lng: 125.65403708357618,
      ),
      (
        name: 'NCCC Panacan',
        lat: 7.143951693564209,
        lng: 125.66121195588696,
      ),
    ],
    pmInStops: [
      (
        name: 'NCCC Panacan',
        lat: 7.143951693564209,
        lng: 125.66121195588696,
      ),
      (name: 'Sasa Palengke', lat: 7.135255, lng: 125.661507),
      (
        name: 'Sulpicio Rd. Sasa',
        lat: 7.127609335602626,
        lng: 125.661675557983,
      ),
      (
        name: 'Dona Salud',
        lat: 7.1222935776519956,
        lng: 125.65875558521984,
      ),
      (
        name: 'Old Airport',
        lat: 7.117205884351722,
        lng: 125.65467495284958,
      ),
      (
        name: 'Petron Dona Pilar',
        lat: 7.114635002992314,
        lng: 125.65254134647583,
      ),
      (
        name: 'Nova Tierra',
        lat: 7.110980064704668,
        lng: 125.64954814880186,
      ),
      (
        name: 'Jerome R. Castillo',
        lat: 7.09665698474913,
        lng: 125.63786641688755,
      ),
      (
        name: 'Holy Cross R. Castillo',
        lat: 7.08721563127331,
        lng: 125.62900799073341,
      ),
      (
        name: 'Agdao Flyover',
        lat: 7.080935317784382,
        lng: 125.62460530324813,
      ),
      (name: 'Sta. Ana Sobrecarey', lat: 7.076969, lng: 125.619016),
      (
        name: 'Red Cross Roxas',
        lat: 7.072610830052556,
        lng: 125.6115644288388,
      ),
    ],
  );
}
