import 'package:connectedx/pages/home/home_page.dart';
import 'package:connectedx/pages/home/ui/user_view.dart';
import 'package:connectedx/repository/distance_repository.dart';
import 'package:flutter/material.dart';
import 'package:connectedx/models/user_item.dart';
import 'package:connectedx/models/percentage_item.dart';
import 'package:connectedx/repository/user_repository.dart';
import 'package:connectedx/repository/percentage_repository.dart';

class PagePeople extends StatefulWidget {
  final String loggedUser;

  const PagePeople({super.key, required this.loggedUser});

  @override
  // ignore: library_private_types_in_public_api
  _PagePeopleState createState() => _PagePeopleState();
}

class _PagePeopleState extends State<PagePeople> {
  List<Map<String, String>> interests = [];
  UserItem? user;
  bool _isPositionChecked = false;
  bool _isLoading = true;
  bool _isUserLoading = false;

  final UserRepository _userRepository = UserRepository();
  final DistanceRepository _distanceRepository = DistanceRepository();
  List<UserItem> _users = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userRepository = UserRepository();
      final percentageRepository = PercentageRepository();

      UserItem? fetchedUser = await userRepository.fetchUserById(loggedUser); 
      setState(() {
        user = fetchedUser;
      });

      List<UserPercentage>? fetchedPercentages = await percentageRepository.fetchPercentagesById(loggedUser);
      setState(() {
        interests = fetchedPercentages.map((item) {
          return {
            'name': item.tag, 
            'percentage': item.percentage.toString(), 
          };
        }).toList();
        _updateAltroPercentage();
      });
    
      _fetchUsers();
    } catch (error) {
      _showSnackbar("Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  void _updateAltroPercentage() {
    double totalPercentage = 0;
    for (var interest in interests) {
      totalPercentage += double.parse(interest['percentage']!.replaceAll('%', ''));
    }

    double newAltroPercentage = 100 - totalPercentage;

    interests.removeWhere((element) => element['name'] == 'Altro');

    interests.add({
      'name': 'Altro',
      'percentage': '$newAltroPercentage%', 
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _fetchUsers() async {
    setState(() {
      _isUserLoading = true;
      _page = 1;
    });

    try {
      List<UserItem> users;

      if (_isPositionChecked) {
        final distanceList = await _distanceRepository.fetchDistance(loggedUser, _page);

        List<Future<UserItem?>> userFutures = distanceList.map((distance) async {
          if (distance.id == loggedUser) return null;
          UserItem? user = await _userRepository.fetchUserById(distance.id);
          user.distance = distance.distance;
          return user;
        }).toList();

        users = await Future.wait(userFutures).then((results) => results.whereType<UserItem>().toList());
      } else {
        final casualUsers = await _userRepository.fetchCasualUsers(_page);
        users = casualUsers.where((user) => user.id != loggedUser).toList();
      }

      setState(() {
        _users = users;
      });
    } catch (error) {
      _showSnackbar('Errore nel caricamento degli utenti: $error');
    } finally {
      setState(() {
        _isUserLoading = false;
      });
    }
  }

  void _loadMore() async {
    setState(() {
      _isUserLoading = true;
    });

    _page++;
    try {
      List<UserItem> moreUsers;

      if (_isPositionChecked) {
        final distanceList = await _distanceRepository.fetchDistance(loggedUser, _page);

        List<Future<UserItem?>> userFutures = distanceList.map((distance) async {
          if (distance.id == loggedUser) return null;
          UserItem? user = await _userRepository.fetchUserById(distance.id);
          user.distance = distance.distance;
          return user;
        }).toList();

        moreUsers = await Future.wait(userFutures).then((results) => results.whereType<UserItem>().toList());
      } else {
        final users = await _userRepository.fetchCasualUsers(_page);
        final userSet = {..._users.map((e) => e.id)};
        moreUsers = users.where((user) => !userSet.contains(user.id) && user.id != loggedUser).toList();
      }

      setState(() {
        _users.addAll(moreUsers);
      });
    } catch (error) {
      _showSnackbar('Errore nel caricamento degli utenti: $error');
      setState(() {
        _page--;
      });
    } finally {
      setState(() {
        _isUserLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? _buildLoadingScreen() : _buildMainScreen();
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017DC7)),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1), 
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0), 
            child: Card(
              color: Colors.white,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2.0),
                              ),
                              child: user?.image != null
                                  ? Image.network(
                                      user!.image,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 100.0,
                                      color: Colors.blue,
                                    ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              user?.name ?? 'Nome utente',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                            Text(
                              user?.position ?? 'Luogo',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "I tuoi interessi",
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                            ),
                            for (int i = 0; i < interests.length; i++)
                              _buildInterestRow(context, interests[i]['name']!, interests[i]['percentage']!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), 
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPositionChecked ? Icons.location_on : Icons.location_on_outlined,
                    color: _isPositionChecked ? const Color(0xFF017DC7) : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPositionChecked = !_isPositionChecked;
                      _fetchUsers();
                    });
                  },
                ),
                Text(
                  'Vicini a me',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    return UserView(userItem: _users[index], showDistance: _isPositionChecked);
                  },
                ),
                if (_isUserLoading)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFF1F1F1).withOpacity(0.75),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF017DC7),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), 
            child: ElevatedButton(
              onPressed: _loadMore,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return const Color(0xFF017DC7);
                  },
                ),
                overlayColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return const Color(0xFF017DC7);
                    }
                    return Colors.white;
                  },
                ),
              ),
              child: const Text('Carica altri'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestRow(BuildContext context, String interestName, String percentage) {
    double percentageValue = double.parse(percentage.replaceAll('%', ''));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 45,
            child: Text(
              interestName,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 30,
            child: LinearProgressIndicator(
              value: percentageValue / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            flex: 30,
            child: Text(
              percentage,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF017DC7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
