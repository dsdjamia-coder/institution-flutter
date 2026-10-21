class InstitutionSetting {
  final String appName;
  final String institutionName;
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

  InstitutionSetting({
    this.appName = 'Institution Portal',
    this.institutionName = 'Institution Management System',
    this.type = 'Academy / School',
    this.regNo = '',
    this.place = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.currencySymbol = '₹',
    this.logoUrl = '',
    this.activeAcademicYear = '2026-2027',
    this.aboutText = 'Welcome to our institution portal.',
    this.receiptHeader = 'FEE RECEIPT',
    this.receiptFooter = 'Thank you for your payment.',
  });

  factory InstitutionSetting.fromMap(Map<String, dynamic> map) {
    return InstitutionSetting(
      appName: map['appName']?.toString() ?? 'Institution Portal',
      institutionName: map['institutionName']?.toString() ?? 'Institution Management System',
      type: map['type']?.toString() ?? 'Academy / School',
      regNo: map['regNo']?.toString() ?? '',
      place: map['place']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      website: map['website']?.toString() ?? '',
      currencySymbol: map['currencySymbol']?.toString() ?? '₹',
      logoUrl: map['logoUrl']?.toString() ?? '',
      activeAcademicYear: map['activeAcademicYear']?.toString() ?? '2026-2027',
      aboutText: map['aboutText']?.toString() ?? '',
      receiptHeader: map['receiptHeader']?.toString() ?? 'FEE RECEIPT',
      receiptFooter: map['receiptFooter']?.toString() ?? 'Thank you for your payment.',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'institutionName': institutionName,
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
    };
  }

  InstitutionSetting copyWith({
    String? appName,
    String? institutionName,
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
  }) {
    return InstitutionSetting(
      appName: appName ?? this.appName,
      institutionName: institutionName ?? this.institutionName,
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
    );
  }
}
