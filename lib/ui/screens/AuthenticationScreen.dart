import 'package:flutter/material.dart';
import '../components/login_component.dart';
import '../components/register_component.dart';
import '../widgets/screen_util.dart';


class AuthenticationScreen extends StatefulWidget {
  final String role;
  final bool allowRegister;

  AuthenticationScreen({Key? key, required this.role, required this.allowRegister}) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.allowRegister ? 2 : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ScreenUtil(
        color: Colors.transparent,
        screenType: ScreenType.column,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'EducaNet',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TabBar(
                controller: _tabController,
                tabs: widget.allowRegister
                    ? [Tab(text: 'Acceso'), Tab(text: 'Crear una cuenta')]
                    : [Tab(text: 'Acceso')],
                indicatorColor: Colors.blue,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: widget.allowRegister
                      ? [LoginComponent(), RegisterComponent(role: widget.role)]
                      : [LoginComponent()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
