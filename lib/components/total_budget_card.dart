import 'package:flutter/material.dart';

class TotalBudgetCard extends StatelessWidget {
  final double budget;
  const TotalBudgetCard({super.key, this.budget = 59765.00});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const SmallBgProjection(),
        Align(
          alignment: Alignment(0, 0),
          child: SizedBox(
            width: 300,
            height: 150,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Buget",
                            style: TextStyle(color: Colors.grey[500])),
                        const Icon(Icons.more_horiz, color: Colors.white)
                      ],
                    ),
                    Text(
                      "\$$budget",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SmallBgProjection extends StatelessWidget {
  const SmallBgProjection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.1, -0.2),
      child: SizedBox(
        height: 100,
        width: 260,
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.indigo[500]),
      ),
    );
  }
}
