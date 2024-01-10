import 'package:revo_pos/layers/domain/entities/user_setting.dart';

class UserSettingModel extends UserSetting {
  final WaModel? wa;
  final SmsModel? sms;
  final PhoneModel? phone;
  final AboutModel? about;
  final PrivacyPolicyModel? privacyPolicy;
  final TermConditionModel? termCondition;
  final CsModel? cs;
  final LogoModel? logo;
  final bool? barcodeActive;
  final bool? wholesale;
  final bool? liveChat;
  final int? unread;
  final List<EmptyImageModel>? emptyImage;
  final LinkPlaystoreModel? linkPlaystore;
  final CurrencyModel? currency;
  final FormatCurrencyModel? formatCurrency;

  UserSettingModel({
    this.wa,
    this.sms,
    this.phone,
    this.about,
    this.privacyPolicy,
    this.termCondition,
    this.cs,
    this.liveChat,
    this.unread,
    this.logo,
    this.barcodeActive,
    this.wholesale,
    this.emptyImage,
    this.linkPlaystore,
    this.currency,
    this.formatCurrency,
  });

  factory UserSettingModel.fromJson(Map<String, dynamic> json) {
    var wa;
    if (json['wa'] != null) {
      wa = WaModel.fromJson(json['wa']);
    }

    var sms;
    if (json['sms'] != null) {
      sms = SmsModel.fromJson(json['sms']);
    }

    var phone;
    if (json['phone'] != null) {
      phone = PhoneModel.fromJson(json['phone']);
    }

    var about;
    if (json['about'] != null) {
      about = AboutModel.fromJson(json['about']);
    }

    var privacyPolicy;
    if (json['privacy_policy'] != null) {
      privacyPolicy = PrivacyPolicyModel.fromJson(json['privacy_policy']);
    }

    var termCondition;
    if (json['term_condition'] != null) {
      termCondition = TermConditionModel.fromJson(json['term_condition']);
    }

    var cs;
    if (json['cs'] != null) {
      cs = CsModel.fromJson(json['cs']);
    }

    var logo;
    if (json['logo'] != null) {
      logo = LogoModel.fromJson(json['logo']);
    }

    var emptyImage;
    if (json['empty_image'] != null) {
      emptyImage = List.generate(0, (index) => EmptyImageModel());
      json['empty_image'].forEach((v) {
        emptyImage.add(EmptyImageModel.fromJson(v));
      });
    }

    var linkPlaystore;
    if (json['link_playstore'] != null) {
      linkPlaystore = LinkPlaystoreModel.fromJson(json['link_playstore']);
    }

    var currency;
    if (json['currency'] != null) {
      currency = CurrencyModel.fromJson(json['currency']);
    }

    var formatCurrency;
    if (json['format_currency'] != null) {
      formatCurrency = FormatCurrencyModel.fromJson(json['format_currency']);
    }

    return UserSettingModel(
      wa: wa,
      sms: sms,
      phone: phone,
      about: about,
      privacyPolicy: privacyPolicy,
      termCondition: termCondition,
      cs: cs,
      logo: logo,
      barcodeActive: json['barcode_active'],
      liveChat: json['livechat_to_revowoo'],
      wholesale: json['wholesale'],
      unread: json['unread_message'],
      emptyImage: emptyImage,
      linkPlaystore: linkPlaystore,
      currency: currency,
      formatCurrency: formatCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    var wa;
    if (this.wa != null) {
      wa = this.wa?.toJson();
    }

    var sms;
    if (this.sms != null) {
      sms = this.sms?.toJson();
    }

    var phone;
    if (this.phone != null) {
      phone = this.phone?.toJson();
    }

    var about;
    if (this.about != null) {
      about = this.about?.toJson();
    }

    var privacyPolicy;
    if (this.privacyPolicy != null) {
      privacyPolicy = this.privacyPolicy?.toJson();
    }

    var termCondition;
    if (this.termCondition != null) {
      termCondition = this.termCondition?.toJson();
    }

    var cs;
    if (this.cs != null) {
      cs = this.cs?.toJson();
    }

    var logo;
    if (this.logo != null) {
      logo = this.logo?.toJson();
    }

    var emptyImage;
    if (this.emptyImage != null) {
      emptyImage = this.emptyImage?.map((v) => v.toJson()).toList();
    }

    var linkPlaystore;
    if (this.linkPlaystore != null) {
      linkPlaystore = this.linkPlaystore?.toJson();
    }

    var currency;
    if (this.currency != null) {
      currency = this.currency?.toJson();
    }

    var formatCurrency;
    if (this.formatCurrency != null) {
      formatCurrency = this.formatCurrency?.toJson();
    }

    return {
      'wa': wa,
      'sms': sms,
      'phone': phone,
      'about': about,
      'privacy_policy': privacyPolicy,
      'term_condition': termCondition,
      'cs': cs,
      'logo': logo,
      'livechat_to_revowoo': liveChat,
      'wholesale': wholesale,
      'unread_message': unread,
      'barcode_active': this.barcodeActive,
      'empty_image': emptyImage,
      'link_playstore': linkPlaystore,
      'currency': currency,
      'format_currency': formatCurrency,
    };
  }
}

class WaModel extends Wa {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  WaModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory WaModel.fromJson(Map<String, dynamic> json) {
    return WaModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class SmsModel extends Sms {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  SmsModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory SmsModel.fromJson(Map<String, dynamic> json) {
    return SmsModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class PhoneModel extends Phone {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  PhoneModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class AboutModel extends About {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  AboutModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class PrivacyPolicyModel extends PrivacyPolicy {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  PrivacyPolicyModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class TermConditionModel extends TermCondition {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  TermConditionModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory TermConditionModel.fromJson(Map<String, dynamic> json) {
    return TermConditionModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class CsModel extends Cs {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  CsModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory CsModel.fromJson(Map<String, dynamic> json) {
    return CsModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class LogoModel extends Logo {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  LogoModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory LogoModel.fromJson(Map<String, dynamic> json) {
    return LogoModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class EmptyImageModel extends EmptyImage {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  EmptyImageModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory EmptyImageModel.fromJson(Map<String, dynamic> json) {
    return EmptyImageModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class LinkPlaystoreModel extends LinkPlaystore {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  LinkPlaystoreModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory LinkPlaystoreModel.fromJson(Map<String, dynamic> json) {
    return LinkPlaystoreModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class CurrencyModel extends Currency {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  CurrencyModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}

class FormatCurrencyModel extends FormatCurrency {
  final int? slug;
  final String? title;
  final String? image;
  final String? description;

  FormatCurrencyModel({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  factory FormatCurrencyModel.fromJson(Map<String, dynamic> json) {
    return FormatCurrencyModel(
      slug: json['slug'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': this.slug,
      'title': this.title,
      'image': this.image,
      'description': this.description,
    };
  }
}
