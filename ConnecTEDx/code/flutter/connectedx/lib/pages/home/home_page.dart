import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectedx/models/home_tab_model.dart';
import 'package:connectedx/pages/home/tabs/events.dart';
import 'package:connectedx/pages/home/tabs/videos.dart';
import 'package:connectedx/pages/home/tabs/people.dart';
import 'package:connectedx/pages/home/tabs/chats.dart';
import 'package:connectedx/pages/home/tabs/profile.dart';

final indexTabProvider = StateProvider<int>((ref) => 0);

const String loggedUser = "t";

final List<HomeTab> tabList = [
  HomeTab(
    label: "Partecipa ad eventi",
    icon: Icons.event,
    content: const PageEvent(loggedUser: loggedUser),
  ),
  HomeTab(
    label: "Guarda TEDx Talks",  
    icon: Icons.smart_display,
    content: const PageVideo(loggedUser: loggedUser),
  ),
  HomeTab(
    label: "Scopri persone affini",  
    icon: Icons.groups,
    content: const PagePeople(loggedUser: loggedUser),
  ),
  HomeTab(
    label: "Le mie chat",  
    icon: Icons.chat,
    content: const PageChat(),
  ),
  HomeTab(
    label: "Modifica profilo",  
    icon: Icons.person,
    content: const PageProfile(loggedUser: loggedUser),
  ),
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(indexTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: Text(
          tabList[currentIndex].label,
          style: const TextStyle(color: Colors.white),
          ), 
        backgroundColor: const Color(0xFFEE2921),
      ),
      body: tabList[currentIndex].content,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFEE2921),
        indicatorColor: const Color(0xFFF14D46),
        onDestinationSelected: (int index) {
          ref.read(indexTabProvider.notifier).state = index;
        },
        selectedIndex: currentIndex,
        destinations: tabList
            .map(
              (singleScreenTab) => NavigationDestination(
                icon: Icon(singleScreenTab.icon, color: Colors.white),
                
                label: "",
              ),
            )
            .toList(),
      ),
    );
  }
}
