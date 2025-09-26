// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMemoryCollection on Isar {
  IsarCollection<Memory> get memorys => this.collection();
}

const MemorySchema = CollectionSchema(
  name: r'Memory',
  id: 6426130528628242831,
  properties: {
    r'ambientSound': PropertySchema(
      id: 0,
      name: r'ambientSound',
      type: IsarType.string,
    ),
    r'audioKeysOrder': PropertySchema(
      id: 1,
      name: r'audioKeysOrder',
      type: IsarType.stringList,
    ),
    r'audioNotePaths': PropertySchema(
      id: 2,
      name: r'audioNotePaths',
      type: IsarType.stringList,
    ),
    r'audioUrls': PropertySchema(
      id: 3,
      name: r'audioUrls',
      type: IsarType.stringList,
    ),
    r'content': PropertySchema(
      id: 4,
      name: r'content',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 5,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'emotionsData': PropertySchema(
      id: 6,
      name: r'emotionsData',
      type: IsarType.stringList,
    ),
    r'firestoreId': PropertySchema(
      id: 7,
      name: r'firestoreId',
      type: IsarType.string,
    ),
    r'isEncrypted': PropertySchema(
      id: 8,
      name: r'isEncrypted',
      type: IsarType.bool,
    ),
    r'lastModified': PropertySchema(
      id: 9,
      name: r'lastModified',
      type: IsarType.dateTime,
    ),
    r'mediaKeysOrder': PropertySchema(
      id: 10,
      name: r'mediaKeysOrder',
      type: IsarType.stringList,
    ),
    r'mediaPaths': PropertySchema(
      id: 11,
      name: r'mediaPaths',
      type: IsarType.stringList,
    ),
    r'mediaThumbPaths': PropertySchema(
      id: 12,
      name: r'mediaThumbPaths',
      type: IsarType.stringList,
    ),
    r'mediaThumbUrls': PropertySchema(
      id: 13,
      name: r'mediaThumbUrls',
      type: IsarType.stringList,
    ),
    r'mediaUrls': PropertySchema(
      id: 14,
      name: r'mediaUrls',
      type: IsarType.stringList,
    ),
    r'reflectionAction': PropertySchema(
      id: 15,
      name: r'reflectionAction',
      type: IsarType.string,
    ),
    r'reflectionActionCompleted': PropertySchema(
      id: 16,
      name: r'reflectionActionCompleted',
      type: IsarType.bool,
    ),
    r'reflectionAutoThought': PropertySchema(
      id: 17,
      name: r'reflectionAutoThought',
      type: IsarType.string,
    ),
    r'reflectionEvidenceAgainst': PropertySchema(
      id: 18,
      name: r'reflectionEvidenceAgainst',
      type: IsarType.string,
    ),
    r'reflectionEvidenceFor': PropertySchema(
      id: 19,
      name: r'reflectionEvidenceFor',
      type: IsarType.string,
    ),
    r'reflectionFollowUpAt': PropertySchema(
      id: 20,
      name: r'reflectionFollowUpAt',
      type: IsarType.dateTime,
    ),
    r'reflectionImpact': PropertySchema(
      id: 21,
      name: r'reflectionImpact',
      type: IsarType.string,
    ),
    r'reflectionLesson': PropertySchema(
      id: 22,
      name: r'reflectionLesson',
      type: IsarType.string,
    ),
    r'reflectionReframe': PropertySchema(
      id: 23,
      name: r'reflectionReframe',
      type: IsarType.string,
    ),
    r'spotifyTrackIds': PropertySchema(
      id: 24,
      name: r'spotifyTrackIds',
      type: IsarType.stringList,
    ),
    r'syncStatus': PropertySchema(
      id: 25,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 26,
      name: r'title',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 27,
      name: r'userId',
      type: IsarType.string,
    ),
    r'videoKeysOrder': PropertySchema(
      id: 28,
      name: r'videoKeysOrder',
      type: IsarType.stringList,
    ),
    r'videoPaths': PropertySchema(
      id: 29,
      name: r'videoPaths',
      type: IsarType.stringList,
    ),
    r'videoUrls': PropertySchema(
      id: 30,
      name: r'videoUrls',
      type: IsarType.stringList,
    )
  },
  estimateSize: _memoryEstimateSize,
  serialize: _memorySerialize,
  deserialize: _memoryDeserialize,
  deserializeProp: _memoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'firestoreId': IndexSchema(
      id: 1863077355534729001,
      name: r'firestoreId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'firestoreId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _memoryGetId,
  getLinks: _memoryGetLinks,
  attach: _memoryAttach,
  version: '3.1.0+1',
);

int _memoryEstimateSize(
  Memory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.ambientSound;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.audioKeysOrder.length * 3;
  {
    for (var i = 0; i < object.audioKeysOrder.length; i++) {
      final value = object.audioKeysOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.audioNotePaths.length * 3;
  {
    for (var i = 0; i < object.audioNotePaths.length; i++) {
      final value = object.audioNotePaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.audioUrls.length * 3;
  {
    for (var i = 0; i < object.audioUrls.length; i++) {
      final value = object.audioUrls[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.emotionsData.length * 3;
  {
    for (var i = 0; i < object.emotionsData.length; i++) {
      final value = object.emotionsData[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.firestoreId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaKeysOrder.length * 3;
  {
    for (var i = 0; i < object.mediaKeysOrder.length; i++) {
      final value = object.mediaKeysOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaPaths.length * 3;
  {
    for (var i = 0; i < object.mediaPaths.length; i++) {
      final value = object.mediaPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaThumbPaths.length * 3;
  {
    for (var i = 0; i < object.mediaThumbPaths.length; i++) {
      final value = object.mediaThumbPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaThumbUrls.length * 3;
  {
    for (var i = 0; i < object.mediaThumbUrls.length; i++) {
      final value = object.mediaThumbUrls[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaUrls.length * 3;
  {
    for (var i = 0; i < object.mediaUrls.length; i++) {
      final value = object.mediaUrls[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.reflectionAction;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionAutoThought;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionEvidenceAgainst;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionEvidenceFor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionImpact;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionLesson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reflectionReframe;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.spotifyTrackIds.length * 3;
  {
    for (var i = 0; i < object.spotifyTrackIds.length; i++) {
      final value = object.spotifyTrackIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.syncStatus.length * 3;
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.videoKeysOrder.length * 3;
  {
    for (var i = 0; i < object.videoKeysOrder.length; i++) {
      final value = object.videoKeysOrder[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.videoPaths.length * 3;
  {
    for (var i = 0; i < object.videoPaths.length; i++) {
      final value = object.videoPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.videoUrls.length * 3;
  {
    for (var i = 0; i < object.videoUrls.length; i++) {
      final value = object.videoUrls[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _memorySerialize(
  Memory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.ambientSound);
  writer.writeStringList(offsets[1], object.audioKeysOrder);
  writer.writeStringList(offsets[2], object.audioNotePaths);
  writer.writeStringList(offsets[3], object.audioUrls);
  writer.writeString(offsets[4], object.content);
  writer.writeDateTime(offsets[5], object.date);
  writer.writeStringList(offsets[6], object.emotionsData);
  writer.writeString(offsets[7], object.firestoreId);
  writer.writeBool(offsets[8], object.isEncrypted);
  writer.writeDateTime(offsets[9], object.lastModified);
  writer.writeStringList(offsets[10], object.mediaKeysOrder);
  writer.writeStringList(offsets[11], object.mediaPaths);
  writer.writeStringList(offsets[12], object.mediaThumbPaths);
  writer.writeStringList(offsets[13], object.mediaThumbUrls);
  writer.writeStringList(offsets[14], object.mediaUrls);
  writer.writeString(offsets[15], object.reflectionAction);
  writer.writeBool(offsets[16], object.reflectionActionCompleted);
  writer.writeString(offsets[17], object.reflectionAutoThought);
  writer.writeString(offsets[18], object.reflectionEvidenceAgainst);
  writer.writeString(offsets[19], object.reflectionEvidenceFor);
  writer.writeDateTime(offsets[20], object.reflectionFollowUpAt);
  writer.writeString(offsets[21], object.reflectionImpact);
  writer.writeString(offsets[22], object.reflectionLesson);
  writer.writeString(offsets[23], object.reflectionReframe);
  writer.writeStringList(offsets[24], object.spotifyTrackIds);
  writer.writeString(offsets[25], object.syncStatus);
  writer.writeString(offsets[26], object.title);
  writer.writeString(offsets[27], object.userId);
  writer.writeStringList(offsets[28], object.videoKeysOrder);
  writer.writeStringList(offsets[29], object.videoPaths);
  writer.writeStringList(offsets[30], object.videoUrls);
}

Memory _memoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Memory();
  object.ambientSound = reader.readStringOrNull(offsets[0]);
  object.audioKeysOrder = reader.readStringList(offsets[1]) ?? [];
  object.audioNotePaths = reader.readStringList(offsets[2]) ?? [];
  object.audioUrls = reader.readStringList(offsets[3]) ?? [];
  object.content = reader.readStringOrNull(offsets[4]);
  object.date = reader.readDateTime(offsets[5]);
  object.emotionsData = reader.readStringList(offsets[6]) ?? [];
  object.firestoreId = reader.readStringOrNull(offsets[7]);
  object.id = id;
  object.isEncrypted = reader.readBool(offsets[8]);
  object.lastModified = reader.readDateTime(offsets[9]);
  object.mediaKeysOrder = reader.readStringList(offsets[10]) ?? [];
  object.mediaPaths = reader.readStringList(offsets[11]) ?? [];
  object.mediaThumbPaths = reader.readStringList(offsets[12]) ?? [];
  object.mediaThumbUrls = reader.readStringList(offsets[13]) ?? [];
  object.mediaUrls = reader.readStringList(offsets[14]) ?? [];
  object.reflectionAction = reader.readStringOrNull(offsets[15]);
  object.reflectionActionCompleted = reader.readBool(offsets[16]);
  object.reflectionAutoThought = reader.readStringOrNull(offsets[17]);
  object.reflectionEvidenceAgainst = reader.readStringOrNull(offsets[18]);
  object.reflectionEvidenceFor = reader.readStringOrNull(offsets[19]);
  object.reflectionFollowUpAt = reader.readDateTimeOrNull(offsets[20]);
  object.reflectionImpact = reader.readStringOrNull(offsets[21]);
  object.reflectionLesson = reader.readStringOrNull(offsets[22]);
  object.reflectionReframe = reader.readStringOrNull(offsets[23]);
  object.spotifyTrackIds = reader.readStringList(offsets[24]) ?? [];
  object.syncStatus = reader.readString(offsets[25]);
  object.title = reader.readString(offsets[26]);
  object.userId = reader.readStringOrNull(offsets[27]);
  object.videoKeysOrder = reader.readStringList(offsets[28]) ?? [];
  object.videoPaths = reader.readStringList(offsets[29]) ?? [];
  object.videoUrls = reader.readStringList(offsets[30]) ?? [];
  return object;
}

P _memoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (reader.readStringList(offset) ?? []) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringList(offset) ?? []) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringList(offset) ?? []) as P;
    case 29:
      return (reader.readStringList(offset) ?? []) as P;
    case 30:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _memoryGetId(Memory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _memoryGetLinks(Memory object) {
  return [];
}

void _memoryAttach(IsarCollection<dynamic> col, Id id, Memory object) {
  object.id = id;
}

extension MemoryByIndex on IsarCollection<Memory> {
  Future<Memory?> getByFirestoreId(String? firestoreId) {
    return getByIndex(r'firestoreId', [firestoreId]);
  }

  Memory? getByFirestoreIdSync(String? firestoreId) {
    return getByIndexSync(r'firestoreId', [firestoreId]);
  }

  Future<bool> deleteByFirestoreId(String? firestoreId) {
    return deleteByIndex(r'firestoreId', [firestoreId]);
  }

  bool deleteByFirestoreIdSync(String? firestoreId) {
    return deleteByIndexSync(r'firestoreId', [firestoreId]);
  }

  Future<List<Memory?>> getAllByFirestoreId(List<String?> firestoreIdValues) {
    final values = firestoreIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'firestoreId', values);
  }

  List<Memory?> getAllByFirestoreIdSync(List<String?> firestoreIdValues) {
    final values = firestoreIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'firestoreId', values);
  }

  Future<int> deleteAllByFirestoreId(List<String?> firestoreIdValues) {
    final values = firestoreIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'firestoreId', values);
  }

  int deleteAllByFirestoreIdSync(List<String?> firestoreIdValues) {
    final values = firestoreIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'firestoreId', values);
  }

  Future<Id> putByFirestoreId(Memory object) {
    return putByIndex(r'firestoreId', object);
  }

  Id putByFirestoreIdSync(Memory object, {bool saveLinks = true}) {
    return putByIndexSync(r'firestoreId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByFirestoreId(List<Memory> objects) {
    return putAllByIndex(r'firestoreId', objects);
  }

  List<Id> putAllByFirestoreIdSync(List<Memory> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'firestoreId', objects, saveLinks: saveLinks);
  }
}

extension MemoryQueryWhereSort on QueryBuilder<Memory, Memory, QWhere> {
  QueryBuilder<Memory, Memory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension MemoryQueryWhere on QueryBuilder<Memory, Memory, QWhereClause> {
  QueryBuilder<Memory, Memory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> firestoreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> firestoreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firestoreId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> firestoreIdEqualTo(
      String? firestoreId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firestoreId',
        value: [firestoreId],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> firestoreIdNotEqualTo(
      String? firestoreId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [firestoreId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firestoreId',
              lower: [],
              upper: [firestoreId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'userId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> userIdEqualTo(
      String? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> userIdNotEqualTo(
      String? userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> syncStatusEqualTo(
      String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterWhereClause> syncStatusNotEqualTo(
      String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MemoryQueryFilter on QueryBuilder<Memory, Memory, QFilterCondition> {
  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ambientSound',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ambientSound',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ambientSound',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ambientSound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ambientSound',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ambientSound',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> ambientSoundIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ambientSound',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioKeysOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioKeysOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioKeysOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioKeysOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioKeysOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioNotePaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioNotePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioNotePaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioNotePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioNotePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioNotePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioNotePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioNotePaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audioUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audioUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audioUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      audioUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> audioUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'audioUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emotionsData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emotionsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emotionsData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotionsData',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emotionsData',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> emotionsDataLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> emotionsDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> emotionsDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      emotionsDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> emotionsDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'emotionsData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firestoreId',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firestoreId',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firestoreId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firestoreId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firestoreId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> firestoreIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firestoreId',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> isEncryptedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEncrypted',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> lastModifiedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> lastModifiedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> lastModifiedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModified',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> lastModifiedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModified',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaKeysOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaKeysOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaKeysOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaKeysOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaKeysOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaThumbPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaThumbPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaThumbPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaThumbPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaThumbPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaThumbPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaThumbUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaThumbUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaThumbUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaThumbUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaThumbUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaThumbUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaThumbUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaThumbUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      mediaUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> mediaUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mediaUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionAction',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionAction',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionAction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionActionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionAction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAction',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionAction',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionActionCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionActionCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionAutoThought',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionAutoThought',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionAutoThought',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionAutoThought',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionAutoThought',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionAutoThought',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionAutoThoughtIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionAutoThought',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionEvidenceAgainst',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionEvidenceAgainst',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionEvidenceAgainst',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionEvidenceAgainst',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionEvidenceAgainst',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionEvidenceAgainst',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceAgainstIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionEvidenceAgainst',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionEvidenceFor',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionEvidenceFor',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionEvidenceFor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionEvidenceFor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionEvidenceFor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionEvidenceFor',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionEvidenceForIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionEvidenceFor',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionFollowUpAt',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionFollowUpAt',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionFollowUpAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionFollowUpAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionFollowUpAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionFollowUpAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionFollowUpAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionImpact',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionImpactIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionImpact',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionImpactGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionImpact',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionImpactStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionImpact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionImpactMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionImpact',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionImpactIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionImpact',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionImpactIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionImpact',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionLesson',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionLessonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionLesson',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionLessonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionLesson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionLessonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionLesson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionLessonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionLesson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionLessonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionLesson',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionLessonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionLesson',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflectionReframe',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflectionReframe',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflectionReframe',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflectionReframe',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> reflectionReframeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflectionReframe',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflectionReframe',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      reflectionReframeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflectionReframe',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spotifyTrackIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spotifyTrackIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spotifyTrackIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotifyTrackIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spotifyTrackIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> spotifyTrackIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      spotifyTrackIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotifyTrackIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoKeysOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoKeysOrder',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoKeysOrder',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoKeysOrder',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoKeysOrderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoKeysOrderLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoKeysOrder',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'videoUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'videoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'videoUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'videoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'videoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition>
      videoUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Memory, Memory, QAfterFilterCondition> videoUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'videoUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MemoryQueryObject on QueryBuilder<Memory, Memory, QFilterCondition> {}

extension MemoryQueryLinks on QueryBuilder<Memory, Memory, QFilterCondition> {}

extension MemoryQuerySortBy on QueryBuilder<Memory, Memory, QSortBy> {
  QueryBuilder<Memory, Memory, QAfterSortBy> sortByAmbientSound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ambientSound', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByAmbientSoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ambientSound', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByIsEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAction', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAction', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionActionCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionActionCompleted', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy>
      sortByReflectionActionCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionActionCompleted', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionAutoThought() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAutoThought', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionAutoThoughtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAutoThought', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionEvidenceAgainst() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceAgainst', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy>
      sortByReflectionEvidenceAgainstDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceAgainst', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionEvidenceFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceFor', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionEvidenceForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceFor', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionFollowUpAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionFollowUpAt', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionFollowUpAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionFollowUpAt', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionImpact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionImpact', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionImpactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionImpact', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionLesson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionLesson', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionLessonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionLesson', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionReframe() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionReframe', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByReflectionReframeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionReframe', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MemoryQuerySortThenBy on QueryBuilder<Memory, Memory, QSortThenBy> {
  QueryBuilder<Memory, Memory, QAfterSortBy> thenByAmbientSound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ambientSound', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByAmbientSoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ambientSound', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByFirestoreId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByFirestoreIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firestoreId', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByIsEncryptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEncrypted', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByLastModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModified', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAction', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAction', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionActionCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionActionCompleted', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy>
      thenByReflectionActionCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionActionCompleted', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionAutoThought() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAutoThought', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionAutoThoughtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionAutoThought', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionEvidenceAgainst() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceAgainst', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy>
      thenByReflectionEvidenceAgainstDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceAgainst', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionEvidenceFor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceFor', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionEvidenceForDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionEvidenceFor', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionFollowUpAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionFollowUpAt', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionFollowUpAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionFollowUpAt', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionImpact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionImpact', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionImpactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionImpact', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionLesson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionLesson', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionLessonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionLesson', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionReframe() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionReframe', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByReflectionReframeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflectionReframe', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<Memory, Memory, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MemoryQueryWhereDistinct on QueryBuilder<Memory, Memory, QDistinct> {
  QueryBuilder<Memory, Memory, QDistinct> distinctByAmbientSound(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ambientSound', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByAudioKeysOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioKeysOrder');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByAudioNotePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioNotePaths');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByAudioUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioUrls');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByEmotionsData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emotionsData');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByFirestoreId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firestoreId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByIsEncrypted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEncrypted');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByLastModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModified');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByMediaKeysOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaKeysOrder');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByMediaPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaPaths');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByMediaThumbPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaThumbPaths');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByMediaThumbUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaThumbUrls');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByMediaUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaUrls');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionAction(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionAction',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct>
      distinctByReflectionActionCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionActionCompleted');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionAutoThought(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionAutoThought',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionEvidenceAgainst(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionEvidenceAgainst',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionEvidenceFor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionEvidenceFor',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionFollowUpAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionFollowUpAt');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionImpact(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionImpact',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionLesson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionLesson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByReflectionReframe(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflectionReframe',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctBySpotifyTrackIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spotifyTrackIds');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByVideoKeysOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoKeysOrder');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByVideoPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoPaths');
    });
  }

  QueryBuilder<Memory, Memory, QDistinct> distinctByVideoUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'videoUrls');
    });
  }
}

extension MemoryQueryProperty on QueryBuilder<Memory, Memory, QQueryProperty> {
  QueryBuilder<Memory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> ambientSoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ambientSound');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      audioKeysOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioKeysOrder');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      audioNotePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioNotePaths');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> audioUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioUrls');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<Memory, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> emotionsDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emotionsData');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> firestoreIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firestoreId');
    });
  }

  QueryBuilder<Memory, bool, QQueryOperations> isEncryptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEncrypted');
    });
  }

  QueryBuilder<Memory, DateTime, QQueryOperations> lastModifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModified');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      mediaKeysOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaKeysOrder');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> mediaPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaPaths');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      mediaThumbPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaThumbPaths');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      mediaThumbUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaThumbUrls');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> mediaUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaUrls');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> reflectionActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionAction');
    });
  }

  QueryBuilder<Memory, bool, QQueryOperations>
      reflectionActionCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionActionCompleted');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations>
      reflectionAutoThoughtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionAutoThought');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations>
      reflectionEvidenceAgainstProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionEvidenceAgainst');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations>
      reflectionEvidenceForProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionEvidenceFor');
    });
  }

  QueryBuilder<Memory, DateTime?, QQueryOperations>
      reflectionFollowUpAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionFollowUpAt');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> reflectionImpactProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionImpact');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> reflectionLessonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionLesson');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> reflectionReframeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflectionReframe');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      spotifyTrackIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spotifyTrackIds');
    });
  }

  QueryBuilder<Memory, String, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<Memory, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Memory, String?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations>
      videoKeysOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoKeysOrder');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> videoPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoPaths');
    });
  }

  QueryBuilder<Memory, List<String>, QQueryOperations> videoUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'videoUrls');
    });
  }
}
