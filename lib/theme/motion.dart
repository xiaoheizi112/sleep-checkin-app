import 'package:flutter/material.dart';

/// 系统开启"减少动态效果"时返回零时长，否则返回指定毫秒数。
Duration appMotion(BuildContext context, int milliseconds) {
  final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return reduce ? Duration.zero : Duration(milliseconds: milliseconds);
}