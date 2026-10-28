import 'package:flutter/material.dart';

/// موقع المستخدم اللي حدده يدوياً على الخريطة.
/// القيمة نسبة من عرض وارتفاع الخريطة (x و y من 0 لـ 1)، أو null إذا ما تحدد.
final ValueNotifier<Offset?> userLocationNotifier =
    ValueNotifier<Offset?>(null);

/// true = الخريطة بوضع "حدد مكانك": الضغط على أي نقطة بيثبّت موقعك فيها.
final ValueNotifier<bool> pickLocationMode = ValueNotifier<bool>(false);