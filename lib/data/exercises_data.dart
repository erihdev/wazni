class Exercise {
  final String name;
  final String icon;
  final int duration; // seconds per round
  final int rounds;
  final int rest; // seconds rest between rounds
  final String type; // cardio | abs | lower | upper | stretch
  final String desc;
  final List<String> zones;

  const Exercise({
    required this.name,
    required this.icon,
    required this.duration,
    required this.rounds,
    required this.rest,
    required this.type,
    required this.desc,
    required this.zones,
  });
}

const kExercises = <Exercise>[
  // ─── CARDIO ───
  Exercise(name: 'الجري في المكان',     icon: '🏃', duration: 30, rounds: 3, rest: 15, type: 'cardio', desc: 'ارفعي ركبتيكِ عالياً بسرعة مناسبة', zones: ['full', 'calves']),
  Exercise(name: 'رقصة الطاقة',        icon: '💃', duration: 40, rounds: 3, rest: 20, type: 'cardio', desc: 'تحركي بحرية مع أغنية مفضّلة!', zones: ['full']),
  Exercise(name: 'القفز النجمة',        icon: '🦘', duration: 20, rounds: 3, rest: 15, type: 'cardio', desc: 'افتحي يديكِ وساقيكِ معاً وثبي!', zones: ['full', 'calves']),
  Exercise(name: 'التخطي الوهمي',      icon: '🪢', duration: 30, rounds: 3, rest: 15, type: 'cardio', desc: 'تظاهري بتخطي حبل — استمري بسرعة!', zones: ['calves', 'full']),
  Exercise(name: 'التسلق الجانبي',     icon: '🧗', duration: 30, rounds: 3, rest: 20, type: 'cardio', desc: 'على يديكِ وركبتيكِ — حرّكي ساقيكِ بسرعة', zones: ['belly', 'arms', 'full']),
  Exercise(name: 'المشي السريع',       icon: '🚶', duration: 40, rounds: 3, rest: 20, type: 'cardio', desc: 'تحرّكي بسرعة في غرفتكِ ذهاباً وإياباً!', zones: ['full', 'calves']),
  // ─── ABS ───
  Exercise(name: 'الكرنش العادي',      icon: '🎽', duration: 30, rounds: 3, rest: 20, type: 'abs', desc: 'استلقي وارفعي كتفيكِ للأمام 15 مرة', zones: ['belly']),
  Exercise(name: 'رفع الساقين',       icon: '🦵', duration: 25, rounds: 3, rest: 20, type: 'abs', desc: 'استلقي وارفعي ساقيكِ معاً للأعلى', zones: ['belly', 'lowerabs']),
  Exercise(name: 'البلانك',            icon: '🏋️', duration: 20, rounds: 3, rest: 20, type: 'abs', desc: 'ثبّتي جسمكِ على يديكِ وقدميكِ كالطاولة', zones: ['belly', 'arms', 'back']),
  Exercise(name: 'الدراجة الهوائية',  icon: '🚲', duration: 30, rounds: 3, rest: 15, type: 'abs', desc: 'دوري كوعيكِ نحو الركبة المعاكسة ببطء', zones: ['belly', 'obliques']),
  Exercise(name: 'السكوات البطني',    icon: '💫', duration: 25, rounds: 3, rest: 20, type: 'abs', desc: 'استلقي واجلسي بالكامل — عشر مرات!', zones: ['belly', 'obliques']),
  Exercise(name: 'الجانبي المائل',    icon: '↔️', duration: 30, rounds: 3, rest: 15, type: 'abs', desc: 'شدّي الجانب باليد نحو الأسفل 10 مرات', zones: ['obliques', 'belly']),
  // ─── LOWER BODY ───
  Exercise(name: 'السكوات',            icon: '🪑', duration: 30, rounds: 3, rest: 20, type: 'lower', desc: 'انزلي ببطء كأنكِ تجلسين ثم قومي!', zones: ['thighs', 'glutes']),
  Exercise(name: 'اللانج الأمامي',    icon: '🦿', duration: 30, rounds: 3, rest: 20, type: 'lower', desc: 'خطوة للأمام وانزلي حتى تلمسي الأرض', zones: ['thighs', 'glutes', 'calves']),
  Exercise(name: 'ركل الحمار',        icon: '🐴', duration: 25, rounds: 3, rest: 15, type: 'lower', desc: 'على أربعة قوائم — ارفعي ساقكِ للخلف', zones: ['glutes']),
  Exercise(name: 'جسر المؤخرة',       icon: '🌉', duration: 30, rounds: 3, rest: 20, type: 'lower', desc: 'استلقي وارفعي الحوض للأعلى وثبّتيه', zones: ['glutes', 'hamstrings']),
  Exercise(name: 'السكوات السومو',    icon: '🥋', duration: 30, rounds: 3, rest: 20, type: 'lower', desc: 'افردي قدميكِ للخارج وانزلي عميقاً', zones: ['thighs', 'glutes', 'inner']),
  Exercise(name: 'رفع الكعب',         icon: '👟', duration: 30, rounds: 3, rest: 10, type: 'lower', desc: 'قفي وارفعي أصابع قدميكِ 20 مرة', zones: ['calves']),
  Exercise(name: 'الضغط الداخلي',    icon: '🦵', duration: 25, rounds: 3, rest: 15, type: 'lower', desc: 'ضعي وسادة بين ركبتيكِ واضغطي 15 ثانية', zones: ['inner', 'thighs']),
  // ─── UPPER BODY ───
  Exercise(name: 'التصفيق أمام الجسم', icon: '👏', duration: 30, rounds: 3, rest: 15, type: 'upper', desc: 'مدّي ذراعيكِ وصفّقي أمامكِ بقوة', zones: ['chest', 'arms']),
  Exercise(name: 'الضغط المعدّل',     icon: '💪', duration: 20, rounds: 3, rest: 20, type: 'upper', desc: 'على الركبتين — انزلي واصعدي ببطء', zones: ['chest', 'arms', 'shoulders']),
  Exercise(name: 'ثني المرفق',         icon: '🏺', duration: 30, rounds: 3, rest: 15, type: 'upper', desc: 'استخدمي زجاجة ماء — ارفعي وانزلي', zones: ['arms']),
  Exercise(name: 'الغمز الجانبي',      icon: '🤜', duration: 30, rounds: 3, rest: 15, type: 'upper', desc: 'ذراعيكِ للجانب وحرّكيهما للخلف والأمام', zones: ['arms', 'shoulders']),
  Exercise(name: 'دفع الجدار',         icon: '🧱', duration: 30, rounds: 3, rest: 20, type: 'upper', desc: 'قفي أمام الجدار وادفعيه وكأنكِ تعملين ضغط', zones: ['chest', 'arms']),
  Exercise(name: 'تمرين الكتفين',      icon: '🏋️', duration: 25, rounds: 3, rest: 15, type: 'upper', desc: 'ارفعي ذراعيكِ للجانب ببطء حتى مستوى الكتف', zones: ['shoulders']),
  // ─── STRETCH ───
  Exercise(name: 'تمدد الظهر القطة',  icon: '🐱', duration: 30, rounds: 2, rest: 10, type: 'stretch', desc: 'على أربعة: قوسي ظهركِ للأعلى والأسفل', zones: ['back']),
  Exercise(name: 'التوازن على رجل',    icon: '🦩', duration: 20, rounds: 3, rest: 10, type: 'stretch', desc: 'قفي على رجل واحدة وثبّتي نفسكِ', zones: ['calves', 'back']),
  Exercise(name: 'تمدد الفخذ',        icon: '🧎', duration: 30, rounds: 2, rest: 10, type: 'stretch', desc: 'اجلسي واحني ساقاً للخلف وثبّتي 20 ثانية', zones: ['thighs', 'hip']),
  Exercise(name: 'التنفس العميق',      icon: '🌬️', duration: 40, rounds: 2, rest: 5,  type: 'stretch', desc: 'شهيق 4 ثوان، احبسي 2، زفير 6 ثوان', zones: ['full']),
  Exercise(name: 'تمدد الكتفين',       icon: '🙆', duration: 25, rounds: 2, rest: 10, type: 'stretch', desc: 'شبّكي يديكِ خلف ظهركِ واسحبي للأعلى', zones: ['shoulders', 'back']),
];

const kExerciseCategories = [
  {'key': 'cardio',  'label': 'كارديو (حرق الدهون)', 'icon': '🔥', 'color': 0xFFFA8231},
  {'key': 'abs',     'label': 'البطن والخصر',         'icon': '🎯', 'color': 0xFFFF6B9D},
  {'key': 'lower',   'label': 'الأرداف والأفخاذ',    'icon': '🦵', 'color': 0xFFC44DFF},
  {'key': 'upper',   'label': 'الجزء العلوي',          'icon': '💪', 'color': 0xFF4facfe},
  {'key': 'stretch', 'label': 'تمدد واسترخاء',        'icon': '🧘', 'color': 0xFF43E97B},
];

const kMotivations = [
  ('🌟', 'نجمة تتألق!',         'كل جولة تكمليها تجعلكِ أقوى وأجمل. مبهرة يا حبيبتي! 💕'),
  ('🦁', 'قوية كالأسد!',        'تمريناتكِ تجعل قلبكِ أقوى وجسمكِ أكثر نشاطاً. واصلي! 🔥'),
  ('🌸', 'أحسنتِ!',             'لكل خطوة قيمتها. ما تفعلينه الآن ستشكرين نفسكِ عليه غداً! ✨'),
  ('💪', 'بطلة الجيم المنزلي!', 'بدون صالة، بدون معدات، وبكل هذه القوة! أنتِ مذهلة!'),
  ('🎯', 'هدف محقق!',           'كل تمرين يقربكِ من هدفكِ. استمري ولا تستسلمي أبداً! 🌈'),
  ('🦋', 'فراشتي الجميلة!',    'تتحولين كل يوم لنسخة أفضل. هذه رحلة حب لجسمكِ! 💜'),
  ('🏆', 'بطولة في كل جولة!',  'الفائزون يصنعون أنفسهم بالمثابرة. هذا ما تفعلينه الآن!'),
  ('⭐', 'نجمة لا تغيب!',      'جسمكِ يشكركِ على كل حركة! استمري في حبّ نفسكِ والعناية بها!'),
];
