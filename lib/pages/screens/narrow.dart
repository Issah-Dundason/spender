import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spender/bloc/bill/bill_bloc.dart';
import 'package:spender/bloc/bill/billing_state.dart';
import 'package:spender/pages/bill_view.dart';

import '../../bloc/app/app_cubit.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/appbar.dart';
import '../../components/bottom_appbar.dart';
import '../expenses.dart';
import '../home_page.dart';


class NarrowWidthView extends StatefulWidget {
  const NarrowWidthView({
    Key? key,
  }) : super(key: key);

  @override
  State<NarrowWidthView> createState() => _NarrowWidthViewState();
}

class _NarrowWidthViewState extends State<NarrowWidthView> {
  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((AppCubit bloc) => bloc.state);
    final profileState = context.select((ProfileBloc bloc) => bloc.state);
    return BlocListener<BillBloc, IBillingState>(
      listener: (context, state) {
        if(state is BillCreateState || state is BillUpdateState) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillView()));
        }
      },
      child: Scaffold(
        appBar: TopBar.getAppBar(
            context,
            toBeginningOfSentenceCase(selectedTab.name) as String,
            profileState.currentAvatar, () async {
          await Navigator.of(context).push(TopBar.createRoute());
          if (!mounted) return;
          context.read<HomeBloc>().add(const HomeInitializationEvent());
        }),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: IndexedStack(
          index: selectedTab.index,
          children: const [HomePage(), ExpensesPage()],
        ),
        bottomNavigationBar: const MainBottomAppBar(),
      ),
    );
  }
}