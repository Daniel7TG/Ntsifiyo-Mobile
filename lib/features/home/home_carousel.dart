import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/palette.dart';
import '../../app/theme.dart';
import '../../shared/widgets/kid_card.dart';

class HomeSuggestion {
  final String id, badge, title, subtitle, action, image;
  final Color color;
  final VoidCallback onTap;
  const HomeSuggestion({
    required this.id,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.image,
    required this.color,
    required this.onTap,
  });
}

class HomeCarousel extends StatefulWidget {
  final List<HomeSuggestion> items;
  final bool visible;
  const HomeCarousel({super.key, required this.items, this.visible = true});
  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  Timer? _timer;
  GoRouter? _router;
  int _index = 0, _next = 0;
  bool _paused = false, _foreground = true;
  bool get _allowed =>
      !_paused &&
      _foreground &&
      widget.visible &&
      !MediaQuery.of(context).disableAnimations &&
      (_router?.routeInformationProvider.value.uri.path == '/inicio');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
    _motion =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1150),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            // Restablecer el valor antes de cambiar la tarjeta evita que un
            // frame pinte el fondo de la tarjeta saliente con el índice nuevo.
            // Ese frame era el destello de color que se veía al aterrizar.
            _motion.stop(canceled: false);
            _motion.value = 0;
            setState(() {
              _index = _next;
            });
            _schedule();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (_router != router) {
      _router?.routeInformationProvider.removeListener(_routeChanged);
      _router = router;
      router.routeInformationProvider.addListener(_routeChanged);
    }
    _schedule();
  }

  void _fontsChanged() {
    if (mounted) setState(() {});
  }

  void _routeChanged() {
    if (!mounted) return;
    if (_router?.routeInformationProvider.value.uri.path != '/inicio') {
      _motion.reset();
    }
    _schedule();
  }

  @override
  void didUpdateWidget(HomeCarousel old) {
    super.didUpdateWidget(old);
    if (old.items.map((e) => e.id).join('|') !=
        widget.items.map((e) => e.id).join('|')) {
      final id = old.items.isEmpty
          ? ''
          : old.items[_index.clamp(0, old.items.length - 1)].id;
      _index = widget.items.indexWhere((e) => e.id == id);
      if (_index < 0) _index = 0;
      _motion.reset();
    }
    if (!widget.visible) _motion.reset();
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _motion.reset();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (_allowed && !_motion.isAnimating && widget.items.length > 1) {
      _timer = Timer(const Duration(milliseconds: 4800), () => _go(_index + 1));
    }
  }

  void _go(int index) {
    if (_motion.isAnimating || widget.items.length < 2) return;
    _timer?.cancel();
    _next = index % widget.items.length;
    if (_next == _index) {
      _schedule();
      return;
    }
    if (MediaQuery.of(context).disableAnimations) {
      setState(() => _index = _next);
      return;
    }
    _motion.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    _router?.routeInformationProvider.removeListener(_routeChanged);
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final copyWidth = ((constraints.maxWidth - 12) * .64 - 18).clamp(
          40.0,
          double.infinity,
        );
        double measure(
          String text,
          TextStyle style,
          double width, {
          int? maxLines,
        }) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: DefaultTextStyle.of(context).style.merge(style),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: maxLines,
            ellipsis: maxLines == null ? null : '…',
          )..layout(maxWidth: width);
          final height = painter.height;
          painter.dispose();
          return height;
        }

        var height = 224.0;
        for (final item in widget.items) {
          final needed =
              90 +
              measure(item.badge, _badgeStyle, copyWidth) +
              measure(item.title, _titleStyle, copyWidth, maxLines: 3) +
              measure(item.subtitle, _subtitleStyle, copyWidth, maxLines: 3) +
              measure(item.action, _actionStyle, copyWidth - 42);
          if (needed > height) height = needed;
        }
        return Column(
          children: [
            GestureDetector(
              onHorizontalDragEnd: (d) {
                if ((d.primaryVelocity ?? 0).abs() > 100) {
                  _go(_index + ((d.primaryVelocity ?? 0) < 0 ? 1 : -1));
                }
              },
              child: ClipRect(
                child: SizedBox(
                  height: height,
                  child: AnimatedBuilder(
                    animation: _motion,
                    builder: (context, _) {
                      final t = _motion.value;
                      final outgoing = t < .28
                          ? .065 * Curves.easeOut.transform(t / .28)
                          : .065 -
                                1.27 *
                                    Curves.easeInCubic.transform(
                                      ((t - .28) / .46).clamp(0, 1),
                                    );
                      final incoming =
                          1.15 *
                          (1 -
                              Curves.easeOutBack.transform(
                                ((t - .365) / .635).clamp(0, 1),
                              ));
                      Widget card(int i, double x) => FractionalTranslation(
                        translation: Offset(x, 0),
                        child: _SuggestionCard(item: widget.items[i]),
                      );
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          IgnorePointer(
                            ignoring: _motion.isAnimating,
                            child: card(_index, outgoing),
                          ),
                          if (_motion.isAnimating)
                            ExcludeSemantics(
                              child: IgnorePointer(
                                child: card(_next, incoming),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Tarjeta anterior',
                  onPressed: () => _go(_index - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                for (var i = 0; i < widget.items.length; i++)
                  SizedBox(
                    width: 24,
                    height: 44,
                    child: Semantics(
                      selected: i == _index,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: '${i + 1}: ${widget.items[i].title}',
                        onPressed: () => _go(i),
                        icon: Icon(
                          Icons.circle,
                          size: i == _index ? 10 : 6,
                          color: i == _index
                              ? adaptBrand(context, AppColors.primary)
                              : context.palette.border,
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: _paused ? 'Reanudar recorrido' : 'Pausar recorrido',
                  onPressed: () {
                    setState(() => _paused = !_paused);
                    _schedule();
                  },
                  icon: Icon(
                    _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                ),
                IconButton(
                  tooltip: 'Siguiente tarjeta',
                  onPressed: () => _go(_index + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

const _badgeStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w800,
  letterSpacing: .5,
);
const _titleStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  fontWeight: FontWeight.w800,
  height: 1.15,
);
const _subtitleStyle = TextStyle(fontSize: 11);
const _actionStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w800);

class _SuggestionCard extends StatelessWidget {
  final HomeSuggestion item;
  const _SuggestionCard({required this.item});
  @override
  Widget build(BuildContext context) {
    final accent = adaptBrand(context, item.color);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
      child: KidCard(
        accentColor: item.color,
        padding: EdgeInsets.zero,
        onTap: item.onTap,
        semanticLabel: '${item.badge}. ${item.title}. ${item.action}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card - 4),
          child: ColoredBox(
            color: accent.withValues(alpha: .12),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  top: 48,
                  width: MediaQuery.sizeOf(context).width * .29,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(72),
                    ),
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: .64,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 4, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.badge,
                          style: _badgeStyle.copyWith(color: accent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _titleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _subtitleStyle.copyWith(
                            color: context.palette.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(
                              AppRadius.input,
                            ),
                          ),
                          child: DefaultTextStyle(
                            style: DefaultTextStyle.of(context).style.merge(
                              _actionStyle.copyWith(
                                color:
                                    ThemeData.estimateBrightnessForColor(
                                          accent,
                                        ) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text(item.action)),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 14,
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            accent,
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
