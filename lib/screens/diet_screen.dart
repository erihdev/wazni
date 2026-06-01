import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wazni/theme/app_theme.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionTitle('🍽️ خطة يوم صحي'),
              _mealCard(
                icon: '🌅',
                time: 'الإفطار — 7 إلى 8 صباحاً',
                name: 'إفطار القوة 💪',
                items: [
                  '🥚 بيضتان مسلوقتان أو مقليتان',
                  '🍞 شريحة خبز توست أسمر',
                  '🍅 طماطم وخيار طازج',
                  '🥛 كوب حليب قليل الدسم',
                ],
                color: const Color(0xFFFA8231),
              ),
              _mealCard(
                icon: '🍎',
                time: 'وجبة خفيفة — 10 صباحاً',
                name: 'وجبة الطاقة 🍎',
                items: [
                  '🍎 تفاحة أو موزة متوسطة',
                  '🥜 10–12 حبة لوز',
                  '💧 كوب ماء مع ليمون',
                ],
                color: const Color(0xFF43E97B),
              ),
              _mealCard(
                icon: '☀️',
                time: 'الغداء — 12 إلى 1 ظهراً',
                name: 'غداء البطلة 🥗',
                items: [
                  '🍗 نصف صدر دجاج مشوي',
                  '🍚 كوب أرز بكمية معتدلة',
                  '🥦 خضار مسلوقة أو سلطة',
                  '🍋 عصير ليمون طازج',
                ],
                color: WazniTheme.brand,
              ),
              _mealCard(
                icon: '🍓',
                time: 'وجبة خفيفة — 4 عصراً',
                name: 'وجبة ما بعد التمرين 🥤',
                items: [
                  '🫐 كوب فواكه مشكلة',
                  '🥛 لبن زبادي قليل الدسم',
                  '🍯 ملعقة عسل (اختياري)',
                ],
                color: const Color(0xFFC44DFF),
              ),
              _mealCard(
                icon: '🌙',
                time: 'العشاء — 7 إلى 8 مساءً',
                name: 'عشاء خفيف 🌙',
                items: [
                  '🥗 سلطة كبيرة متنوعة',
                  '🐟 قطعة سمك مشوية أو تونة',
                  '🍞 شريحة خبز أسمر',
                  '💧 ماء أو شاي أخضر',
                ],
                color: const Color(0xFF6C63FF),
              ),

              _sectionTitle('❌ تجنبي هذه الأطعمة'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚫 ابتعدي عنها',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w900,
                          color: WazniTheme.red,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...['🥤 المشروبات الغازية والعصائر المعلبة',
                          '🍟 البطاطس المقلية والأطعمة المقلية',
                          '🍫 الحلوى والشوكولاتة بكميات كبيرة',
                          '🍕 الفطائر والبيتزا يومياً',
                          '🌙 الأكل بعد الساعة 9 مساءً'].map((item) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: WazniTheme.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item, style: GoogleFonts.tajawal(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _sectionTitle('💧 الماء صديقتكِ الأولى'),
              Card(
                color: WazniTheme.brand.withValues(alpha: 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: WazniTheme.brand.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💧 اشربي 6–8 أكواب ماء يومياً',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w800,
                          color: WazniTheme.brand,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'كوب قبل كل وجبة يساعدكِ على الشبع أسرع!\nالماء يساعد في حرق الدهون وتنظيف الجسم.',
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: WazniTheme.inkMuted,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                color: WazniTheme.green.withValues(alpha: 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: WazniTheme.green.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '🌟 قاعدة ذهبية: لا تجوعي نفسكِ أبداً! كلي ببطء وتوقفي حين تشبعين. جسمكِ يستحق أفضل وقود! 💚',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: WazniTheme.green,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
    child: Text(
      t,
      style: GoogleFonts.tajawal(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: WazniTheme.ink,
      ),
    ),
  );

  Widget _mealCard({
    required String icon,
    required String time,
    required String name,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      name,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: WazniTheme.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: WazniTheme.border, height: 1),
            const SizedBox(height: 10),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                item,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: WazniTheme.inkMuted,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
