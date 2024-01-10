import 'package:flutter/material.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemChat extends StatefulWidget {
  final ChatLists? customer;
  final Function() onTap;

  const ItemChat({Key? key, this.customer, required this.onTap})
      : super(key: key);

  @override
  State<ItemChat> createState() => _ItemChatState();
}

class _ItemChatState extends State<ItemChat> {
  @override
  void initState() {
    super.initState();
    _initTimeAgo();
  }

  _initTimeAgo() {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
    timeago.setLocaleMessages('az', timeago.AzMessages());
    timeago.setLocaleMessages('az_short', timeago.AzShortMessages());
    timeago.setLocaleMessages('ca', timeago.CaMessages());
    timeago.setLocaleMessages('ca_short', timeago.CaShortMessages());
    timeago.setLocaleMessages('cs', timeago.CsMessages());
    timeago.setLocaleMessages('cs_short', timeago.CsShortMessages());
    timeago.setLocaleMessages('da', timeago.DaMessages());
    timeago.setLocaleMessages('da_short', timeago.DaShortMessages());
    timeago.setLocaleMessages('de', timeago.DeMessages());
    timeago.setLocaleMessages('de_short', timeago.DeShortMessages());
    timeago.setLocaleMessages('dv', timeago.DvMessages());
    timeago.setLocaleMessages('dv_short', timeago.DvShortMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
    timeago.setLocaleMessages('es', timeago.EsMessages());
    timeago.setLocaleMessages('es_short', timeago.EsShortMessages());
    timeago.setLocaleMessages('et', timeago.EtMessages());
    timeago.setLocaleMessages('et_short', timeago.EtShortMessages());
    timeago.setLocaleMessages('fa', timeago.FaMessages());
    timeago.setLocaleMessages('fi', timeago.FiMessages());
    timeago.setLocaleMessages('fi_short', timeago.FiShortMessages());
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    timeago.setLocaleMessages('gr', timeago.GrMessages());
    timeago.setLocaleMessages('gr_short', timeago.GrShortMessages());
    timeago.setLocaleMessages('he', timeago.HeMessages());
    timeago.setLocaleMessages('he', timeago.HeMessages());
    timeago.setLocaleMessages('he_short', timeago.HeShortMessages());
    timeago.setLocaleMessages('hi', timeago.HiMessages());
    timeago.setLocaleMessages('hi_short', timeago.HiShortMessages());
    timeago.setLocaleMessages('hu', timeago.HuMessages());
    timeago.setLocaleMessages('hu_short', timeago.HuShortMessages());
    timeago.setLocaleMessages('id', timeago.IdMessages());
    timeago.setLocaleMessages('it', timeago.ItMessages());
    timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    timeago.setLocaleMessages('km', timeago.KmMessages());
    timeago.setLocaleMessages('km_short', timeago.KmShortMessages());
    timeago.setLocaleMessages('ko', timeago.KoMessages());
    timeago.setLocaleMessages('ku', timeago.KuMessages());
    timeago.setLocaleMessages('ku_short', timeago.KuShortMessages());
    timeago.setLocaleMessages('mn', timeago.MnMessages());
    timeago.setLocaleMessages('mn_short', timeago.MnShortMessages());
    timeago.setLocaleMessages('ms_MY', timeago.MsMyMessages());
    timeago.setLocaleMessages('ms_MY_short', timeago.MsMyShortMessages());
    timeago.setLocaleMessages('nb_NO', timeago.NbNoMessages());
    timeago.setLocaleMessages('nb_NO_short', timeago.NbNoShortMessages());
    timeago.setLocaleMessages('nl', timeago.NlMessages());
    timeago.setLocaleMessages('nl_short', timeago.NlShortMessages());
    timeago.setLocaleMessages('nn_NO', timeago.NnNoMessages());
    timeago.setLocaleMessages('nn_NO_short', timeago.NnNoShortMessages());
    timeago.setLocaleMessages('pl', timeago.PlMessages());
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
    timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
    timeago.setLocaleMessages('ro', timeago.RoMessages());
    timeago.setLocaleMessages('ro_short', timeago.RoShortMessages());
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('ru_short', timeago.RuShortMessages());
    timeago.setLocaleMessages('rw', timeago.RwMessages());
    timeago.setLocaleMessages('rw_short', timeago.RwShortMessages());
    timeago.setLocaleMessages('sv', timeago.SvMessages());
    timeago.setLocaleMessages('sv_short', timeago.SvShortMessages());
    timeago.setLocaleMessages('ta', timeago.TaMessages());
    timeago.setLocaleMessages('th', timeago.ThMessages());
    timeago.setLocaleMessages('th_short', timeago.ThShortMessages());
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    timeago.setLocaleMessages('uk', timeago.UkMessages());
    timeago.setLocaleMessages('uk_short', timeago.UkShortMessages());
    timeago.setLocaleMessages('ur', timeago.UrMessages());
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    timeago.setLocaleMessages('vi_short', timeago.ViShortMessages());
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
    timeago.setLocaleMessages('zh', timeago.ZhMessages());
  }

  @override
  Widget build(BuildContext context) {
    String? name;
    String? chat;
    String? fullName;
    String? lastMessage = timeago.format(
        DateTime.parse(widget.customer!.time!)
            .subtract(const Duration(microseconds: 1 * 44 * 1000)),
        locale: 'en');

    if (widget.customer != null) {
      name = "${widget.customer!.userName}";
      fullName = "${widget.customer!.fullName}";
      chat = "${widget.customer!.lastMessage}";
      if (chat == "") {
        chat = "Photo";
      }
    }

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        "assets/images/user_avatar.jpg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName ?? "John Doe",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          name ?? "John Doe",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(children: [
                          chat == "Photo"
                              ? Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                )
                              : Container(),
                          Flexible(
                            child: Text(
                              chat ??
                                  "Halo, apa barang ini ready banyak? karena saya mau order grosiran apa dapat potongan harga ya?",
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(lastMessage),
                      Visibility(
                          visible: widget.customer!.unread != '0',
                          child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.red),
                              child: Text(
                                widget.customer!.unread!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemChatShimmer extends StatelessWidget {
  const ItemChatShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      "assets/images/user_avatar.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 14,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    const SizedBox(height: 2),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.green),
                        child: const Text(
                          "10",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
