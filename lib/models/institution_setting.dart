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
  final String socialFacebook;
  final String socialTelegram;
  final int defaultStudentsCount;
  final int defaultTeachersCount;
  final int defaultMaleCount;
  final int defaultFemaleCount;

  // Fee Settings & Window Schedule
  final double defaultMonthlyFee;
  final String feeStatusTitle;
  final int feeCollectStartDay;
  final int feeCollectEndDay;
  final String feeNotifyMode;
  final int feeNotifyDaysBefore;
  final bool isDefaultFeeReceiptRequired;

  // Bank & UPI Details
  final String bankAccountName;
  final String bankUpiNumber;
  final String bankUpiId;
  final String bankName;
  final String bankAccountNumber;
  final String bankIfsc;
  final String bankBranch;

  // Student Portal Permissions
  final bool allowStudentPhotoUpload;
  final bool allowStudentDetailsEdit;

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
    this.socialFacebook = '',
    this.socialTelegram = '',
    this.defaultStudentsCount = 326,
    this.defaultTeachersCount = 7,
    this.defaultMaleCount = 155,
    this.defaultFemaleCount = 171,
    this.defaultMonthlyFee = 400.0,
    this.feeStatusTitle = 'Monthly Fee Status',
    this.feeCollectStartDay = 1,
    this.feeCollectEndDay = 10,
    this.feeNotifyMode = 'month_start',
    this.feeNotifyDaysBefore = 5,
    this.isDefaultFeeReceiptRequired = true,
    this.bankAccountName = 'Noorul Islam Madrasa Committee',
    this.bankUpiNumber = '9946806268',
    this.bankUpiId = 'nimdevathiyal@upi',
    this.bankName = 'Kerala Gramin Bank',
    this.bankAccountNumber = '40123456789',
    this.bankIfsc = 'KLGB0040123',
    this.bankBranch = 'Chelari',
    this.allowStudentPhotoUpload = true,
    this.allowStudentDetailsEdit = false,
  });

  factory InstitutionSetting.fromMap(Map<String, dynamic> map) {
    return InstitutionSetting(
      appName: map['appName']?.toString() ?? map['name']?.toString() ?? 'NIM Higher Secondary',
      institutionName: map['institutionName']?.toString() ?? map['name']?.toString() ?? 'NIM HIGHER SECONDARY',
      managementName: map['managementName']?.toString() ?? map['affiliationBoard']?.toString() ?? 'Muhyudheen jumma masjid Devathiyal',
      type: map['type']?.toString() ?? 'Higher Secondary Madrasa',
      regNo: map['regNo']?.toString() ?? '4883',
      place: map['place']?.toString() ?? 'Devathiyal',
      address: map['address']?.toString() ?? map['addressLine1']?.toString() ?? 'Devathiyal near Chelari, Malappuram, Kerala',
      phone: map['phone']?.toString() ?? '+91 9946 806 268',
      email: map['email']?.toString() ?? 'nimdevathiyal4883@gmail.com',
      website: map['website']?.toString() ?? '',
      currencySymbol: map['currencySymbol']?.toString() ?? '₹',
      logoUrl: map['logoUrl']?.toString() ?? 'assets/images/logo.png',
      activeAcademicYear: map['activeAcademicYear']?.toString() ?? '2026-2027',
      aboutText: map['aboutText']?.toString() ?? 'NOORUL ISLAM HIGHER SECONDARY MADRASA, located at Devathiyal near Chelari, Malappuram, Kerala, is a well-established Islamic educational institution affiliated to the Samastha Kerala Islam Matha Vidyabhyasa Board (Register No. 4883). The institution offers classes from Grade 1 to Higher Secondary Level (Grade 12), ensuring a comprehensive Islamic education for every student.\n\nManaged by the Muhyudheen Jumma Masjid Committee, Devathiyal, the Madrasa is guided by highly qualified and experienced Ustads who are dedicated to building students with strong faith, good character, and creative potential. The institution takes pride in identifying and nurturing the unique talents of each student alongside their religious studies.\n\nThe wholehearted support of the committee and the local community continues to be the driving force behind the institution\'s progress — working together to raise a generation firmly rooted in Islamic values.',
      receiptHeader: map['receiptHeader']?.toString() ?? 'FEE RECEIPT',
      receiptFooter: map['receiptFooter']?.toString() ?? map['receiptFooterMessage']?.toString() ?? 'Thank you for your payment.',
      developerCredit: map['developerCredit']?.toString() ?? 'HADI MAHIRI FAIZY',
      versionText: map['versionText']?.toString() ?? 'v2.6.0',
      lastUpdatedText: map['lastUpdatedText']?.toString() ?? '2026-04-25',
      socialYoutube: map['socialYoutube']?.toString() ?? 'https://youtube.com',
      socialInstagram: map['socialInstagram']?.toString() ?? 'https://www.instagram.com/muhammed_sanjide_p',
      socialWhatsapp: map['socialWhatsapp']?.toString() ?? '+919946806268',
      socialFacebook: map['socialFacebook']?.toString() ?? '',
      socialTelegram: map['socialTelegram']?.toString() ?? '',
      defaultStudentsCount: int.tryParse(map['defaultStudentsCount']?.toString() ?? '') ?? 326,
      defaultTeachersCount: int.tryParse(map['defaultTeachersCount']?.toString() ?? '') ?? 7,
      defaultMaleCount: int.tryParse(map['defaultMaleCount']?.toString() ?? '') ?? 155,
      defaultFemaleCount: int.tryParse(map['defaultFemaleCount']?.toString() ?? '') ?? 171,
      defaultMonthlyFee: double.tryParse(map['defaultMonthlyFee']?.toString() ?? '') ?? 400.0,
      feeStatusTitle: map['feeStatusTitle']?.toString() ?? 'Monthly Fee Status',
      feeCollectStartDay: int.tryParse(map['feeCollectStartDay']?.toString() ?? '') ?? 1,
      feeCollectEndDay: int.tryParse(map['feeCollectEndDay']?.toString() ?? '') ?? 10,
      feeNotifyMode: map['feeNotifyMode']?.toString() ?? 'month_start',
      feeNotifyDaysBefore: int.tryParse(map['feeNotifyDaysBefore']?.toString() ?? '') ?? 5,
      isDefaultFeeReceiptRequired: map['isDefaultFeeReceiptRequired'] == null ? true : (map['isDefaultFeeReceiptRequired'] == true || map['isDefaultFeeReceiptRequired'].toString().toLowerCase() == 'true'),
      bankAccountName: map['bankAccountName']?.toString() ?? 'Noorul Islam Madrasa Committee',
      bankUpiNumber: map['bankUpiNumber']?.toString() ?? '9946806268',
      bankUpiId: map['bankUpiId']?.toString() ?? 'nimdevathiyal@upi',
      bankName: map['bankName']?.toString() ?? 'Kerala Gramin Bank',
      bankAccountNumber: map['bankAccountNumber']?.toString() ?? '40123456789',
      bankIfsc: map['bankIfsc']?.toString() ?? 'KLGB0040123',
      bankBranch: map['bankBranch']?.toString() ?? 'Chelari',
      allowStudentPhotoUpload: map['allowStudentPhotoUpload'] == null ? true : (map['allowStudentPhotoUpload'] == true || map['allowStudentPhotoUpload'].toString().toLowerCase() == 'true'),
      allowStudentDetailsEdit: map['allowStudentDetailsEdit'] == null ? false : (map['allowStudentDetailsEdit'] == true || map['allowStudentDetailsEdit'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': institutionName,
      'appName': appName,
      'institutionName': institutionName,
      'managementName': managementName,
      'affiliationBoard': managementName,
      'type': type,
      'regNo': regNo,
      'place': place,
      'address': address,
      'addressLine1': address,
      'phone': phone,
      'email': email,
      'website': website,
      'currencySymbol': currencySymbol,
      'logoUrl': logoUrl,
      'activeAcademicYear': activeAcademicYear,
      'aboutText': aboutText,
      'receiptHeader': receiptHeader,
      'receiptFooter': receiptFooter,
      'receiptFooterMessage': receiptFooter,
      'developerCredit': developerCredit,
      'versionText': versionText,
      'lastUpdatedText': lastUpdatedText,
      'socialYoutube': socialYoutube,
      'socialInstagram': socialInstagram,
      'socialWhatsapp': socialWhatsapp,
      'socialFacebook': socialFacebook,
      'socialTelegram': socialTelegram,
      'defaultStudentsCount': defaultStudentsCount,
      'defaultTeachersCount': defaultTeachersCount,
      'defaultMaleCount': defaultMaleCount,
      'defaultFemaleCount': defaultFemaleCount,
      'defaultMonthlyFee': defaultMonthlyFee,
      'feeStatusTitle': feeStatusTitle,
      'feeCollectStartDay': feeCollectStartDay,
      'feeCollectEndDay': feeCollectEndDay,
      'feeNotifyMode': feeNotifyMode,
      'feeNotifyDaysBefore': feeNotifyDaysBefore,
      'isDefaultFeeReceiptRequired': isDefaultFeeReceiptRequired,
      'bankAccountName': bankAccountName,
      'bankUpiNumber': bankUpiNumber,
      'bankUpiId': bankUpiId,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankIfsc': bankIfsc,
      'bankBranch': bankBranch,
      'allowStudentPhotoUpload': allowStudentPhotoUpload,
      'allowStudentDetailsEdit': allowStudentDetailsEdit,
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
    String? socialFacebook,
    String? socialTelegram,
    int? defaultStudentsCount,
    int? defaultTeachersCount,
    int? defaultMaleCount,
    int? defaultFemaleCount,
    double? defaultMonthlyFee,
    String? feeStatusTitle,
    int? feeCollectStartDay,
    int? feeCollectEndDay,
    String? feeNotifyMode,
    int? feeNotifyDaysBefore,
    bool? isDefaultFeeReceiptRequired,
    String? bankAccountName,
    String? bankUpiNumber,
    String? bankUpiId,
    String? bankName,
    String? bankAccountNumber,
    String? bankIfsc,
    String? bankBranch,
    bool? allowStudentPhotoUpload,
    bool? allowStudentDetailsEdit,
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
      socialFacebook: socialFacebook ?? this.socialFacebook,
      socialTelegram: socialTelegram ?? this.socialTelegram,
      defaultStudentsCount: defaultStudentsCount ?? this.defaultStudentsCount,
      defaultTeachersCount: defaultTeachersCount ?? this.defaultTeachersCount,
      defaultMaleCount: defaultMaleCount ?? this.defaultMaleCount,
      defaultFemaleCount: defaultFemaleCount ?? this.defaultFemaleCount,
      defaultMonthlyFee: defaultMonthlyFee ?? this.defaultMonthlyFee,
      feeStatusTitle: feeStatusTitle ?? this.feeStatusTitle,
      feeCollectStartDay: feeCollectStartDay ?? this.feeCollectStartDay,
      feeCollectEndDay: feeCollectEndDay ?? this.feeCollectEndDay,
      feeNotifyMode: feeNotifyMode ?? this.feeNotifyMode,
      feeNotifyDaysBefore: feeNotifyDaysBefore ?? this.feeNotifyDaysBefore,
      isDefaultFeeReceiptRequired: isDefaultFeeReceiptRequired ?? this.isDefaultFeeReceiptRequired,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankUpiNumber: bankUpiNumber ?? this.bankUpiNumber,
      bankUpiId: bankUpiId ?? this.bankUpiId,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      bankBranch: bankBranch ?? this.bankBranch,
      allowStudentPhotoUpload: allowStudentPhotoUpload ?? this.allowStudentPhotoUpload,
      allowStudentDetailsEdit: allowStudentDetailsEdit ?? this.allowStudentDetailsEdit,
    );
  }
}
