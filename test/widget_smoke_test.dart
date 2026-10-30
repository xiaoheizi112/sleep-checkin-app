import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sleep_checkin/data/database.dart';
import 'package:sleep_checkin/logic/badges.dart';
import 'package:sleep_checkin/providers.dart';
import 'package:sleep_checkin/screens/shell.dart';
import 'package:sleep_checkin/theme/app_theme.dart';

class _FakeBadgeChecker implements BadgeChecker {
  @override
  Future<List<BadgeDef>> checkAndUnlock({DateTime? now}) async => const [];
}

void main() {
  testWidgets('三个页面能正常渲染', (tester) async {
    await initializeDateFormatting('zh_CN', null);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime.now();
    final anchor = DateTime(today.year, today.month, today.day);
    final bed = DateTime(anchor.year, anchor.month, anchor.day - 1, 23, 10);
    final wake = DateTime(anchor.year, anchor.month, anchor.day, 7, 10);
    final record = SleepRecord(
      id: 1,
      anchorDate: anchor,
      bedTime: bed,
      wakeTime: wake,
      durationMin: 480,
      quality: 4,
      note: '睡前喝了杯热牛奶',
      dream: '梦见在海边散步',
      isManual: false,
      status: 'complete',
      createdAt: anchor,
      updatedAt: anchor,
    );
    final fixedNow = DateTime(today.year, today.month, today.day, 9, 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordsProvider.overrideWith((ref) => Stream.value([record])),
          settingsProvider
              .overrideWith((ref) => Stream.value(<String, String>{})),
          badgesProvider
              .overrideWith((ref) => Stream.value(<UnlockedBadge>[])),
          badgeServiceProvider.overrideWithValue(_FakeBadgeChecker()),
          clockProvider.overrideWith((ref) => Stream.value(fixedNow)),
        ],
        child: MaterialApp(
          theme: buildDarkTheme(),
          locale: const Locale('zh', 'CN'),
          supportedLocales: const [Locale('zh', 'CN')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ShellScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 首页：已完成今日打卡，概览卡展示统计与早睡进度
    expect(find.text('今日已记录'), findsOneWidget);
    expect(find.text('连续打卡'), findsOneWidget);
    expect(find.text('本周早睡'), findsOneWidget);

    // 统计页：日历与当日详情在首屏
    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();
    expect(find.text('达标'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('梦见在海边散步'), findsOneWidget);

    // 向下滚动查看趋势图、指标与周报
    Future<void> swipeUntilVisible(String text) async {
      for (var i = 0; i < 8; i++) {
        if (find.text(text).evaluate().isNotEmpty) return;
        await tester.dragFrom(const Offset(180, 600), const Offset(0, -350));
        await tester.pumpAndSettle();
      }
    }

    await swipeUntilVisible('睡眠趋势');
    expect(find.text('睡眠趋势'), findsOneWidget);
    await swipeUntilVisible('规律性评分');
    expect(find.text('规律性评分'), findsWidgets);
    await swipeUntilVisible('周报');
    expect(find.text('周报'), findsOneWidget);

    // 我的页：目标设置、徽章墙入口与备份
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('睡眠目标'), findsOneWidget);
    expect(find.text('打卡提醒'), findsOneWidget);
    expect(find.text('徽章墙'), findsOneWidget);
    Future<void> scrollSettingsUntil(String text) async {
      for (var i = 0; i < 6; i++) {
        if (find.text(text).evaluate().isNotEmpty) return;
        await tester.dragFrom(const Offset(180, 600), const Offset(0, -350));
        await tester.pumpAndSettle();
      }
    }

    await scrollSettingsUntil('导出备份');
    expect(find.text('导出备份'), findsOneWidget);
  });
}