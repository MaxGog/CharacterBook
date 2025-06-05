import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/character_model.dart';

class CharacterQRService {
  static Widget generateQRCode(Character character, {double size = 200}) {
    final data = _serializeCharacter(character);
    return SizedBox(
      width: size,
      height: size,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        embeddedImage: character.imageBytes != null
            ? MemoryImage(character.imageBytes!)
            : null,
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(size * 0.25, size * 0.25),
        ),
      ),
    );
  }

  static String _serializeCharacter(Character character) {
    final json = character.toJson();
    json.remove('imageBytes');
    json.remove('referenceImageBytes');
    json.remove('additionalImages');
    final jsonString = jsonEncode(json);
    return base64Url.encode(utf8.encode(jsonString));
  }

  static Character? deserializeCharacter(String data) {
    try {
      final decoded = utf8.decode(base64Url.decode(data));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return Character.fromJson(json);
    } catch (e) {
      debugPrint('Error deserializing character: $e');
      return null;
    }
  }

  static String generateCharacterHash(Character character) {
    final jsonString = jsonEncode(character.toJson());
    return sha256.convert(utf8.encode(jsonString)).toString();
  }
}

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  final MobileScannerController controller = MobileScannerController();

  QRScannerBloc() : super(QRScannerInitial()) {
    on<ScanQRCode>((event, emit) async {
      emit(QRScannerLoading());
      try {
        final Character? character = CharacterQRService.deserializeCharacter(event.data);
        if (character != null) {
          emit(QRScannerSuccess(character));
        } else {
          emit(QRScannerFailure('Invalid character data'));
        }
      } catch (e) {
        emit(QRScannerFailure(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}

abstract class QRScannerEvent {}
class ScanQRCode extends QRScannerEvent {
  final String data;
  ScanQRCode(this.data);
}

abstract class QRScannerState {}
class QRScannerInitial extends QRScannerState {}
class QRScannerLoading extends QRScannerState {}
class QRScannerSuccess extends QRScannerState {
  final Character character;
  QRScannerSuccess(this.character);
}
class QRScannerFailure extends QRScannerState {
  final String error;
  QRScannerFailure(this.error);
}

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Character QR Code')),
      body: BlocProvider(
        create: (context) => QRScannerBloc(),
        child: BlocConsumer<QRScannerBloc, QRScannerState>(
          listener: (context, state) {
            if (state is QRScannerSuccess) {
              Navigator.pop(context, state.character);
            } else if (state is QRScannerFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
          builder: (context, state) {
            final bloc = context.read<QRScannerBloc>();
            return Stack(
              children: [
                MobileScanner(
                  controller: bloc.controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      bloc.add(ScanQRCode(barcode.rawValue ?? ''));
                    }
                  },
                ),
                if (state is QRScannerLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}