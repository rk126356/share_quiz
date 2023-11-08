import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:share_quiz/Models/user_model.dart';
import 'package:share_quiz/common/colors.dart';
import 'package:share_quiz/navigation.dart';
import 'package:share_quiz/providers/user_provider.dart';
import 'package:share_quiz/screens/profile/profile_screen.dart';
import 'package:share_quiz/widgets/loading_widget.dart';

class CreateProfileScreen extends StatefulWidget {
  final bool? isEdit;
  const CreateProfileScreen({Key? key, bool? this.isEdit}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TextEditingController dobController = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController gender = TextEditingController();
  final TextEditingController controller = TextEditingController();
  String userImage =
      'https://as1.ftcdn.net/v2/jpg/02/59/39/46/1000_F_259394679_GGA8JJAEkukYJL9XXFH2JoC3nMguBPNH.jpg';
  XFile? pickedImage;

  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  bool? _isLoading = false;

  Future<void> fetchUser() async {
    _isLoading = true;
    var data = Provider.of<UserProvider>(context, listen: false);
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(data.userData.uid);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      if (kDebugMode) {
        print('User found');
      }
      final userData = userDocSnapshot.data();
      try {
        setState(() {
          email.text = userData!['email'];
          username.text = userData['username'] ?? '';
          fullName.text = userData['displayName'] ?? '';
          bio.text = userData['bio'] ?? '';
          phoneNumber.text = userData['phoneNumber'] ?? '';
          dobController.text = userData['dob'] ?? '';
          gender.text = userData['gender'] ?? '';
          userImage = userData['avatarUrl'] ?? '';
        });

        data.setUserData(UserModel(
          name: userData?['displayName'],
          email: userData!['email'],
          username: userData['username'],
          bio: userData['bio'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          dob: userData['dob'] ?? '',
          gender: userData['gender'] ?? '',
        ));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      if (kDebugMode) {
        print('User not found');
      }
    }
    _isLoading = false;
  }

  Future<void> saveUserData(context) async {
    try {
      // Show a loading indicator.
      setState(() {
        _isLoading = true;
      });

      final firestore = FirebaseFirestore.instance;
      var data = Provider.of<UserProvider>(context, listen: false);
      final userDoc = firestore.collection('users').doc(data.userData.uid);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        if (kDebugMode) {
          print('User found');
        }

        if (data.userData.username != username.text) {
          // Check if the new username is already taken.
          final userCollection = await firestore
              .collection('users')
              .where('username', isEqualTo: username.text)
              .get();

          if (userCollection.docs.isNotEmpty) {
            // Show an error dialog if the username is taken.
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Username already taken'),
                  content: Text('${username.text} is already taken'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            String? avatarUrl = pickedImage != null
                ? await uploadImageToStorage(pickedImage)
                : userImage;

            // Update user data.
            await userDoc.update({
              'username': username.text,
              'displayName': fullName.text,
              'bio': bio.text,
              'phoneNumber': phoneNumber.text,
              'dob': dobController.text,
              'gender': gender.text,
              'avatarUrl': avatarUrl,
              'searchFields': username.text.toLowerCase(),
            });

            // Update the user data in the Provider.
            Provider.of<UserProvider>(context, listen: false)
                .setUserData(UserModel(
              username: username.text,
              name: fullName.text,
              bio: bio.text,
              phoneNumber: phoneNumber.text,
              dob: dobController.text,
              gender: gender.text,
              avatarUrl: avatarUrl,
            ));

            // Navigate based on whether it's an edit or a new user.
            if (widget.isEdit != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NavigationScreen()),
              );
            }
          }
        } else {
          String? avatarUrl = pickedImage != null
              ? await uploadImageToStorage(pickedImage)
              : userImage;

          // Update user data.
          await userDoc.update({
            'displayName': fullName.text,
            'bio': bio.text,
            'phoneNumber': phoneNumber.text,
            'dob': dobController.text,
            'gender': gender.text,
            'avatarUrl': avatarUrl,
          });

          // Update the user data in the Provider.
          Provider.of<UserProvider>(context, listen: false)
              .setUserData(UserModel(
            name: fullName.text,
            bio: bio.text,
            phoneNumber: phoneNumber.text,
            dob: dobController.text,
            gender: gender.text,
            avatarUrl: avatarUrl,
          ));

          // Navigate based on whether it's an edit or a new user.
          if (widget.isEdit != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigationScreen()),
            );
          }
        }
        data.setIsBioAdded(true);
      } else {
        // Handle the case when the user document does not exist.
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } catch (e) {
      // Handle any errors that occur during the process.
      if (kDebugMode) {
        print(e);
      }
    } finally {
      // Hide the loading indicator.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
  }

  pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        pickedImage = pickedFile!;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error picking an image: $e");
      }
    }
  }

  Future<String?> uploadImageToStorage(XFile? imageFile) async {
    if (imageFile == null) {
      return null;
    }

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");
    try {
      await storageReference.putFile(File(imageFile.path));
      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading image to storage: $e");
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading!) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit != null ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(
            color: Colors.white, // Title text color
            fontSize: 24.0, // Title text size
          ),
        ),
        backgroundColor: AppColors.primaryColor, // App bar background color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ignore: prefer_const_constructors
              SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Container(
                    width: 135,
                    height: 135,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, // Vibrant pink
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 5.0,
                      ),
                    ),
                    child: ClipOval(
                        child: pickedImage == null
                            ? Image.network(
                                userImage,
                                width: 125,
                                height: 125,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                pickedImage!.path,
                                width: 125,
                                height: 125,
                                fit: BoxFit.cover,
                              )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black, // Vibrant teal
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        pickImage();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          CupertinoIcons.number,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      validator: (value) {
                        if (value!.length > 16) {
                          return 'Username is too long (max 16 characters)';
                        }
                        return null; // No error
                      },
                    ),
                    TextFormField(
                      controller: fullName,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      validator: (value) {
                        if (value!.length > 20) {
                          return 'Full Name is too long (max 20 characters)';
                        }
                        return null; // No error
                      },
                    ),
                    TextFormField(
                      controller: bio,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(
                          CupertinoIcons.info,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Bio is required';
                        }
                        if (value!.length > 80) {
                          return 'Bio is too long (max 80 characters)';
                        }
                        return null; // No error
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dobController,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(CupertinoIcons.calendar_today,
                                color: AppColors.primaryColor), // Icon color
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Date of Birth is required';
                            }
                            DateTime dob = DateTime.parse(value);
                            DateTime currentDate = DateTime.now();
                            Duration difference = currentDate.difference(dob);
                            int age = (difference.inDays / 365).floor();

                            if (age < 14) {
                              return 'You must be at least 14 years old to register';
                            }

                            return null; // No error
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      items: <String>['Male', 'Female', 'Other']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ), // Text color
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Genderis required';
                        }
                        return null; // No error
                      },
                      onChanged: (String? newValue) {
                        gender.text = newValue!;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(CupertinoIcons.person_fill,
                            color: AppColors.primaryColor), // Icon color
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          if (kDebugMode) {
                            print(number.phoneNumber);
                          }
                        },
                        onInputValidated: (bool value) {
                          if (kDebugMode) {
                            print(value);
                          }
                        },
                        validator: (value) {
                          if (value!.length < 5) {
                            return 'Phone number is required';
                          }

                          return null; // No error
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                        initialValue: number,
                        textFieldController: phoneNumber,
                        formatInput: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputBorder: const OutlineInputBorder(),
                        onSaved: (PhoneNumber number) {
                          if (kDebugMode) {
                            print('On Saved: $number');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveUserData(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .primaryColor, // Change to your desired color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(150, 50),
                      ),
                      child: const Text('Save Profile'),
                    ),
                  ],
                ),
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     saveUserData(context);
              //   },
              //   child: const Text('Save'),
              // ),

              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ))!;
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }
}
