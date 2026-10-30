/// Layout classes by available width (decision D-003). Widgets pick their
/// structure with `LayoutBuilder`, never by operating system.
class Breakpoints {
  const Breakpoints._();

  /// At or above this width the desktop layout is used.
  static const double desktop = 800;

  static bool isDesktop(double width) => width >= desktop;
}
