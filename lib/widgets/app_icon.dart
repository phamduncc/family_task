import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static const String home = 'assets/icons/home.svg';
  static const String task = 'assets/icons/task.svg';
  static const String check = 'assets/icons/check.svg';
  static const String hourglass = 'assets/icons/hourglass.svg';
  static const String star = 'assets/icons/star.svg';
  static const String refresh = 'assets/icons/refresh.svg';
  static const String timer = 'assets/icons/timer.svg';
  static const String calendar = 'assets/icons/calendar.svg';
  static const String joystick = 'assets/icons/joystick.svg';
  static const String trophy = 'assets/icons/trophy.svg';
  static const String medal = 'assets/icons/medal.svg';
  static const String medalSilver = 'assets/icons/medal (1).svg';
  static const String medalBronze = 'assets/icons/medal (2).svg';
  static const String pizza = 'assets/icons/pizza.svg';
  static const String playground = 'assets/icons/playground.svg';
  static const String videoPlayer = 'assets/icons/video-player.svg';
  static const String happy = 'assets/icons/happy.svg';
  static const String cancan = 'assets/icons/cancan.svg';
  static const String meditation = 'assets/icons/meditation.svg';
  static const String father = 'assets/icons/father.svg';
  static const String mother = 'assets/icons/mother.svg';
  static const String boy = 'assets/icons/boy.svg';
  static const String woman = 'assets/icons/woman.svg';
  static const String grandfather = 'assets/icons/grandfather.svg';
  static const String oldWoman = 'assets/icons/old-woman.svg';
  static const String kitty = 'assets/icons/kitty.svg';

  static const Map<String, String> _keyMap = {
    'home': home,
    'task': task,
    'check': check,
    'hourglass': hourglass,
    'star': star,
    'refresh': refresh,
    'timer': timer,
    'calendar': calendar,
    'joystick': joystick,
    'trophy': trophy,
    'medal': medal,
    'medal_1': medalSilver,
    'medal_2': medalBronze,
    'pizza': pizza,
    'playground': playground,
    'video_player': videoPlayer,
    'happy': happy,
    'cancan': cancan,
    'meditation': meditation,
    'father': father,
    'mother': mother,
    'boy': boy,
    'woman': woman,
    'grandfather': grandfather,
    'old_woman': oldWoman,
    'kitty': kitty,
  };

  static String? pathForKey(String key) => _keyMap[key];
  static bool isValidKey(String key) => _keyMap.containsKey(key);

  static const List<String> memberAvatarKeys = [
    'father',
    'mother',
    'boy',
    'woman',
    'grandfather',
    'old_woman',
    'kitty',
    'meditation',
  ];

  static const Map<String, String> memberAvatarLabels = {
    'father': 'Bố',
    'mother': 'Mẹ',
    'boy': 'Bé trai',
    'woman': 'Bé gái',
    'grandfather': 'Ông',
    'old_woman': 'Bà',
    'kitty': 'Mèo',
    'meditation': 'Khác',
  };

  static const List<String> rewardIconKeys = [
    'cancan',
    'video_player',
    'playground',
    'pizza',
    'trophy',
    'star',
    'joystick',
    'happy',
    'calendar',
    'home',
  ];
}

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const SvgIcon(this.assetPath, {super.key, this.size = 24.0, this.color});

  factory SvgIcon.fromKey(String iconKey,
      {Key? key, double size = 24.0, Color? color}) {
    final path = AppIcons.pathForKey(iconKey) ?? AppIcons.task;
    return SvgIcon(path, key: key, size: size, color: color);
  }

  static Widget auto(String keyOrFallback, {double size = 24.0, Color? color}) {
    if (AppIcons.isValidKey(keyOrFallback)) {
      return SvgIcon.fromKey(keyOrFallback, size: size, color: color);
    }
    return SvgIcon(AppIcons.task, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final String avatarKey;
  final double size;
  final Color? backgroundColor;

  const MemberAvatar({
    super.key,
    required this.avatarKey,
    this.size = 48.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final path = AppIcons.pathForKey(avatarKey) ?? AppIcons.father;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFF6B6B).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: SvgPicture.asset(path),
    );
  }
}
