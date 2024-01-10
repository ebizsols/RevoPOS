import 'package:equatable/equatable.dart';

class UserSetting extends Equatable {
  final Wa? wa;
  final Sms? sms;
  final Phone? phone;
  final About? about;
  final PrivacyPolicy? privacyPolicy;
  final TermCondition? termCondition;
  final bool? liveChat;
  final int? unread;
  final Cs? cs;
  final Logo? logo;
  final bool? barcodeActive;
  final bool? wholesale;
  final List<EmptyImage>? emptyImage;
  final LinkPlaystore? linkPlaystore;
  final Currency? currency;
  final FormatCurrency? formatCurrency;

  UserSetting({
    this.wa,
    this.sms,
    this.phone,
    this.about,
    this.privacyPolicy,
    this.termCondition,
    this.liveChat,
    this.unread,
    this.cs,
    this.logo,
    this.barcodeActive,
    this.wholesale,
    this.emptyImage,
    this.linkPlaystore,
    this.currency,
    this.formatCurrency,
  });

  @override
  List<Object?> get props => [
        wa,
        sms,
        phone,
        liveChat,
        unread,
        about,
        privacyPolicy,
        termCondition,
        cs,
        logo,
        barcodeActive,
        wholesale,
        emptyImage,
        linkPlaystore,
        currency,
        formatCurrency,
      ];
}

class Wa extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Wa({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class Sms extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Sms({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class Phone extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Phone({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class About extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  About({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class PrivacyPolicy extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  PrivacyPolicy({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class TermCondition extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  TermCondition({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class Cs extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Cs({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class Logo extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Logo({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class EmptyImage extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  EmptyImage({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class LinkPlaystore extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  LinkPlaystore({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class Currency extends Equatable {
  final String? slug;
  final String? title;
  final String? image;
  final String? description;

  Currency({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}

class FormatCurrency extends Equatable {
  final int? slug;
  final String? title;
  final String? image;
  final String? description;

  FormatCurrency({
    this.slug,
    this.title,
    this.image,
    this.description,
  });

  @override
  List<Object?> get props => [
        slug,
        title,
        image,
        description,
      ];
}
