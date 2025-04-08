class MPGS {
  final String host;
  final String merchantId;
  final String currency;
  final String fpan;
  final String expMonth;
  final String expYear;
  final String securityCode;
  final String fpanAdditional;
  final String expMonthAdditional;
  final String expYearAdditional;
  final String authorizationCode;
  final String giftCardNumber;
  final String costcoGiftCardNumber;
  final String costcoCardPin;
  final String apiPassword;
  final String orderId;

  MPGS({
    required this.host,
    required this.merchantId,
    required this.currency,
    required this.fpan,
    required this.expMonth,
    required this.expYear,
    required this.securityCode,
    required this.fpanAdditional,
    required this.expMonthAdditional,
    required this.expYearAdditional,
    required this.authorizationCode,
    required this.giftCardNumber,
    required this.costcoGiftCardNumber,
    required this.costcoCardPin,
    required this.apiPassword,
    required this.orderId,
  });
}
