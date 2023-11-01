import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      _isLoading = true;

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
            // Update user data.
            await userDoc.update({
              'username': username.text,
              'displayName': fullName.text,
              'bio': bio.text,
              'phoneNumber': phoneNumber.text,
              'dob': dobController.text,
              'gender': gender.text,
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
          // Update user data.
          await userDoc.update({
            'displayName': fullName.text,
            'bio': bio.text,
            'phoneNumber': phoneNumber.text,
            'dob': dobController.text,
            'gender': gender.text,
          });

          // Update the user data in the Provider.
          Provider.of<UserProvider>(context, listen: false)
              .setUserData(UserModel(
            name: fullName.text,
            bio: bio.text,
            phoneNumber: phoneNumber.text,
            dob: dobController.text,
            gender: gender.text,
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
      _isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading!) {
      return const Scaffold(body: LoadingWidget());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Profile',
          style: TextStyle(
            color: Colors.white, // Title text color
            fontSize: 24.0, // Title text size
          ),
        ),
        backgroundColor: AppColors.primaryColor, // App bar background color
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.white, // Checkmark icon color
              size: 30.0, // Checkmark icon size
            ),
            onPressed: () {
              // Handle profile creation logic here
            },
          ),
        ],
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
                    child: const Icon(
                      Icons.camera_alt,
                      size: 60.0,
                      color: Colors.white,
                    ),
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
                        // Implement image editing logic here
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
                    TextFormField(
                      controller: phoneNumber,
                      decoration: const InputDecoration(
                        hintText: 'Include country code ex: +91',
                        labelText: 'Phone Number',
                        prefixIcon: Icon(CupertinoIcons.phone,
                            color: AppColors.primaryColor),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Phone number is required';
                        }

                        if (!value.startsWith('+')) {
                          return 'Please include country code ex: "+91"';
                        }

                        // You can add additional validation here if needed.

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
