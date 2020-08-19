import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:talawa/services/Queries.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/GraphAPI.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:talawa/utils/validator.dart';
import 'package:talawa/views/pages/nav_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CreateOrganization extends StatefulWidget {
  @override
  _CreateOrganizationState createState() => _CreateOrganizationState();
}

class _CreateOrganizationState extends State<CreateOrganization> {
  final orgNameController = TextEditingController();
  final orgDescController = TextEditingController();
  final orgMemberDescController = TextEditingController();
  Queries _queries = Queries();
  bool _progressBarState = false;
  bool _validate = false;
  final _formKey = GlobalKey<FormState>();
  int radioValue = -1;
  int radioValue1 = -1;
  bool isPublic = true;
  bool isVisible = true;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  GraphAPI _graphAPI = GraphAPI();
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fToast = FToast(context);
  }

  void toggleProgressBarState() {
    _progressBarState = !_progressBarState;
  }

  createOrg() async {
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client.mutate(MutationOptions(
        documentNode: gql(_queries.createOrg(
      orgNameController.text,
      orgDescController.text,
      orgMemberDescController.text,
      isPublic,
      isVisible,
    ))));

    String e =
        "Access Token has expired. Please refresh session.: Undefined location";
    if (result.hasException && result.exception.toString().substring(16) == e) {
      _graphAPI.getNewToken();
      return createOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != e) {
      print(result.exception);
      setState(() {
        _progressBarState = false;
      });
      _exceptionToast(result.exception.toString());
    } else if (!result.hasException && !result.loading) {
      setState(() {
        _progressBarState = true;
      });
      _successToast("Sucess!");
      print(result.data);
      //Navigate user to join organization screen
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => new HomePage()));
    }
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organization'),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 10.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              addImage(),
              Form(
                key: _formKey,
                autovalidate: _validate,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        validator: (value) => Validator.validateOrgName(value),
                        textAlign: TextAlign.left,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: UIData.secondaryColor),
                              borderRadius: BorderRadius.circular(20.0)),
                          prefixIcon: Icon(
                            Icons.group,
                            color: UIData.secondaryColor,
                          ),
                          labelText: "Organization Name",
                          labelStyle: TextStyle(color: Colors.black),
                          alignLabelWithHint: true,
                          hintText: 'My Organization',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: orgNameController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => Validator.validateOrgDesc(value),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: UIData.secondaryColor),
                              borderRadius: BorderRadius.circular(20.0)),
                          prefixIcon:
                              Icon(Icons.note, color: UIData.secondaryColor),
                          labelText: "Organization Description",
                          labelStyle: TextStyle(color: Colors.black),
                          alignLabelWithHint: true,
                          hintText: 'My Description',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: orgDescController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            Validator.validateOrgAttendeesDesc(value),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black),
                        decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                              borderSide:
                                  new BorderSide(color: UIData.secondaryColor)),
                          prefixIcon:
                              Icon(Icons.note, color: UIData.secondaryColor),
                          labelText: "Member Description",
                          labelStyle: TextStyle(color: Colors.black),
                          alignLabelWithHint: true,
                          hintText: 'Member Description',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: orgMemberDescController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Do you want your organization to be public?',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      RadioListTile(
                        groupValue: radioValue,
                        title: Text('Yes'),
                        value: 0,
                        activeColor: UIData.secondaryColor,
                        onChanged: (val) {
                          setState(() {
                            radioValue = val;
                            if (radioValue == 0) {
                              return isPublic;
                            }
                          });
                        },
                      ),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue,
                        title: Text('No'),
                        value: 1,
                        onChanged: (val) {
                          setState(() {
                            radioValue = val;
                            if (radioValue == 1) {
                              isPublic = false;
                              return isPublic;
                            }
                          });
                        },
                      ),
                      Text(
                          'Do you want others to be able to find your organization from the search page?',
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue1,
                        title: Text('Yes'),
                        value: 0,
                        onChanged: (val) {
                          setState(() {
                            radioValue1 = val;
                            if (radioValue1 == 0) {
                              return isVisible;
                            }
                          });
                        },
                      ),
                      RadioListTile(
                        activeColor: UIData.secondaryColor,
                        groupValue: radioValue1,
                        title: Text('No'),
                        value: 1,
                        onChanged: (val) {
                          setState(() {
                            radioValue1 = val;
                            if (radioValue1 == 1) {
                              isVisible = false;
                              return isVisible;
                            }
                          });
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 30.0),
                        width: double.infinity,
                        child: RaisedButton(
                          padding: EdgeInsets.all(16.0),
                          shape: StadiumBorder(),
                          child: _progressBarState
                              ? const CircularProgressIndicator()
                              : Text(
                                  "CREATE ORGANIZATION",
                                  style: TextStyle(color: Colors.white),
                                ),
                          color: UIData.secondaryColor,
                          onPressed: () async {
                            if (_formKey.currentState.validate() &&
                                radioValue >= 0 &&
                                radioValue1 >= 0) {
                              _formKey.currentState.save();
                              createOrg();
                              setState(() {
                                toggleProgressBarState();
                              });
                            } else if (radioValue < 0 || radioValue1 < 0) {
                              _exceptionToast("A choice must be selected");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addImage() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32,
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 1),
    );
  }

  _exceptionToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );
  }
}
