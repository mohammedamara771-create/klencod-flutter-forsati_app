import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ForsaTiApp());
}

const Color primaryColor = Color(0xFF6C3BDB);
const Color backgroundColor = Color(0xFFF6F5FB);
const Color greenColor = Color(0xFF159B73);

class ForsaTiApp extends StatelessWidget {
  const ForsaTiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرصتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const MainScreen(),
    );
  }
}

// ======================================================
// نموذج الوظيفة
// ======================================================

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String category;
  final String contract;
  final String salary;
  final String education;
  final String experience;
  final String description;
  final String published;
  final String deadline;
  final bool requiresDrivingLicense;
  final bool isReal;
  final String applicationUrl;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.category,
    required this.contract,
    required this.salary,
    required this.education,
    required this.experience,
    required this.description,
    required this.published,
    required this.deadline,
    required this.requiresDrivingLicense,
    this.isReal = false,
    this.applicationUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'category': category,
        'contract': contract,
        'salary': salary,
        'education': education,
        'experience': experience,
        'description': description,
        'published': published,
        'deadline': deadline,
        'requiresDrivingLicense': requiresDrivingLicense,
        'isReal': isReal,
        'applicationUrl': applicationUrl,
      };

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      contract: json['contract']?.toString() ?? '',
      salary: json['salary']?.toString() ?? 'غير محدد',
      education: json['education']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      published: json['published']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? '',
      requiresDrivingLicense:
          json['requiresDrivingLicense'] == true,
      isReal: json['isReal'] == true,
      applicationUrl: json['applicationUrl']?.toString() ?? '',
    );
  }
}

// ======================================================
// الملف الشخصي
// ======================================================

class UserProfile {
  String name;
  String age;
  String wilaya;
  String municipality;
  String education;
  String experience;
  String preferredJobs;
  String workType;
  String minimumSalary;
  bool acceptsNoExperience;
  bool hasDrivingLicense;
  bool acceptsOutsideWilaya;
  bool acceptsNightShift;

  UserProfile({
    this.name = '',
    this.age = '',
    this.wilaya = 'تقرت',
    this.municipality = '',
    this.education = 'ثانوي',
    this.experience = 'بدون خبرة',
    this.preferredJobs = 'جميع الوظائف',
    this.workType = 'الكل',
    this.minimumSalary = '',
    this.acceptsNoExperience = true,
    this.hasDrivingLicense = false,
    this.acceptsOutsideWilaya = false,
    this.acceptsNightShift = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'wilaya': wilaya,
        'municipality': municipality,
        'education': education,
        'experience': experience,
        'preferredJobs': preferredJobs,
        'workType': workType,
        'minimumSalary': minimumSalary,
        'acceptsNoExperience': acceptsNoExperience,
        'hasDrivingLicense': hasDrivingLicense,
        'acceptsOutsideWilaya': acceptsOutsideWilaya,
        'acceptsNightShift': acceptsNightShift,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? '',
      wilaya: json['wilaya'] ?? 'تقرت',
      municipality: json['municipality'] ?? '',
      education: json['education'] ?? 'ثانوي',
      experience: json['experience'] ?? 'بدون خبرة',
      preferredJobs: json['preferredJobs'] ?? 'جميع الوظائف',
      workType: json['workType'] ?? 'الكل',
      minimumSalary: json['minimumSalary'] ?? '',
      acceptsNoExperience: json['acceptsNoExperience'] ?? true,
      hasDrivingLicense: json['hasDrivingLicense'] ?? false,
      acceptsOutsideWilaya: json['acceptsOutsideWilaya'] ?? false,
      acceptsNightShift: json['acceptsNightShift'] ?? true,
    );
  }
}

// ======================================================
// تخزين البيانات على الهاتف
// ======================================================

class LocalStorage {
  static const String profileKey = 'forsati_profile';
  static const String savedJobsKey = 'forsati_saved_jobs';

  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(profileKey);

    if (raw == null) return UserProfile();

    try {
      return UserProfile.fromJson(jsonDecode(raw));
    } catch (_) {
      return UserProfile();
    }
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      profileKey,
      jsonEncode(profile.toJson()),
    );
  }

  static Future<Set<String>> loadSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(savedJobsKey) ?? []).toSet();
  }

  static Future<void> saveSavedJobs(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(savedJobsKey, ids.toList());
  }
}

// ======================================================
// بيانات توضيحية وليست إعلانات حقيقية
// ======================================================

final List<Job> demoJobs = [
  const Job(
    id: 'demo1',
    title: 'عون إدارة',
    company: 'إعلان تجريبي',
    location: 'تقرت',
    category: 'الإدارة',
    contract: 'مسابقة توظيف',
    salary: 'حسب سلم الأجور',
    education: 'ثانوي',
    experience: 'بدون خبرة',
    description:
        'مثال توضيحي لمنصب إداري. تحقق من الإعلان الرسمي لمعرفة الشروط والوثائق وآخر أجل.',
    published: 'مثال',
    deadline: 'غير محدد',
    requiresDrivingLicense: false,
  ),
  const Job(
    id: 'demo2',
    title: 'عامل متعدد الخدمات',
    company: 'إعلان تجريبي',
    location: 'ورقلة',
    category: 'العمال والخدمات',
    contract: 'عقد عمل',
    salary: 'حسب الاتفاق',
    education: 'ابتدائي',
    experience: 'بدون خبرة',
    description:
        'مثال توضيحي لوظيفة خدمات. يجب التأكد من توفر المنصب لدى المؤسسة قبل التقديم.',
    published: 'مثال',
    deadline: 'غير محدد',
    requiresDrivingLicense: false,
  ),
  const Job(
    id: 'demo3',
    title: 'موظف استقبال',
    company: 'إعلان تجريبي',
    location: 'المسيلة',
    category: 'الاستقبال',
    contract: 'دوام كامل',
    salary: 'غير محدد',
    education: 'ثانوي',
    experience: 'خبرة مفضلة',
    description:
        'مثال توضيحي لوظيفة استقبال. هذه البيانات ليست إعلان توظيف حقيقيًا.',
    published: 'مثال',
    deadline: 'غير محدد',
    requiresDrivingLicense: false,
  ),
  const Job(
    id: 'demo4',
    title: 'سائق',
    company: 'إعلان تجريبي',
    location: 'تقرت',
    category: 'النقل',
    contract: 'عقد عمل',
    salary: 'حسب الاتفاق',
    education: 'متوسط',
    experience: 'خبرة مفضلة',
    description:
        'مثال توضيحي لوظيفة سائق. تحقق من نوع رخصة السياقة المطلوبة في الإعلان الحقيقي.',
    published: 'مثال',
    deadline: 'غير محدد',
    requiresDrivingLicense: true,
  ),
  const Job(
    id: 'demo5',
    title: 'عامل مخزن',
    company: 'إعلان تجريبي',
    location: 'حاسي مسعود',
    category: 'المخازن',
    contract: 'دوام كامل',
    salary: 'غير محدد',
    education: 'ابتدائي',
    experience: 'بدون خبرة',
    description:
        'مثال توضيحي لوظيفة عامل مخزن. لا يمثل عرضًا متاحًا حاليًا.',
    published: 'مثال',
    deadline: 'غير محدد',
    requiresDrivingLicense: false,
  ),
];

// ======================================================
// المطابقة مع ملف الباحث عن العمل
// ======================================================

class MatchResult {
  final int score;
  final List<String> reasons;
  final List<String> warnings;

  const MatchResult({
    required this.score,
    required this.reasons,
    required this.warnings,
  });

  bool get verifiedSuitable =>
      score >= 75 && warnings.isEmpty;
}

MatchResult calculateMatch(Job job, UserProfile profile) {
  int score = 0;
  final reasons = <String>[];
  final warnings = <String>[];

  final preferred = profile.preferredJobs.trim();

  if (preferred.isEmpty ||
      preferred == 'جميع الوظائف' ||
      job.category.contains(preferred) ||
      job.title.contains(preferred)) {
    score += 25;
    reasons.add('مجال العمل مناسب لتفضيلاتك');
  } else {
    warnings.add('تحقق من مدى مناسبة مجال العمل');
  }

  if (job.location == profile.wilaya) {
    score += 25;
    reasons.add('مكان العمل يطابق ولايتك');
  } else if (profile.acceptsOutsideWilaya) {
    score += 15;
    reasons.add('تقبل العمل خارج ولايتك');
  } else {
    warnings.add('مكان العمل خارج ولايتك');
  }

  final educationLevels = <String, int>{
    'بدون شهادة': 0,
    'ابتدائي': 1,
    'متوسط': 2,
    'ثانوي': 3,
    'تكوين مهني': 3,
    'جامعي': 4,
    'ليسانس': 4,
    'ماستر': 5,
  };

  final userEducation = educationLevels[profile.education] ?? 3;
  final jobEducation = educationLevels[job.education] ?? 3;

  if (userEducation >= jobEducation) {
    score += 25;
    reasons.add('مستواك الدراسي يطابق المستوى المطلوب');
  } else {
    warnings.add('تحقق من شرط المستوى الدراسي');
  }

  if (job.requiresDrivingLicense && !profile.hasDrivingLicense) {
    warnings.add('الوظيفة تتطلب رخصة سياقة');
  } else {
    score += 15;
    reasons.add('لا يوجد تعارض معروف بشأن رخصة السياقة');
  }

  if (job.experience.contains('بدون خبرة')) {
    if (profile.acceptsNoExperience) {
      score += 10;
      reasons.add('الوظيفة تقبل المبتدئين بحسب البيانات التجريبية');
    } else {
      warnings.add('الوظيفة مخصصة للمبتدئين');
    }
  } else {
    score += 5;
    reasons.add('يجب التحقق من شرط الخبرة');
  }

  if (score > 100) score = 100;

  return MatchResult(
    score: score,
    reasons: reasons,
    warnings: warnings,
  );
}

// ======================================================
// الشاشة الرئيسية والتنقل
// ======================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  UserProfile profile = UserProfile();
  Set<String> savedJobs = {};
  bool loading = true;
  String searchQuery = '';
  String selectedLocation = 'الكل';
  String selectedCategory = 'الكل';
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final p = await LocalStorage.loadProfile();
    final s = await LocalStorage.loadSavedJobs();

    if (!mounted) return;

    setState(() {
      profile = p;
      savedJobs = s;
      loading = false;
    });
  }

  Future<void> saveProfile() async {
    await LocalStorage.saveProfile(profile);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> toggleSaved(Job job) async {
    setState(() {
      if (savedJobs.contains(job.id)) {
        savedJobs.remove(job.id);
      } else {
        savedJobs.add(job.id);
      }
    });

    await LocalStorage.saveSavedJobs(savedJobs);
  }

  Future<void> refreshJobs() async {
    // هذه النسخة تستخدم بيانات توضيحية محلية.
    // ستتم إضافة جلب الوظائف الحقيقية عند ربط مصادر البيانات.
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      lastUpdated = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تحديث العرض المحلي. لا توجد مصادر توظيف حقيقية مربوطة بعد.',
        ),
      ),
    );
  }

  List<Job> get filteredJobs {
    Iterable<Job> jobs = demoJobs;

    if (selectedIndex == 2) {
      jobs = jobs.where((job) => savedJobs.contains(job.id));
    }

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();

      jobs = jobs.where((job) =>
          job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query) ||
          job.category.toLowerCase().contains(query));
    }

    if (selectedLocation != 'الكل') {
      jobs = jobs.where((job) => job.location == selectedLocation);
    }

    if (selectedCategory != 'الكل') {
      jobs = jobs.where((job) => job.category == selectedCategory);
    }

    return jobs.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      buildHome(),
      buildSearchPage(),
      buildSavedPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work_outline,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فرصتي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'وظيفتك القادمة تبدأ هنا',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: refreshJobs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'المحفوظات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'ملفي',
          ),
        ],
      ),
    );
  }

  // ====================================================
  // الرئيسية
  // ====================================================

  Widget buildHome() {
    final matchingCount = demoJobs.where((job) {
      return calculateMatch(job, profile).verifiedSuitable;
    }).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6C3BDB),
                Color(0xFF392078),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا ${profile.name.isEmpty ? 'بك' : profile.name} 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'دع فرصتي يساعدك في تنظيم بحثك عن العمل.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => selectedIndex = 1);
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('ابحث عن عمل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'الإعلانات التجريبية',
                value: '${demoJobs.length}',
                icon: Icons.work_outline,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'مطابقة أولية',
                value: '$matchingCount',
                icon: Icons.verified_outlined,
                color: greenColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تنبيه: الإعلانات الحالية تجريبية وليست فرص عمل مؤكدة. يجب ربط التطبيق بمصادر حقيقية للحصول على الوظائف الجديدة.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'أحدث الإعلانات',
          action: 'عرض الكل',
          onTap: () => setState(() => selectedIndex = 1),
        ),
        const SizedBox(height: 12),
        ...demoJobs.take(3).map(
              (job) => JobCard(
                job: job,
                result: calculateMatch(job, profile),
                saved: savedJobs.contains(job.id),
                onSave: () => toggleSaved(job),
                onTap: () => openJob(job),
              ),
            ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => setState(() => selectedIndex = 3),
          icon: const Icon(Icons.person_outline),
          label: const Text('أكمل معلومات ملفك الشخصي'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }

  // ====================================================
  // البحث والتصفية
  // ====================================================

  Widget buildSearchPage() {
    const locations = [
      'الكل',
      'تقرت',
      'ورقلة',
      'المسيلة',
      'حاسي مسعود',
    ];

    const categories = [
      'الكل',
      'الإدارة',
      'العمال والخدمات',
      'الاستقبال',
      'النقل',
      'المخازن',
    ];

    final jobs = filteredJobs;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'ابحث عن فرصتك',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'ابحث بالوظيفة أو المؤسسة أو مكان العمل.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'مثال: عون إدارة، سائق...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      setState(() => searchQuery = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedLocation,
          decoration: const InputDecoration(
            labelText: 'الولاية أو المنطقة',
          ),
          items: locations
              .map((location) => DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => selectedLocation = value ?? 'الكل');
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: const InputDecoration(
            labelText: 'مجال العمل',
          ),
          items: categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => selectedCategory = value ?? 'الكل');
          },
        ),
        const SizedBox(height: 20),
        Text(
          'النتائج: ${jobs.length}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        if (jobs.isEmpty)
          const EmptyState(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            subtitle: 'جرّب تغيير كلمات البحث أو عوامل التصفية.',
          ),
        ...jobs.map(
          (job) => JobCard(
            job: job,
            result: calculateMatch(job, profile),
            saved: savedJobs.contains(job.id),
            onSave: () => toggleSaved(job),
            onTap: () => openJob(job),
          ),
        ),
      ],
    );
  }

  // ====================================================
  // الوظائف المحفوظة
  // ====================================================

  Widget buildSavedPage() {
    final jobs = demoJobs
        .where((job) => savedJobs.contains(job.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'وظائفي المحفوظة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'احتفظ بالوظائف التي تريد الرجوع إليها.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        if (jobs.isEmpty)
          const EmptyState(
            icon: Icons.bookmark_border,
            title: 'لا توجد وظائف محفوظة',
            subtitle: 'اضغط على رمز الحفظ في أي إعلان.',
          ),
        ...jobs.map(
          (job) => JobCard(
            job: job,
            result: calculateMatch(job, profile),
            saved: true,
            onSave: () => toggleSaved(job),
            onTap: () => openJob(job),
          ),
        ),
      ],
    );
  }

  // ====================================================
  // الملف الشخصي
  // ====================================================

  Widget buildProfilePage() {
    return ProfileEditor(
      initialProfile: profile,
      onSave: (newProfile) async {
        profile = newProfile;
        await LocalStorage.saveProfile(profile);

        if (!mounted) return;

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ معلوماتك بنجاح'),
          ),
        );
      },
    );
  }

  // ====================================================
  // تفاصيل الوظيفة
  // ====================================================

  void openJob(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsPage(
          job: job,
          profile: profile,
          saved: savedJobs.contains(job.id),
          onSave: () => toggleSaved(job),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }
}

// ======================================================
// بطاقة إحصائيات
// ======================================================

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// عنوان قسم
// ======================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(action),
        ),
      ],
    );
  }
}

// ======================================================
// بطاقة وظيفة
// ======================================================

class JobCard extends StatelessWidget {
  final Job job;
  final MatchResult result;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.result,
    required this.saved,
    required this.onSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final suitable = result.verifiedSuitable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          job.company,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onSave,
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: saved ? primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  InfoChip(
                    icon: Icons.location_on_outlined,
                    text: job.location,
                  ),
                  InfoChip(
                    icon: Icons.work_history_outlined,
                    text: job.contract,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    suitable
                        ? Icons.verified
                        : Icons.fact_check_outlined,
                    color: suitable ? greenColor : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      suitable
                          ? 'مطابقة أولية للشروط المتاحة'
                          : 'تحتاج إلى مراجعة الشروط',
                      style: TextStyle(
                        color: suitable ? greenColor : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${result.score}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: result.score / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: suitable ? greenColor : Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'الراتب: ${job.salary}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (!job.isReal)
                const Padding(
                  padding: EdgeInsets.only(top: 9),
                  child: Text(
                    'إعلان تجريبي - ليس عرض عمل حقيقيًا',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primaryColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// تفاصيل الوظيفة
// ======================================================

class JobDetailsPage extends StatelessWidget {
  final Job job;
  final UserProfile profile;
  final bool saved;
  final VoidCallback onSave;

  const JobDetailsPage({
    super.key,
    required this.job,
    required this.profile,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final result = calculateMatch(job, profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الوظيفة'),
        actions: [
          IconButton(
            onPressed: onSave,
            icon: Icon(
              saved ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 40,
                  color: primaryColor,
                ),
                const SizedBox(height: 14),
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.company,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DetailRow(label: 'مكان العمل', value: job.location),
          DetailRow(label: 'المجال', value: job.category),
          DetailRow(label: 'نوع العمل', value: job.contract),
          DetailRow(label: 'الراتب', value: job.salary),
          DetailRow(label: 'المستوى المطلوب', value: job.education),
          DetailRow(label: 'الخبرة', value: job.experience),
          DetailRow(label: 'آخر أجل', value: job.deadline),
          DetailRow(
            label: 'رخصة السياقة',
            value: job.requiresDrivingLicense ? 'مطلوبة' : 'غير مشترطة',
          ),
          const SizedBox(height: 20),
          const Text(
            'وصف الوظيفة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            job.description,
            style: const TextStyle(height: 1.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'مدى مطابقة الوظيفة لملفك',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${result.score}% - ${result.verifiedSuitable ? 'مطابقة أولية' : 'تحتاج إلى مراجعة'}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          ...result.reasons.map(
            (reason) => ReasonTile(
              text: reason,
              positive: true,
            ),
          ),
          ...result.warnings.map(
            (warning) => ReasonTile(
              text: warning,
              positive: false,
            ),
          ),
          const SizedBox(height: 15),
          if (!job.isReal)
            const Text(
              'هذا مثال تجريبي فقط. لا توجد جهة توظيف حقيقية مرتبطة بهذا الإعلان.',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'لا يوجد رابط تقديم حقيقي لهذا الإعلان التجريبي.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('التقديم على الوظيفة'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReasonTile extends StatelessWidget {
  final String text;
  final bool positive;

  const ReasonTile({
    super.key,
    required this.text,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.check_circle : Icons.warning_amber,
            color: positive ? greenColor : Colors.orange,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// ======================================================
// محرر الملف الشخصي
// ======================================================

class ProfileEditor extends StatefulWidget {
  final UserProfile initialProfile;
  final ValueChanged<UserProfile> onSave;

  const ProfileEditor({
    super.key,
    required this.initialProfile,
    required this.onSave,
  });

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  late UserProfile profile;

  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController municipalityController;
  late TextEditingController salaryController;

  static const wilayas = [
    'تقرت',
    'ورقلة',
    'المسيلة',
    'الجزائر',
    'الوادي',
    'بسكرة',
    'إليزي',
    'غرداية',
    'الأغواط',
    'سطيف',
    'باتنة',
    'قسنطينة',
    'وهران',
    'عنابة',
    'ولايات أخرى',
  ];

  static const educationOptions = [
    'بدون شهادة',
    'ابتدائي',
    'متوسط',
    'ثانوي',
    'تكوين مهني',
    'جامعي',
    'ليسانس',
    'ماستر',
  ];

  static const jobOptions = [
    'جميع الوظائف',
    'الإدارة',
    'الأمن',
    'النقل',
    'الاستقبال',
    'العمال والخدمات',
    'المخازن',
    'التجارة',
    'الإعلام الآلي',
  ];

  @override
  void initState() {
    super.initState();

    profile = UserProfile.fromJson(widget.initialProfile.toJson());

    nameController = TextEditingController(text: profile.name);
    ageController = TextEditingController(text: profile.age);
    municipalityController =
        TextEditingController(text: profile.municipality);
    salaryController =
        TextEditingController(text: profile.minimumSalary);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    municipalityController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget dropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = options.contains(value) ? value : options.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(labelText: label),
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget toggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      activeThumbColor: primaryColor,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'ملفي الشخصي',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'كلما كانت معلوماتك دقيقة، كان تقييم الوظائف أكثر فائدة.',
          style: TextStyle(color: Colors.grey),
        ),
        sectionTitle('المعلومات الشخصية'),
        textField(
          label: 'الاسم',
          controller: nameController,
        ),
        textField(
          label: 'العمر',
          controller: ageController,
          keyboardType: TextInputType.number,
        ),
        dropdown(
          label: 'الولاية',
          value: profile.wilaya,
          options: wilayas,
          onChanged: (value) {
            if (value != null) {
              setState(() => profile.wilaya = value);
            }
          },
        ),
        textField(
          label: 'البلدية',
          controller: municipalityController,
        ),
        sectionTitle('المؤهلات'),
        dropdown(
          label: 'المستوى الدراسي',
          value: profile.education,
          options: educationOptions,
          onChanged: (value) {
            if (value != null) {
              setState(() => profile.education = value);
            }
          },
        ),
        dropdown(
          label: 'الخبرة المهنية',
          value: profile.experience,
          options: [
            'بدون خبرة',
            'أقل من سنة',
            '1-3 سنوات',
            'أكثر من 3 سنوات',
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => profile.experience = value);
            }
          },
        ),
        sectionTitle('تفضيلات العمل'),
        dropdown(
          label: 'مجال العمل المفضل',
          value: profile.preferredJobs,
          options: jobOptions,
          onChanged: (value) {
            if (value != null) {
              setState(() => profile.preferredJobs = value);
            }
          },
        ),
        dropdown(
          label: 'نوع العمل',
          value: profile.workType,
          options: [
            'الكل',
            'دائم',
            'مؤقت',
            'مسابقة توظيف',
            'عقد عمل',
            'دوام كامل',
            'دوام جزئي',
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => profile.workType = value);
            }
          },
        ),
        textField(
          label: 'الحد الأدنى للراتب (دج)',
          controller: salaryController,
          keyboardType: TextInputType.number,
        ),
        sectionTitle('شروط إضافية'),
        toggle(
          title: 'أقبل الوظائف التي لا تتطلب خبرة',
          value: profile.acceptsNoExperience,
          onChanged: (value) {
            setState(() => profile.acceptsNoExperience = value);
          },
        ),
        toggle(
          title: 'أملك رخصة سياقة',
          value: profile.hasDrivingLicense,
          onChanged: (value) {
            setState(() => profile.hasDrivingLicense = value);
          },
        ),
        toggle(
          title: 'أقبل العمل خارج ولايتي',
          value: profile.acceptsOutsideWilaya,
          onChanged: (value) {
            setState(() => profile.acceptsOutsideWilaya = value);
          },
        ),
        toggle(
          title: 'أقبل العمل الليلي والمناوبات',
          value: profile.acceptsNightShift,
          onChanged: (value) {
            setState(() => profile.acceptsNightShift = value);
          },
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            profile.name = nameController.text.trim();
            profile.age = ageController.text.trim();
            profile.municipality =
                municipalityController.text.trim();
            profile.minimumSalary = salaryController.text.trim();

            widget.onSave(profile);
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('حفظ معلوماتي'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ======================================================
// حالة القائمة الفارغة
// ======================================================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Icon(
            icon,
            size: 65,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}