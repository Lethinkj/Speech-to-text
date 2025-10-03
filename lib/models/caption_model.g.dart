// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caption_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaptionModelAdapter extends TypeAdapter<CaptionModel> {
  @override
  final int typeId = 0;

  @override
  CaptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaptionModel(
      text: fields[0] as String,
      originalText: fields[1] as String?,
      language: fields[2] as String,
      confidence: fields[3] as double,
      timestamp: fields[4] as DateTime,
      isSimplified: fields[5] as bool,
      hasPictograms: fields[6] as bool,
      pictograms: (fields[7] as List).cast<String>(),
      metadata: (fields[8] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CaptionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.originalText)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.confidence)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isSimplified)
      ..writeByte(6)
      ..write(obj.hasPictograms)
      ..writeByte(7)
      ..write(obj.pictograms)
      ..writeByte(8)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
