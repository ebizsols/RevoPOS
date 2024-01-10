import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/layers/presentation/pos/widget/item_draft.dart';

class DraftPage extends StatefulWidget {
  const DraftPage({Key? key}) : super(key: key);

  @override
  _DraftPageState createState() => _DraftPageState();
}

class _DraftPageState extends State<DraftPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // context.read<DraftNotifier>().scanBarcode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: colorWhite,
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: 5,
      itemBuilder: (_, index) {
        return const ItemDraft();
      },
      separatorBuilder: (_, index) => const SizedBox(height: 12),
    );
  }

  _buildAppBar() => AppBar(
    title: const Text("All Draft (5)"),
  );
}
