import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spender/bloc/app_bloc.dart';
import 'package:spender/pages/expenses.dart';
import 'package:spender/pages/home_page.dart';
import 'package:spender/repository/expenditure_repo.dart';
import 'package:spender/service/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DatabaseClient dbClient = await DatabaseClient().init();

  AppRepository appRepo = AppRepository(dbClient);

  runApp(Spender(
    appRepo: appRepo,
  ));
}

class Spender extends StatelessWidget {
  final AppRepository appRepo;

  const Spender({super.key, required this.appRepo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RepositoryProvider<AppRepository>.value(
          value: appRepo,
          child: BlocProvider<HomeCubit>(
              create: (_) => HomeCubit(), child: const AppView())),
    );
  }
}

class AppView extends StatelessWidget {

  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit bloc) => bloc.state);
    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
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
    return BottomAppBar(child: Row(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.home_mini_rounded)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.home_mini_rounded)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.home_mini_rounded))
      ],
    ),);
  }
}
