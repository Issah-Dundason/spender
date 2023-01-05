import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spender/pages/home_page.dart';

class AppProfile extends StatefulWidget {
  const AppProfile({Key? key}) : super(key: key);

  @override
  State<AppProfile> createState() => _AppProfileState();
}

class _AppProfileState extends State<AppProfile> {
  @override
  Widget build(BuildContext context) {
    return (SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change your avatar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        AvatarProfile(
                          avatarWidth: 70,
                          avatarHeight: 70,
                          backColor: Colors.blueAccent,
                        ),
                        SizedBox(width: 15),
                        Column(
                          children: [
                            Divider(),
                            Container(
                              height: 50,
                              width: 270,
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context,
                                          int index) =>
                                      AvatarProfile(
                                          avatarHeight: 50,
                                          avatarWidth: 50,
                                          backColor: Colors.deepOrangeAccent),
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          SizedBox(width: 10),
                                  itemCount: 20),
                            ),
                            Divider(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  const Text(
                    'Current Month Budget',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Form(
                    child: Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: const InputDecoration(
                                    hintText: "enter monthly budget"),
                              ),
                            )),
                        SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Icon(Icons.update),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  TitleButtonComponent(
                      topTitle: "Budgets", buttonText: "Select Year"),
                  DataTable(columns: [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Amount',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ], rows: [
                    DataRow(cells: [
                      DataCell(Text('10567')),
                      DataCell(Text('GHS200.00')),
                      DataCell(Text('4-Jan-2023')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('10567')),
                      DataCell(Text('GHS200.00')),
                      DataCell(Text('4-Jan-2023')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('10567')),
                      DataCell(Text('GHS200.00')),
                      DataCell(Text('4-Jan-2023')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('10567')),
                      DataCell(Text('GHS200.00')),
                      DataCell(Text('4-Jan-2023')),
                    ]),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class AvatarProfile extends StatelessWidget {
  const AvatarProfile(
      {Key? key,
      required this.avatarHeight,
      required this.avatarWidth,
      required this.backColor})
      : super(key: key);
  final double avatarHeight;
  final double avatarWidth;
  final Color backColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: avatarWidth,
      height: avatarHeight,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: SvgPicture.asset('assets/images/avatar/035-man.svg'),
    );
  }
}
