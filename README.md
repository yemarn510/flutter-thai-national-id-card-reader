# Flutter Thai National ID Card Reader

This is an example for reading <b>Thai National ID Card</b> using PCSC reader.

The service is provided in `CardReaderService` class.
The example is provided in `main.dart` file.
Program was tested on Windows 11.

The card reader device is [EZ100PU Smart Card Reader](https://www.castlestech.com/products/ez100-series/).
The driver for the device is downloaded from [here](https://www.castlestech.com/zh-hant/%e6%aa%94%e6%a1%88%e4%b8%8b%e8%bc%89/).

this example used two flutter packages.
[flutter_pcsc: ^0.0.4](https://pub.dev/packages/flutter_pcsc)
[charset_converter: ^2.1.1](https://pub.dev/packages/charset_converter)

This example was written referenced on this [bouroo's python snippet](https://gist.github.com/bouroo/8b34daf5b7deed57ea54819ff7aeef6e) and [pstudiodev1's repo](https://github.com/pstudiodev1/lab-python3-th-idcard)

![Screenshot](card_reader/assets/Screenshot%202566-07-07%20at%205.00.13%20PM.png)
