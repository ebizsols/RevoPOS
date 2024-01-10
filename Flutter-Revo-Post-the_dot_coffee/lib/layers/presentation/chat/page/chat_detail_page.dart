import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:revo_pos/core/utils/global_functions.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/core/utils/route_builder.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists.dart';
import 'package:revo_pos/layers/domain/entities/chat_lists_detail.dart';
import 'package:revo_pos/layers/domain/entities/customer.dart';
import 'package:revo_pos/layers/domain/entities/order.dart';
import 'package:revo_pos/layers/domain/entities/product_image.dart';
import 'package:revo_pos/layers/presentation/chat/notifier/chat_notifier.dart';
import 'package:revo_pos/layers/presentation/chat/widget/detail_image.dart';
import 'package:revo_pos/layers/presentation/chat/widget/image_send.dart';
import 'package:revo_pos/layers/presentation/chat/widget/item_chat.dart';
import 'package:revo_pos/layers/presentation/customers/widget/bottom_sheet_detail_customer.dart';
import 'package:revo_pos/layers/presentation/main/notifier/main_notifier.dart';
import 'package:revo_pos/layers/presentation/main/widget/drawer_main.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/detail_order_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/notifier/orders_notifier.dart';
import 'package:revo_pos/layers/presentation/orders/page/detail_order_page.dart';
import 'package:revo_pos/layers/presentation/pos/notifier/pos_notifier.dart';
import 'package:revo_pos/layers/presentation/pos/page/pos_page.dart';
import 'package:revo_pos/layers/presentation/revo_pos_image.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';
import 'package:shimmer/shimmer.dart';

import '../../revo_pos_text_field.dart';

class ChatDetailPage extends StatefulWidget {
  final int? chatID;
  final String? username;
  final int? receiverID;
  final int? orderID;
  final Orders? orders;
  const ChatDetailPage(
      {Key? key,
      this.chatID,
      this.username,
      this.receiverID,
      this.orderID,
      this.orders})
      : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  ScrollController? _scrollController;
  final text = TextEditingController();
  final List<ChatListsDetail> _detailChat = [];
  final picker = ImagePicker();
  File? _image;
  ChatNotifier? chatNotifier;
  OrdersNotifier? ordersNotifier;
  PosNotifier? posNotifier;
  DetailOrderNotifier? detailOrderNotifier;
  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
    ordersNotifier = Provider.of<OrdersNotifier>(context, listen: false);
    detailOrderNotifier =
        Provider.of<DetailOrderNotifier>(context, listen: false);
    posNotifier = Provider.of<PosNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.receiverID != null) {
        context
            .read<DetailOrderNotifier>()
            .getDetailCustomer(widget.receiverID!);
      }
      context
          .read<ChatNotifier>()
          .getDetailChat(chatID: widget.chatID, receiverID: widget.receiverID)
          .then((value) => scrollToBottom());
    });
    if (widget.orderID != null) {
      sendOrder = true;
    }
  }

  void scrollToBottom() {
    if (_scrollController!.hasClients) {
      Timer(Duration(milliseconds: 500), () {
        _scrollController!.animateTo(
            _scrollController!.position.maxScrollExtent * 2.5,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((ChatNotifier n) => n.isLoading);
    final loadingChat = context.select((ChatNotifier n) => n.loadingChat);
    final loadingSend = context.select((ChatNotifier n) => n.loadingSend);
    final page = context.select((ChatNotifier n) => n.chatPage);
    final list = context.select((ChatNotifier n) => n.detailChatList);
    final tempList = context.select((ChatNotifier n) => n.tempChatLists);

    return Scaffold(
      appBar: _buildAppBar(),
      body: loadingChat && loadingSend
          ? RevoPosLoading()
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10, bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        _buildList(
                            chats: list, isLoading: loadingChat, page: page),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(loadingSend)
              ]),
            ),
    );
  }

  _buildAppBar() => AppBar(
        backgroundColor: colorWhite,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          widget.username == ""
              ? detailOrderNotifier!.customer!.username!
              : widget.username!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildList(
      {List<ChatListsDetail?>? chats,
      required bool isLoading,
      required int page}) {
    return isLoading
        ? RevoPosLoading()
        : Container(
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: chats!.length,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemBuilder: (_, index) {
                return Column(
                  children: [
                    Container(
                      child: Text(
                        chats[index]!.date!,
                        style:
                            TextStyle(fontSize: 14, color: HexColor("c8c8c8")),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: chats[index]!.chatDetail!.length,
                        itemBuilder: (_, j) {
                          return _buildCardChat(chats[index]!.chatDetail![j]);
                        })
                  ],
                );
              },
            ),
          );
  }

  _buildCardOrder(ChatDetail chat) {
    String name = "";
    if (chat.subject!.status != "Product") {
      name = chat.subject!.name!;
    } else if (chat.subject!.name!.length > 11) {
      name = chat.subject!.name!.substring(0, 11) + "...";
    } else if (chat.subject!.name!.length <= 11) {
      name = chat.subject!.name!;
    }
    return chat.subject == null
        ? Container()
        : GestureDetector(
            onTap: () async {
              if (chat.subject!.status!.toLowerCase() == "product") {
                await Navigator.push(
                    context,
                    RevoPosRouteBuilder.routeBuilder(PosPage(
                      pos: 1,
                      nameProduct: chat.subject!.name,
                    )));
              } else {
                context.read<OrdersNotifier>().getOrders(search: "");
                for (int i = 0; i < ordersNotifier!.orders!.length; i++) {
                  if (ordersNotifier!.orders![i].id == chat.subject!.id) {
                    await Navigator.push(
                        context,
                        RevoPosRouteBuilder.routeBuilder(DetailOrderPage(
                          orders: ordersNotifier!.orders![i],
                        )));
                  }
                }
              }
            },
            child: Row(
                mainAxisAlignment: chat.potition == "left"
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 250),
                    alignment: chat.potition == "left"
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: HexColor("c8c8c8")),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: RevoPosImage(
                              url: chat.subject!.imageFirst!,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(chat.subject!.status!),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    "${MultiCurrency.convert(double.parse(chat.subject!.price!), context)}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                ]),
          );
  }

  _buildCardChat(ChatDetail chat) {
    return Container(
      child: Column(
        children: [
          chat.subject != null ? _buildCardOrder(chat) : Container(),
          chat.image == null
              ? Row(
                  mainAxisAlignment: chat.potition == "left"
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        alignment: chat.potition == "left"
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topLeft: chat.potition == "left"
                                ? Radius.circular(0)
                                : Radius.circular(10),
                            topRight: chat.potition == "right"
                                ? Radius.circular(0)
                                : Radius.circular(10),
                          ),
                          color: chat.potition == "left"
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.secondary,
                        ),
                        child: Column(
                            crossAxisAlignment: chat.potition == "left"
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat.message!,
                                softWrap: true,
                                textAlign: chat.potition == "left"
                                    ? TextAlign.left
                                    : TextAlign.right,
                                style: TextStyle(
                                    color: chat.potition == "left"
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14),
                              ),
                              Text(
                                chat.time!,
                                textAlign: chat.potition == "left"
                                    ? TextAlign.right
                                    : TextAlign.end,
                                style: TextStyle(
                                    color: HexColor("c8c8c8"), fontSize: 11),
                              )
                            ]),
                      ),
                    ])
              : GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return DetailScreen(
                        image: chat.image,
                      );
                    }));
                  },
                  child: Row(
                      mainAxisAlignment: chat.potition == "left"
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 250),
                          alignment: chat.potition == "left"
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          padding: const EdgeInsets.only(
                              bottom: 5, top: 8, right: 8, left: 8),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              topLeft: chat.potition == "left"
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                              topRight: chat.potition == "right"
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                            ),
                            color: chat.potition == "left"
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          child: Column(
                              crossAxisAlignment: chat.potition == "left"
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: CachedNetworkImage(
                                    imageUrl: chat.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        RevoPosLoading(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                Text(
                                  chat.time!,
                                  textAlign: chat.potition == "left"
                                      ? TextAlign.right
                                      : TextAlign.end,
                                  style: TextStyle(
                                      color: chat.potition == "left"
                                          ? Colors.white
                                          : HexColor("c8c8c8"),
                                      fontSize: 11),
                                )
                              ]),
                        ),
                      ]),
                )
        ],
      ),
    );
  }

  _buildCardBottomOrder() {
    return widget.orders == null
        ? Container()
        : Container(
            constraints: BoxConstraints(maxWidth: 250),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              border:
                  Border.all(width: 2, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.white,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "ORDER #${widget.orders!.id!}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Text(widget.orders!.status!),
                      Text(
                        "${MultiCurrency.convert(double.parse(widget.orders!.total!), context)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
            ]),
          );
  }

  Future<Map<String, dynamic>> uploadImage(File file) async {
    List<int> imageBytes = file.readAsBytesSync();
    Map<String, dynamic> result = {};
    String base64Image = base64Encode(imageBytes);
    await chatNotifier!
        .uploadImage(title: "${"image".toLowerCase()}.jpg", image: base64Image)
        .then((value) {
      result = value;
    });
    return result;
  }

  Future getImageFromGallery() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const RevoPosLoading();
        });
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      uploadImage(_image!).then((value) {
        if (value != null) {
          Navigator.pop(context);
          printLog(value.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageSend(
                username: widget.username,
                image: _image,
                urlImage: value,
                receiverID: widget.receiverID == 0
                    ? chatNotifier!.receiverId!
                    : widget.receiverID,
              ),
            ),
          ).then(getBackProsesKirim);
        } else {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future getImageFromCamera() async {
    try {
      print("Picking Image");
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (pickedFile == null) return;
      final imageTemporary = File(pickedFile.path);
      setState(() {
        _image = imageTemporary;
      });
      print("Image Picked");

      if (_image != null) {
        print("Sending Image");
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const RevoPosLoading();
            });

        await uploadImage(_image!).then((value) {
          if (value != null) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageSend(
                  username: widget.username,
                  image: _image,
                  urlImage: value,
                  receiverID: widget.receiverID == 0
                      ? chatNotifier!.receiverId!
                      : widget.receiverID,
                ),
              ),
            ).then(getBackProsesKirim);
          } else {
            Navigator.pop(context);
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (error) {
      printLog("error: $error");
    }
  }

  getBackProsesKirim(dynamic value) {
    context
        .read<ChatNotifier>()
        .getDetailChat(chatID: widget.chatID, receiverID: widget.receiverID)
        .then((value) => scrollToBottom());
  }

  void _detailModalBottomSheet(context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 20, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 100),
                                child: Container(
                                  width:
                                      RevoPosMediaQuery.getWidth(context) * 0.5,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 60),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        getImageFromGallery();
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 30,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Image Gallery",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        getImageFromCamera();
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 30,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Camera",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool sendOrder = false;
  _buildBottomSection(bool loading) {
    return Stack(children: [
      widget.orderID != null && sendOrder
          ? Positioned(
              bottom: 70,
              left: 20,
              child: Container(
                width: 150,
                child: _buildCardBottomOrder(),
              ))
          : Container(),
      Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.grey.withOpacity(0.23),
                offset: Offset(0, 0),
              )
            ],
          ),
          child: Container(
            child: Row(children: [
              !sendOrder
                  ? GestureDetector(
                      onTap: () {
                        _detailModalBottomSheet(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Icon(Icons.image,
                            color: Theme.of(context).primaryColor),
                      ),
                    )
                  : Container(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: TextField(
                    controller: text,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Text Here ...",
                      hintStyle: TextStyle(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(17, 5, 17, 5),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (text.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please write a message first")));
                  } else {
                    if (!loading) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        context
                            .read<ChatNotifier>()
                            .sendChat(
                                message: text.text,
                                receiverID: widget.receiverID == 0
                                    ? chatNotifier!.receiverId!
                                    : widget.receiverID,
                                image: "",
                                postID: sendOrder ? widget.orderID : 0,
                                types:
                                    widget.orderID == null ? "chat" : "order")
                            .then((value) {
                          context
                              .read<ChatNotifier>()
                              .getDetailChat(
                                  chatID: widget.chatID,
                                  receiverID: widget.receiverID)
                              .then((value) => scrollToBottom());
                        });
                        setState(() {
                          sendOrder = false;
                        });
                        text.clear();
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child:
                      Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
              )
            ]),
          ),
        ),
      ),
    ]);
  }
}
