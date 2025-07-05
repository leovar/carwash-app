import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/user/ui/screens/create_user_admin_page.dart';
import 'package:car_wash_app/user/ui/widgets/item_user_admin_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UsersAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UsersAdminPage();
}

class _UsersAdminPage extends State<UsersAdminPage>
    with SingleTickerProviderStateMixin {
  late UserBloc _userBloc;
  late TabController _tabController;
  List<SysUser> _userList = <SysUser>[];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Usuarios",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _bodyContainer(),
      ),
    );
  }

  Widget _bodyContainer() {
    return StreamBuilder(
      stream: _userBloc.allUsersStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading user data"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Users not found"));
        }
        return _listUsersContainer(snapshot);
      },
    );
  }

  Widget _listUsersContainer(AsyncSnapshot snapshot) {
    _userList = _userBloc.buildAllUsers(snapshot.data.docs);
    List<SysUser> _activeUsers = _userList.where((x) => x.active == true).toList();
    List<SysUser> _inactiveUsers = _userList.where((x) => x.active == false).toList();
    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).colorScheme.secondary,
              tabs: [
                Tab(
                  text: 'Usuarios activos',
                ),
                Tab(
                  text: 'Usuarios inactivos',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _showActiveUsers(_activeUsers),
                _showInactiveUsers(_inactiveUsers),
              ],
              controller: _tabController,
            ),
          ),
          _buttonNewUser(),
        ],
      ),
    );
  }

  Widget _listUsersStream() {
    return StreamBuilder(
      stream: _userBloc.allUsersStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getDataUsersList(snapshot);
        }
      },
    );
  }

  Widget _getDataUsersList(AsyncSnapshot snapshot) {
    _userList = _userBloc.buildAllUsers(snapshot.data.docs);
    List<SysUser> _activeUsers = _userList.where((x) => x.active == true).toList();
    List<SysUser> _inactiveUsers =
        _userList.where((x) => x.active == false).toList();
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Material(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(
                text: 'Usuarios activos',
              ),
              Tab(
                text: 'Usuarios inactivos',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _showActiveUsers(_activeUsers),
              _showInactiveUsers(_inactiveUsers),
            ],
            controller: _tabController,
          ),
        ),
      ],
    );
  }

  Widget _showActiveUsers(List<SysUser> activeUsers) {
    return ListView.builder(
      itemCount: activeUsers.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ItemUserAdminList(activeUsers, index);
      },
    );
  }

  Widget _showInactiveUsers(List<SysUser> inactiveUsers) {
    return ListView.builder(
      itemCount: inactiveUsers.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ItemUserAdminList(inactiveUsers, index);
      },
    );
  }

  Widget _buttonNewUser() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(
        top: 8,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Color(0xFF59B258),
          ),
          child: Text(
            "Nuevo Usuario",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: _updateCompanyUsers,
        ),
      ),
    );
  }

  void _updateCompanyUsers() async {
    _userList.forEach((item) async {
      if (item.companyId == null) {
        SysUser newUser = SysUser.copyWith(origin: item, companyId: 'gtixUTsEImKUuhdSCwKX');
        await _userBloc.updateUserCompany(newUser);
      }
    });
    Fluttertoast.showToast(msg: "Usuario actualizados con la compania gtixUTsEImKUuhdSCwKX", toastLength: Toast.LENGTH_LONG);
  }
}
