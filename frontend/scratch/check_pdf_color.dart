import 'package:pdf/pdf.dart';

void main() {
  final color = PdfColor.fromInt(0xFFF8F8F8);
  print('Red: ${color.red}');
  print('Green: ${color.green}');
  print('Blue: ${color.blue}');
}
