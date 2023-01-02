import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/app_event.dart';
import 'package:spender/icons/icons.dart';
import 'package:spender/model/model.dart';
import 'package:spender/repository/expenditure_repo.dart';

import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import 'expenses.dart';
import 'home_page.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit bloc) => bloc.state);
    return Scaffold(
      body: IndexedStack(
        index: selectedTab.current.index,
        children: const [HomePage(), ExpensesPage()],
      ),
      bottomNavigationBar: const MainBottomAppBar(),
    );
  }
}

class MainBottomAppBar extends StatelessWidget {
  const MainBottomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.current != HomeTab.bill) return;
        var appRepo = context.read<AppRepository>();
        showModalBottomSheet(
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            context: context,
            builder: (_) => _BillView(appRepo: appRepo,));

        context.read<HomeCubit>().currentState =
            HomeState(current: state.previous);
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  color: state.current == HomeTab.home
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  alignment: Alignment.center,
                  splashRadius: 30,
                  onPressed: () => context.read<HomeCubit>().currentState =
                      HomeState(previous: state.current, current: HomeTab.home),
                  icon: const Icon(HomeIcon.icon)),
              CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: IconButton(
                      splashRadius: 30,
                      onPressed: () => context.read<HomeCubit>().currentState =
                          HomeState(
                              previous: state.current, current: HomeTab.bill),
                      icon: const Icon(AddIcon.icon))),
              IconButton(
                  color: state.current == HomeTab.expenses
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  iconSize: 40,
                  splashRadius: 30,
                  onPressed: () => context.read<HomeCubit>().currentState =
                      HomeState(
                          previous: state.current, current: HomeTab.expenses),
                  icon: const Icon(
                    CardIcon.icon,
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _BillView extends StatelessWidget {
  final AppRepository appRepo;

  const _BillView({Key? key, required this.appRepo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillBloc>(
      create: (context) =>
      BillBloc(appRepo: appRepo)
        ..add(BillInitializationEvent()),
      child: _BillSheet(),
    );
  }
}


class _BillSheet extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  _BillSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillBloc, BillingState>(
      builder: (context, state) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12)),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 24, right: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                onChanged: (s) => context
                                    .read<BillBloc>()
                                    .add(BillTitleChangeEvent(s)),
                                decoration: const InputDecoration(
                                    hintText: "bill name"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: ProductTypeDropDown<ProductType>(
                              title: "Bill Type",
                              items: state.billTypes,
                              menuItemBuilder: (t) => Text(t.name),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                initialValue: state.amount,
                                onChanged: (s) => context
                                    .read<BillBloc>()
                                    .add(BillAmountChangeEvent(s)),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                                ],
                                decoration: const InputDecoration(
                                    hintText: "amount paid"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: ProductTypeDropDown<PaymentType>(
                              title: "Payment Type",
                              value: state.paymentType,
                              menuItemBuilder: (t) => Text(t.name, softWrap: false, overflow: TextOverflow.ellipsis,),
                              items: PaymentType.values,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              flex: 4,
                              child: TextFormField(
                                onChanged: (s) => context
                                    .read<BillBloc>()
                                    .add(BillDescriptionEvent(s)),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 2,
                                maxLines: 9,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                    hintText: "description"),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                           Expanded(
                            flex: 2,
                            child: ProductTypeDropDown<Priority>(
                              value: state.priority,
                              title: "Priority",
                              menuItemBuilder: (t) => Text(t.name),
                              items: Priority.values,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Center(
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: const Text("ADD")))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductTypeDropDown<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? value;
  final Widget Function(T) menuItemBuilder;
  final void Function(T?)? onChange;

  const ProductTypeDropDown(
      {Key? key,
      required this.title,
      this.items = const [],
      required this.menuItemBuilder,
      this.value,
      this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //  mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        DropdownButton<T>(
          isExpanded: true,
          onChanged: (s) {if(onChange != null) onChange!(s); },
          alignment: AlignmentDirectional.bottomEnd,
          hint: const Padding(
            padding:  EdgeInsets.only(bottom: 15),
            child:  Text("----Select"),
          ),
          value: value,
          itemHeight: null,
          items: [
            ...items.map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: menuItemBuilder(e),
                ))
          ],
        )
      ],
    );
  }
}
