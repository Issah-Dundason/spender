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
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 5)),
        ]
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text("You haven't set any budget for this month", style: TextStyle(
                 fontSize: 16,
                color: Theme.of(context).colorScheme.onSecondary
              ), textAlign: TextAlign.center,),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Text("Tap ", style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary
                    )),
                    const SizedBox(width: 5,),
                    TextButton(
                      onPressed: () async {
                       await  Navigator.of(context).push(TopBar.createRoute());
                       if(!mounted) return;
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
      ),
    );
  }
}
