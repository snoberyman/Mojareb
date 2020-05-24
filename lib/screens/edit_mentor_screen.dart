import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../providers/mentor.dart';
import '../providers/mentors.dart';
import '../providers/slot.dart';
import '../providers/slots.dart';

class EditMentorscreen extends StatefulWidget {
  static const routeName = '/edit-Mentor';

  @override
  _EditMentorscreenState createState() => _EditMentorscreenState();
}

class _EditMentorscreenState extends State<EditMentorscreen> {
  final _durationFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedMentor = Mentor(
    id: null,
    title: '',
    name: '',
    tag: '',
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'name': '',
    'description': '',
    'tag': '',
    'imageUrl': '',
  };

  int noOfTimeSlots = 1;
  int noOfTimeSlotss = 0;
  bool firstReg = false;
  var mentorIdd;

  List<bool> tcVisibility = new List<bool>();
  List<String> dateTimeValue = new List<String>();

  List<Slot> _editedSlots = [
    Slot(
      id: null,
      time: '',
      duration: '',
      status: '',
      mentorId: '',
    )
  ];
  List<Slot> _initSlotsValues = new List<Slot>();

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImgUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Slots>(context, listen: true).fetchAndSetSlots(true);
      final mentorId = ModalRoute.of(context).settings.arguments as String;
      if (mentorId != null) {
        mentorIdd = mentorId;
        firstReg = true;
        _editedMentor =
            Provider.of<Mentors>(context, listen: false).findById(mentorId);
        _initValues = {
          'title': _editedMentor.title,
          'name': _editedMentor.name,
          'description': _editedMentor.description,
          'tag': _editedMentor.tag,
          //'imageUrl': _editedMentor.imageUrl,
          'imageUrl': '',
        };
        int noOfTimeSlotss = Provider.of<Slots>(context, listen: true)
            .noOfSlotsByMentorId(mentorId);

        if (noOfTimeSlotss != 0) {
          noOfTimeSlots = noOfTimeSlotss;
          _editedSlots = Provider.of<Slots>(context, listen: true)
              .findByMentorId(mentorId);

          // tcVisibility = List<bool>.generate(noOfTimeSlots, (_) => (true));
          var formatter = new DateFormat('yyyy-MMMM-dd,  HH:mm');
          // String formatted = DateTime.parse(formattedString);

          for (int i = 0; i < noOfTimeSlots; i++) {
            //  print();
            _initSlotsValues.add(Slot(
              id: _editedSlots[i].id,
              time: _editedSlots[i].time,
              duration: _editedSlots[i].duration,
              status: _editedSlots[i].status,
              mentorId: _editedSlots[i].mentorId,
            ));
            tcVisibility.add(true);
            dateTimeValue.add(formatter
                .format(DateTime.parse(_editedSlots[i].time))
                .toString());
          }
        } else {
          _initSlotsValues.add(Slot(
            id: null,
            time: '',
            duration: '',
            status: '',
            mentorId: mentorId,
          ));

          _editedSlots.add(Slot(
            id: null,
            time: '',
            duration: '',
            status: '',
            mentorId: mentorId,
          ));

          tcVisibility.add(false);
          dateTimeValue.add('');
          dateTimeValue.add('');
        }

        _imageUrlController.text = _editedMentor.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImgUrl);
    _durationFocusNode.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImgUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedMentor.id != null) {
      await Provider.of<Mentors>(context, listen: false)
          .updateMentor(_editedMentor.id, _editedMentor);

      for (int i = 0; i < noOfTimeSlots; i++) {
        if (_editedSlots[i].id != null) {
          await Provider.of<Slots>(context, listen: false)
              .updateSlot(_editedSlots[i].id, _editedSlots[i]);
        } else {
          await Provider.of<Slots>(context, listen: false)
              .addSlot(_editedSlots[i]);
        }
      }
      await Provider.of<Slots>(context, listen: true).fetchAndSetSlots(true);
    } else {
      try {
        await Provider.of<Mentors>(context, listen: false)
            .addMentor(_editedMentor);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occuerrd'),
            content: Text('something went wrong'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      } // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Mentor'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_nameFocusNode);
                      },
                      onSaved: (value) {
                        _editedMentor = Mentor(
                            title: _editedMentor.title,
                            name: value,
                            tag: _editedMentor.tag,
                            description: _editedMentor.description,
                            imageUrl: _editedMentor.imageUrl,
                            id: _editedMentor.id,
                            isFavorite: _editedMentor.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                    ),

                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {},
                      onSaved: (value) {
                        _editedMentor = Mentor(
                            title: value,
                            name: _editedMentor.name,
                            tag: _editedMentor.tag,
                            description: _editedMentor.description,
                            imageUrl: _editedMentor.imageUrl,
                            id: _editedMentor.id,
                            isFavorite: _editedMentor.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['tag'],
                      decoration: InputDecoration(
                        labelText: 'Tags',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_nameFocusNode);
                      },
                      onSaved: (value) {
                        _editedMentor = Mentor(
                            title: _editedMentor.title,
                            name: _editedMentor.name,
                            tag: value,
                            description: _editedMentor.description,
                            imageUrl: _editedMentor.imageUrl,
                            id: _editedMentor.id,
                            isFavorite: _editedMentor.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                    ),
                    // TextFormField(
                    //   initialValue: _initValues['tag'],
                    //   decoration: InputDecoration(labelText: 'tag'),
                    //   textInputAction: TextInputAction.next,
                    //   // keyboardType: TextInputType.number,
                    //   focusNode: _priceFocusNode,
                    //   onFieldSubmitted: (_) {
                    //     FocusScope.of(context)
                    //         .requestFocus(_descriptionFocusNode);
                    //   },
                    //   onSaved: (value) {
                    //     _editedMentor = Mentor(
                    //         title: _editedMentor.title,
                    //         name: _editedMentor.name,
                    //         tag: value,
                    //         description: _editedMentor.description,
                    //         imageUrl: _editedMentor.imageUrl,
                    //         id: _editedMentor.id,
                    //         isFavorite: _editedMentor.isFavorite);
                    //   },
                    //   validator: (value) {
                    //     if (value.isEmpty) {
                    //       return 'Please enter a tag';
                    //     }
                    //     if (double.tryParse(value) == null) {
                    //       return 'Please enter a valid tag';
                    //     }
                    //     // if (double.parse(value) <= 0) {
                    //     //   return 'Please enter a number greater than zero';
                    //     // }
                    //     return null;
                    //   },
                    // ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedMentor = Mentor(
                            title: _editedMentor.title,
                            name: _editedMentor.name,
                            tag: _editedMentor.tag,
                            description: value,
                            imageUrl: _editedMentor.imageUrl,
                            id: _editedMentor.id,
                            isFavorite: _editedMentor.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters lenght';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedMentor = Mentor(
                                  title: _editedMentor.title,
                                  name: _editedMentor.name,
                                  tag: _editedMentor.tag,
                                  description: _editedMentor.description,
                                  imageUrl: value,
                                  id: _editedMentor.id,
                                  isFavorite: _editedMentor.isFavorite);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    firstReg == true
                        ? Text(
                            'Time Slots',
                            style: TextStyle(fontSize: 16),
                          )
                        : Text(''),
                    firstReg == true
                        ? RaisedButton(
                            onPressed: () {
                              setState(() {
                                noOfTimeSlots++;
                                tcVisibility.add(false);
                                dateTimeValue.add('');

                                _initSlotsValues.add(
                                  Slot(
                                    id: null,
                                    time: '',
                                    duration: '',
                                    status: '',
                                    mentorId: mentorIdd,
                                  ),
                                );
                                _editedSlots.add(
                                  Slot(
                                    id: null,
                                    time: '',
                                    duration: '',
                                    status: '',
                                    mentorId: mentorIdd,
                                  ),
                                );
                                print(noOfTimeSlots);
                              });
                            },
                            child: Text(
                              'Add new slot',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 14),
                            ))
                        : Container(),
                    firstReg == true
                        ? Container(
                            height: 250,
                            child: Scrollbar(
                              child: GridView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(10.0),
                                itemCount: noOfTimeSlots,
                                itemBuilder: (ctx, i) => Container(
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Slot' + (i + 1).toString() + ' ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            padding: EdgeInsets.all(0),
                                            onPressed: () async {
                                              try {
                                                if (_editedSlots[i].id !=
                                                    null) {
                                                  await Provider.of<Slots>(
                                                          context,
                                                          listen: false)
                                                      .deleteSlot(
                                                          _editedSlots[i].id);
                                                }
                                                setState(() {
                                                  tcVisibility.removeAt(i);
                                                  _editedSlots.removeAt(i);
                                                  _initSlotsValues.removeAt(i);
                                                  dateTimeValue.removeAt(i);
                                                  noOfTimeSlots--;
                                                  print(noOfTimeSlots);
                                                });
                                              } catch (error) {
                                                AlertDialog(
                                                  content: Text(
                                                    'Deleting failed',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              }
                                            },
                                            color: Theme.of(context).errorColor,
                                          )
                                        ],
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          DatePicker.showDateTimePicker(context,
                                              showTitleActions: true,
                                              onChanged: (date) {
                                            print('change $date in time zone ' +
                                                date.timeZoneOffset.inHours
                                                    .toString());
                                          }, onConfirm: (date) {
                                            print('confirm $date');
                                            setState(() {
                                              tcVisibility[i] = true;
                                              _editedSlots[i] = Slot(
                                                id: _editedSlots[i].id,
                                                mentorId: mentorIdd,
                                                time: date.toString(),
                                                duration:
                                                    _editedSlots[i].duration,
                                                status: 'active',
                                              );
                                              var formatter = new DateFormat(
                                                  'yyyy-MMMM-dd,  HH:mm');
                                              String formatted =
                                                  formatter.format(date);
                                              dateTimeValue[i] = formatted;
                                            });
                                          }, currentTime: DateTime.now(), );
                                        },
                                        child: tcVisibility[i] == false
                                            ? Text(
                                                'Choose Date and Time',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 14),
                                              )
                                            : Text(
                                                dateTimeValue[i],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 16),
                                              ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Session duration (in minutes)'),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: 50,
                                        height: 40,
                                        child: TextFormField(
                                          // focusNode: _durationFocusNode,
                                          initialValue:
                                              _initSlotsValues[i].duration,
                                          inputFormatters: [
                                            new LengthLimitingTextInputFormatter(
                                                2),
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          showCursor: false,
                                          enableInteractiveSelection: false,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          keyboardAppearance: Brightness.light,
                                          onSaved: (value) {
                                            _editedSlots[i] = Slot(
                                              id: _editedSlots[i].id,
                                              mentorId: mentorIdd,
                                              time: _editedSlots[i].time,
                                              duration: value,
                                              status: 'active',
                                            );
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please enter a duration';
                                            }
                                            // if (_editedSlots[i].duration ==
                                            //     '') {
                                            //   return 'Please choose date and time';
                                            // }

                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(
                                        thickness: 1.5,
                                      )
                                    ],
                                  ),
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.4 / 1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 5,
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    // ListView(
                    //   scrollDirection: Axis.vertical,
                    //   shrinkWrap: true,
                    //   padding: const EdgeInsets.all(8),
                    //   children: [
                    //     ..._getListings(),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
