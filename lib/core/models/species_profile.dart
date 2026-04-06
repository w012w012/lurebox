import 'dart:convert';

/// Conservation status enumeration
enum ConservationStatus {
  lc('LC', 'Least Concern', '无危'),
  nt('NT', 'Near Threatened', '近危'),
  vu('VU', 'Vulnerable', '易危'),
  en('EN', 'Endangered', '濒危'),
  cr('CR', 'Critical', '极危'),
  ew('EW', 'Extinct in Wild', '野外灭绝'),
  ex('EX', 'Extinct', '灭绝'),
  invasive('Invasive', 'Invasive', '入侵种'),
  notEvaluated('NE', 'Not Evaluated', '未评估'),
  dataDeficient('DD', 'Data Deficient', '数据缺乏');

  const ConservationStatus(this.code, this.label, this.labelCn);
  final String code;
  final String label;
  final String labelCn;

  static ConservationStatus fromCode(String code) {
    final upperCode = code.toUpperCase();
    for (final status in ConservationStatus.values) {
      if (status.code.toUpperCase() == upperCode) {
        return status;
      }
    }
    // Handle compound status like "IUCN: Least Concern (LC), CITES: Not Evaluated"
    if (upperCode.contains('LC')) return ConservationStatus.lc;
    if (upperCode.contains('NT')) return ConservationStatus.nt;
    if (upperCode.contains('VU')) return ConservationStatus.vu;
    if (upperCode.contains('EN')) return ConservationStatus.en;
    if (upperCode.contains('CR')) return ConservationStatus.cr;
    if (upperCode.contains('EW')) return ConservationStatus.ew;
    if (upperCode.contains('EX')) return ConservationStatus.ex;
    if (upperCode.contains('INVASIVE')) return ConservationStatus.invasive;
    if (upperCode.contains('NE') || upperCode.contains('NOT EVALUATED')) {
      return ConservationStatus.notEvaluated;
    }
    if (upperCode.contains('DD') || upperCode.contains('DATA DEFICIENT')) {
      return ConservationStatus.dataDeficient;
    }
    return ConservationStatus.notEvaluated;
  }
}

/// Source reference model
class SourceReference {
  final String name;
  final String url;
  final List<String> accessedFields;
  final String accessDate;

  const SourceReference({
    required this.name,
    required this.url,
    required this.accessedFields,
    required this.accessDate,
  });

  factory SourceReference.fromMap(Map<String, dynamic> map) {
    return SourceReference(
      name: map['name'] as String,
      url: map['url'] as String,
      accessedFields: (map['accessed_fields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      accessDate: map['access_date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'accessed_fields': accessedFields,
      'access_date': accessDate,
    };
  }
}

/// Species profile model
///
/// Contains detailed information about a fish species including
/// identification, habitat, behavior, fishing techniques, and conservation status.
class SpeciesProfile {
  final int? id;
  final String speciesId;
  final String? aliases;
  final String? identification;
  final String? habitat;
  final String? feedingBehavior;
  final String? fishingTechniques;
  final String? sizeRecords;
  final String? conservationStatus;
  final List<SourceReference> sourceReferences;
  final String? confidenceScore;
  final int version;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpeciesProfile({
    this.id,
    required this.speciesId,
    this.aliases,
    this.identification,
    this.habitat,
    this.feedingBehavior,
    this.fishingTechniques,
    this.sizeRecords,
    this.conservationStatus,
    this.sourceReferences = const [],
    this.confidenceScore,
    this.version = 1,
    this.createdAt,
    this.updatedAt,
  });

  /// Get parsed conservation status enum
  ConservationStatus get status {
    if (conservationStatus == null) return ConservationStatus.notEvaluated;
    return ConservationStatus.fromCode(conservationStatus!);
  }

  /// Check if profile has any data to display
  bool get hasData {
    return aliases != null ||
        identification != null ||
        habitat != null ||
        feedingBehavior != null ||
        fishingTechniques != null ||
        sizeRecords != null ||
        conservationStatus != null;
  }

  factory SpeciesProfile.fromMap(Map<String, dynamic> map) {
    List<SourceReference> sources = [];
    if (map['source_references'] != null) {
      try {
        final decoded = jsonDecode(map['source_references'] as String);
        if (decoded is List) {
          sources = decoded
              .map((e) => SourceReference.fromMap(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // If parsing fails, return empty list
      }
    }

    return SpeciesProfile(
      id: map['id'] as int?,
      speciesId: map['species_id'] as String,
      aliases: map['aliases'] as String?,
      identification: map['identification'] as String?,
      habitat: map['habitat'] as String?,
      feedingBehavior: map['feeding_behavior'] as String?,
      fishingTechniques: map['fishing_techniques'] as String?,
      sizeRecords: map['size_records'] as String?,
      conservationStatus: map['conservation_status'] as String?,
      sourceReferences: sources,
      confidenceScore: map['confidence_score'] as String?,
      version: map['version'] as int? ?? 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'species_id': speciesId,
      'aliases': aliases,
      'identification': identification,
      'habitat': habitat,
      'feeding_behavior': feedingBehavior,
      'fishing_techniques': fishingTechniques,
      'size_records': sizeRecords,
      'conservation_status': conservationStatus,
      'source_references':
          jsonEncode(sourceReferences.map((e) => e.toMap()).toList()),
      'confidence_score': confidenceScore,
      'version': version,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SpeciesProfile copyWith({
    int? id,
    String? speciesId,
    String? aliases,
    String? identification,
    String? habitat,
    String? feedingBehavior,
    String? fishingTechniques,
    String? sizeRecords,
    String? conservationStatus,
    List<SourceReference>? sourceReferences,
    String? confidenceScore,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpeciesProfile(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      aliases: aliases ?? this.aliases,
      identification: identification ?? this.identification,
      habitat: habitat ?? this.habitat,
      feedingBehavior: feedingBehavior ?? this.feedingBehavior,
      fishingTechniques: fishingTechniques ?? this.fishingTechniques,
      sizeRecords: sizeRecords ?? this.sizeRecords,
      conservationStatus: conservationStatus ?? this.conservationStatus,
      sourceReferences: sourceReferences ?? this.sourceReferences,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeciesProfile &&
          runtimeType == other.runtimeType &&
          speciesId == other.speciesId;

  @override
  int get hashCode => speciesId.hashCode;

  @override
  String toString() {
    return 'SpeciesProfile(speciesId: $speciesId, aliases: $aliases)';
  }
}
