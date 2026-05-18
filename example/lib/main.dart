import 'package:flutter/material.dart';
import 'package:stories/stories.dart';

void main() {
  runApp(const StoriesExampleApp());
}

class StoriesExampleApp extends StatefulWidget {
  const StoriesExampleApp({super.key});

  @override
  State<StoriesExampleApp> createState() => _StoriesExampleAppState();
}

class _StoriesExampleAppState extends State<StoriesExampleApp> {
  bool _rtl = false;
  late List<StoryUser> _users;
  StoryItemTransition _storyTransition = StoryItemTransition.slide;
  StoryUserTransition _userTransition = StoryUserTransition.cube;

  @override
  void initState() {
    super.initState();
    _users = _demoUsers();
  }

  StoriesThemeData get _theme => StoriesThemeData.light.copyWith(
        trayAvatarSize: 72,
        ringWidth: 3,
        unseenRingGradient: const LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFF77737)],
        ),
        defaultStoryDuration: const Duration(seconds: 4),
        progressBarHeight: 3,
        addStoryLabel: 'Add',
        addButtonColor: Colors.purple,
        storyItemTransition: _storyTransition,
        userTransition: _userTransition,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stories Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        extensions: [_theme],
      ),
      builder: (context, child) {
        return StoriesScope(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          theme: _theme,
          child: child!,

        );
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stories'),
          actions: [
            TextButton(
              onPressed: () => setState(() => _rtl = !_rtl),
              child: Text(_rtl ? 'RTL' : 'LTR'),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Story slide transition'),
                  const SizedBox(height: 4),
                  _TransitionChips<StoryItemTransition>(
                    value: _storyTransition,
                    labels: const {
                      StoryItemTransition.none: 'None',
                      StoryItemTransition.fade: 'Fade',
                      StoryItemTransition.slide: 'Slide',
                      StoryItemTransition.slideVertical: 'Vertical',
                      StoryItemTransition.scale: 'Scale',
                      StoryItemTransition.zoom: 'Zoom',
                    },
                    onChanged: (v) => setState(() => _storyTransition = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('User transition'),
                  const SizedBox(height: 4),
                  _TransitionChips<StoryUserTransition>(
                    value: _userTransition,
                    labels: const {
                      StoryUserTransition.page: 'Page',
                      StoryUserTransition.fade: 'Fade',
                      StoryUserTransition.scale: 'Scale',
                      StoryUserTransition.cube: 'Cube',
                      StoryUserTransition.slideVertical: 'Vertical',
                    },
                    onChanged: (v) => setState(() => _userTransition = v),
                  ),
                ],
              ),
            ),
            StoriesPanel(
              users: _users,
              showAddButton: true,
              onAddStoryTap: () {},
              onUsersChanged: (users) => setState(() => _users = users),
              storyItemTransition: _storyTransition,
              userTransition: _userTransition,
            ),
            const Expanded(
              child: Center(child: Text('Feed content below stories tray')),
            ),
          ],
        ),
      ),
    );
  }

  List<StoryUser> _demoUsers() {
    const colors = [
      Color(0xFF6C5CE7),
      Color(0xFF00B894),
      Color(0xFFE17055),
      Color(0xFF0984E3),
      Color(0xFFFDCB6E),
    ];

    return List.generate(6, (i) {
      return StoryUser(
        id: 'user_$i',
        name: 'User ${i + 1}',
        seen: i.isEven,
        stories: List.generate(3, (j) {
          final color = colors[(i + j) % colors.length];
          return StoryItem.widget(
            ColoredBox(
              color: color,
              child: Center(
                child: Text(
                  'User ${i + 1} · Story ${j + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: 'User ${i + 1}',
            subtitle: 'Story ${j + 1}',
            caption: j == 1 ? 'Bottom caption' : null,
          );
        }),
      );
    });
  }
}

class _TransitionChips<T> extends StatelessWidget {
  const _TransitionChips({
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.entries.map((e) {
          final selected = e.key == value;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: ChoiceChip(
              label: Text(e.value),
              selected: selected,
              onSelected: (_) => onChanged(e.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
