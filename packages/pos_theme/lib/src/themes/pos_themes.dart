import 'corporate_blue.dart';
import 'emerald_fresh.dart';
import 'midnight_pro.dart';
import 'monochrome_minimal.dart';
import 'pos_theme_spec.dart';
import 'warm_terracotta.dart';

/// Registry of all bundled themes.
abstract final class PosThemes {
  static const PosThemeSpec corporateBlue = corporateBlueSpec;
  static const PosThemeSpec midnightPro = midnightProSpec;
  static const PosThemeSpec emeraldFresh = emeraldFreshSpec;
  static const PosThemeSpec warmTerracotta = warmTerracottaSpec;
  static const PosThemeSpec monochromeMinimal = monochromeMinimalSpec;

  static const List<PosThemeSpec> all = [corporateBlue, midnightPro, emeraldFresh, warmTerracotta, monochromeMinimal];

  static PosThemeSpec byId(String? id) => all.firstWhere((t) => t.id == id, orElse: () => corporateBlue);
}
