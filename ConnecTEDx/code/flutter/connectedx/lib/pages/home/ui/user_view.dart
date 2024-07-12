import 'package:connectedx/models/percentage_item.dart';
import 'package:connectedx/repository/percentage_repository.dart';
import 'package:flutter/material.dart';
import 'package:connectedx/models/user_item.dart';

class UserView extends StatefulWidget {
  final UserItem userItem;
  final bool showDistance;

  const UserView({super.key, required this.userItem, this.showDistance = false});

  @override
  // ignore: library_private_types_in_public_api
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late Future<List<UserPercentage>> _interests;

  @override
  void initState() {
    super.initState();
    _interests = getPercentage(widget.userItem.id);
  }

  Future<List<UserPercentage>> getPercentage(String userId) async {
    return PercentageRepository().fetchPercentagesById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserPercentage>>(
      future: _interests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("");
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<UserPercentage> interests = snapshot.data!;
          return Container(
            margin: const EdgeInsets.all(10.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(widget.userItem.image),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userItem.name,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.userItem.surname,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.userItem.position,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                          Visibility(
                            visible: widget.userItem.distance != null && widget.userItem.distance != 'null',
                            child: Text(
                              "A ${widget.userItem.distance}",
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: interests.take(2).map((interest) {
                          double percentageValue = double.parse(interest.percentage.replaceAll('%', ''));
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 45,
                                  child: Text(
                                    interest.tag,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                    softWrap: true,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  flex: 25,
                                  child: LinearProgressIndicator(
                                    value: percentageValue / 100.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  flex: 30,
                                  child: Text(
                                    interest.percentage,
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF017DC7),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No interests available'));
        }
      },
    );
  }
}
