import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/user/ui/screens/create_user_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class ItemUserAdminList extends StatefulWidget {
  final List<SysUser> userList;
  final int index;

  ItemUserAdminList(this.userList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemUserAdminList();
}

class _ItemUserAdminList extends State<ItemUserAdminList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BlocProvider(
                bloc: UserBloc(),
                child: CreateUserAdminPage(
                  currentUser: widget.userList[widget.index],
                ),
              );
            },
          ),
        );
      },
      child: itemDecoration(widget.userList[widget.index]),
    );
  }

  Widget itemDecoration(SysUser _itemUser) {
    String _userType = '';
    if (_itemUser.isAdministrator ?? false)
      _userType = 'Administrador';
    else if (_itemUser.isCoordinator ?? false)
      _userType = 'Coordinador';
    else if (_itemUser.isOperator ?? false)
      _userType = 'Operator';
    else
      _userType = 'Usuario';

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 70.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 18),
                    alignment: Alignment.centerLeft,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Colors.grey,
                      ),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _itemUser.photoUrl?.isEmpty ?? true
                            ? AssetImage('assets/images/profile_placeholder.png') as ImageProvider
                            : NetworkImage(_itemUser.photoUrl ?? '') as ImageProvider ,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //direction: Axis.vertical,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _itemUser.name??'',
                            style: TextStyle(
                              fontFamily: "Lato",
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.none,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _itemUser.email,
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _userType,
                            style: TextStyle(
                              fontFamily: "Lato",
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 25,
              margin: EdgeInsets.only(right: 8.0),
              child: _itemUser.active ?? false
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
