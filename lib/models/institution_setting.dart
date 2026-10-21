class InstitutionSetting {
  final String appName;
  final String institutionName;
  final String managementName;
  final String type;
  final String regNo;
  final String place;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String currencySymbol;
  final String logoUrl;
  final String activeAcademicYear;
  final String aboutText;
  final String receiptHeader;
  final String receiptFooter;
  final String developerCredit;
  final String versionText;
  final String lastUpdatedText;
  final String socialYoutube;
  final String socialInstagram;
  final String socialWhatsapp;
  final int defaultStudentsCount;
  final int defaultTeachersCount;
  final int defaultMaleCount;
  final int defaultFemaleCount;

  InstitutionSetting({
    this.appName = 'NIM Higher Secondary',
    this.institutionName = 'NIM HIGHER SECONDARY',
    this.managementName = 'Muhyudheen jumma masjid Devathiyal',
    this.type = 'Higher Secondary Madrasa',
    this.regNo = '4883',
    this.place = 'Devathiyal',
    this.address = 'Devathiyal near Chelari, Malappuram, Kerala',
    this.phone = '+91 9946 806 268',
    this.email = 'nimdevathiyal4883@gmail.com',
    this.website = '',
    this.currencySymbol = '₹',
    this.logoUrl = 'assets/images/logo.png',
    this.activeAcademicYear = '2026-2027',
    this.aboutText = 'NOORUL ISLAM HIGHER SECONDARY MADRASA, located at Devathiyal near Chelari, Malappuram, Kerala, is a well-established Islamic educational institution affiliated to the Samastha Kerala Islam Matha Vidyabhyasa Board (Register No. 4883). The institution offers classes from Grade 1 to Higher Secondary Level (Grade 12), ensuring a comprehensive Islamic education for every student.\n\nManaged by the Muhyudheen Jumma Masjid Committee, Devathiyal, the Madrasa is guided by highly qualified and experienced Ustads who are dedicated to building students with strong faith, good character, and creative potential. The institution takes pride in identifying and nurturing the unique talents of each student alongside their religious studies.\n\nThe wholehearted support of the committee and the local community continues to be the driving force behind the institution\'s progress — working together to raise a generation firmly rooted in Islamic values.',
    this.receiptHeader = 'FEE RECEIPT',
    this.receiptFooter = 'Thank you for your payment.',
    this.developerCredit = 'HADI MAHIRI FAIZY',
    this.versionText = 'v2.6.0',
    this.lastUpdatedText = '2026-04-25',
    this.socialYoutube = 'https://youtube.com',
    this.socialInstagram = 'https://www.instagram.com/muhammed_sanjide_p',
    this.socialWhatsapp = '+919946806268',
    this.defaultStudentsCount = 326,
    this.defaultTeachersCount = 7,
    this.defaultMaleCount = 155,
    this.defaultFemaleCount = 171,
  });

  factory InstitutionSetting.fromMap(Map<String, dynamic> map) {
    return InstitutionSetting(
      appName: map['appName']?.toString() ?? 'NIM Higher Secondary',
      institutionName: map['institutionName']?.toString() ?? 'NIM HIGHER SECONDARY',
      managementName: map['managementName']?.toString() ?? 'Muhyudheen jumma masjid Devathiyal',
      type: map['type']?.toString() ?? 'Higher Secondary Madrasa',
      regNo: map['regNo']?.toString() ?? '4883',
      place: map['place']?.toString() ?? 'Devathiyal',
      address: map['address']?.toString() ?? 'Devathiyal near Chelari, Malappuram, Kerala',
      phone: map['phone']?.toString() ?? '+91 9946 806 268',
      email: map['email']?.toString() ?? 'nimdevathiyal4883@gmail.com',
      website: map['website']?.toString() ?? '',
      currencySymbol: map['currencySymbol']?.toString() ?? '₹',
      logoUrl: map['logoUrl']?.toString() ?? 'assets/images/logo.png',
      activeAcademicYear: map['activeAcademicYear']?.toString() ?? '2026-2027',
      aboutText: map['aboutText']?.toString() ?? 'NOORUL ISLAM HIGHER SECONDARY MADRASA, located at Devathiyal near Chelari, Malappuram, Kerala, is a well-established Islamic educational institution affiliated to the Samastha Kerala Islam Matha Vidyabhyasa Board (Register No. 4883). The institution offers classes from Grade 1 to Higher Secondary Level (Grade 12), ensuring a comprehensive Islamic education for every student.\n\nManaged by the Muhyudheen Jumma Masjid Committee, Devathiyal, the Madrasa is guided by highly qualified and experienced Ustads who are dedicated to building students with strong faith, good character, and creative potential. The institution takes pride in identifying and nurturing the unique talents of each student alongside their religious studies.\n\nThe wholehearted support of the committee and the local community continues to be the driving force behind the institution\'s progress — working together to raise a generation firmly rooted in Islamic values.',
      receiptHeader: map['receiptHeader']?.toString() ?? 'FEE RECEIPT',
      receiptFooter: map['receiptFooter']?.toString() ?? 'Thank you for your payment.',
      developerCredit: map['developerCredit']?.toString() ?? 'HADI MAHIRI FAIZY',
      versionText: map['versionText']?.toString() ?? 'v2.6.0',
      lastUpdatedText: map['lastUpdatedText']?.toString() ?? '2026-04-25',
      socialYoutube: map['socialYoutube']?.toString() ?? 'https://youtube.com',
      socialInstagram: map['socialInstagram']?.toString() ?? 'https://www.instagram.com/muhammed_sanjide_p',
      socialWhatsapp: map['socialWhatsapp']?.toString() ?? '+919946806268',
      defaultStudentsCount: int.tryParse(map['defaultStudentsCount']?.toString() ?? '') ?? 326,
      defaultTeachersCount: int.tryParse(map['defaultTeachersCount']?.toString() ?? '') ?? 7,
      defaultMaleCount: int.tryParse(map['defaultMaleCount']?.toString() ?? '') ?? 155,
      defaultFemaleCount: int.tryParse(map['defaultFemaleCount']?.toString() ?? '') ?? 171,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'institutionName': institutionName,
      'managementName': managementName,
      'type': type,
      'regNo': regNo,
      'place': place,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'currencySymbol': currencySymbol,
      'logoUrl': logoUrl,
      'activeAcademicYear': activeAcademicYear,
      'aboutText': aboutText,
      'receiptHeader': receiptHeader,
      'receiptFooter': receiptFooter,
      'developerCredit': developerCredit,
      'versionText': versionText,
      'lastUpdatedText': lastUpdatedText,
      'socialYoutube': socialYoutube,
      'socialInstagram': socialInstagram,
      'socialWhatsapp': socialWhatsapp,
      'defaultStudentsCount': defaultStudentsCount,
      'defaultTeachersCount': defaultTeachersCount,
      'defaultMaleCount': defaultMaleCount,
      'defaultFemaleCount': defaultFemaleCount,
    };
  }

  InstitutionSetting copyWith({
    String? appName,
    String? institutionName,
    String? managementName,
    String? type,
    String? regNo,
    String? place,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? currencySymbol,
    String? logoUrl,
    String? activeAcademicYear,
    String? aboutText,
    String? receiptHeader,
    String? receiptFooter,
    String? developerCredit,
    String? versionText,
    String? lastUpdatedText,
    String? socialYoutube,
    String? socialInstagram,
    String? socialWhatsapp,
    int? defaultStudentsCount,
    int? defaultTeachersCount,
    int? defaultMaleCount,
    int? defaultFemaleCount,
  }) {
    return InstitutionSetting(
      appName: appName ?? this.appName,
      institutionName: institutionName ?? this.institutionName,
      managementName: managementName ?? this.managementName,
      type: type ?? this.type,
      regNo: regNo ?? this.regNo,
      place: place ?? this.place,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      logoUrl: logoUrl ?? this.logoUrl,
      activeAcademicYear: activeAcademicYear ?? this.activeAcademicYear,
      aboutText: aboutText ?? this.aboutText,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      developerCredit: developerCredit ?? this.developerCredit,
      versionText: versionText ?? this.versionText,
      lastUpdatedText: lastUpdatedText ?? this.lastUpdatedText,
      socialYoutube: socialYoutube ?? this.socialYoutube,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialWhatsapp: socialWhatsapp ?? this.socialWhatsapp,
      defaultStudentsCount: defaultStudentsCount ?? this.defaultStudentsCount,
      defaultTeachersCount: defaultTeachersCount ?? this.defaultTeachersCount,
      defaultMaleCount: defaultMaleCount ?? this.defaultMaleCount,
      defaultFemaleCount: defaultFemaleCount ?? this.defaultFemaleCount,
    );
  }
}
