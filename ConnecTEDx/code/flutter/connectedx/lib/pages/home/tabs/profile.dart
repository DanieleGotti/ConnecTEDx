import 'package:connectedx/pages/home/home_page.dart';
import 'package:connectedx/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:connectedx/models/user_item.dart';

class PageProfile extends StatefulWidget {
  final String loggedUser;
  const PageProfile({super.key, required this.loggedUser});

  @override
  // ignore: library_private_types_in_public_api
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  UserItem? userItem;
  bool _isLoading = true;
  // ignore: unused_field
  bool _showTesterMessage = false; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _positionController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      UserRepository userRepository = UserRepository();
      userItem = await userRepository.fetchUserById(loggedUser);
      _nameController.text = userItem?.name ?? '';
      _surnameController.text = userItem?.surname ?? '';
      _positionController.text = userItem?.position ?? '';
      _emailController.text = userItem?.email ?? '';
      _passwordController.text = userItem?.password ?? '';
    } catch (e) {
      _showErrorSnackbar('Failed to load user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showTesterMessageSnackbar() {
    const snackBar = SnackBar(
      content: Text("Non è possibile modificare i dati di Tester. Nuova funzionalità presto disponibile"),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: _isLoading
          ? Container(
              color: const Color(0xFFF1F1F1), 
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF017DC7), 
                ),
              ),
            )
          : userItem == null
              ? const Center(child: Text('Utente non trovato'))
              : Container(
                  color: const Color(0xFFF1F1F1),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(userItem!.image),
                                ),
                                const SizedBox(height: 16.0),
                                TextButton(
                                  onPressed: () {
                                    _showTesterMessageSnackbar(); 
                                  },
                                  child: Text(
                                    'Modifica immagine',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: const Color(0xFF017DC7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24.0),
                                _buildTextFieldRow('Nome', _nameController),
                                const SizedBox(height: 16.0),
                                _buildTextFieldRow('Cognome', _surnameController),
                                const SizedBox(height: 16.0),
                                _buildTextFieldRow('Posizione', _positionController),
                                const SizedBox(height: 16.0),
                                _buildTextFieldRow('Email', _emailController),
                                const SizedBox(height: 16.0),
                                _buildPasswordFieldRow('Password', _passwordController),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40, 
            child: TextField(
              onTap: () {
                _showTesterMessageSnackbar();
                setState(() {
                  _showTesterMessage = true;
                });
              },
              controller: controller,
              style: const TextStyle(fontSize: 14.0), 
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), 
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017DC7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017DC7)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFieldRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40, 
            child: TextField(
              onTap: () {
                _showTesterMessageSnackbar();
                setState(() {
                  _showTesterMessage = true;
                });
              },
              controller: controller,
              style: const TextStyle(fontSize: 14.0), 
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), 
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF017DC7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017DC7)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF017DC7)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
