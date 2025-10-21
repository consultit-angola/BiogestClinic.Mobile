import 'index.dart';

class RoomDTO {
  final int id;
  final String name;
  final StoreDTO store;
  final bool deleted;
  final RoomTypeDTO type;
  final ExtendedDataDTO extendedData;
  final List<BroadcastChannelDTO> broadcastChannels;
  final String deletedAsString;
  final String nameAndType;
  final List<StockDTO> consumptionStocks;
  final StockDTO warehouseStock;
  final StockDTO salesStock;
  final int code;
  final String description;

  RoomDTO({
    required this.id,
    required this.name,
    required this.store,
    required this.deleted,
    required this.type,
    required this.extendedData,
    required this.broadcastChannels,
    required this.deletedAsString,
    required this.nameAndType,
    required this.consumptionStocks,
    required this.warehouseStock,
    required this.salesStock,
    required this.code,
    required this.description,
  });

  factory RoomDTO.fromJson(Map<String, dynamic> json) => RoomDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    store: StoreDTO.fromJson(json['Store'] ?? {}),
    deleted: json['Deleted'] ?? false,
    type: RoomTypeDTO.fromJson(json['Type'] ?? {}),
    extendedData: ExtendedDataDTO.fromJson(json['ExtendedData'] ?? {}),
    broadcastChannels:
        (json['BroadcastChannels'] as List<dynamic>?)
            ?.map((e) => BroadcastChannelDTO.fromJson(e))
            .toList() ??
        [],
    deletedAsString: json['DeletedAsString'] ?? '',
    nameAndType: json['NameAndType'] ?? '',
    consumptionStocks:
        (json['ConsumptionStocks'] as List<dynamic>?)
            ?.map((e) => StockDTO.fromJson(e))
            .toList() ??
        [],
    warehouseStock: StockDTO.fromJson(json['WarehouseStock'] ?? {}),
    salesStock: StockDTO.fromJson(json['SalesStock'] ?? {}),
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Store': store.toJson(),
    'Deleted': deleted,
    'Type': type.toJson(),
    'ExtendedData': extendedData.toJson(),
    'BroadcastChannels': broadcastChannels.map((e) => e.toJson()).toList(),
    'DeletedAsString': deletedAsString,
    'NameAndType': nameAndType,
    'ConsumptionStocks': consumptionStocks.map((e) => e.toJson()).toList(),
    'WarehouseStock': warehouseStock.toJson(),
    'SalesStock': salesStock.toJson(),
    'Code': code,
    'Description': description,
  };
}

class RoomTypeDTO {
  final int id;
  final String name;
  final int enumValue;
  final int code;
  final String description;
  final bool deleted;

  RoomTypeDTO({
    required this.id,
    required this.name,
    required this.enumValue,
    required this.code,
    required this.description,
    required this.deleted,
  });

  factory RoomTypeDTO.fromJson(Map<String, dynamic> json) => RoomTypeDTO(
    id: json['ID'] ?? 0,
    name: json['Name'] ?? '',
    enumValue: json['Enum'] ?? 0,
    code: json['Code'] ?? 0,
    description: json['Description'] ?? '',
    deleted: json['Deleted'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Name': name,
    'Enum': enumValue,
    'Code': code,
    'Description': description,
    'Deleted': deleted,
  };
}
