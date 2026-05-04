// AgriGate color tokens — mapped directly from the React app's design constants.

import 'package:flutter/material.dart';

abstract final class AgriColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFEBE9E0);
  static const Color backgroundAlt = Color(0xFFDCD9CC);
  static const Color card = Color(0xFFFFFFFF);

  // ── Forest (dark panels / hero) ──────────────────────────────────────────
  static const Color forest = Color(0xFF1E2823);
  static const Color forestDeep = Color(0xFF141A16);

  // ── Lime (CTAs / highlights) ─────────────────────────────────────────────
  static const Color lime = Color(0xFFC8F04D);
  static const Color limeDark = Color(0xFFA9D12D);

  // ── Ink (text) ───────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF1C2620);
  static const Color inkSoft = Color(0xFF4A5450);
  static const Color inkMuted = Color(0xFF6B736E);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border = Color(0x141C2620);         // rgba(28,38,32, 0.08)
  static const Color borderStrong = Color(0x281C2620);   // rgba(28,38,32, 0.16)

  // ── Status colors ────────────────────────────────────────────────────────
  static const Color statusAktifBg = lime;
  static const Color statusAktifText = ink;

  static const Color statusPerencanaanBg = Color(0xFFFCE6B8);
  static const Color statusPerencanaanText = Color(0xFF5C4015);

  static const Color statusTidakAktifBg = Color(0xFFDCD9CC);
  static const Color statusTidakAktifText = Color(0xFF3A3830);

  // ── pH label colors ──────────────────────────────────────────────────────
  static const Color phSangatAsamBg = Color(0xFFFDE7E7);
  static const Color phSangatAsamText = Color(0xFF7A1818);

  static const Color phAsamBg = Color(0xFFFCE8D8);
  static const Color phAsamText = Color(0xFF7A3A12);

  static const Color phNetralBg = Color(0xFFE8F5D4);
  static const Color phNetralText = Color(0xFF2E4A14);

  static const Color phBasaRinganBg = Color(0xFFD8E8FA);
  static const Color phBasaRinganText = Color(0xFF1A3A72);

  static const Color phBasaBg = Color(0xFFE3DCFA);
  static const Color phBasaText = Color(0xFF3A1D72);

  // ── Moisture label colors ────────────────────────────────────────────────
  static const Color moistureRendahBg = Color(0xFFFCEFD6);
  static const Color moistureRendahText = Color(0xFF7A4A0A);

  static const Color moistureSedangBg = Color(0xFFEAF2DA);
  static const Color moistureSedangText = Color(0xFF3A4A14);

  static const Color moistureCukupBg = Color(0xFFDCECDC);
  static const Color moistureCukupText = Color(0xFF1F4A2A);

  static const Color moistureTinggiBg = Color(0xFFD6ECF2);
  static const Color moistureTinggiText = Color(0xFF0E4F5E);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD4183D);
  static const Color onError = Colors.white;
  static const Color surface = card;
  static const Color onSurface = ink;
}
