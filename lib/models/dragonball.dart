// To parse this JSON data, do
//
//     final dragonball = dragonballFromJson(jsonString);

import 'dart:convert';

Dragonball dragonballFromJson(String str) =>
    Dragonball.fromJson(json.decode(str));

String dragonballToJson(Dragonball data) => json.encode(data.toJson());

class Dragonball {
  final List<Item> items;
  final Meta meta;
  final Links links;

  Dragonball({required this.items, required this.meta, required this.links});

  factory Dragonball.fromJson(Map<String, dynamic> json) => Dragonball(
    items: (json["items"] as List<dynamic>? ?? [])
        .map((x) => Item.fromJson(x as Map<String, dynamic>))
        .toList(),
    meta: Meta.fromJson(json["meta"] as Map<String, dynamic>? ?? {}),
    links: Links.fromJson(json["links"] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "meta": meta.toJson(),
    "links": links.toJson(),
  };
}

class Item {
  final int id;
  final String name;
  final String ki;
  final String maxKi;
  final Race race;
  final Gender gender;
  final String description;
  final String image;
  final Affiliation affiliation;
  final dynamic deletedAt;

  Item({
    required this.id,
    required this.name,
    required this.ki,
    required this.maxKi,
    required this.race,
    required this.gender,
    required this.description,
    required this.image,
    required this.affiliation,
    required this.deletedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] as int? ?? 0,
    name: json["name"] as String? ?? "Unknown",
    ki: json["ki"] as String? ?? "Unknown",
    maxKi: json["maxKi"] as String? ?? "Unknown",
    race: raceValues.map[json["race"]] ?? Race.UNKNOWN,
    gender: genderValues.map[json["gender"]] ?? Gender.UNKNOWN,
    description: json["description"] as String? ?? "No description available.",
    image: json["image"] as String? ?? "",
    affiliation:
        affiliationValues.map[json["affiliation"]] ?? Affiliation.UNKNOWN,
    deletedAt: json["deletedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "ki": ki,
    "maxKi": maxKi,
    "race": raceValues.reverse[race],
    "gender": genderValues.reverse[gender],
    "description": description,
    "image": image,
    "affiliation": affiliationValues.reverse[affiliation],
    "deletedAt": deletedAt,
  };
}

enum Affiliation {
  ARMY_OF_FRIEZA,
  FREELANCER,
  OTHER,
  VILLAIN,
  Z_FIGHTER,
  UNKNOWN,
}

final affiliationValues = EnumValues({
  "Army of Frieza": Affiliation.ARMY_OF_FRIEZA,
  "Freelancer": Affiliation.FREELANCER,
  "Other": Affiliation.OTHER,
  "Villain": Affiliation.VILLAIN,
  "Z Fighter": Affiliation.Z_FIGHTER,
});

enum Gender { FEMALE, MALE, UNKNOWN }

final genderValues = EnumValues({"Female": Gender.FEMALE, "Male": Gender.MALE});

enum Race { ANDROID, FRIEZA_RACE, HUMAN, NAMEKIAN, SAIYAN, UNKNOWN }

final raceValues = EnumValues({
  "Android": Race.ANDROID,
  "Frieza Race": Race.FRIEZA_RACE,
  "Human": Race.HUMAN,
  "Namekian": Race.NAMEKIAN,
  "Saiyan": Race.SAIYAN,
});

class Links {
  final String? first;
  final String? previous;
  final String? next;
  final String? last;

  Links({
    required this.first,
    required this.previous,
    required this.next,
    required this.last,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json["first"] as String?,
    previous: json["previous"] as String?,
    next: json["next"] as String?,
    last: json["last"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "previous": previous,
    "next": next,
    "last": last,
  };
}

class Meta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  Meta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    totalItems: json["totalItems"] as int? ?? 0,
    itemCount: json["itemCount"] as int? ?? 0,
    itemsPerPage: json["itemsPerPage"] as int? ?? 0,
    totalPages: json["totalPages"] as int? ?? 0,
    currentPage: json["currentPage"] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "itemCount": itemCount,
    "itemsPerPage": itemsPerPage,
    "totalPages": totalPages,
    "currentPage": currentPage,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
