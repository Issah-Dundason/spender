import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/home/home_event.dart';
import 'package:spender/components/appbar.dart';

import '../bloc/home/home_bloc.dart';

class NoBudgetWidget extends StatefulWidget {
  const NoBudgetWidget({Key? key}) : super(key: key);

  @override
  State<NoBudgetWidget> createState() => _NoBudgetWidgetState();
}

class _NoBudgetWidgetState extends State<NoBudgetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 150,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        image: const DecorationImage(image: AssetImage("assets/images/no_budget.png", ), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 5)),
        ]
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text("You haven't set any budget for this month", style: TextStyle(
               fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondary
            ),),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Text("Click ", style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary
                  )),
                  const SizedBox(width: 5,),
                  TextButton(
                    onPressed: () async {
                     await  Navigator.of(context).push(TopBar.createRoute());
                     if(!mounted) return;
                     print('Yeah');
                     context.read<HomeBloc>().add(const HomeInitializationEvent());
                    },
                    style: TextButton.styleFrom(
                      shape:  RoundedRectangleBorder(side: BorderSide(width: 2, color: Theme.of(context).colorScheme.onSecondary)),
                      padding: EdgeInsets.zero
                    ),
                    child:  Text("here", style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary
                    )),
                  ),
                  const SizedBox(width: 5,),
                   Text("to set budget", style: TextStyle(
                       color: Theme.of(context).colorScheme.onSecondary
                   ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
