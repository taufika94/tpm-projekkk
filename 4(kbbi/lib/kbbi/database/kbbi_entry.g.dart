// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kbbi_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KbbiEntryAdapter extends TypeAdapter<KbbiEntry> {
  @override
  final int typeId = 0;

  @override
  KbbiEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KbbiEntry(
      word: fields[0] as String,
      type: fields[1] as String?,
      lema: fields[2] as String?,
      arti: (fields[3] as List?)?.cast<Arti>(),
      tesaurusLink: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KbbiEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.lema)
      ..writeByte(3)
      ..write(obj.arti)
      ..writeByte(4)
      ..write(obj.tesaurusLink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KbbiEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArtiAdapter extends TypeAdapter<Arti> {
  @override
  final int typeId = 1;

  @override
  Arti read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Arti(
      deskripsi: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Arti obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.deskripsi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
