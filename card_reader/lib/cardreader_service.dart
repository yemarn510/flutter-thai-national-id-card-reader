import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_pcsc/flutter_pcsc.dart';
import 'package:charset_converter/charset_converter.dart';

const List<int> requestCommand = [0x00, 0xc0, 0x00, 0x00];
const List<int> initialCommand = [0, 164, 4, 0, 8, 160, 0, 0, 0, 84, 72, 0, 1];
const List<int> cidCommand = [0x80, 0xb0, 0x00, 0x04, 0x02, 0x00, 0x0d];
const List<int> thaiNameCommand = [0x80, 0xb0, 0x00, 0x11, 0x02, 0x00, 0x64];
const List<int> englishNameCommand = [0x80, 0xb0, 0x00, 0x75, 0x02, 0x00, 0x64];
const List<int> birthdayCommand = [0x80, 0xb0, 0x00, 0xD9, 0x02, 0x00, 0x08];
const List<int> genderCommand = [0x80, 0xb0, 0x00, 0xE1, 0x02, 0x00, 0x01];
const List<int> issuerCommand = [0x80, 0xb0, 0x00, 0xF6, 0x02, 0x00, 0x64];
const List<int> issueDateCommand = [0x80, 0xb0, 0x01, 0x67, 0x02, 0x00, 0x08];
const List<int> expireDateCommand = [0x80, 0xb0, 0x01, 0x6F, 0x02, 0x00, 0x08];
const List<int> addressCommand = [0x80, 0xb0, 0x15, 0x79, 0x02, 0x00, 0x64];

const Map<String, List<int>> photoCommand = {
  "CMD_PHOTO1": [0x80, 0xb0, 0x01, 0x7B, 0x02, 0x00, 0xFF],
  "CMD_PHOTO2": [0x80, 0xb0, 0x02, 0x7A, 0x02, 0x00, 0xFF],
  "CMD_PHOTO3": [0x80, 0xb0, 0x03, 0x79, 0x02, 0x00, 0xFF],
  "CMD_PHOTO4": [0x80, 0xb0, 0x04, 0x78, 0x02, 0x00, 0xFF],
  "CMD_PHOTO5": [0x80, 0xb0, 0x05, 0x77, 0x02, 0x00, 0xFF],
  "CMD_PHOTO6": [0x80, 0xb0, 0x06, 0x76, 0x02, 0x00, 0xFF],
  "CMD_PHOTO7": [0x80, 0xb0, 0x07, 0x75, 0x02, 0x00, 0xFF],
  "CMD_PHOTO8": [0x80, 0xb0, 0x08, 0x74, 0x02, 0x00, 0xFF],
  "CMD_PHOTO9": [0x80, 0xb0, 0x09, 0x73, 0x02, 0x00, 0xFF],
  "CMD_PHOTO10": [0x80, 0xb0, 0x0A, 0x72, 0x02, 0x00, 0xFF],
  "CMD_PHOTO11": [0x80, 0xb0, 0x0B, 0x71, 0x02, 0x00, 0xFF],
  "CMD_PHOTO12": [0x80, 0xb0, 0x0C, 0x70, 0x02, 0x00, 0xFF],
  "CMD_PHOTO13": [0x80, 0xb0, 0x0D, 0x6F, 0x02, 0x00, 0xFF],
  "CMD_PHOTO14": [0x80, 0xb0, 0x0E, 0x6E, 0x02, 0x00, 0xFF],
  "CMD_PHOTO15": [0x80, 0xb0, 0x0F, 0x6D, 0x02, 0x00, 0xFF],
  "CMD_PHOTO16": [0x80, 0xb0, 0x10, 0x6C, 0x02, 0x00, 0xFF],
  "CMD_PHOTO17": [0x80, 0xb0, 0x11, 0x6B, 0x02, 0x00, 0xFF],
  "CMD_PHOTO18": [0x80, 0xb0, 0x12, 0x6A, 0x02, 0x00, 0xFF],
  "CMD_PHOTO19": [0x80, 0xb0, 0x13, 0x69, 0x02, 0x00, 0xFF],
  "CMD_PHOTO20": [0x80, 0xb0, 0x14, 0x68, 0x02, 0x00, 0xFF]
};

class CardData {
  String cid;
  String thaiName;
  String englishName;
  String birthday;
  String gender;
  String issuer;
  String issueDate;
  String expireDate;
  String address;
  String photo;
  String? base64Photo;

  CardData({
    this.cid = '',
    this.thaiName = '',
    this.englishName = '',
    this.birthday = '',
    this.gender = '',
    this.issuer = '',
    this.issueDate = '',
    this.expireDate = '',
    this.address = '',
    this.photo = '',
  });

  Map<String, String> values() {
    return {
      'cid': cid,
      'thaiName': thaiName,
      'englishName': englishName,
      'birthday': birthday,
      'gender': gender,
      'issuer': issuer,
      'issueDate': issueDate,
      'expireDate': expireDate,
      'address': address,
      'photo': photo,
      'base64Photo': base64Photo ?? '',
    };
  }
}

class CardReaderService {

  Future<CardData> readCard() async {
    int ctx = await Pcsc.establishContext(PcscSCope.user);
    CardStruct? card;

    try {
      List<String> readers = await Pcsc.listReaders(ctx);
      if (readers.isEmpty) {
        throw Exception('Could not detect any reader');
      }
      var reader = readers[0];

      card = await Pcsc.cardConnect(
          ctx, reader, PcscShare.shared, PcscProtocol.any);
      await Pcsc.transmit(card, initialCommand);

      CardData cardData = CardData();

      cardData.cid = await getDataAndChangeToThai(card, cidCommand);
      cardData.thaiName = await getDataAndChangeToThai(card, thaiNameCommand);
      cardData.englishName = await getDataAndChangeToThai(card, englishNameCommand);
      cardData.birthday = convertToThaiDate(await getDataAndChangeToThai(card, birthdayCommand));
      cardData.gender = (await getDataAndChangeToThai(card, genderCommand) == '2') ? 'Female' : 'Male';
      cardData.issuer = await getDataAndChangeToThai(card, issuerCommand);
      cardData.issueDate = convertToThaiDate(await getDataAndChangeToThai(card, issueDateCommand));
      cardData.expireDate = convertToThaiDate(await getDataAndChangeToThai(card, expireDateCommand));
      cardData.address = await getDataAndChangeToThai(card, addressCommand);

      List<int> photos = [];
      for (int index = 1; index < 21; index++) {
        List<int> cmd = photoCommand['CMD_PHOTO${index}'] as List<int>;
        Uint8List responseCommand = await getData(card, cmd);
        for (int eachInt in responseCommand) {
          photos.add(eachInt);
        }
      }
      String base64Image = uint8ListTob64(photos);
      cardData.photo = base64Image.toString();
      cardData.base64Photo = base64DecodeImage(base64Image.toString());

      return cardData;
    } on Exception catch (e) {
      throw Exception(e);
    } finally {
      if (card != null) {
        try {
          await Pcsc.cardDisconnect(card.hCard, PcscDisposition.resetCard);
        } on Exception catch (e) {
          throw Exception(e);
        }
      }
      try {
        await Pcsc.releaseContext(ctx);
      } on Exception catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<Uint8List> getData(CardStruct card, List<int> command) async {
    List<int> response = requestCommand + [command[command.length - 1]];
    await Pcsc.transmit(card, command);
    List<int> responseCommand = await Pcsc.transmit(card, response);

    return responseCommand.sublist(0, responseCommand.length - 2) as Uint8List;
  }

  String convertToThaiDate(String dateString) {
    String year = dateString.substring(0, 4);
    String month = dateString.substring(4, 6);
    String day = dateString.substring(6, 8);

    return '$day/$month/$year';
  }


  String uint8ListTob64(List<int> photosInt) {
    String base64String = base64Encode(photosInt);
    String header = "data:image/png;base64,";
    return header + base64String;
  }

  Future<String> convertToThai(List<int> sequence) async {
    String decoded = await CharsetConverter.decode(
        "iso-8859-11", Uint8List.fromList(sequence));
    return decoded.replaceAll("#", " ").replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<String> getDataAndChangeToThai(CardStruct card, List<int> cmd) async {
    Uint8List value = await getData(card, cmd);
    return convertToThai(value);
  }

  String base64DecodeImage(String base64Image) {
    final regex = RegExp(r'^data:image/[^;]+;base64,');
    return base64Image.replaceAll(regex, '');
  }
}