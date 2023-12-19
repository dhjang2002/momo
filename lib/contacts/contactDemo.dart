import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsDemo extends StatefulWidget {
  const ContactsDemo({Key? key}) : super(key: key);

  @override
  State<ContactsDemo> createState() => _ContactsDemoState();
}

class _ContactsDemoState extends State<ContactsDemo> {

  bool _waiting = false;
  List<Contact> contacts = <Contact>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("연락처 테스트"),),
      body: _buildBody(),
        floatingActionButton: Visibility(
          visible: !_waiting,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              _selectContact();
              //getContact();
            },
            child: Icon(Icons.add),
          ),
        )
    );
  }


  Widget _buildBody() {
    if(_waiting) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      child: ListView.builder(
        itemCount: contacts.length,
          itemBuilder: (BuildContext context, int index) {
            String? displayName= contacts[index].displayName;
            String? givenName= contacts[index].givenName;
            String? middleName= contacts[index].middleName;
            String? prefix= contacts[index].prefix;
            String? suffix= contacts[index].suffix;
            String? familyName= contacts[index].familyName;
            String? jobTitle = contacts[index].jobTitle;
            String? company    = contacts[index].company;
            List<Item>? phone  = contacts[index].phones;
            List<Item>? emails = contacts[index].emails;
            List<PostalAddress>? postalAddresses = contacts[index].postalAddresses;
            DateTime? birthday = contacts[index].birthday;
            String title = "";
            if(displayName!=null && displayName.isNotEmpty)
              title = "$displayName(";

            if(givenName!=null && givenName.isNotEmpty)
              title += " givenName:$givenName";
            if(middleName!=null && middleName.isNotEmpty)
              title += " middleName:$middleName";
            if(prefix!=null && prefix.isNotEmpty)
              title += " prefix:$prefix";
            if(suffix!=null && suffix.isNotEmpty)
              title += " suffix:$suffix";
            if(familyName!=null && familyName.isNotEmpty)
              title += " sufffamilyNameix:$familyName";
            title += ")";

            String display = "";
            if(jobTitle!=null && jobTitle.isNotEmpty)
              display += " jobTitle:$jobTitle";
            if(company!=null && company.isNotEmpty)
              display += " company:$company";
            if(phone!=null && phone.isNotEmpty)
              display += " phone:${phone[0].label}->${phone[0].value}";
            if(emails!=null && emails.isNotEmpty)
              display += " emails:${emails[0].label}->${emails[0].value}";
            return ListTile(
              title:Text(title),
              subtitle: Text(display),
            );
          }),
    );
  }

  Future <void> _traceContact() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _getContact();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future <void> _selectContact() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _openContact();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('contacts data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future <void> _getContact() async {
    setState(() {
      _waiting = true;
    });

    await ContactsService.getContacts(withThumbnails: true).then((value) {
      setState(() {
        contacts = value;
        _waiting = false;
      });
    });

  }

  Future <void> _openContact() async {
    setState(() {
      _waiting = true;
    });

    await ContactsService.openDeviceContactPicker().then((value) {
      setState(() {
        if(value != null) {
          contacts.add(value);
        }
        _waiting = false;
      });
    });

  }
}
